import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientFactory {
  const SupabaseClientFactory();

  SupabaseClient get client => Supabase.instance.client;
}

