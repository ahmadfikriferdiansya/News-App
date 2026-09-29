import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app/controllers/auth_controller.dart';
import 'package:news_app/controllers/profile_controller.dart';
import 'package:news_app/routes/app_routes.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/theme_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final profile = Get.put(ProfileController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ==================== PROFILE CARD ====================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                // Photo
                GestureDetector(
                  onTap: () => _changePhoto(profile),
                  child: Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Obx(() {
                          final path = profile.photoPath.value;
                          if (path != null && File(path).existsSync()) {
                            return ClipOval(
                              child: Image.file(
                                File(path),
                                width: 66,
                                height: 66,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                          return Center(
                            child: Text(
                              auth.userName.isNotEmpty
                                  ? auth.userName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.userEmail,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Terdaftar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ==================== STATS GRID (3 kotak) ====================
          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  label: 'Streak',
                  value: '${profile.streak.value} Hari',
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  icon: Icons.track_changes,
                  iconColor: AppColors.accent,
                  label: 'Target',
                  value: '${profile.targetPerDay.value} Berita',
                  theme: theme,
                  onTap: () => _editTarget(profile),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  icon: Icons.timer_outlined,
                  iconColor: Colors.blue,
                  label: 'Waktu',
                  value: '${profile.readMinutesToday.value} Menit',
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ==================== TEMA ====================
          _sectionTitle('Pengaturan Tampilan', theme),
          const SizedBox(height: 12),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.themeMode,
            builder: (context, mode, _) {
              return Row(
                children: [
                  _themeOption(
                    label: 'Terang',
                    icon: Icons.light_mode_rounded,
                    isSelected: mode == ThemeMode.light,
                    onTap: () => ThemeService.setMode(ThemeMode.light),
                    theme: theme,
                  ),
                  const SizedBox(width: 10),
                  _themeOption(
                    label: 'Gelap',
                    icon: Icons.dark_mode_rounded,
                    isSelected: mode == ThemeMode.dark,
                    onTap: () => ThemeService.setMode(ThemeMode.dark),
                    theme: theme,
                  ),
                  const SizedBox(width: 10),
                  _themeOption(
                    label: 'Sistem',
                    icon: Icons.phone_android_rounded,
                    isSelected: mode == ThemeMode.system,
                    onTap: () => ThemeService.setMode(ThemeMode.system),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // ==================== PERSONALISASI MINAT ====================
          _sectionTitle('Minat Anda', theme),
          const SizedBox(height: 4),
          Text(
            'Pilih topik untuk kurasi berita',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            const topics = [
              'Artificial Intelligence',
              'Green Economy',
              'Quantum Computing',
              'Pasar Modal',
              'Energi Terbarukan',
              'Pemerintahan',
              'Kebijakan Publik',
              'Astronomi',
              'Bulutangkis',
              'Kesehatan Mental',
              'Sinema',
              'Semikonduktor',
              'Gadgets',
              'Startup',
            ];
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topics.map((t) {
                final isSelected = profile.interests.contains(t);
                return GestureDetector(
                  onTap: () {
                    final newList = List<String>.from(profile.interests);
                    if (isSelected) {
                      newList.remove(t);
                    } else {
                      newList.add(t);
                    }
                    profile.setInterests(newList);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark
                              ? const Color(0xFF22222C)
                              : const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                                ? const Color(0xFF2A2A35)
                                : const Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Text(
                      '${isSelected ? '✓ ' : '+ '}$t',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 32),

          // ==================== LOGOUT ====================
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(auth),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ==================== WIDGETS ====================

  Widget _sectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 15,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16161D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isDark ? const Color(0xFF2A2A35) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? const Color(0xFF16161D) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? const Color(0xFF2A2A35) : const Color(0xFFE5E7EB)),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodySmall?.color,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _changePhoto(ProfileController profile) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      await profile.setPhotoPath(picked.path);
    }
  }

  void _editTarget(ProfileController profile) {
    int temp = profile.targetPerDay.value;
    Get.defaultDialog(
      title: 'Target Harian',
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            Text('$temp berita / hari',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              value: temp.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (v) => setState(() => temp = v.round()),
            ),
          ],
        ),
      ),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      onConfirm: () async {
        await profile.setTarget(temp);
        Get.back();
      },
    );
  }

  void _confirmLogout(AuthController auth) {
    Get.defaultDialog(
      title: 'Keluar',
      middleText: 'Yakin ingin keluar dari akun ini?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () async {
        await auth.logout();
        Get.offAllNamed(AppRoutes.LOGIN);
      },
    );
  }
}