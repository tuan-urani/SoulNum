import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

type AuthContext = {
  userId: string;
  userClient: SupabaseClient;
};

function getEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`Missing required env: ${name}`);
  }
  return value;
}

export function createServiceClient(): SupabaseClient {
  return createClient(
    getEnv("SUPABASE_URL"),
    getEnv("SUPABASE_SERVICE_ROLE_KEY"),
    {
      auth: {
        persistSession: false,
      },
    },
  );
}

export async function requireAuth(req: Request): Promise<AuthContext> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    throw new Error("Missing Authorization header.");
  }

  const userClient = createClient(
    getEnv("SUPABASE_URL"),
    getEnv("SUPABASE_ANON_KEY"),
    {
      global: {
        headers: {
          Authorization: authHeader,
        },
      },
      auth: {
        persistSession: false,
      },
    },
  );

  const { data, error } = await userClient.auth.getUser();
  if (error || !data.user) {
    throw new Error("Unauthorized");
  }

  return {
    userId: data.user.id,
    userClient,
  };
}

export async function requireCronSecret(req: Request): Promise<void> {
  const expected = getEnv("CRON_SECRET");
  const actual = req.headers.get("x-cron-secret");
  if (!actual || actual !== expected) {
    throw new Error("Unauthorized cron request.");
  }
}

