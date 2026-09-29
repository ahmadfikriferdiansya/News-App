import 'package:hive_flutter/hive_flutter.dart';

class ProfileService {
  static const String _boxName = 'profile';
  static const String _streakKey = 'streak';
  static const String _lastLoginKey = 'last_login';
  static const String _targetKey = 'target_per_day';
  static const String _readMinutesKey = 'read_minutes_today';
  static const String _readDateKey = 'read_date';
  static const String _interestsKey = 'interests';
  static const String _photoKey = 'photo_path';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  // ==================== STREAK ====================
  int get streak => _box.get(_streakKey, defaultValue: 0) as int;

  /// Update streak — dipanggil saat app dibuka
  Future<void> updateStreak() async {
    final lastLoginStr = _box.get(_lastLoginKey) as String?;
    final today = _dateKey(DateTime.now());

    if (lastLoginStr == null) {
      // First time login
      await _box.put(_streakKey, 1);
      await _box.put(_lastLoginKey, today);
      return;
    }

    final last = DateTime.parse(lastLoginStr);
    final diff = DateTime.now().difference(last).inDays;

    if (diff == 0) {
      // Sudah login hari ini
      return;
    } else if (diff == 1) {
      // Lanjut streak
      await _box.put(_streakKey, streak + 1);
    } else {
      // Streak patah
      await _box.put(_streakKey, 1);
    }
    await _box.put(_lastLoginKey, today);
  }

  // ==================== TARGET ====================
  int get targetPerDay => _box.get(_targetKey, defaultValue: 3) as int;

  Future<void> setTarget(int value) async {
    await _box.put(_targetKey, value);
  }

  // ==================== WAKTU BACA ====================
  int get readMinutesToday {
    final savedDate = _box.get(_readDateKey) as String?;
    final today = _dateKey(DateTime.now());
    if (savedDate != today) return 0;
    return _box.get(_readMinutesKey, defaultValue: 0) as int;
  }

  Future<void> addReadMinute() async {
    final today = _dateKey(DateTime.now());
    final savedDate = _box.get(_readDateKey) as String?;
    if (savedDate != today) {
      await _box.put(_readDateKey, today);
      await _box.put(_readMinutesKey, 1);
    } else {
      await _box.put(_readMinutesKey, readMinutesToday + 1);
    }
  }

  // ==================== INTERESTS ====================
  List<String> get interests {
    final list = _box.get(_interestsKey, defaultValue: <dynamic>[]) as List;
    return list.map((e) => e.toString()).toList();
  }

  Future<void> setInterests(List<String> value) async {
    await _box.put(_interestsKey, value);
  }

  // ==================== PHOTO ====================
  String? get photoPath => _box.get(_photoKey) as String?;

  Future<void> setPhotoPath(String? path) async {
    if (path == null) {
      await _box.delete(_photoKey);
    } else {
      await _box.put(_photoKey, path);
    }
  }

  // ==================== HELPER ====================
  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}