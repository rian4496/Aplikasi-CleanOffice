
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/user_role.dart';
import '../../models/user_profile.dart';

// ==================== MOCK AUTH PROVIDERS ====================
// These are for testing/development only. In production, use auth_providers.dart

// 1. Provider for "Current User ID" (Mock)
final mockUserIdProvider = Provider<String>((ref) => 'mock-user-123');

// 2. Notifier for "Current User Role" (Mock - can be changed via Debug Switcher)
class MockRoleNotifier extends Notifier<String> {
  @override
  String build() => UserRole.admin;
  
  void setRole(String newRole) {
    state = newRole;
  }
}

final mockUserRoleProvider = NotifierProvider<MockRoleNotifier, String>(
  MockRoleNotifier.new,
);

// 3. Computed "Current User Profile" (Mock)
// Returns a dummy profile with the selected Role
final mockUserProfileProvider = Provider<UserProfile>((ref) {
  final role = ref.watch(mockUserRoleProvider);
  
  return UserProfile(
    uid: 'mock-user-123',
    displayName: 'Mock User (${UserRole.getRoleDisplayName(role)})',
    email: 'mock@dinas.go.id',
    role: role,
    joinDate: DateTime.now(),
    departmentId: 'UMUM',
    status: 'active',
  );
});

// Legacy aliases for backward compatibility
final currentUserIdProvider = mockUserIdProvider;
final currentUserRoleProvider = mockUserRoleProvider;
final currentUserProvider = mockUserProfileProvider;
