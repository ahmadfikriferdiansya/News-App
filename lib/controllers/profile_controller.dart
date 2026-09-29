import 'package:get/get.dart';
import 'package:news_app/services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();

  // ==================== OBSERVABLES ====================
  final streak = 0.obs;
  final targetPerDay = 3.obs;
  final readMinutesToday = 0.obs;
  final interests = <String>[].obs;
  final photoPath = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadAll();
    updateStreakOnLogin();
  }

  void _loadAll() {
    streak.value = _service.streak;
    targetPerDay.value = _service.targetPerDay;
    readMinutesToday.value = _service.readMinutesToday;
    interests.value = _service.interests;
    photoPath.value = _service.photoPath;
  }

  Future<void> updateStreakOnLogin() async {
    await _service.updateStreak();
    streak.value = _service.streak;
  }

  Future<void> setTarget(int value) async {
    await _service.setTarget(value);
    targetPerDay.value = value;
  }

  Future<void> addReadMinute() async {
    await _service.addReadMinute();
    readMinutesToday.value = _service.readMinutesToday;
  }

  Future<void> setInterests(List<String> value) async {
    await _service.setInterests(value);
    interests.value = value;
  }

  Future<void> setPhotoPath(String? path) async {
    await _service.setPhotoPath(path);
    photoPath.value = path;
  }

  // Progress target (%)
  double get targetProgress {
    if (targetPerDay.value == 0) return 0;
    return (readMinutesToday.value / (targetPerDay.value * 3)).clamp(0.0, 1.0);
  }
}