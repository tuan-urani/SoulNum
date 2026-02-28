export type GeminiResult = {
  rawText: string;
  json: Record<string, unknown>;
  usage: {
    promptTokenCount: number | null;
    candidatesTokenCount: number | null;
    totalTokenCount: number | null;
  };
};

function getGeminiApiKey(): string {
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) {
    throw new Error("Missing GEMINI_API_KEY");
  }
  return key;
}

function maybeParseJson(text: string): Record<string, unknown> {
  const cleaned = text.trim().replace(/^```json\s*/i, "").replace(/^```\s*/i, "").replace(/```$/, "").trim();
  try {
    return JSON.parse(cleaned) as Record<string, unknown>;
  } catch (_error) {
    return { summary: cleaned };
  }
}

export async function callGemini({
  model,
  systemInstruction,
  userPayload,
}: {
  model: string;
  systemInstruction: string;
  userPayload: Record<string, unknown>;
}): Promise<GeminiResult> {
  const apiKey = getGeminiApiKey();
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

  const payload = {
    system_instruction: {
      parts: [{ text: systemInstruction }],
    },
    contents: [
      {
        role: "user",
        parts: [{ text: JSON.stringify(userPayload) }],
      },
    ],
    generationConfig: {
      temperature: 0.6,
      responseMimeType: "application/json",
    },
  };

  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Gemini API error (${response.status}): ${body}`);
  }

  const data = (await response.json()) as Record<string, any>;
  const candidateText =
    data?.candidates?.[0]?.content?.parts?.map((p: { text?: string }) => p.text ?? "").join("\n") ?? "{}";

  const usageMeta = data?.usageMetadata ?? {};

  return {
    rawText: candidateText,
    json: maybeParseJson(candidateText),
    usage: {
      promptTokenCount: usageMeta.promptTokenCount ?? null,
      candidatesTokenCount: usageMeta.candidatesTokenCount ?? null,
      totalTokenCount: usageMeta.totalTokenCount ?? null,
    },
  };
}

