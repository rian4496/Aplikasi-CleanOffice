// lib/core/config/supabase_config.dart
// Supabase Configuration for CleanOffice App

class SupabaseConfig {
  // Project URL and Keys
  static const String supabaseUrl = 'https://nrbijfhtkigszvibminy.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYmlqZmh0a2lnc3p2aWJtaW55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ3NTQ1NTksImV4cCI6MjA4MDMzMDU1OX0.FEfz1IC4WYH5jYAzn-4PjOFdqvEp6sF_uwoRongKlVQ';

  // Table Names
  static const String usersTable = 'users';
  static const String reportsTable = 'reports';
  static const String requestsTable = 'requests';
  static const String departmentsTable = 'departments';
  static const String inventoryTable = 'inventory';
  static const String chatsTable = 'chats';
  static const String messagesTable = 'messages';
  static const String notificationsTable = 'notifications';

  // Storage Buckets
  static const String reportImagesBucket = 'report_images';
  static const String profileImagesBucket = 'profile_images';
  static const String inventoryImagesBucket = 'inventory_images'; // Changed to match user's bucket (underscore)

  // Realtime Channels
  static const String reportsChannel = 'public:reports';
  static const String requestsChannel = 'public:requests';
  static const String chatsChannel = 'public:chats';
  static const String messagesChannel = 'public:messages';
  static const String notificationsChannel = 'public:notifications';
}

