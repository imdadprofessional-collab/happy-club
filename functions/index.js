const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret, defineString} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");

// Set with: firebase functions:secrets:set GEMINI_API_KEY
// (a Gemini API key from https://aistudio.google.com/apikey — this is a
// separate step from any GitHub Actions secret of the same name; GitHub
// secrets aren't visible to Cloud Functions).
const geminiApiKey = defineSecret("GEMINI_API_KEY");

// Override with: firebase functions:config or redeploy after editing the
// default below — no code change needed elsewhere to bump models.
const geminiModel = defineString("GEMINI_MODEL", {default: "gemini-2.0-flash"});

const SYSTEM_PROMPT = `You are the Happy Club AI Happiness Coach, inside a daily positive-habit
and gratitude app. Be warm, brief, and encouraging — 2-4 sentences, never
clinical or therapist-like. You are NOT a mental health professional and
must never claim to diagnose, treat, or cure depression or any condition.
If someone sounds like they may be in real distress or mentions self-harm,
gently encourage them to reach out to a real person, a counselor, or a
crisis line, alongside anything else you say.`;

exports.coachChat = onCall(
  {secrets: [geminiApiKey], cors: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const message = (request.data && request.data.message || "").toString().trim();
    if (!message) {
      throw new HttpsError("invalid-argument", "message is required.");
    }
    if (message.length > 2000) {
      throw new HttpsError("invalid-argument", "message is too long.");
    }

    const ctx = (request.data && request.data.context) || {};
    const contextLines = [];
    if (typeof ctx.name === "string" && ctx.name) {
      contextLines.push(`User's name: ${ctx.name}`);
    }
    if (typeof ctx.streak === "number") {
      contextLines.push(`Current streak: ${ctx.streak} days`);
    }
    if (typeof ctx.happinessScore === "number") {
      contextLines.push(`Happiness score: ${Math.round(ctx.happinessScore)}/100`);
    }

    const systemInstruction = contextLines.length
      ? `${SYSTEM_PROMPT}\n\nContext:\n${contextLines.join("\n")}`
      : SYSTEM_PROMPT;

    const model = geminiModel.value();
    const url =
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent` +
      `?key=${geminiApiKey.value()}`;

    const body = {
      systemInstruction: {parts: [{text: systemInstruction}]},
      contents: [{role: "user", parts: [{text: message}]}],
      generationConfig: {maxOutputTokens: 220, temperature: 0.8},
    };

    let response;
    try {
      response = await fetch(url, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(body),
      });
    } catch (err) {
      logger.error("Gemini request failed", err);
      throw new HttpsError("unavailable", "Coach is temporarily unavailable.");
    }

    if (!response.ok) {
      logger.error("Gemini API error", response.status, await response.text());
      throw new HttpsError("internal", "Coach is temporarily unavailable.");
    }

    const json = await response.json();
    const text = json.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!text) {
      logger.error("Gemini API returned no text", JSON.stringify(json));
      throw new HttpsError("internal", "Coach didn't return a response.");
    }

    return {reply: text.trim()};
  },
);
