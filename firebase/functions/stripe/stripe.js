const functions = require("firebase-functions");
const admin = require("firebase-admin");

function getStripe() {
  return require("stripe")(functions.config().stripe?.secret);
}

function getDb() {
  return admin.firestore();
}

/**
 * Create a Stripe Connect Express account for a creator.
 * Called when a creator clicks "Connect Stripe" in the app.
 */
async function createStripeConnectAccount(uid, email) {
  // 1. Check if account already exists
  const db = getDb();
  const stripe = getStripe();
  const settingsSnap = await db.collection("creator_settings").doc(uid).get();
  const settings = settingsSnap.data();
  if (settings?.stripe_account_id) {
    // Account exists — return a new account link for onboarding
    return createAccountLink(settings.stripe_account_id);
  }
  
  // 2. Create Express account
  const account = await stripe.accounts.create({
    type: "express",
    email: email,
    business_type: "individual",
    capabilities: {
      transfers: { requested: true },
    },
    metadata: { firebase_uid: uid },
  });
  
  // 3. Save account ID to Firestore
  await db.collection("creator_settings").doc(uid).set({
    stripe_account_id: account.id,
    stripe_onboarding_complete: false,
  }, { merge: true });
  
  // 4. Return onboarding link
  return createAccountLink(account.id);
}

/**
 * Create a Stripe Account Link for onboarding.
 */
async function createAccountLink(accountId) {
  const stripe = getStripe();
  const accountLink = await stripe.accountLinks.create({
    account: accountId,
    refresh_url: "https://perezfans.app/stripe/refresh",
    return_url: "https://perezfans.app/stripe/complete",
    type: "account_onboarding",
  });
  return accountLink.url;
}

/**
 * Create a Checkout Session for subscribing to a creator.
 */
async function createSubscriptionCheckout(uid, creatorId, priceInCents) {
  const db = getDb();
  const stripe = getStripe();
  const creatorSnap = await db.collection("creator_settings").doc(creatorId).get();
  const creatorSettings = creatorSnap.data();
  if (!creatorSettings?.stripe_account_id) {
    throw new functions.https.HttpsError("failed-precondition", 
      "Creator has not set up Stripe yet.");
  }
  if (!creatorSettings?.is_active) {
    throw new functions.https.HttpsError("failed-precondition",
      "Creator subscriptions are not active.");
  }
  
  // Create or retrieve the price
  // For simplicity, create a one-time price for the product
  const product = await stripe.products.create({
    name: `Subscription to ${creatorId}`,
    metadata: { creator_id: creatorId },
  });
  
  const stripePrice = await stripe.prices.create({
    product: product.id,
    unit_amount: priceInCents,
    currency: "usd",
    recurring: { interval: "month" },
    metadata: { creator_id: creatorId },
  });
  
  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    line_items: [{ price: stripePrice.id, quantity: 1 }],
    payment_intent_data: {
      application_fee_amount: Math.round(priceInCents * 0.1), // 10% platform fee
    },
    subscription_data: {
      metadata: {
        subscriber_uid: uid,
        creator_uid: creatorId,
      },
    },
    metadata: {
      subscriber_uid: uid,
      creator_uid: creatorId,
    },
    success_url: "https://perezfans.app/subscription/success",
    cancel_url: "https://perezfans.app/subscription/cancel",
    customer_email: null, // Will be collected during checkout
  });
  
  return session.url;
}

/**
 * Create a PaymentIntent for tipping.
 */
async function createTipPaymentIntent(uid, creatorId, amountInCents, currency) {
  const db = getDb();
  const stripe = getStripe();
  const creatorSnap = await db.collection("creator_settings").doc(creatorId).get();
  const creatorSettings = creatorSnap.data();
  if (!creatorSettings?.stripe_account_id) {
    throw new functions.https.HttpsError("failed-precondition",
      "Creator has not set up Stripe yet.");
  }
  
  const platformFee = Math.round(amountInCents * 0.1); // 10% platform fee
  
  const paymentIntent = await stripe.paymentIntents.create({
    amount: amountInCents,
    currency: currency || "usd",
    application_fee_amount: platformFee,
    transfer_data: {
      destination: creatorSettings.stripe_account_id,
    },
    metadata: {
      type: "tip",
      sender_uid: uid,
      creator_uid: creatorId,
    },
  });
  
  return paymentIntent.client_secret;
}

