/**
 * Stripe Connect — Accounts v2 (PerezFans)
 *
 * PRODUCT DEFAULT: destination charges for fan → creator (createMarketplacePaymentCheckout).
 * Keep this as the primary path until a feature explicitly needs something else.
 *
 * Two payment models (both implemented; #2 is optional / future-facing):
 *
 * 1) Destination charges (default here: createMarketplacePaymentCheckout)
 *    Platform creates Checkout; funds route to the connected account via
 *    payment_intent_data.transfer_data.destination + application_fee_amount.
 *    Good when the platform controls pricing/routing (typical “fan pays creator” marketplace).
 *
 * 2) Direct charges on the connected account (createDirectChargeCheckoutSession)
 *    Checkout is created *as* the connected account (Stripe-Account header / stripeAccount
 *    option). Seller is merchant of record; platform keeps application_fee_amount only.
 *    Reserved for future use — Flutter app currently favors (1).
 *
 * Account onboarding: use accountProfile "marketplace" (Express, app liability) or
 * "subscriptions_embedded" (full dashboard, Stripe liability, merchant+customer configs)
 * per the Subscriptions + embedded payments blueprint.
 *
 * Subscriptions (platform fee from seller balance via stripe_balance) are not implemented
 * here — add only if you need a recurring “PerezFans platform fee” billed to sellers.
 *
 * Config (firebase functions:config:set):
 *   stripe.accounts_v2_api_version — preview version from Stripe docs / Dashboard
 *   stripe.marketplace_application_fee_bps — optional, default 1000 (10%)
 */
const axios = require("axios");
const { randomUUID } = require("crypto");
const Stripe = require("stripe");

function getStripeSecret(functions) {
  const secret = functions.config()?.stripe?.secret;
  if (!secret) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Stripe secret is not configured.",
    );
  }
  return secret;
}

function getAccountsV2ApiVersion(functions) {
  const v = functions.config()?.stripe?.accounts_v2_api_version;
  if (!v) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Set stripe.accounts_v2_api_version to the Accounts v2 preview API version from Stripe (Connect → Accounts v2 docs).",
    );
  }
  return v;
}

function getMarketplaceFeeBps(functions) {
  const raw = functions.config()?.stripe?.marketplace_application_fee_bps;
  const n = Number(raw);
  if (Number.isFinite(n) && n >= 0 && n <= 10000) {
    return Math.floor(n);
  }
  return 1000;
}

/**
 * @param {import("firebase-functions")} functions
 */
async function stripeV2JsonRequest(functions, method, path, body) {
  const secret = getStripeSecret(functions);
  const stripeVersion = getAccountsV2ApiVersion(functions);
  const url = `https://api.stripe.com${path}`;
  const res = await axios({
    method,
    url,
    data: body,
    headers: {
      Authorization: `Bearer ${secret}`,
      "Content-Type": "application/json",
      "Stripe-Version": stripeVersion,
      "Idempotency-Key": randomUUID(),
    },
    validateStatus: () => true,
  });
  if (res.status >= 400) {
    const errObj = res.data?.error;
    const code = errObj?.code ? `[${errObj.code}] ` : "";
    const msg =
      code +
      (errObj?.message ||
        (typeof res.data === "string" ? res.data : JSON.stringify(res.data)) ||
        res.statusText ||
        "Stripe Accounts v2 request failed");
    throw new functions.https.HttpsError("failed-precondition", msg);
  }
  return res.data;
}

function getStripeClient(functions) {
  const secret = getStripeSecret(functions);
  return new Stripe(secret);
}

async function getStripeAccount(functions, accountId) {
  if (!accountId || typeof accountId !== 'string') {
    throw new Error('Invalid account id for Stripe lookup.');
  }
  const account = await stripeV2JsonRequest(functions, 'get', `/v2/core/accounts/${encodeURIComponent(accountId)}`, {});
  if (!account || !account.id) {
    throw new Error('Could not fetch Stripe account details.');
  }
  return account;
}

/**
 * @param {import("firebase-functions")} functions
 * @param {FirebaseFirestore.Firestore} db
 */
