#!/usr/bin/env node
/* eslint-disable no-console */
/**
 * Backfill existing videos with:
 *   - video_is_vault: false (when missing)
 *   - video_niche: "general" (when missing/empty)
 *
 * Usage:
 *   node scripts/backfill_videos_niche_vault.js           # dry run
 *   node scripts/backfill_videos_niche_vault.js --apply   # write changes
 *   node scripts/backfill_videos_niche_vault.js --apply --batch-size=300
 */
const admin = require("firebase-admin");

const DEFAULT_BATCH_SIZE = 400;
const GENERAL_NICHE = "general";

function parseArgs(argv) {
  const args = {
    apply: false,
    batchSize: DEFAULT_BATCH_SIZE,
    projectId: process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT || "",
  };

  for (const raw of argv) {
    if (raw === "--apply") {
      args.apply = true;
      continue;
    }
    if (raw.startsWith("--batch-size=")) {
      const n = Number(raw.split("=")[1]);
      if (Number.isFinite(n) && n > 0 && n <= 500) {
        args.batchSize = Math.floor(n);
      }
      continue;
    }
    if (raw.startsWith("--project=")) {
      args.projectId = raw.split("=")[1] || "";
      continue;
    }
  }

  return args;
}

function needsBackfill(data) {
  const needsVault = typeof data.video_is_vault !== "boolean";
  const needsNiche =
    typeof data.video_niche !== "string" || data.video_niche.trim().length === 0;
  return { needsVault, needsNiche, needsAny: needsVault || needsNiche };
}

async function main() {
  const { apply, batchSize, projectId } = parseArgs(process.argv.slice(2));
  if (projectId) {
    admin.initializeApp({ projectId });
  } else {
    admin.initializeApp();
  }
  const db = admin.firestore();

  console.log(
    `[backfill] start mode=${apply ? "apply" : "dry-run"} batchSize=${batchSize} project=${projectId || "(auto)"}`,
  );

  let lastDoc = null;
  let scanned = 0;
  let candidates = 0;
  let updated = 0;

  while (true) {
    let q = db.collection("videos").orderBy("__name__").limit(batchSize);
    if (lastDoc) {
      q = q.startAfter(lastDoc);
    }
    const snap = await q.get();
    if (snap.empty) {
      break;
    }

    const docsToUpdate = [];
    for (const doc of snap.docs) {
      scanned += 1;
      const data = doc.data() || {};
      const { needsVault, needsNiche, needsAny } = needsBackfill(data);
      if (!needsAny) {
        continue;
      }
      candidates += 1;

      const payload = {};
      if (needsVault) payload.video_is_vault = false;
      if (needsNiche) payload.video_niche = GENERAL_NICHE;
      docsToUpdate.push({ ref: doc.ref, payload, id: doc.id });
    }

    if (apply && docsToUpdate.length > 0) {
      let batch = db.batch();
      let ops = 0;

      for (const item of docsToUpdate) {
        batch.set(item.ref, item.payload, { merge: true });
        ops += 1;
        updated += 1;
        if (ops === 500) {
          await batch.commit();
          batch = db.batch();
          ops = 0;
        }
      }
      if (ops > 0) {
        await batch.commit();
      }
    }

    console.log(
      `[backfill] scanned=${scanned} candidates=${candidates} updated=${updated}`,
    );
    lastDoc = snap.docs[snap.docs.length - 1];
  }

  console.log(
    `[backfill] done scanned=${scanned} candidates=${candidates} updated=${apply ? updated : 0}`,
  );
  if (!apply) {
    console.log("[backfill] dry-run only. Re-run with --apply to persist.");
  }
}

main().catch((err) => {
  console.error("[backfill] failed", err);
  if (
    typeof err?.message === "string" &&
    err.message.includes("Unable to detect a Project Id")
  ) {
    console.error(
      "[backfill] tip: run with --project=<firebaseProjectId> and ensure ADC is available.",
    );
  }
  process.exitCode = 1;
});
