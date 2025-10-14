import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// A reusable password text form field with a toggle to show/hide the password.
class CustomPasswordField extends StatefulWidget {
  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.enabled = true,
    this.helperText,
  });

  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final String? helperText;

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: '••••••••',
        helperText: widget.helperText,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: AppTheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textSecondary,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
        // Disable border color when field is disabled
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}