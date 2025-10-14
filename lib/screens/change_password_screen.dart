import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_password_field.dart';
import '../providers/riverpod/auth_providers.dart';


/// Modern Change Password Screen
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengubah widget menjadi Consumer untuk mengakses ref
    return Consumer(builder: (context, ref, child) {
      // Listener untuk menangani side-effects (SnackBar, Navigasi)
      ref.listen<AsyncValue<void>>(authActionsProvider, (previous, next) {
        next.when(
          error: (error, stackTrace) {
            String message;
            if (error is FirebaseAuthException) {
              switch (error.code) {
                case 'wrong-password':
                case 'user-mismatch':
                  message = 'Password saat ini salah';
                  break;
                case 'weak-password':
                  message = 'Password baru terlalu lemah';
                  break;
                default:
                  message = 'Terjadi kesalahan. Silahkan coba lagi.';
              }
            } else {
              message = 'Terjadi kesalahan yang tidak diketahui.';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          data: (_) {
            // Hanya tampilkan snackbar jika state sebelumnya tidak null (bukan state awal)
            if (previous != null && !previous.isLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Password berhasil diubah'),
                    ],
                  ),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            }
          },
          loading: () {}, // Tidak perlu melakukan apa-apa saat loading
        );
      });

      // Mendapatkan state saat ini untuk mengontrol UI
      final state = ref.watch(authActionsProvider);
      final isChanging = state.isLoading;

      return Scaffold(
        appBar: AppBar(title: const Text('Ubah Password'), backgroundColor: Colors.indigo[800]),
        body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2.0,
                          ),      
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 64,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Masukkan password saat ini dan password baru Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                CustomPasswordField(
                                  controller: _currentPasswordController,
                                  labelText: 'Password Saat Ini',
                                  enabled: !isChanging,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password saat ini tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomPasswordField(
                                  controller: _newPasswordController,
                                  labelText: 'Password Baru',
                                  helperText: 'Minimal 6 karakter',
                                  enabled: !isChanging,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password baru tidak boleh kosong';
                                    }
                                    if (value.length < 6) {
                                      return 'Password minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomPasswordField(
                                  controller: _confirmPasswordController,
                                  labelText: 'Konfirmasi Password Baru',
                                  enabled: !isChanging,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi password tidak boleh kosong';
                                    }
                                    if (value != _newPasswordController.text) {
                                      return 'Password tidak cocok';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Change Password Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: isChanging
                                        ? null
                                        : () {
                                            final isFormValid = _formKey
                                                    .currentState
                                                    ?.validate() ??
                                                false;
                                            if (!isFormValid) return;

                                            ref
                                                .read(authActionsProvider.notifier)
                                                .changePassword(
                                                  currentPassword:
                                                      _currentPasswordController.text,
                                                  newPassword:
                                                      _newPasswordController.text,
                                                );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo[800],
                                      foregroundColor: Colors.white,
                                    ),
                                    child: isChanging
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'Ubah Password',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Security Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.info.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppTheme.info),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Gunakan password yang kuat dengan kombinasi huruf, angka, dan simbol',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }
}
