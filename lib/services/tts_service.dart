import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

enum TtsState { playing, stopped, paused }

class TtsService extends GetxService {
  final FlutterTts _flutterTts = FlutterTts();

  final isPlaying = false.obs;
  final state = TtsState.stopped.obs;

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  Future<void> _initTts() async {
    // ==================== SETTING DASAR ====================
    await _flutterTts.setLanguage('id-ID');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // ==================== HANDLER STATE ====================
    _flutterTts.setStartHandler(() {
      state.value = TtsState.playing;
      isPlaying.value = true;
    });

    _flutterTts.setCompletionHandler(() {
      state.value = TtsState.stopped;
      isPlaying.value = false;
    });

    _flutterTts.setCancelHandler(() {
      state.value = TtsState.stopped;
      isPlaying.value = false;
    });

    _flutterTts.setPauseHandler(() {
      state.value = TtsState.paused;
      isPlaying.value = false;
    });

    // setContinueHandler (bukan setResumeHandler) — dipakai saat resume
    _flutterTts.setContinueHandler(() {
      state.value = TtsState.playing;
      isPlaying.value = true;
    });

    _flutterTts.setErrorHandler((msg) {
      state.value = TtsState.stopped;
      isPlaying.value = false;
      Get.snackbar(
        'Error',
        'Text-to-Speech gagal: $msg',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  /// Baca teks dari awal
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await stop();
    await _flutterTts.speak(text);
  }

  /// Stop
  Future<void> stop() async {
    await _flutterTts.stop();
    state.value = TtsState.stopped;
    isPlaying.value = false;
  }

  /// Pause
  Future<void> pause() async {
    await _flutterTts.pause();
    state.value = TtsState.paused;
    isPlaying.value = false;
  }

  @override
  void onClose() {
    _flutterTts.stop();
    super.onClose();
  }
}