/**
 * Create a Checkout Session for a one-time tip payment.
 * Returns a URL the user opens in their browser.
 */
async function createTipCheckout(uid, creatorId, amountInCents, currency) {
  const db = getDb();
  const stripe = getStripe();
  const creatorSnap = await db.collection("creator_settings").doc(creatorId).get();
  const creatorSettings = creatorSnap.data();
  if (!creatorSettings?.stripe_account_id) {
    throw new functions.https.HttpsError("failed-precondition",
      "Creator has not set up Stripe yet.");
  }

  const platformFee = Math.round(amountInCents * 0.1);

  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    line_items: [{
      price_data: {
        currency: currency || "usd",
        product_data: {
          name: "Tip",
          description: `Tip for creator ${creatorId}`,
        },
        unit_amount: amountInCents,
      },
      quantity: 1,
    }],
    payment_intent_data: {
      application_fee_amount: platformFee,
      transfer_data: {
        destination: creatorSettings.stripe_account_id,
      },
      metadata: {
        type: "tip",
        sender_uid: uid,
        creator_uid: creatorId,
      },
    },
    metadata: {
      type: "tip",
      sender_uid: uid,
      creator_uid: creatorId,
    },
    success_url: "https://perezfans.app/tip/success",
    cancel_url: "https://perezfans.app/tip/cancel",
  });

  return session.url;
}

/**
 * Check Stripe account onboarding status.
 */
async function checkStripeAccountStatus(accountId) {
  const stripe = getStripe();
  const account = await stripe.accounts.retrieve(accountId);
  return {
    onBoarded: account.charges_enabled && account.payouts_enabled,
    details_submitted: account.details_submitted,
    charges_enabled: account.charges_enabled,
    payouts_enabled: account.payouts_enabled,
  };
}

/**
 * Handle Stripe webhook events.
 */
