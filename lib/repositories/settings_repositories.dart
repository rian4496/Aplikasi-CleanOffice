
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/agency_profile.dart';
import '../models/user_profile.dart';

// ==================== AGENCY REPOSITORY ====================
class AgencyRepository {
  final SupabaseClient _client;
  AgencyRepository(this._client);

  /// Fetch the single agency profile row
  Future<AgencyProfile?> getAgencyProfile() async {
    try {
      final data = await _client.from('agency_profiles').select().maybeSingle();
      if (data == null) return null;
      return AgencyProfile.fromJson(data);
    } catch (e) {
      // If table is empty or error, return null
      return null;
    }
  }

  /// Update or Insert (Upsert) the agency profile
  Future<AgencyProfile> upsertAgencyProfile(AgencyProfile profile) async {
    // If ID is empty, we remove it from map to let DB generate it, 
    // OR we use a Known ID strategy. For simplicity, we assume single row logic.
    // If existing row exists, update it. If not, insert.
    
    // Check if any row exists first
    final existing = await _client.from('agency_profiles').select('id').limit(1).maybeSingle();
    
    Map<String, dynamic> dataToSave = profile.toJson();
    
    if (existing != null) {
       // Update existing
       final id = existing['id'];
       // Remove ID from payload to avoid PK conflict if any
       dataToSave.remove('id');
       
       final response = await _client
          .from('agency_profiles')
          .update(dataToSave)
          .eq('id', id)
          .select()
          .single();
       return AgencyProfile.fromJson(response);
    } else {
      // Insert new
      // Remove empty ID if present
      if (profile.id.isEmpty) dataToSave.remove('id');
      
      final response = await _client
          .from('agency_profiles')
          .insert(dataToSave)
          .select()
          .single();
      return AgencyProfile.fromJson(response);
    }
  }
}

// ==================== USER REPOSITORY ====================
class UserRepository {
  final SupabaseClient _client;
  UserRepository(this._client);

  /// Get all user profiles (for admin table)
  Future<List<UserProfile>> getAllUsers() async {
    final data = await _client.from('profiles').select().order('created_at', ascending: false);
    return (data as List).map((x) => UserProfile.fromSupabase(x)).toList();
  }
  
  /// Get single user
  Future<UserProfile?> getUser(String uid) async {
    final data = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    if (data == null) return null;
    return UserProfile.fromSupabase(data);
  }

  /// Create or Update Profile
  Future<void> saveUserProfile(UserProfile user) async {
    await _client.from('profiles').upsert(user.toSupabase());
  }
  
  /// Admin: Update User Status/Role
  Future<void> updateUserStatus(String uid, {String? status, String? role}) async {
    final updates = <String, dynamic>{};
    if (status != null) updates['status'] = status;
    if (role != null) updates['role'] = role;
    
    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', uid);
    }
  }
  
  /// Create new user (Requires Auth Admin capability or public signup trigger)
  /// Note: Client-side creation of other users is tricky in Supabase without Admin API.
  /// For now, we assume this app uses standard Supabase Invite/Signup flow.
  /// This function updates the *Profile* data after Auth creation.
}
