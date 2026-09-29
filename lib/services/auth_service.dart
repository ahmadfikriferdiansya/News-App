import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static const String _boxName = 'users';
  static const String _sessionKey = 'current_user';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  /// Register user baru
  /// Return null kalau sukses, return error message kalau gagal.
  String? register({
    required String email,
    required String password,
    required String name,
  }) {
    final users = _box.get('users_list', defaultValue: <dynamic>[]) as List;

    // Cek email sudah terdaftar
    final exists = users.any((u) =>
        (u as Map)['email'].toString().toLowerCase() ==
        email.toLowerCase());
    if (exists) {
      return 'Email sudah terdaftar';
    }

    // Validasi
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'Email tidak valid';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (name.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    // Simpan user
    final newUsers = [...users, {
      'email': email.toLowerCase(),
      'password': password,
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
    }];
    _box.put('users_list', newUsers);
    return null;
  }

  /// Login
  /// Return null kalau sukses, return error message kalau gagal.
  String? login({
    required String email,
    required String password,
  }) {
    final users = _box.get('users_list', defaultValue: <dynamic>[]) as List;

    final user = users.firstWhereOrNull((u) =>
        (u as Map)['email'].toString().toLowerCase() ==
            email.toLowerCase() &&
        u['password'] == password);

    if (user == null) {
      return 'Email atau password salah';
    }

    // Simpan session
    _box.put(_sessionKey, Map<String, dynamic>.from(user as Map));
    return null;
  }

  /// Logout
  Future<void> logout() async {
    await _box.delete(_sessionKey);
  }

  /// Cek user yang sedang login
  Map<String, dynamic>? get currentUser {
    final data = _box.get(_sessionKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Cek login status
  bool get isLoggedIn => currentUser != null;
}

// Extension helper
extension _FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}