async function handleWebhookEvent(event) {
  const db = getDb();
  switch (event.type) {
    case "account.updated": {
      const account = event.data.object;
      const uid = account.metadata?.firebase_uid;
      if (uid) {
        await db.collection("creator_settings").doc(uid).update({
          stripe_onboarding_complete: account.charges_enabled && account.payouts_enabled,
        });
      }
      break;
    }
    
    case "checkout.session.completed": {
      const session = event.data.object;
      const subscriberUid = session.metadata?.subscriber_uid;
      const creatorUid = session.metadata?.creator_uid;
      const subscriptionId = session.subscription;
      
      if (subscriberUid && creatorUid && subscriptionId) {
        // Create subscription record in Firestore
        const subRef = db.collection("subscriptions").doc();
        await subRef.set({
          subscriber: db.collection("users").doc(subscriberUid),
          creator: db.collection("users").doc(creatorUid),
          start_date: admin.firestore.FieldValue.serverTimestamp(),
          status: "active",
          tier: "monthly",
          stripe_subscription_id: subscriptionId,
          auto_renew: true,
          created_time: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        // Increment subscriber count
        await db.collection("creator_settings").doc(creatorUid).update({
          subscriber_count: admin.firestore.FieldValue.increment(1),
        });
        
        // Add to user's subscriptions list
        await db.collection("users").doc(subscriberUid).update({
          subscribed_to_ids: admin.firestore.FieldValue.arrayUnion([creatorUid]),
        });
      }
      break;
    }
    
    case "payment_intent.succeeded": {
      const pi = event.data.object;
      if (pi.metadata?.type === "tip") {
        // Record the tip
        const senderUid = pi.metadata.sender_uid;
        const creatorUid = pi.metadata.creator_uid;
        if (senderUid && creatorUid) {
          await db.collection("tips").add({
            sender: db.collection("users").doc(senderUid),
            creator: db.collection("users").doc(creatorUid),
            amount: pi.amount / 100, // Store in dollars
            currency: pi.currency?.toUpperCase() || "USD",
            created_time: admin.firestore.FieldValue.serverTimestamp(),
            stripe_payment_intent_id: pi.id,
            status: "completed",
          });
        }
      }
      break;
    }
    
    case "customer.subscription.deleted":
    case "customer.subscription.updated": {
      // Handle subscription cancellations / updates
      const subscription = event.data.object;
      const subId = subscription.id;
      
      const subSnapshot = await db.collection("subscriptions")
        .where("stripe_subscription_id", "==", subId)
        .limit(1)
        .get();
      
      if (!subSnapshot.empty) {
        const doc = subSnapshot.docs[0];
        const status = subscription.status === "active" ? "active" 
          : subscription.status === "canceled" ? "cancelled" 
          : subscription.status === "past_due" ? "past_due" 
          : "expired";
        
        await doc.ref.update({ status, end_date: admin.firestore.FieldValue.serverTimestamp() });
        
        if (status !== "active") {
          const data = doc.data();
          // Don't decrement on cancel — only when truly ended
        }
      }
      break;
    }

    case "checkout.session.completed": {
      const session = event.data.object;
      if (session.metadata?.type === "coin_purchase") {
        const userId = session.metadata.userId;
        const coins = parseInt(session.metadata.coins, 10);

        await db.collection("virtual_coins").doc(userId).set(
          {
            user: db.collection("users").doc(userId),
            balance: admin.firestore.FieldValue.increment(coins),
            last_updated: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );

        // Update transaction status
        const txSnap = await db.collection("coin_transactions")
          .where("stripe_session_id", "==", session.id)
          .limit(1)
          .get();
        if (!txSnap.empty) {
          await txSnap.docs[0].ref.update({ status: "completed" });
        }

        // Increment promo code usage
        const promoId = session.metadata.promoId;
        if (promoId) {
          await db.collection("promo_codes").doc(promoId).update({
            current_uses: admin.firestore.FieldValue.increment(1),
          });
        }
      }
      break;
    }
  }
}

async function createCoinPurchaseCheckout(uid, coins, priceInCents, promoCode) {
  const stripe = getStripe();
  const db = getDb();

  let finalPrice = priceInCents;
  let promoId = null;

  if (promoCode) {
    const snap = await db.collection("promo_codes")
      .where("code", "==", promoCode.toUpperCase())
      .limit(1)
      .get();

    if (!snap.empty) {
      const promo = snap.docs[0];
      const data = promo.data();
      if (data.is_active && (!data.expires_at || data.expires_at.toDate() > new Date()) &&
          (!data.max_uses || data.current_uses < data.max_uses)) {
        const discount = data.discount_percent || 0;
        finalPrice = Math.round(priceInCents * (100 - discount) / 100);
        promoId = promo.id;
      }
    }
  }

  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    line_items: [
      {
        price_data: {
          currency: "usd",
          product_data: {
            name: `${coins} Coins${promoCode ? " (Discounted)" : ""}`,
            description: `Buy ${coins} virtual coins`,
          },
          unit_amount: finalPrice,
        },
        quantity: 1,
      },
    ],
    metadata: {
      type: "coin_purchase",
      userId: uid,
      coins: coins.toString(),
      promoId: promoId || "",
    },
    success_url: "https://perezfans.web.app/gift-shop?success=true",
    cancel_url: "https://perezfans.web.app/gift-shop?canceled=true",
  });

  // Record pending transaction
  await db.collection("coin_transactions").add({
    user: db.collection("users").doc(uid),
    amount: coins,
    type: "purchase",
    status: "pending",
    stripe_session_id: session.id,
    created_time: admin.firestore.FieldValue.serverTimestamp(),
  });

  return session.url;
}

module.exports = {
  createStripeConnectAccount,
  createAccountLink,
  createSubscriptionCheckout,
  createTipPaymentIntent,
  createTipCheckout,
  checkStripeAccountStatus,
  handleWebhookEvent,
  createCoinPurchaseCheckout,
};
