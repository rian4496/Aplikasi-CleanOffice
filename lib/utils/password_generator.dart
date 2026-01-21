/// Password Generator Utility
/// Generates secure passwords from employee names

class PasswordGenerator {
  /// Generate password from employee name
  /// Example: "Danang" → "Danang@2024!"
  /// 
  /// Rules:
  /// - Capitalize first letter of name
  /// - Add special character (@, #, $, !)
  /// - Add current year
  /// - Add ending special character
  static String fromName(String name) {
    if (name.isEmpty) return _generateRandom();
    
    // Clean and format name
    final cleanName = name.trim().split(' ').first; // Take first name only
    final capitalizedName = _capitalize(cleanName);
    
    // Get current year
    final year = DateTime.now().year.toString();
    
    // Pick special characters
    const specialChars = ['@', '#', '\$', '!', '&'];
    final startChar = specialChars[capitalizedName.length % specialChars.length];
    const endChar = '!';
    
    // Combine: Name + Special + Year + EndChar
    // Example: "Danang@2024!"
    return '$capitalizedName$startChar$year$endChar';
  }
  
  /// Capitalize first letter, lowercase rest
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Generate random password if name is empty
  static String _generateRandom() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
    const specials = '@#\$!';
    final random = DateTime.now().millisecondsSinceEpoch;
    
    String password = '';
    for (int i = 0; i < 8; i++) {
      password += chars[(random + i * 7) % chars.length];
    }
    password += specials[random % specials.length];
    password += DateTime.now().year.toString().substring(2); // Last 2 digits of year
    
    return password;
  }
  
  /// Validate password meets security requirements
  static bool isSecure(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false; // Uppercase
    if (!password.contains(RegExp(r'[a-z]'))) return false; // Lowercase
    if (!password.contains(RegExp(r'[0-9]'))) return false; // Number
    if (!password.contains(RegExp(r'[@#\$!&%]'))) return false; // Special
    return true;
  }
}
