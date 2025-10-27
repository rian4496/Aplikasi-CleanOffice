// lib/screens/employee/create_request_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../providers/riverpod/auth_providers.dart';

final _logger = AppLogger('CreateRequestScreen');

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isUrgent = false;
  bool _isSubmitting = false;
  DateTime? _preferredTime;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final now = DateTime.now();
      setState(() {
        _preferredTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Creating cleaning request');

      final firestore = ref.read(firestoreProvider);
      await firestore.collection('requests').add({
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? 'User',
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'isUrgent': _isUrgent,
        'preferredTime': _preferredTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Request created successfully');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Permintaan berhasil dikirim'),
            ],
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Create request error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      _showError(exception.message);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error', e, stackTrace);
      _showError(AppConstants.genericErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permintaan Kebersihan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: AppConstants.defaultPadding),
                      const Expanded(
                        child: Text(
                          'Buat permintaan untuk pembersihan area tertentu',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Location with Autocomplete
              Autocomplete<String>(
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  _locationController.text = controller.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi',
                      hintText: 'Ketik atau pilih lokasi',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppConstants.requiredFieldMessage;
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  );
                },
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return AppConstants.predefinedLocations.where((location) {
                    return location.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                onSelected: (selection) {
                  _locationController.text = selection;
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Jelaskan apa yang perlu dibersihkan',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                maxLength: AppConstants.maxDescriptionLength,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppConstants.requiredFieldMessage;
                  }
                  if (value.trim().length < AppConstants.minDescriptionLength) {
                    return 'Deskripsi minimal ${AppConstants.minDescriptionLength} karakter';
                  }
                  return null;
                },
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Preferred Time
              ListTile(
                title: const Text('Waktu yang Diinginkan'),
                subtitle: Text(
                  _preferredTime != null
                      ? TimeOfDay.fromDateTime(_preferredTime!).format(context)
                      : 'Pilih waktu (opsional)',
                ),
                leading: const Icon(Icons.access_time),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isSubmitting ? null : _selectTime,
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Urgent Switch
              SwitchListTile(
                title: const Text('Tandai sebagai Urgen'),
                subtitle: const Text('Permintaan yang perlu segera ditangani'),
                value: _isUrgent,
                onChanged: _isSubmitting
                    ? null
                    : (bool value) {
                        setState(() {
                          _isUrgent = value;
                        });
                      },
                secondary: Icon(
                  Icons.priority_high,
                  color: _isUrgent ? AppConstants.errorColor : null,
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text(
                            'Kirim Permintaan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
  }
}
