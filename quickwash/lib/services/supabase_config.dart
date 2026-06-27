class SupabaseConfig {
  /// The URL of your Supabase project (e.g., https://xyz.supabase.co)
  static const String url = 'https://your-project.supabase.co';

  /// The Anon/Public Key of your Supabase project
  static const String anonKey = 'your-anon-key';

  /// Helper utility to check if Supabase is configured with actual credentials
  static bool get isConfigured {
    return url != 'https://your-project.supabase.co' &&
        anonKey != 'your-anon-key' &&
        url.isNotEmpty &&
        anonKey.isNotEmpty;
  }
}
