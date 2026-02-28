export async function sha256Hex(input: unknown): Promise<string> {
  const normalized = typeof input === "string" ? input : JSON.stringify(input);
  const bytes = new TextEncoder().encode(normalized);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

