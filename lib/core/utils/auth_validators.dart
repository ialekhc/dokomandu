class AuthValidators {
  const AuthValidators._();

  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool isValidPhone(String phone) {
    final normalized = normalizePhone(phone);
    return normalized.length >= 10 && normalized.length <= 15;
  }

  static bool isValidPassword(String password) {
    return password.trim().length >= 6;
  }
}
