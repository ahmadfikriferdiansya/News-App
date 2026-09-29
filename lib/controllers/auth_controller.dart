import 'package:get/get.dart';
import 'package:news_app/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _service = AuthService();

  final isLoading = false.obs;
  final currentUser = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  void _loadSession() {
    currentUser.value = _service.currentUser;
  }

  bool get isLoggedIn => currentUser.value != null;
  String get userName => currentUser.value?['name'] ?? 'User';
  String get userEmail => currentUser.value?['email'] ?? '';

  Future<String?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500)); // simulasi network
    final error = _service.register(
      email: email,
      password: password,
      name: name,
    );
    isLoading.value = false;
    if (error == null) {
      // Auto login setelah register
      _service.login(email: email, password: password);
      _loadSession();
    }
    return error;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final error = _service.login(email: email, password: password);
    isLoading.value = false;
    if (error == null) {
      _loadSession();
    }
    return error;
  }

  Future<void> logout() async {
    await _service.logout();
    currentUser.value = null;
  }
}