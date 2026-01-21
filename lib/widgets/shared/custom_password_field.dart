import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

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
      style: GoogleFonts.inter(color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
        hintText: '••••••••',
        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
        helperText: widget.helperText,
        helperStyle: widget.helperText != null ? GoogleFonts.inter(color: const Color(0xFF64748B)) : null,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: const Color(0xFF64748B), // Slate-500
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF94A3B8), // Slate-400
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate-200
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate-200
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF3B82F6), // Blue-500
            width: 1.5,
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
