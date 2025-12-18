
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import 'settings_providers.dart';

// AsyncNotifier: Loads all users from DB
class UserListNotifier extends AsyncNotifier<List<UserProfile>> {
  @override
  Future<List<UserProfile>> build() async {
    final repo = ref.read(userRepositoryProvider);
    return await repo.getAllUsers();
  }

  // Reload list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(userRepositoryProvider).getAllUsers();
    });
  }
}

final userListProvider = AsyncNotifierProvider<UserListNotifier, List<UserProfile>>(() {
  return UserListNotifier();
});