function registerStripeMarketplace(functions, admin, db) {
  return {
    createSellerConnectedAccount: functions.https.onCall(async (data, context) => {
      if (!context.auth?.uid) {
        throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
      }
      const uid = context.auth.uid;
      const userRef = db.collection("users").doc(uid);
      const userSnap = await userRef.get();
      if (!userSnap.exists) {
        throw new functions.https.HttpsError("failed-precondition", "User profile not found.");
      }
      const user = userSnap.data() || {};
      const existing = user.stripe_connect_account_id;
      if (typeof existing === "string" && existing.length > 0) {
        return { accountId: existing, alreadyExists: true };
      }

      const displayName = (data?.displayName || user.display_name || "Seller").toString().trim();
      const contactEmail = (data?.contactEmail || user.email || "").toString().trim();
      if (!contactEmail) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "contactEmail or user email is required.",
        );
      }
      const country = (data?.country || "us").toString().trim().toLowerCase();
      /** @type {"marketplace"|"subscriptions_embedded"} */
      const accountProfile =
        data?.accountProfile === "subscriptions_embedded"
          ? "subscriptions_embedded"
          : "marketplace";

      const secret = getStripeSecret(functions);
      const isTest = secret.startsWith("sk_test");
      /**
       * Marketplace (destination charges) requires recipient.stripe_balance.stripe_transfers
       * per Stripe's Accounts v2 marketplace guide — omitting it can yield confusing errors.
       * @see https://docs.stripe.com/connect/marketplace/tasks/create
       */
      const configuration = {
        merchant: {},
        recipient: {
          capabilities: {
            stripe_balance: {
              stripe_transfers: {
                requested: true,
              },
            },
          },
        },
      };
      if (accountProfile === "subscriptions_embedded") {
        configuration.customer = {};
        delete configuration.recipient;
      }
      if (isTest && data?.simulateAcceptTosObo === true) {
        configuration.merchant.simulate_accept_tos_obo = true;
      }

      const businessPhone = (data?.businessPhone || "0000000000").toString();

      const body =
        accountProfile === "subscriptions_embedded"
          ? {
            display_name: displayName,
            contact_email: contactEmail,
            configuration,
            include: [
              "configuration.merchant",
              "configuration.recipient",
              "identity",
              "defaults",
              "configuration.customer",
              "requirements",
            ],
            identity: {
              country,
              business_details: {
                phone: businessPhone,
              },
            },
            dashboard: "full",
            defaults: {
              responsibilities: {
                losses_collector: "stripe",
                fees_collector: "stripe",
              },
            },
          }
          : {
            display_name: displayName,
            contact_email: contactEmail,
            configuration,
            defaults: {
              responsibilities: {
                losses_collector: "application",
                fees_collector: "application",
              },
            },
            dashboard: "express",
            include: [
              "configuration.merchant",
              "configuration.recipient",
              "identity",
              "defaults",
              "requirements",
            ],
            identity: {
              country,
            },
          };

      const created = await stripeV2JsonRequest(functions, "post", "/v2/core/accounts", body);
      const accountId = created?.id;
      if (!accountId) {
        throw new functions.https.HttpsError("internal", "Stripe did not return account id.");
      }

      await userRef.set(
        {
          stripe_connect_account_id: accountId,
          stripe_connect_account_profile: accountProfile,
          stripe_connect_created_at: admin.firestore.FieldValue.serverTimestamp(),
          stripe_connect_onboarding_status: "pending",
        },
        { merge: true },
      );

      return { accountId, alreadyExists: false, accountProfile };
    }),

    createSellerOnboardingLink: functions.https.onCall(async (data, context) => {
      if (!context.auth?.uid) {
        throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
      }
      const uid = context.auth.uid;
      const userRef = db.collection("users").doc(uid);
      const userSnap = await userRef.get();
      if (!userSnap.exists) {
        throw new functions.https.HttpsError("failed-precondition", "User profile not found.");
      }
      let accountId = userSnap.data()?.stripe_connect_account_id;
      if (!accountId || typeof accountId !== "string") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Create a Stripe seller account first (tap 'Create Stripe seller account' in profile).",
        );
      }

      // Ensure account exists in Stripe and respond with current onboarding status.
      try {
        const account = await getStripeAccount(functions, accountId);
        await userRef.set(
          {
            stripe_connect_onboarding_status: String(account.requirements?.currently_due || account.requirements?.disabled_reason || account?.status || 'pending'),
            stripe_connect_updated_at: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      } catch (err) {
        console.warn('Could not read Stripe account status for onboarding link', err);
      }

      const defaultBase = "https://perezfans.web.app/stripe";
      const refreshUrl =
        typeof data?.refreshUrl === "string" && data.refreshUrl
          ? data.refreshUrl
          : `${defaultBase}/onboarding-refresh.html`;
      const returnUrl =
        typeof data?.returnUrl === "string" && data.returnUrl
          ? data.returnUrl
          : `${defaultBase}/onboarding-return.html`;

      const profile = userSnap.data()?.stripe_connect_account_profile;
      let configurations = ["recipient", "merchant"];
      if (Array.isArray(data?.onboardingConfigurations)) {
        configurations = data.onboardingConfigurations.map((x) => String(x));
      } else if (profile === "subscriptions_embedded") {
        configurations = ["merchant", "customer"];
      }

      const linkBody = {
        account: accountId,
        use_case: {
          type: "account_onboarding",
          account_onboarding: {
            configurations,
            refresh_url: refreshUrl,
            return_url: returnUrl,
          },
        },
      };

      const created = await stripeV2JsonRequest(
        functions,
        "post",
        "/v2/core/account_links",
        linkBody,
      );
      const url = created?.url;
      if (!url) {
        throw new functions.https.HttpsError("internal", "Stripe did not return onboarding URL.");
      }
      return { url };
    }),

    refreshSellerStripeStatus: functions.https.onCall(async (data, context) => {
      if (!context.auth?.uid) {
        throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
      }
      const uid = context.auth.uid;
      const userRef = db.collection("users").doc(uid);
      const userSnap = await userRef.get();
      if (!userSnap.exists) {
        throw new functions.https.HttpsError("failed-precondition", "User profile not found.");
      }
      const accountId = userSnap.data()?.stripe_connect_account_id;
      if (!accountId || typeof accountId !== "string") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "No connected Stripe account found. Create one first.",
        );
      }
      const stripeAccount = await getStripeAccount(functions, accountId);
      const status =
        String(stripeAccount.requirements?.currently_due || stripeAccount.requirements?.disabled_reason || stripeAccount.status || "pending");
      await userRef.set(
        {
          stripe_connect_onboarding_status: status,
          stripe_connect_updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return {
        accountId,
        status,
        profile: userSnap.data()?.stripe_connect_account_profile || "marketplace",
      };
    }),

    createMarketplacePaymentCheckout: functions.https.onCall(async (data, context) => {
      if (!context.auth?.uid) {
        throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
      }
      const buyerUid = context.auth.uid;
      const sellerUid = data?.sellerUid;
      if (!sellerUid || typeof sellerUid !== "string") {
        throw new functions.https.HttpsError("invalid-argument", "sellerUid is required.");
      }
      if (sellerUid === buyerUid) {
        throw new functions.https.HttpsError("invalid-argument", "Cannot pay yourself.");
      }

      const amountCents = Number(data?.amountCents);
      if (!Number.isFinite(amountCents) || amountCents < 50) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "amountCents must be at least 50.",
        );
      }

      const sellerSnap = await db.collection("users").doc(sellerUid).get();
      if (!sellerSnap.exists) {
        throw new functions.https.HttpsError("not-found", "Seller not found.");
      }
      const destination = sellerSnap.data()?.stripe_connect_account_id;
      const onboardingStatus = (sellerSnap.data()?.stripe_connect_onboarding_status || '').toString().toLowerCase();
      if (!destination || typeof destination !== "string") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Seller has not connected Stripe payouts yet. Make sure the creator has completed Stripe onboarding.",
        );
      }
      if (onboardingStatus.includes('rejected') || onboardingStatus.includes('disabled')) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Seller Stripe account is currently restricted. Contact support to resolve onboarding issues.",
        );
      }

      const currency = (data?.currency || "usd").toString().toLowerCase();
      const productName = (data?.productName || "PerezFans purchase").toString();
      const feeBps = getMarketplaceFeeBps(functions);
      const applicationFeeAmount = Math.min(
        Math.floor((amountCents * feeBps) / 10000),
        amountCents - 1,
      );

      const stripe = getStripeClient(functions);
      const successUrl =
        typeof data?.successUrl === "string" && data.successUrl
          ? data.successUrl
          : "https://perezfans.web.app/stripe/marketplace-success.html";
      const cancelUrl =
        typeof data?.cancelUrl === "string" && data.cancelUrl
          ? data.cancelUrl
          : "https://perezfans.web.app/stripe/marketplace-cancel.html";

      const session = await stripe.checkout.sessions.create({
        mode: "payment",
        success_url: successUrl,
        cancel_url: cancelUrl,
        payment_method_types: ["card"],
        line_items: [
          {
            quantity: 1,
            price_data: {
              currency,
              unit_amount: amountCents,
              product_data: {
                name: productName,
              },
            },
          },
        ],
        payment_intent_data: {
          application_fee_amount: Math.max(applicationFeeAmount, 0),
          transfer_data: {
            destination,
          },
        },
        metadata: {
          checkout_kind: "marketplace_purchase",
          buyer_uid: buyerUid,
          seller_uid: sellerUid,
          amount_cents: String(amountCents),
          currency,
        },
      });

      return {
        checkoutUrl: session.url,
        sessionId: session.id,
      };
    }),

    /**
     * Direct charge: Checkout created in the connected account’s context (Stripe-Account).
     * Use when the seller is the merchant of record; platform takes application_fee_amount only.
     */
    createDirectChargeCheckoutSession: functions.https.onCall(async (data, context) => {
      if (!context.auth?.uid) {
        throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
      }
      const buyerUid = context.auth.uid;
      const sellerUid = data?.sellerUid;
      if (!sellerUid || typeof sellerUid !== "string") {
        throw new functions.https.HttpsError("invalid-argument", "sellerUid is required.");
      }
      if (sellerUid === buyerUid) {
        throw new functions.https.HttpsError("invalid-argument", "Cannot pay yourself.");
      }

      const amountCents = Number(data?.amountCents);
      if (!Number.isFinite(amountCents) || amountCents < 50) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "amountCents must be at least 50.",
        );
      }

      const sellerSnap = await db.collection("users").doc(sellerUid).get();
      if (!sellerSnap.exists) {
        throw new functions.https.HttpsError("not-found", "Seller not found.");
      }
      const stripeAccountId = sellerSnap.data()?.stripe_connect_account_id;
      if (!stripeAccountId || typeof stripeAccountId !== "string") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Seller has not connected Stripe yet.",
        );
      }

      const currency = (data?.currency || "usd").toString().toLowerCase();
      const productName = (data?.productName || "PerezFans purchase").toString();
      const feeBps = getMarketplaceFeeBps(functions);
      const applicationFeeAmount = Math.min(
        Math.floor((amountCents * feeBps) / 10000),
        amountCents - 1,
      );

      const stripe = getStripeClient(functions);
      const successUrl =
        typeof data?.successUrl === "string" && data.successUrl
          ? data.successUrl
          : "https://perezfans.web.app/stripe/marketplace-success.html";
      const cancelUrl =
        typeof data?.cancelUrl === "string" && data.cancelUrl
          ? data.cancelUrl
          : "https://perezfans.web.app/stripe/marketplace-cancel.html";

      const session = await stripe.checkout.sessions.create(
        {
          mode: "payment",
          success_url: successUrl,
          cancel_url: cancelUrl,
          payment_method_types: ["card"],
          line_items: [
            {
              quantity: 1,
              price_data: {
                currency,
                unit_amount: amountCents,
                product_data: {
                  name: productName,
                },
              },
            },
          ],
          payment_intent_data: {
            application_fee_amount: Math.max(applicationFeeAmount, 0),
          },
          metadata: {
            checkout_kind: "direct_charge_purchase",
            buyer_uid: buyerUid,
            seller_uid: sellerUid,
            amount_cents: String(amountCents),
            currency,
          },
        },
        { stripeAccount: stripeAccountId },
      );

      return {
        checkoutUrl: session.url,
        sessionId: session.id,
      };
    }),
  };
}

