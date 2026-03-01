export type GeminiResult = {
  rawText: string;
  json: Record<string, unknown>;
  usage: {
    promptTokenCount: number | null;
    candidatesTokenCount: number | null;
    totalTokenCount: number | null;
  };
};

export class AiGatewayError extends Error {
  readonly code: "ai_key_error" | "ai_schema_invalid" | "ai_timeout" | "ai_gateway_error";
  readonly status: number;
  readonly details?: unknown;

  constructor(params: {
    code: "ai_key_error" | "ai_schema_invalid" | "ai_timeout" | "ai_gateway_error";
    message: string;
    status?: number;
    details?: unknown;
  }) {
    super(params.message);
    this.name = "AiGatewayError";
    this.code = params.code;
    this.status = params.status ?? 500;
    this.details = params.details;
  }
}

function getGeminiApiKeys(): string[] {
  const primary = Deno.env.get("GEMINI_API_KEY")?.trim() ?? "";
  const fallback = Deno.env.get("GEMINI_API_KEY_FALLBACK")?.trim() ?? "";

  const keys = [primary, fallback].filter((k) => k.length > 0);
  if (keys.length === 0) {
    throw new AiGatewayError({
      code: "ai_key_error",
      message: "Missing GEMINI_API_KEY",
      status: 500,
    });
  }
  return [...new Set(keys)];
}

function maybeParseJson(text: string): Record<string, unknown> {
  const cleaned = text
    .trim()
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```$/, "")
    .trim();
  try {
    return JSON.parse(cleaned) as Record<string, unknown>;
  } catch (_error) {
    return { summary: cleaned };
  }
}

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

const GEMINI_ALLOWED_SCHEMA_KEYS = new Set<string>([
  "type",
  "format",
  "description",
  "nullable",
  "enum",
  "items",
  "properties",
  "required",
  "minimum",
  "maximum",
  "minItems",
  "maxItems",
  "minLength",
  "maxLength",
  "anyOf",
  "oneOf",
  "allOf",
]);

function normalizeSchemaType(typeValue: unknown): string | null {
  if (typeof typeValue !== "string") {
    return null;
  }
  if (typeValue === "integer") {
    return "number";
  }
  return typeValue;
}

function sanitizeSchemaNode(node: unknown): Record<string, unknown> | null {
  if (!isPlainObject(node)) {
    return null;
  }

  const sanitized: Record<string, unknown> = {};

  for (const [key, value] of Object.entries(node)) {
    if (!GEMINI_ALLOWED_SCHEMA_KEYS.has(key)) {
      continue;
    }

    switch (key) {
      case "type": {
        const normalizedType = normalizeSchemaType(value);
        if (normalizedType) {
          sanitized.type = normalizedType;
        }
        break;
      }
      case "format":
      case "description": {
        if (typeof value === "string" && value.length > 0) {
          sanitized[key] = value;
        }
        break;
      }
      case "nullable": {
        if (typeof value === "boolean") {
          sanitized.nullable = value;
        }
        break;
      }
      case "minimum":
      case "maximum":
      case "minItems":
      case "maxItems":
      case "minLength":
      case "maxLength": {
        if (typeof value === "number" && !Number.isNaN(value)) {
          sanitized[key] = value;
        }
        break;
      }
      case "enum": {
        if (Array.isArray(value)) {
          const enumValues = value.filter((item) =>
            item === null ||
            typeof item === "string" ||
            typeof item === "number" ||
            typeof item === "boolean"
          );
          if (enumValues.length > 0) {
            sanitized.enum = enumValues;
          }
        }
        break;
      }
      case "required": {
        if (Array.isArray(value)) {
          const requiredKeys = value.filter((item): item is string =>
            typeof item === "string"
          );
          if (requiredKeys.length > 0) {
            sanitized.required = requiredKeys;
          }
        }
        break;
      }
      case "items": {
        const sanitizedItems = sanitizeSchemaNode(value);
        if (sanitizedItems) {
          sanitized.items = sanitizedItems;
        }
        break;
      }
      case "properties": {
        if (isPlainObject(value)) {
          const sanitizedProperties: Record<string, unknown> = {};
          for (const [propKey, propSchema] of Object.entries(value)) {
            const sanitizedProperty = sanitizeSchemaNode(propSchema);
            if (sanitizedProperty) {
              sanitizedProperties[propKey] = sanitizedProperty;
            }
          }
          if (Object.keys(sanitizedProperties).length > 0) {
            sanitized.properties = sanitizedProperties;
          }
        }
        break;
      }
      case "anyOf":
      case "oneOf":
      case "allOf": {
        if (Array.isArray(value)) {
          const sanitizedVariants = value
            .map((item) => sanitizeSchemaNode(item))
            .filter((item): item is Record<string, unknown> => item != null);
          if (sanitizedVariants.length > 0) {
            sanitized[key] = sanitizedVariants;
          }
        }
        break;
      }
      default:
        break;
    }
  }

  return Object.keys(sanitized).length > 0 ? sanitized : null;
}

function sanitizeResponseSchemaForGemini(
  schema: Record<string, unknown> | null | undefined,
): Record<string, unknown> | null {
  if (!schema) {
    return null;
  }
  return sanitizeSchemaNode(schema);
}

function validateAgainstSchema(
  value: unknown,
  schema: Record<string, unknown>,
  path = "$",
): string[] {
  const errors: string[] = [];
  const schemaType = schema.type;

  if (typeof schemaType === "string") {
    const typeMatches = (
      (schemaType === "object" && isPlainObject(value)) ||
      (schemaType === "array" && Array.isArray(value)) ||
      (schemaType === "string" && typeof value === "string") ||
      (schemaType === "number" && typeof value === "number") ||
      (schemaType === "boolean" && typeof value === "boolean") ||
      (schemaType === "null" && value === null)
    );

    if (!typeMatches) {
      errors.push(`${path}: expected type \"${schemaType}\".`);
      return errors;
    }
  }

  if (Array.isArray(schema.required) && isPlainObject(value)) {
    for (const requiredKey of schema.required) {
      if (typeof requiredKey === "string" && !(requiredKey in value)) {
        errors.push(`${path}: missing required key \"${requiredKey}\".`);
      }
    }
  }

  if (isPlainObject(schema.properties) && isPlainObject(value)) {
    const properties = schema.properties as Record<string, unknown>;
    for (const [key, propSchema] of Object.entries(properties)) {
      if (!(key in value)) continue;
      if (!isPlainObject(propSchema)) continue;
      errors.push(...validateAgainstSchema(value[key], propSchema, `${path}.${key}`));
    }

    if (schema.additionalProperties === false) {
      for (const key of Object.keys(value)) {
        if (!(key in properties)) {
          errors.push(`${path}: additional key \"${key}\" is not allowed.`);
        }
      }
    }
  }

  if (isPlainObject(schema.items) && Array.isArray(value)) {
    value.forEach((item, index) => {
      errors.push(...validateAgainstSchema(item, schema.items as Record<string, unknown>, `${path}[${index}]`));
    });
  }

  return errors;
}

