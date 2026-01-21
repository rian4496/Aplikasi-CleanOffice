import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/error/exceptions.dart';
import '../../widgets/custom_password_field.dart';
import '../../riverpod/auth_providers.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Consumer(builder: (context, ref, child) {
      ref.listen<AsyncValue<void>>(authActionsProvider, (previous, next) {
        next.when(
          error: (error, stackTrace) {
            String message;
             if (error is AuthException) {
              if (error.code == 'wrong-password' || error.code == 'user-mismatch') {
                message = 'Password saat ini salah';
              } else if (error.code == 'weak-password') {
                message = 'Password baru terlalu lemah';
              } else {
                message = error.message;
              }
            } else {
              message = 'Terjadi kesalahan yang tidak diketahui.';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
            );
          },
          data: (_) {
            if (previous != null && !previous.isLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Password berhasil diubah')]),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            }
          },
          loading: () {},
        );
      });

      final state = ref.watch(authActionsProvider);
      final isChanging = state.isLoading;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Ubah Password',
            style: GoogleFonts.inter(
              color: const Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat password baru yang aman',
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 32),

                CustomPasswordField(
                  controller: _currentPasswordController,
                  labelText: 'Password Saat Ini',
                  enabled: !isChanging,
                  validator: (value) => value?.isEmpty == true ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                CustomPasswordField(
                  controller: _newPasswordController,
                  labelText: 'Password Baru',
                  helperText: 'Minimal 6 karakter',
                  enabled: !isChanging,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Wajib diisi';
                    if (value.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomPasswordField(
                  controller: _confirmPasswordController,
                  labelText: 'Konfirmasi Password',
                  enabled: !isChanging,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Wajib diisi';
                    if (value != _newPasswordController.text) return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                  SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isChanging
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              ref.read(authActionsProvider.notifier).changePassword(
                                    currentPassword: _currentPasswordController.text,
                                    newPassword: _newPasswordController.text,
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isChanging ? const Color(0xFF94A3B8) : const Color(0xFF3B82F6), // Blue-500
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isChanging
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Simpan Password Baru', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
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

