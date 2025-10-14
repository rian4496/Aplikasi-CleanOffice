import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Changes the current user's password.
  ///
  /// Throws a [FirebaseAuthException] on failure from Firebase.
  /// Throws a generic [Exception] if the user is not found.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final userEmail = user?.email;

    if (user == null || userEmail == null) {
      throw Exception('Pengguna tidak ditemukan. Silahkan login kembali.');
    }

    // Re-authenticate user before changing password
    final credential = EmailAuthProvider.credential(
      email: userEmail,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}