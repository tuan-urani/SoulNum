export const CORS_HEADERS: HeadersInit = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-cron-secret",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Content-Type": "application/json",
};

export function handleOptions(req: Request): Response | null {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  return null;
}

export function ok(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: CORS_HEADERS,
  });
}

export function fail(message: string, status = 400, details?: unknown): Response {
  return new Response(
    JSON.stringify({
      error: message,
      details: details ?? null,
    }),
    {
      status,
      headers: CORS_HEADERS,
    },
  );
}

export async function readJson<T>(req: Request): Promise<T> {
  return (await req.json()) as T;
}