/**
 * Webhook side-effects for marketplace + Accounts v2 (used from index.js).
 * @param {import("stripe").Stripe.Event} event
 */
async function processStripeMarketplaceEvent(functions, admin, db, event) {
  if (event.type === "checkout.session.completed") {
    const session = event.data.object;
    const kind = session?.metadata?.checkout_kind;
    if (kind === "marketplace_purchase" || kind === "direct_charge_purchase") {
      const buyerUid = session.metadata?.buyer_uid;
      const sellerUid = session.metadata?.seller_uid;
      const amountCents = Number(session.metadata?.amount_cents || 0);
      const paymentIntentId =
        typeof session.payment_intent === "string"
          ? session.payment_intent
          : session.payment_intent?.id;
      await db.collection("marketplace_purchases").add({
        checkout_session_id: session.id,
        payment_intent_id: paymentIntentId || null,
        buyer_uid: buyerUid || null,
        seller_uid: sellerUid || null,
        amount_cents: amountCents,
        currency: session.metadata?.currency || "usd",
        charge_model: kind === "direct_charge_purchase" ? "direct" : "destination",
        paid_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    return;
  }

  if (
    typeof event.type === "string" &&
    event.type.includes("v2.core.account") &&
    event.type.includes("capability")
  ) {
    const obj = event.data?.object || {};
    const accountId = obj.id || obj.account?.id;
    if (!accountId) {
      return;
    }
    const snap = await db
      .collection("users")
      .where("stripe_connect_account_id", "==", accountId)
      .limit(1)
      .get();
    if (snap.empty) {
      return;
    }
    const ref = snap.docs[0].ref;
    const merchantCap =
      obj.configuration?.merchant?.capabilities?.card_payments;
    const recipientCap =
      obj.configuration?.recipient?.capabilities?.stripe_balance
        ?.stripe_transfers;
    const capStr = (v) => {
      if (v == null || v === "") return "";
      return typeof v === "string" ? v : JSON.stringify(v);
    };
    const status =
      [capStr(merchantCap), capStr(recipientCap)].filter(Boolean).join(" | ") ||
      (obj.status != null ? String(obj.status) : "") ||
      event.type ||
      "updated";
    await ref.set(
      {
        stripe_connect_onboarding_status: String(status).slice(0, 500),
        stripe_connect_updated_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }
}

module.exports = {
  registerStripeMarketplace,
  processStripeMarketplaceEvent,
};
