/**
 * Server-side reCAPTCHA Enterprise token verification (CreateAssessment).
 *
 * Prerequisites (GCP project = Firebase project, e.g. perezfans):
 * - Enable API: gcloud services enable recaptchaenterprise.googleapis.com --project=perezfans
 * - Default Functions runtime SA needs recaptchaenterprise.assessments.create, e.g.:
 *     roles/recaptchaenterprise.agent on the project (or use a custom SA with deploy).
 *
 * Optional runtime config (recommended so you can rotate without redeploy):
 *   firebase functions:config:set recaptcha.site_key="6LeBRqIsAAAAAOWXICKGW5Lt0NTIDMlGHXWN2vS0"
 */
const { RecaptchaEnterpriseServiceClient } = require("@google-cloud/recaptcha-enterprise");
const functions = require("firebase-functions");

const DEFAULT_SITE_KEY = "6LeBRqIsAAAAAOWXICKGW5Lt0NTIDMlGHXWN2vS0";

let _client;

function getClient() {
  if (!_client) {
    _client = new RecaptchaEnterpriseServiceClient();
  }
  return _client;
}

function getSiteKey() {
  const key = functions.config()?.recaptcha?.site_key;
  if (key && String(key).trim()) {
    return String(key).trim();
  }
  return DEFAULT_SITE_KEY;
}

/**
 * @param {object} opts
 * @param {string} opts.token - Token from grecaptcha.enterprise.execute()
 * @param {string} [opts.expectedAction] - Must match the action passed to execute() if you use actions
 * @returns {Promise<{ valid: boolean, score: number|null, action: string|null, invalidReason: string|null }>}
 */
async function verifyRecaptchaEnterpriseToken({ token, expectedAction }) {
  if (!token || typeof token !== "string" || !token.trim()) {
    throw new Error("reCAPTCHA token is required");
  }

  const siteKey = getSiteKey();
  const projectId = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || "perezfans";
  const client = getClient();
  const parent = client.projectPath(projectId);

  const event = {
    token: token.trim(),
    siteKey,
  };
  if (expectedAction && typeof expectedAction === "string" && expectedAction.trim()) {
    event.expectedAction = expectedAction.trim();
  }

  const [response] = await client.createAssessment({
    parent,
    assessment: { event },
  });

  const tp = response.tokenProperties || {};
  const valid = tp.valid === true;
  const score =
    response.riskAnalysis && typeof response.riskAnalysis.score === "number"
      ? response.riskAnalysis.score
      : null;
  const action = tp.action || null;
  const invalidReason = tp.invalidReason || null;

  return { valid, score, action, invalidReason };
}

module.exports = {
  verifyRecaptchaEnterpriseToken,
  getSiteKey,
  DEFAULT_SITE_KEY,
};
