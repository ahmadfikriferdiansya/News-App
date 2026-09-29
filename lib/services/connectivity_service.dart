import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final isOnline = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitial();
    _subscription = _connectivity.onConnectivityChanged.listen(_update);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _checkInitial() async {
    final result = await _connectivity.checkConnectivity();
    _update(result);
  }

  void _update(List<ConnectivityResult> results) {
    // Online jika ada koneksi selain 'none'
    final online = results.any((r) => r != ConnectivityResult.none);
    isOnline.value = online;

    if (!online) {
      Get.snackbar(
        'Offline',
        'Anda sedang offline. Beberapa fitur mungkin tidak tersedia.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
}