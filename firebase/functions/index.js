const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripeModule = require("./stripe/stripe");
const notifications = require("./notifications");

admin.initializeApp();

// ============================================================
// Auth triggers
// ============================================================

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const firestore = admin.firestore();
  await firestore.collection("users").doc(user.uid).delete();
});

// ============================================================
// Stripe Connect Callable Functions (called from Flutter app)
// ============================================================

/**
 * Creates a Stripe Connect Express account for the caller.
 * Returns an onboarding URL the user opens in their browser.
 */
exports.createStripeConnectAccount = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }
  
  const uid = context.auth.uid;
  const email = context.auth.token.email || data.email;
  
  try {
    const url = await stripeModule.createStripeConnectAccount(uid, email);
    return { url };
  } catch (err) {
    console.error("Stripe Connect account creation failed:", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});

/**
 * Returns a new onboarding link for an existing Stripe account.
 * (e.g., if the user didn't finish onboarding)
 */
exports.createStripeAccountLink = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }
  
  const { accountId } = data;
  if (!accountId) {
    throw new functions.https.HttpsError("invalid-argument", "accountId is required.");
  }
  
  try {
    const url = await stripeModule.createAccountLink(accountId);
    return { url };
  } catch (err) {
    console.error("Stripe account link creation failed:", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});

/**
 * Creates a Stripe Checkout Session for subscribing to a creator.
 * Returns the URL the user opens to complete payment.
 */
exports.createSubscriptionCheckout = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }
  
  const { creatorId, priceInCents } = data;
  if (!creatorId || !priceInCents) {
    throw new functions.https.HttpsError("invalid-argument", "creatorId and priceInCents are required.");
  }
  
  try {
    const url = await stripeModule.createSubscriptionCheckout(
      context.auth.uid, creatorId, priceInCents
    );
    return { url };
  } catch (err) {
    console.error("Subscription checkout creation failed:", err);
    if (err instanceof functions.https.HttpsError) throw err;
    throw new functions.https.HttpsError("internal", err.message);
  }
});

/**
 * Creates a PaymentIntent for tipping a creator.
 * Returns the client_secret the Flutter app uses to confirm payment.
 */
exports.createTipPaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }
  
  const { creatorId, amountInCents, currency } = data;
  if (!creatorId || !amountInCents) {
    throw new functions.https.HttpsError("invalid-argument", "creatorId and amountInCents are required.");
  }
  
  try {
    const clientSecret = await stripeModule.createTipPaymentIntent(
      context.auth.uid, creatorId, amountInCents, currency
    );
    return { clientSecret };
  } catch (err) {
    console.error("Tip PaymentIntent creation failed:", err);
    if (err instanceof functions.https.HttpsError) throw err;
    throw new functions.https.HttpsError("internal", err.message);
  }
});

/**
 * Creates a Stripe Checkout Session for a one-time tip.
 * Returns a URL the user opens in their browser to pay.
 */
exports.createTipCheckout = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }

  const { creatorId, amountInCents, currency } = data;
  if (!creatorId || !amountInCents) {
    throw new functions.https.HttpsError("invalid-argument", "creatorId and amountInCents are required.");
  }

  try {
    const url = await stripeModule.createTipCheckout(
      context.auth.uid, creatorId, amountInCents, currency
    );
    return { url };
  } catch (err) {
    console.error("Tip checkout creation failed:", err);
    if (err instanceof functions.https.HttpsError) throw err;
    throw new functions.https.HttpsError("internal", err.message);
  }
});

/**
 * Checks the onboarding status of a creator's Stripe account.
 */
exports.checkStripeAccountStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }
  
  const { accountId } = data;
  if (!accountId) {
    throw new functions.https.HttpsError("invalid-argument", "accountId is required.");
  }
  
  try {
    const status = await stripeModule.checkStripeAccountStatus(accountId);
    return status;
  } catch (err) {
    console.error("Stripe account status check failed:", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});

