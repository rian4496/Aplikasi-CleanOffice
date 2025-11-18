// lib/screens/shared/reset_password_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
// Screen for handling password reset requests through Firebase Auth

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

/// Screen for handling password reset requests through Firebase Auth.
///
/// This screen allows users to:
/// - Enter their email address (or uses pre-filled email)
/// - Request a password reset link
/// - See confirmation when the reset link is sent
/// - Handle various error cases with clear feedback
///
/// ✅ MIGRATED: StatefulWidget → HookConsumerWidget
class ResetPasswordScreen extends HookConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // ✅ HOOKS: Auto-disposed email controller
    final emailController = useTextEditingController();

    // ✅ HOOKS: Logger
    final logger = useMemoized(() => Logger('ResetPasswordScreen'));

    // ✅ HOOKS: State management
    final isLoading = useState(false);
    final resetEmailSent = useState(false);

    // ✅ HOOKS: Handle initial email from navigation arguments
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final initialEmail = ModalRoute.of(context)?.settings.arguments as String?;
        if (initialEmail != null) {
          emailController.text = initialEmail;
        }
      });
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Icon(Icons.lock_reset, size: 64, color: Colors.grey[800]),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Masukkan email Anda untuk menerima link reset password',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (!resetEmailSent.value) ...[
                    // Email Field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _resetPassword(
                        context,
                        formKey,
                        emailController,
                        isLoading,
                        resetEmailSent,
                        logger,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Reset Button
                    ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : () => _resetPassword(
                                context,
                                formKey,
                                emailController,
                                isLoading,
                                resetEmailSent,
                                logger,
                              ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.indigo[600],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.indigo[200],
                      ),
                      child: isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Kirim Link Reset',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ] else ...[
                    // Success Message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Email Terkirim!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silakan cek email Anda untuk link reset password',
                            style: TextStyle(color: Colors.green[800]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Back to Login Button
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Kembali ke Login'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== STATIC HELPER: RESET PASSWORD ====================

  /// Handle password reset request
  static Future<void> _resetPassword(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    ValueNotifier<bool> isLoading,
    ValueNotifier<bool> resetEmailSent,
    Logger logger,
  ) async {
    if (isLoading.value) return;

    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      logger.info('Attempting to send password reset email');
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!context.mounted) return;

      resetEmailSent.value = true;

      logger.info('Password reset email sent successfully');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email reset password telah dikirim'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      logger.warning('Password reset failed', e);
      if (!context.mounted) return;

      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar';
          break;
        case 'too-many-requests':
          errorMessage = 'Terlalu banyak permintaan. Silakan coba lagi nanti';
          break;
        default:
          errorMessage =
              e.message ?? 'Terjadi kesalahan saat mengirim email reset';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      logger.severe('Unexpected error during password reset', e);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Terjadi kesalahan yang tidak terduga'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'DETAIL',
            textColor: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('TUTUP'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
