class SupabaseConfig {
  /// The URL of your Supabase project (e.g., https://xyz.supabase.co)
  static const String url = 'https://kyeylwlnqszpjuaugiep.supabase.co';

  /// The Anon/Public Key of your Supabase project
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5ZXlsd2xucXN6cGp1YXVnaWVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1NDc2MTEsImV4cCI6MjA5ODEyMzYxMX0.umTWjav8iCqJUTlyaVDcRZyhAV4KE5jyG7VaTkNAODU';

  /// Helper utility to check if Supabase is configured with actual credentials
  static bool get isConfigured {
    return url != 'https://your-project.supabase.co' &&
        anonKey != 'your-anon-key' &&
        url.isNotEmpty &&
        anonKey.isNotEmpty;
  }
}