/**
 * Webhook endpoint for Stripe events.
 * MUST be configured in Stripe Dashboard to point to:
 * https://PERUSZONE-REGION-PROJECT.cloudfunctions.net/stripeWebhook
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers["stripe-signature"];
  const endpointSecret = functions.config().stripe?.webhook_secret;
  
  if (!endpointSecret) {
    console.error("Stripe webhook secret not configured.");
    res.status(500).send("Webhook secret not configured.");
    return;
  }
  
  let event;
  try {
    const stripe = require("stripe")(functions.config().stripe.secret);
    event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }
  
  try {
    await stripeModule.handleWebhookEvent(event);
    res.status(200).json({ received: true });
  } catch (err) {
    console.error("Webhook handler failed:", err);
    res.status(500).json({ error: err.message });
  }
});

// ============================================================
// Push Notification Triggers
// ============================================================

exports.onCommentCreated = functions.firestore
  .document("comments/{commentId}")
  .onCreate(async (snap, context) => {
    await notifications.onCommentCreated(snap);
  });

exports.onTipCompleted = functions.firestore
  .document("tips/{tipId}")
  .onWrite(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (after && after.status === "completed" && (!before || before.status !== "completed")) {
      await notifications.onTipCompleted(change.after);
    }
  });

exports.onUserFollowed = functions.firestore
  .document("users/{userId}")
  .onWrite(async (change, context) => {
    await notifications.onFollowOrLike(change);
  });

exports.createCoinPurchaseCheckout = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }

  const { coins, priceInCents, promoCode } = data;
  if (!coins || !priceInCents) {
    throw new functions.https.HttpsError("invalid-argument", "coins and priceInCents are required.");
  }

  try {
    const url = await stripeModule.createCoinPurchaseCheckout(
      context.auth.uid, coins, priceInCents, promoCode
    );
    return { url };
  } catch (err) {
    console.error("Coin purchase checkout failed:", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// ============================================================
// Agora Live Streaming Functions
// ============================================================

const {RtcTokenBuilder, RtcRole} = require('agora-access-token');

/**
 * Creates a new live stream document in Firestore and returns the channel name.
 * Expects data: { title, isAdult }
 */
exports.startLiveStream = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }

  const { title, isAdult } = data;
  const uid = context.auth.uid;
  const channelName = `live_${uid}_${Date.now()}`;

  try {
    const db = admin.firestore();
    const docRef = await db.collection("live_streams").add({
      host_user: db.collection("users").doc(uid),
      title: title || "Untitled Stream",
      channel_name: channelName,
      status: "live",
      started_at: admin.firestore.FieldValue.serverTimestamp(),
      is_adult: isAdult || false,
      viewer_count: 0,
    });

    return { streamId: docRef.id, channelName };
  } catch (err) {
    console.error("startLiveStream failed:", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});

/**
 * Ends a live stream and optionally saves a replay URL.
 * Expects data: { streamId, replayUrl }
 */
exports.endLiveStream = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }

  const { streamId, replayUrl } = data;
  if (!streamId) {
    throw new functions.https.HttpsError("invalid-argument", "streamId is required.");
  }

  try {
    const db = admin.firestore();
    const update = {
      status: "ended",
      ended_at: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (replayUrl) {
      update.replay_url = replayUrl;
    }
    await db.collection("live_streams").doc(streamId).update(update);
    return { success: true };
  } catch (err) {
    console.error("endLiveStream failed:", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});

/**
 * Generates an Agora RTC token for a live stream channel.
 * Expects data: { streamId }
 * Requires agora.app_id and agora.app_certificate in functions config.
 */
exports.createAgoraRtcToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }

  const { streamId } = data;
  if (!streamId) {
    throw new functions.https.HttpsError("invalid-argument", "streamId is required.");
  }

  const appId = functions.config().agora?.app_id;
  const appCertificate = functions.config().agora?.app_certificate;

  if (!appId || !appCertificate) {
    console.error("Agora app_id or app_certificate not configured.");
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Agora is not configured. Set agora.app_id and agora.app_certificate via firebase functions:config:set."
    );
  }

  try {
    const db = admin.firestore();
    const streamDoc = await db.collection("live_streams").doc(streamId).get();
    if (!streamDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Live stream not found.");
    }

    const channelName = streamDoc.data().channel_name;
    const uid = context.auth.uid;
    const role = RtcRole.PUBLISHER;

    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      0,
      role,
      Math.floor(Date.now() / 1000) + 3600
    );

    return {
      appId,
      token,
      rtcUid: 0,
      channelName,
    };
  } catch (err) {
    if (err instanceof functions.https.HttpsError) throw err;
    console.error("createAgoraRtcToken failed:", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});

exports.validatePromoCode = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be signed in.");
  }

  const { code, priceInCents } = data;
  if (!code) {
    throw new functions.https.HttpsError("invalid-argument", "code is required.");
  }

  try {
    const db = admin.firestore();
    const snap = await db.collection("promo_codes")
      .where("code", "==", code.toUpperCase())
      .limit(1)
      .get();

    if (snap.empty) {
      return { valid: false, message: "Invalid promo code." };
    }

    const promo = snap.docs[0].data();
    if (!promo.is_active) {
      return { valid: false, message: "This promo code is no longer active." };
    }

    if (promo.expires_at && promo.expires_at.toDate() < new Date()) {
      return { valid: false, message: "This promo code has expired." };
    }

    if (promo.max_uses && promo.current_uses >= promo.max_uses) {
      return { valid: false, message: "This promo code has reached its usage limit." };
    }

    const discountPercent = promo.discount_percent || 0;
    const discountedPrice = priceInCents
      ? Math.round(priceInCents * (100 - discountPercent) / 100)
      : null;

    return {
      valid: true,
      discountPercent,
      discountedPrice,
      promoId: snap.docs[0].id,
    };
  } catch (err) {
    console.error("Promo code validation failed:", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});
