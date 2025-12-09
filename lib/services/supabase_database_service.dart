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
          .from('inventory')
          .select()
          .order('name', ascending: true);

      final items = (response as List)
          .map((data) => InventoryItem.fromSupabase(data))
          .toList();

      _logger.info('✅ Loaded ${items.length} inventory items');
      yield items;
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
          .from('inventory')
          .select()
          .order('name', ascending: true);

      final allItems = (response as List)
          .map((data) => InventoryItem.fromSupabase(data))
          .toList();

      // Filter low stock items client-side (since Supabase doesn't support column comparison easily)
      final lowStockItems = allItems
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
}

