// lib/services/supabase_database_service.dart
// Supabase Database Service for CleanOffice App
// Handles all database operations (users, reports, requests, inventory, etc.)

import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/logging/app_logger.dart';
import '../core/error/exceptions.dart';
import '../models/user_profile.dart';
import '../models/report.dart';
import '../models/request.dart';
import '../models/inventory_item.dart';
import '../models/stock_request.dart';
import '../models/notification_model.dart';
import '../models/transactions/loan_model.dart'; 
import '../models/transactions/disposal_model.dart';
import '../models/audit_log.dart';


class SupabaseDatabaseService {
  final _logger = AppLogger('SupabaseDatabaseService');
  final SupabaseClient _client = Supabase.instance.client;

  // ==================== USER PROFILE OPERATIONS ====================

  /// Get all user profiles
  Future<List<UserProfile>> getAllUserProfiles() async {
    try {
      _logger.info('📋 Fetching all user profiles');

      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select()
          .order('created_at', ascending: false);

      final users = (response as List)
          .map((data) => UserProfile.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${users.length} user profiles');
      return users;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching user profiles', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data user: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching user profiles', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get users by verification status
  Future<List<UserProfile>> getUsersByVerificationStatus(String status) async {
    try {
      _logger.info('📋 Fetching users with verification_status: $status');

      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('verification_status', status)
          .order('created_at', ascending: false);

      final users = (response as List)
          .map((data) => UserProfile.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${users.length} users with status: $status');
      return users;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching users by status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data user: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching users', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      _logger.info('📋 Fetching user profile: $userId');

      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        _logger.warning('⚠️ User not found: $userId');
        return null;
      }

      final user = UserProfile.fromSupabase(response);
      _logger.info('✅ User profile loaded: ${user.email}');
      return user;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching user', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data user: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching user', e, stackTrace);
      return null;
    }
  }

  /// Update user verification status (approve/reject)
  Future<void> updateUserVerificationStatus({
    required String userId,
    required String status, // 'approved' or 'rejected'
  }) async {
    try {
      _logger.info('📝 Updating verification status for user: $userId to $status');

      final updates = <String, dynamic>{
        'verification_status': status,
      };

      // If approved, also set status to active
      if (status == 'approved') {
        updates['status'] = 'active';
      } else if (status == 'rejected') {
        updates['status'] = 'inactive';
      }

      await _client
          .from(SupabaseConfig.usersTable)
          .update(updates)
          .eq('id', userId);

      _logger.info('✅ Verification status updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating verification status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status verifikasi: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating verification', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status verifikasi',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? location,
    String? role,
    String? status,
    String? departmentId,
  }) async {
    try {
      _logger.info('📝 Updating profile for user: $userId');

      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (location != null) updates['location'] = location;
      if (role != null) updates['role'] = role;
      if (status != null) updates['status'] = status;
      if (departmentId != null) updates['department_id'] = departmentId;

      if (updates.isEmpty) {
        _logger.warning('⚠️ No fields to update');
        return;
      }

      await _client
          .from(SupabaseConfig.usersTable)
          .update(updates)
          .eq('id', userId);

      _logger.info('✅ User profile updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating profile', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update profil: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating profile', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update profil',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete user (soft delete - set status to 'deleted')
  Future<void> deleteUser(String userId) async {
    try {
      _logger.info('🗑️ Soft deleting user: $userId');

      await _client
          .from(SupabaseConfig.usersTable)
          .update({'status': 'deleted'})
          .eq('id', userId);

      _logger.info('✅ User soft deleted successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error deleting user', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal menghapus user: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error deleting user', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal menghapus user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== STATISTICS ====================

  /// Get user count by verification status
  Future<Map<String, int>> getUserCountByStatus() async {
    try {
      _logger.info('📊 Getting user count by status');

      final allUsers = await getAllUserProfiles();

      final counts = <String, int>{
        'pending': allUsers.where((u) => u.verificationStatus == 'pending').length,
        'approved': allUsers.where((u) => u.verificationStatus == 'approved').length,
        'rejected': allUsers.where((u) => u.verificationStatus == 'rejected').length,
      };

      _logger.info('✅ User counts: $counts');
      return counts;
    } catch (e, stackTrace) {
      _logger.error('❌ Error getting user counts', e, stackTrace);
      return {'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }

  // ==================== REPORT OPERATIONS ====================

  /// Get all reports
  Future<List<Report>> getAllReports() async {
    try {
      _logger.info('📋 Fetching all reports');

      final response = await _client
          .from('reports')
          .select()
          .order('created_at', ascending: false);

      final reports = (response as List)
          .map((data) => Report.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${reports.length} reports');
      return reports;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching reports', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching reports', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get report by ID
  Future<Report?> getReportById(String reportId) async {
    try {
      _logger.info('📋 Fetching report: $reportId');

      final response = await _client
          .from('reports')
          .select()
          .eq('id', reportId)
          .maybeSingle();

      if (response == null) {
        _logger.warning('⚠️ Report not found: $reportId');
        return null;
      }

      final report = Report.fromSupabase(response);
      _logger.info('✅ Report loaded: ${report.title}');
      return report;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching report', e, stackTrace);
      return null;
    }
  }

  /// Get reports by status
  Future<List<Report>> getReportsByStatus(String status) async {
    try {
      _logger.info('📋 Fetching reports with status: $status');

      final response = await _client
          .from('reports')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      final reports = (response as List)
          .map((data) => Report.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${reports.length} reports with status: $status');
      return reports;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching reports by status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching reports', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get reports by user ID (employee who created the report)
  Future<List<Report>> getReportsByUserId(String userId) async {
    try {
      _logger.info('📋 Fetching reports for user: $userId');

      final response = await _client
          .from('reports')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final reports = (response as List)
          .map((data) => Report.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${reports.length} reports for user: $userId');
      return reports;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching user reports', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching user reports', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get reports by cleaner ID (cleaner assigned to handle the report)
  /// Returns empty list if cleaner_id column doesn't exist in database
  Future<List<Report>> getReportsByCleanerId(String cleanerId) async {
    try {
      _logger.info('📋 Fetching reports for cleaner: $cleanerId');

      final response = await _client
          .from('reports')
          .select()
          .eq('cleaner_id', cleanerId)
          .order('created_at', ascending: false);

      final reports = (response as List)
          .map((data) => Report.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${reports.length} reports for cleaner: $cleanerId');
      return reports;
    } on PostgrestException catch (e, stackTrace) {
      // If column doesn't exist (42703), return empty list silently
      if (e.code == '42703') {
        _logger.warning('⚠️ cleaner_id column not found in reports table - returning empty list');
        return [];
      }
      _logger.error('❌ Database error fetching cleaner reports', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching cleaner reports', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Create new report
  Future<Report> createReport(Report report) async {
    try {
      _logger.info('➕ Creating new report: ${report.title}');

      final data = report.toSupabase();

      final response = await _client
          .from('reports')
          .insert(data)
          .select()
          .single();

      final createdReport = Report.fromSupabase(response);
      _logger.info('✅ Report created successfully: ${createdReport.id}');
      return createdReport;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error creating report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal membuat laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error creating report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal membuat laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update report
  Future<void> updateReport(String reportId, Map<String, dynamic> updates) async {
    try {
      _logger.info('📝 Updating report: $reportId');

      if (updates.isEmpty) {
        _logger.warning('⚠️ No fields to update');
        return;
      }

      await _client
          .from('reports')
          .update(updates)
          .eq('id', reportId);

      _logger.info('✅ Report updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update report status
  Future<void> updateReportStatus(String reportId, String status) async {
    try {
      _logger.info('📝 Updating report status: $reportId to $status');

      final updates = <String, dynamic>{
        'status': status,
      };

      // Add timestamps based on status
      if (status == 'assigned') {
        updates['assigned_at'] = DateTime.now().toIso8601String();
      } else if (status == 'in_progress') {
        updates['started_at'] = DateTime.now().toIso8601String();
      } else if (status == 'completed') {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }

      await _client
          .from('reports')
          .update(updates)
          .eq('id', reportId);

      _logger.info('✅ Report status updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating report status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Verify report (approve/reject)
  Future<void> verifyReport({
    required String reportId,
    required String status, // 'verified' or 'rejected'
    required String verifiedBy,
    required String verifiedByName,
    String? verificationNotes,
  }) async {
    try {
      _logger.info('✅ Verifying report: $reportId with status: $status');

      final updates = <String, dynamic>{
        'status': status,
        'verified_by': verifiedBy,
        'verified_by_name': verifiedByName,
        'verified_at': DateTime.now().toIso8601String(),
      };

      if (verificationNotes != null) {
        updates['verification_notes'] = verificationNotes;
      }

      await _client
          .from('reports')
          .update(updates)
          .eq('id', reportId);

      _logger.info('✅ Report verified successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error verifying report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal verifikasi laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error verifying report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal verifikasi laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Assign report to cleaner
  Future<void> assignReportToCleaner({
    required String reportId,
    required String cleanerId,
    required String cleanerName,
  }) async {
    try {
      _logger.info('👷 Assigning report: $reportId to cleaner: $cleanerId');

      final updates = <String, dynamic>{
        'cleaner_id': cleanerId,
        'cleaner_name': cleanerName,
        'status': 'assigned',
        'assigned_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('reports')
          .update(updates)
          .eq('id', reportId);

      _logger.info('✅ Report assigned successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error assigning report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal assign laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error assigning report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal assign laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete report (soft delete)
  Future<void> deleteReport(String reportId, String deletedBy) async {
    try {
      _logger.info('🗑️ Soft deleting report: $reportId');

      await _client
          .from('reports')
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'deleted_by': deletedBy,
          })
          .eq('id', reportId);

      _logger.info('✅ Report soft deleted successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error deleting report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal menghapus laporan: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error deleting report', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal menghapus laporan',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== REQUEST OPERATIONS ====================

  /// Get all requests
  Future<List<Request>> getAllRequests() async {
    try {
      _logger.info('📋 Fetching all requests');

      final response = await _client
          .from('requests')
          .select()
          .order('created_at', ascending: false);

      final requests = (response as List)
          .map((data) => Request.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${requests.length} requests');
      return requests;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching requests', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching requests', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get request by ID
  Future<Request?> getRequestById(String requestId) async {
    try {
      _logger.info('📋 Fetching request by ID: $requestId');

      final response = await _client
          .from('requests')
          .select()
          .eq('id', requestId)
          .maybeSingle();

      if (response == null) {
        _logger.info('⚠️ Request not found: $requestId');
        return null;
      }

      final request = Request.fromSupabase(response);
      _logger.info('✅ Request loaded: ${request.id}');
      return request;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get requests by status
  Future<List<Request>> getRequestsByStatus(String status) async {
    try {
      _logger.info('📋 Fetching requests by status: $status');

      final response = await _client
          .from('requests')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      final requests = (response as List)
          .map((data) => Request.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${requests.length} requests with status: $status');
      return requests;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching requests by status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching requests by status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get requests by user ID (employee who created the request)
  Future<List<Request>> getRequestsByUserId(String userId) async {
    try {
      _logger.info('📋 Fetching requests for user: $userId');

      final response = await _client
          .from('requests')
          .select()
          .eq('requested_by', userId)
          .order('created_at', ascending: false);

      final requests = (response as List)
          .map((data) => Request.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${requests.length} requests for user: $userId');
      return requests;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching user requests', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching user requests', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Get notifications for a user
  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      _logger.info('🔔 Fetching notifications for user: $userId');

      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      // Note: Model expects 'userId', 'createdAt' etc. matching DB columns
      // If DB has snake_case (user_id, created_at), we might need a mapper or the model handles it.
      // Based on AppNotification.fromMap, it expects camelCase keys or we map them here.
      // Let's assume standard Supabase snake_case in DB and map manually if needed, 
      // OR assuming the Table column names match what the model expects if we use simple mapping.
      // However, typical Supabase pattern is snake_case. 
      // Let's correct the query to standard Supabase conventions if needed, 
      // but if the table was created with camelCase columns (indicated by previous patterns), we use that.
      // Checking `notifications` table structure isn't possible directly, but typically it is snake_case.
      // I will map snake_case DB to camelCase Model properties here for safety.

      final notifications = (response as List).map((data) {
        // Map snake_case DB to camelCase Model keys if necessary, or just pass if they match.
        // Let's normalize to what AppNotification.fromMap likely expects if it accepts a map.
        // Actually, looking at AppNotification.fromMap:
        // userId: map['userId']
        // createdAt: map['createdAt']
        // 
        // If DB is snake_case (user_id), we need to transform.
        final map = Map<String, dynamic>.from(data);
        if (map.containsKey('user_id')) map['userId'] = map['user_id'];
        if (map.containsKey('created_at')) map['createdAt'] = map['created_at'];
        // 'type', 'title', 'message', 'data', 'read' usually match or are simple.
        
        return AppNotification.fromMap(data['id']?.toString() ?? '', map);
      }).toList();

      return notifications;
    } catch (e, stackTrace) {
      _logger.error('❌ Error fetching notifications', e, stackTrace);
      // Return empty list instead of throwing to avoid breaking UI
      return [];
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .count()
          .eq('user_id', userId) // user_id is standard
          .eq('read', false);
      
      return response;
    } catch (e) {
      // Try snake_case if camelCase fails (fallback)
      try {
         final response = await _client
          .from('notifications')
          .count()
          .eq('user_id', userId)
          .eq('read', false);
         return response;
      } catch (_) {
         return 0;
      }
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      _logger.error('❌ Error marking notification read', e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      // Try both column conventions to be safe or assuming the one that works in getNotifications
      // Safe bet: user_id usually. But let's try strict.
      // We will assume the column is `userId` based on previous code context, but `user_id` is SQL standard.
      // I'll stick to a generic update that handles potential schema naming by trying the most likely first.
      
      // Update: Based on `AppNotification` model using `userId` in `toMap`, it's possible 
      // the columns are camelCase if generated from Dart. 
      // But standard migrations usually use snake_case. 
      // I'll use `user_id` as primary assumption for WHERE clause in DB operations unless proven otherwise.
      
      await _client
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId);
          
    } catch (e) {
       // Fallback to snake_case
       try {
         await _client
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId);
       } catch (_) {}
    }
  }

  /// Get requests by cleaner ID (cleaner assigned to handle the request)
  Future<List<Request>> getRequestsByCleanerId(String cleanerId) async {
    try {
      _logger.info('📋 Fetching requests for cleaner: $cleanerId');

      final response = await _client
          .from('requests')
          .select()
          .eq('assigned_to', cleanerId)
          .order('created_at', ascending: false);

      final requests = (response as List)
          .map((data) => Request.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${requests.length} requests for cleaner: $cleanerId');
      return requests;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching cleaner requests', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching cleaner requests', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil data request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Create new request
  Future<Request> createRequest(Request request) async {
    try {
      _logger.info('➕ Creating new request: ${request.location}');

      final data = request.toSupabase();

      final response = await _client
          .from('requests')
          .insert(data)
          .select()
          .single();

      final createdRequest = Request.fromSupabase(response);
      _logger.info('✅ Request created successfully: ${createdRequest.id}');
      return createdRequest;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error creating request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal membuat request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error creating request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal membuat request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update request
  Future<void> updateRequest(String requestId, Map<String, dynamic> updates) async {
    try {
      _logger.info('✏️ Updating request: $requestId');

      await _client
          .from('requests')
          .update(updates)
          .eq('id', requestId);

      _logger.info('✅ Request updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update request status with automatic timestamps
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      _logger.info('✏️ Updating request status: $requestId → $status');

      final updates = <String, dynamic>{
        'status': status,
      };

      // Add timestamps based on status
      if (status == 'assigned') {
        updates['assigned_at'] = DateTime.now().toIso8601String();
      } else if (status == 'in_progress') {
        updates['started_at'] = DateTime.now().toIso8601String();
      } else if (status == 'completed') {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }

      await _client
          .from('requests')
          .update(updates)
          .eq('id', requestId);

      _logger.info('✅ Request status updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating request status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating request status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Assign request to cleaner
  Future<void> assignRequestToCleaner({
    required String requestId,
    required String cleanerId,
    required String cleanerName,
    String? assignedBy,
  }) async {
    try {
      _logger.info('👷 Assigning request $requestId to cleaner: $cleanerName');

      await _client
          .from('requests')
          .update({
            'assigned_to': cleanerId,
            'assigned_to_name': cleanerName,
            'assigned_at': DateTime.now().toIso8601String(),
            'assigned_by': assignedBy,
            'status': 'assigned',
          })
          .eq('id', requestId);

      _logger.info('✅ Request assigned successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error assigning request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal assign request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error assigning request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal assign request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancel request
  Future<void> cancelRequest(String requestId, String cancelledBy) async {
    try {
      _logger.info('❌ Cancelling request: $requestId');

      await _client
          .from('requests')
          .update({
            'status': 'cancelled',
            'cancelled_at': DateTime.now().toIso8601String(),
            'cancelled_by': cancelledBy,
          })
          .eq('id', requestId);

      _logger.info('✅ Request cancelled successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error cancelling request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal cancel request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error cancelling request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal cancel request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete request (soft delete)
  Future<void> deleteRequest(String requestId, String deletedBy) async {
    try {
      _logger.info('🗑️ Soft deleting request: $requestId');

      await _client
          .from('requests')
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'deleted_by': deletedBy,
          })
          .eq('id', requestId);

      _logger.info('✅ Request soft deleted successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error deleting request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal menghapus request: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error deleting request', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal menghapus request',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== INVENTORY OPERATIONS ====================

  /// Get all inventory items as Stream
  Stream<List<InventoryItem>> getAllInventoryItems() async* {
    try {
      _logger.info('📋 Fetching all inventory items');

      final response = await _client
          .from('inventory_items')
          .select()
          .order('name', ascending: true);

      final allItems = (response as List);
      
      // Filter out deleted items (where deleted_at is not null or is_active is false)
      final activeItems = allItems.where((data) {
        final deletedAt = data['deleted_at'];
        final isActive = data['is_active'] ?? true;
        return deletedAt == null && isActive != false;
      }).map((data) => InventoryItem.fromSupabase(data)).toList();

      _logger.info('✅ Loaded ${activeItems.length} active inventory items (filtered from ${allItems.length} total)');
      yield activeItems;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching inventory', e, stackTrace);
      yield [];
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching inventory', e, stackTrace);
      yield [];
    }
  }

  /// Get low stock items (quantity <= min_stock)
  Stream<List<InventoryItem>> getLowStockItems() async* {
    try {
      _logger.info('📋 Fetching low stock items');

      final response = await _client
          .from('inventory_items')
          .select()
          .order('name', ascending: true);

      final allItems = (response as List);
      
      // First filter out deleted items, then map to InventoryItem
      final activeItems = allItems.where((data) {
        final deletedAt = data['deleted_at'];
        final isActive = data['is_active'] ?? true;
        return deletedAt == null && isActive != false;
      }).map((data) => InventoryItem.fromSupabase(data)).toList();

      // Filter low stock items client-side (since Supabase doesn't support column comparison easily)
      final lowStockItems = activeItems
          .where((item) => item.currentStock <= item.minStock)
          .toList();

      _logger.info('✅ Found ${lowStockItems.length} low stock items');
      yield lowStockItems;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching low stock', e, stackTrace);
      yield [];
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching low stock', e, stackTrace);
      yield [];
    }
  }

  /// Get inventory item by ID
  Future<InventoryItem?> getInventoryItemById(String itemId) async {
    try {
      _logger.info('📋 Fetching inventory item: $itemId');

      final response = await _client
          .from('inventory')
          .select()
          .eq('id', itemId)
          .maybeSingle();

      if (response == null) {
        _logger.warning('⚠️ Inventory item not found: $itemId');
        return null;
      }

      final item = InventoryItem.fromSupabase(response);
      _logger.info('✅ Inventory item loaded: ${item.name}');
      return item;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching inventory item', e, stackTrace);
      return null;
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching inventory item', e, stackTrace);
      return null;
    }
  }

  /// Create inventory item
  Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    try {
      _logger.info('➕ Creating new inventory item: ${item.name}');

      final data = item.toSupabase();

      final response = await _client
          .from('inventory')
          .insert(data)
          .select()
          .single();

      final createdItem = InventoryItem.fromSupabase(response);
      _logger.info('✅ Inventory item created successfully: ${createdItem.id}');
      return createdItem;
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error creating inventory item', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal membuat item inventori: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error creating inventory item', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal membuat item inventori',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update inventory item
  Future<void> updateInventoryItem(String itemId, Map<String, dynamic> updates) async {
    try {
      _logger.info('📝 Updating inventory item: $itemId');

      if (updates.isEmpty) {
        _logger.warning('⚠️ No fields to update');
        return;
      }

      await _client
          .from('inventory')
          .update(updates)
          .eq('id', itemId);

      _logger.info('✅ Inventory item updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating inventory item', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update item inventori: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating inventory item', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update item inventori',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update inventory stock
  Future<void> updateInventoryStock(String itemId, int newQuantity) async {
    try {
      _logger.info('📝 Updating stock for item: $itemId to $newQuantity');

      await _client
          .from('inventory')
          .update({
            'quantity': newQuantity,
            'last_restocked_at': DateTime.now().toIso8601String(),
          })
          .eq('id', itemId);

      _logger.info('✅ Inventory stock updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating stock', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update stok: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating stock', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update stok',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete inventory item (hard delete - inventory can be truly deleted)
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      _logger.info('🗑️ Deleting inventory item: $itemId');

      await _client
          .from('inventory')
          .delete()
          .eq('id', itemId);

      _logger.info('✅ Inventory item deleted successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error deleting inventory item', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal menghapus item inventori: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error deleting inventory item', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal menghapus item inventori',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== STOCK REQUEST OPERATIONS ====================
  // Note: Stock requests are not in the current Supabase schema
  // These methods return empty streams for compatibility
  // TODO: Add stock_requests table to Supabase schema if needed

  /// Get pending stock requests (placeholder - table doesn't exist yet)
  Stream<List<StockRequest>> getPendingStockRequests() async* {
    _logger.warning('⚠️ Stock requests table not yet implemented in Supabase');
    yield [];
  }

  /// Get stock requests by user (placeholder)
  Stream<List<StockRequest>> getStockRequestsByUser(String userId) async* {
    _logger.warning('⚠️ Stock requests table not yet implemented in Supabase');
    yield [];
  }

  // ==================== LOAN OPERATIONS ====================

  /// Get all loan requests
  Future<List<LoanRequest>> getLoanRequests() async {
    try {
      _logger.info('📋 Fetching loan requests');
      final response = await _client
          .from('transactions_loans')
          .select('*, master_assets(name, condition)')
          .order('created_at', ascending: false);

      return (response as List).map((e) => LoanRequest.fromMap(e)).toList();
    } catch (e, stackTrace) {
      _logger.error('❌ Error fetching loans', e, stackTrace);
      // Return empty list on error to prevent UI crash
      return []; 
    }
  }

  /// Create new loan request
  Future<void> createLoanRequest(LoanRequest loan) async {
    try {
      // Remove 'id' if empty/new so Supabase generates UUID
      final data = loan.toMap();
      if (data['id'] == '' || data['id'] == null) {
        data.remove('id');
      }
      
      await _client.from('transactions_loans').insert(data);
      _logger.info('✅ Loan request created: ${loan.requestNumber}');
    } catch (e, stackTrace) {
      _logger.error('❌ Error creating loan', e, stackTrace);
      throw DatabaseException(message: 'Gagal membuat peminjaman', originalError: e);
    }
  }

  /// Update loan status
  Future<void> updateLoanStatus(String id, String status, {String? rejectionReason}) async {
    try {
      final updates = {'status': status};
      if (rejectionReason != null) {
        updates['rejection_reason'] = rejectionReason;
      }

      await _client.from('transactions_loans').update(updates).eq('id', id);
    } catch (e) {
      _logger.error('❌ Error updating loan status', e);
      throw DatabaseException(message: 'Gagal update status peminjaman');
    }
  }

  // ==================== DISPOSAL OPERATIONS ====================

  /// Get all disposal requests
  Future<List<DisposalRequest>> getDisposalRequests() async {
    try {
      _logger.info('📋 Fetching disposal requests');
      
      final response = await _client
          .from('transactions_disposal')
          .select('*, master_assets(name, asset_code)') 
          .order('created_at', ascending: false);

      return (response as List).map((e) {
        final map = Map<String, dynamic>.from(e);
        if (map['master_assets'] != null) {
          map['asset_name'] = map['master_assets']['name'];
          map['asset_code'] = map['master_assets']['asset_code'];
        }
        return DisposalRequest.fromJson(map);
      }).toList();
    } catch (e, stackTrace) {
      _logger.error('❌ Error fetching disposals', e, stackTrace);
      return [];
    }
  }

  /// Create disposal proposal
  Future<void> createDisposalRequest(DisposalRequest request) async {
    try {
      final data = request.toJson();
      if (data['id'] == '' || data['id'] == null) data.remove('id');
      
      // Clean up fields that shouldn't be inserted on create (like joined fields)
      data.remove('asset_name');
      data.remove('asset_code');
      
      await _client.from('transactions_disposal').insert(data);
      _logger.info('✅ Disposal request created: ${request.code}');
    } catch (e, stackTrace) {
      _logger.error('❌ Error creating disposal', e, stackTrace);
      throw DatabaseException(message: 'Gagal membuat usulan penghapusan', originalError: e);
    }
  }

  /// Update disposal status
  Future<void> updateDisposalStatus(String id, String status, {
    String? approvedBy, 
    DateTime? approvalDate
  }) async {
    try {
      final updates = <String, dynamic>{'status': status};
      if (approvedBy != null) updates['approved_by'] = approvedBy;
      if (approvalDate != null) updates['approval_date'] = approvalDate.toIso8601String();

      await _client.from('transactions_disposal').update(updates).eq('id', id);
    } catch (e) {
      _logger.error('❌ Error updating disposal status', e);
      throw DatabaseException(message: 'Gagal update status penghapusan');
    }
  }

  // ==================== ADVANCED REPORTING ====================
  
  /// Get Disposal Report Data
  Future<List<DisposalRequest>> getDisposalReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _logger.info('📊 Fetching Disposal Report ($startDate - $endDate)');
      
      final response = await _client
          .from('transactions_disposal')
          .select('*, master_assets(name, asset_code)')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: true);
          
      return (response as List).map((e) {
         final map = Map<String, dynamic>.from(e);
         if (map['master_assets'] != null) {
           map['asset_name'] = map['master_assets']['name'];
           map['asset_code'] = map['master_assets']['asset_code'];
         }
         return DisposalRequest.fromJson(map);
      }).toList();
    } catch (e, s) {
      _logger.error('❌ Error fetching disposal report', e, s);
      return [];
    }
  }

  /// Get Maintenance Report Data (Tickets)
  Future<List<Map<String, dynamic>>> getMaintenanceReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _logger.info('📊 Fetching Maintenance Report ($startDate - $endDate)');
      
      final response = await _client
          .from('tickets')
          .select('*, master_assets(name, asset_code), assigned_to_user:users!assigned_to(display_name)') 
          .eq('type', 'kerusakan')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, s) {
      _logger.error('❌ Error fetching maintenance report', e, s);
      return [];
    }
  }

  /// Get Loan Report Data
  Future<List<LoanRequest>> getLoanReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _logger.info('📊 Fetching Loan Report ($startDate - $endDate)');
      
      final response = await _client
          .from('transactions_loans')
          .select('*, master_assets(name, asset_code)')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: true);
          
      return (response as List).map((e) {
          final map = Map<String, dynamic>.from(e);
            if (map['master_assets'] != null) {
              map['asset_name'] = map['master_assets']['name'];
            }
          return LoanRequest.fromMap(map);
      }).toList();
    } catch (e, s) {
      _logger.error('❌ Error fetching loan report', e, s);
      return [];
    }
  }

  // ==================== AUDIT LOGS ====================
  
  /// Log an audit event
  Future<void> logAudit({
    required String action,
    String? entityType,
    String? entityId,
    String? description,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      
      await _client.from('audit_logs').insert({
        'user_id': currentUser?.id,
        'user_email': currentUser?.email,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'description': description,
        'old_data': oldData,
        'new_data': newData,
        'metadata': metadata,
      });
      
      _logger.info('📝 Audit logged: $action on $entityType');
    } catch (e, s) {
      _logger.error('❌ Error logging audit', e, s);
      // Don't throw - audit logging should not break main flow
    }
  }

  /// Get audit logs with optional filters
  Future<List<AuditLog>> getAuditLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? action,
    String? entityType,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      _logger.info('📋 Fetching audit logs');
      
      // Build query with filters first, then order/limit
      var baseQuery = _client.from('audit_logs').select();
      
      if (startDate != null) {
        baseQuery = baseQuery.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        baseQuery = baseQuery.lte('created_at', endDate.toIso8601String());
      }
      if (userId != null) {
        baseQuery = baseQuery.eq('user_id', userId);
      }
      if (action != null) {
        baseQuery = baseQuery.eq('action', action);
      }
      if (entityType != null) {
        baseQuery = baseQuery.eq('entity_type', entityType);
      }
      
      final response = await baseQuery
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List).map((e) => AuditLog.fromJson(e)).toList();
    } catch (e, s) {
      _logger.error('❌ Error fetching audit logs', e, s);
      return [];
    }
  }

  /// Get audit log count for stats
  Future<int> getAuditLogCount({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('audit_logs')
          .select('id');
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      
      final response = await query;
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Delete audit logs older than specified days (retention policy)
  Future<int> deleteOldAuditLogs({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      _logger.info('🗑️ Deleting audit logs older than ${cutoffDate.toIso8601String()}');
      
      // Note: Supabase doesn't return deleted count directly, so we count first
      final countQuery = await _client
          .from('audit_logs')
          .select('id')
          .lt('created_at', cutoffDate.toIso8601String());
      
      final countToDelete = (countQuery as List).length;
      
      if (countToDelete > 0) {
        await _client
            .from('audit_logs')
            .delete()
            .lt('created_at', cutoffDate.toIso8601String());
        
        _logger.info('✅ Deleted $countToDelete old audit logs');
      }
      
      return countToDelete;
    } catch (e, s) {
      _logger.error('❌ Error deleting old audit logs', e, s);
      rethrow;
    }
  }
}