async function requestGemini(params: {
  apiKey: string;
  model: string;
  systemInstruction: string;
  userPayload: Record<string, unknown>;
  responseSchema?: Record<string, unknown> | null;
  timeoutMs: number;
}): Promise<Response> {
  const endpoint =
    `https://generativelanguage.googleapis.com/v1beta/models/${params.model}:generateContent?key=${params.apiKey}`;
  const sanitizedResponseSchema = sanitizeResponseSchemaForGemini(params.responseSchema);

  const payload: Record<string, unknown> = {
    system_instruction: {
      parts: [{ text: params.systemInstruction }],
    },
    contents: [
      {
        role: "user",
        parts: [{ text: JSON.stringify(params.userPayload) }],
      },
    ],
    generationConfig: {
      temperature: 0.6,
      responseMimeType: "application/json",
      ...(sanitizedResponseSchema ? { responseSchema: sanitizedResponseSchema } : {}),
    },
  };

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), params.timeoutMs);

  try {
    return await fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
      signal: controller.signal,
    });
  } catch (error) {
    if (error instanceof DOMException && error.name === "AbortError") {
      throw new AiGatewayError({
        code: "ai_timeout",
        message: "Gemini request timeout.",
        status: 504,
      });
    }
    throw new AiGatewayError({
      code: "ai_gateway_error",
      message: error instanceof Error ? error.message : "Gemini request failed.",
      status: 502,
    });
  } finally {
    clearTimeout(timer);
  }
}

function shouldRetryWithFallback(status: number): boolean {
  return status === 401 || status === 403 || status === 429;
}

export function isAiGatewayError(value: unknown): value is AiGatewayError {
  return value instanceof AiGatewayError;
}

export async function callGemini({
  model,
  systemInstruction,
  userPayload,
  responseSchema,
  timeoutMs = 25000,
}: {
  model: string;
  systemInstruction: string;
  userPayload: Record<string, unknown>;
  responseSchema?: Record<string, unknown> | null;
  timeoutMs?: number;
}): Promise<GeminiResult> {
  const apiKeys = getGeminiApiKeys();

  let lastStatus = 500;
  let lastBody = "";

  for (let index = 0; index < apiKeys.length; index += 1) {
    const apiKey = apiKeys[index];
    const response = await requestGemini({
      apiKey,
      model,
      systemInstruction,
      userPayload,
      responseSchema,
      timeoutMs,
    });

    if (!response.ok) {
      lastStatus = response.status;
      lastBody = await response.text();

      if (shouldRetryWithFallback(response.status) && index < apiKeys.length - 1) {
        continue;
      }

      if (shouldRetryWithFallback(response.status)) {
        throw new AiGatewayError({
          code: "ai_key_error",
          message: `Gemini key rejected (${response.status}).`,
          status: 502,
          details: lastBody,
        });
      }

      throw new AiGatewayError({
        code: "ai_gateway_error",
        message: `Gemini API error (${response.status}).`,
        status: 502,
        details: lastBody,
      });
    }

    const data = (await response.json()) as Record<string, any>;
    const candidateText =
      data?.candidates?.[0]?.content?.parts?.map((p: { text?: string }) => p.text ?? "").join("\n") ?? "{}";

    const outputJson = maybeParseJson(candidateText);

    if (responseSchema) {
      const validationErrors = validateAgainstSchema(outputJson, responseSchema);
      if (validationErrors.length > 0) {
        throw new AiGatewayError({
          code: "ai_schema_invalid",
          message: "Gemini output failed strict response schema validation.",
          status: 422,
          details: validationErrors,
        });
      }
    }

    const usageMeta = data?.usageMetadata ?? {};

    return {
      rawText: candidateText,
      json: outputJson,
      usage: {
        promptTokenCount: usageMeta.promptTokenCount ?? null,
        candidatesTokenCount: usageMeta.candidatesTokenCount ?? null,
        totalTokenCount: usageMeta.totalTokenCount ?? null,
      },
    };
  }

  throw new AiGatewayError({
    code: "ai_gateway_error",
    message: `Gemini API error (${lastStatus}).`,
    status: 502,
    details: lastBody,
  });
}
