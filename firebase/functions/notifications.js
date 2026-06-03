const admin = require("firebase-admin");

/**
 * Sends a push notification to a user's FCM tokens.
 * @param {string} uid - The user to notify.
 * @param {string} title - Notification title.
 * @param {string} body - Notification body.
 * @param {object} [data] - Optional data payload.
 */
async function sendToUser(uid, title, body, data = {}) {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(uid).get();
  if (!userDoc.exists) return;

  const tokens = userDoc.data().fcm_tokens || [];
  if (tokens.length === 0) return;

  const message = {
    notification: { title, body },
    data,
    tokens,
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    const invalidTokens = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success && resp.error?.code === "messaging/registration-token-not-registered") {
        invalidTokens.push(tokens[idx]);
      }
    });
    if (invalidTokens.length > 0) {
      await db.collection("users").doc(uid).update({
        fcm_tokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
      });
    }
  } catch (err) {
    console.error(`Error sending notification to ${uid}:`, err);
  }
}

/**
 * Triggered when a new comment is created.
 * Notifies the video owner.
 */
async function onCommentCreated(snapshot) {
  const comment = snapshot.data();
  if (!comment.video || !comment.user) return;

  const db = admin.firestore();
  const videoDoc = await db.collection("videos").doc(comment.video.id).get();
  if (!videoDoc.exists) return;

  const video = videoDoc.data();
  const videoOwnerId = video.video_user?.id;
  const commenterId = comment.user.id;

  if (!videoOwnerId || videoOwnerId === commenterId) return;

  const commenterDoc = await db.collection("users").doc(commenterId).get();
  const commenterName = commenterDoc.exists
    ? commenterDoc.data().username || commenterDoc.data().display_name || "Someone"
    : "Someone";

  await sendToUser(
    videoOwnerId,
    "New Comment",
    `${commenterName} commented on your video`,
    { type: "comment", videoId: comment.video.id }
  );

  await createActivity({
    actor: comment.user,
    type: "comment",
    targetUser: videoOwnerRef,
    targetVideo: comment.video,
  });
}

/**
 * Creates an activity record in Firestore.
 */
async function createActivity({ actor, type, targetUser, targetVideo }) {
  const db = admin.firestore();
  const activityRef = db.collection("activities").doc();
  const actorRef = typeof actor === "object" && actor.id
    ? db.collection("users").doc(actor.id)
    : actor;
  const targetUserRef = targetUser
    ? (typeof targetUser === "object" && targetUser.id
        ? db.collection("users").doc(targetUser.id)
        : targetUser)
    : null;
  const targetVideoRef = targetVideo
    ? (typeof targetVideo === "object" && targetVideo.id
        ? db.collection("videos").doc(targetVideo.id)
        : targetVideo)
    : null;

  await activityRef.set({
    actor: actorRef,
    type,
    target_user: targetUserRef,
    target_video: targetVideoRef,
    created_time: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Triggered when a tip status changes to 'completed'.
 * Notifies the creator.
 */
async function onTipCompleted(snapshot) {
  const tip = snapshot.data();
  if (!tip.creator || !tip.fan) return;

  const db = admin.firestore();
  const fanDoc = await db.collection("users").doc(tip.fan.id).get();
  const fanName = fanDoc.exists
    ? fanDoc.data().username || fanDoc.data().display_name || "Someone"
    : "Someone";

  const amount = tip.amount ? `$${tip.amount.toFixed(2)}` : "a tip";

  await sendToUser(
    tip.creator.id,
    "Tip Received",
    `${fanName} sent you ${amount}!`,
    { type: "tip" }
  );

  await createActivity({
    actor: tip.fan,
    type: "tip",
    targetUser: tip.creator,
  });
}

/**
 * Triggered when a Firestore document is written (used for follow,
 * like, etc.). Checks for new follows or likes by comparing before/after.
 */
async function onFollowOrLike(change) {
  const before = change.before.data();
  const after = change.after.data();
  const ref = change.after.ref;

  // Detect follow: followers array gains a reference
  if (before && after) {
    const prevFollowers = before.followers || [];
    const currFollowers = after.followers || [];
    if (currFollowers.length > prevFollowers.length) {
      const newFollower = currFollowers.find(
        (f) => !prevFollowers.some((p) => p.id === f.id)
      );
      if (newFollower) {
        await createActivity({
          actor: newFollower,
          type: "follow",
          targetUser: ref,
        });
      }
    }
  }
}

module.exports = { sendToUser, onCommentCreated, onTipCompleted, onFollowOrLike, createActivity };
