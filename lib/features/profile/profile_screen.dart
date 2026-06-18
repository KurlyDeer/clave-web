import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/gamification_controller.dart';
import '../../core/providers/lesson_progress_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../core/providers/study_plan_provider.dart';
import '../../core/providers/user_name_provider.dart';
import '../../core/providers/vocab_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import '../../core/providers/book_pages_provider.dart';
import '../welcome/welcome_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final name = ref.watch(userNameProvider);
    final gamification = ref.watch(gamificationProvider);
    final currentPlan = ref.watch(studyPlanProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final reminderHour = prefs.getInt('reminder_hour');
    final reminderMinute = prefs.getInt('reminder_minute');

    final titleSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final sectionSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 2;

    return Scaffold(
      backgroundColor: AppColors.glassGradientStart,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.glassGradientStart,
              AppColors.glassGradientMid,
              AppColors.glassGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: AppColors.glassText),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        AppStrings.profileTitleEs,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.glassText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Profile Card ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Level badge row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.trim().isNotEmpty
                                        ? name.trim()
                                        : 'Estudiante',
                                    style: TextStyle(
                                      fontSize: isSenior
                                          ? AppFontSizes.titleLarge
                                          : AppFontSizes.title,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.glassText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${gamification.levelTitle} · Nivel ${gamification.currentLevel}',
                                    style: TextStyle(
                                      fontSize: bodySize,
                                      color: AppColors.glowTerracotta,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // XP bubble
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.glowTerracotta
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.glowTerracotta, width: 1),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.bolt,
                                      color: AppColors.glowTerracotta,
                                      size: isSenior ? 24 : 20),
                                  Text(
                                    '${gamification.totalXp}',
                                    style: TextStyle(
                                      fontSize: bodySize,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.glassText,
                                    ),
                                  ),
                                  Text(
                                    'XP',
                                    style: TextStyle(
                                      fontSize: bodySize - 4,
                                      color: AppColors.glassTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // XP progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: gamification.levelProgress,
                            minHeight: 8,
                            backgroundColor:
                                AppColors.glassSurface.withValues(alpha: 0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.glowTerracotta),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          gamification.xpToNextLevel > 0
                              ? '${gamification.xpToNextLevel} XP para el siguiente nivel'
                              : '¡Nivel máximo!',
                          style: TextStyle(
                            fontSize: bodySize - 4,
                            color: AppColors.glassTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Persona Section ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.profilePersonaSectionEs,
                        style: TextStyle(
                          fontSize: sectionSize,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassTextMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _PersonaChip(
                              emoji: AppStrings.personaNinoEmoji,
                              label: AppStrings.personaNino,
                              isSelected: persona == Persona.nino,
                              isSenior: isSenior,
                              bodySize: bodySize,
                              onTap: () => ref
                                  .read(personaProvider.notifier)
                                  .setPersona(Persona.nino),
                            ),
                            const SizedBox(width: 8),
                            _PersonaChip(
                              emoji: AppStrings.personaAdultoEmoji,
                              label: AppStrings.personaAdulto,
                              isSelected: persona == Persona.adulto,
                              isSenior: isSenior,
                              bodySize: bodySize,
                              onTap: () => ref
                                  .read(personaProvider.notifier)
                                  .setPersona(Persona.adulto),
                            ),
                            const SizedBox(width: 8),
                            _PersonaChip(
                              emoji: AppStrings.personaAbueloEmoji,
                              label: AppStrings.personaAbuelo,
                              isSelected: persona == Persona.abuelo,
                              isSenior: isSenior,
                              bodySize: bodySize,
                              onTap: () => ref
                                  .read(personaProvider.notifier)
                                  .setPersona(Persona.abuelo),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Goal Section ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.profileGoalSectionEs,
                        style: TextStyle(
                          fontSize: sectionSize,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassTextMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            _GoalRow(
                              title: AppStrings.studyPlanQuickTitleEs,
                              description: AppStrings.studyPlanQuickDescEs,
                              minutes: '5 min',
                              isSelected: currentPlan == StudyPlanDuration.quick,
                              isSenior: isSenior,
                              bodySize: bodySize,
                              onTap: () => ref
                                  .read(studyPlanProvider.notifier)
                                  .setPlan(StudyPlanDuration.quick),
                            ),
                            const SizedBox(height: 4),
                            _GoalRow(
                              title: AppStrings.studyPlanStandardTitleEs,
                              description: AppStrings.studyPlanStandardDescEs,
                              minutes: '15 min',
                              isSelected:
                                  currentPlan == StudyPlanDuration.standard,
                              isSenior: isSenior,
                              bodySize: bodySize,
                              onTap: () => ref
                                  .read(studyPlanProvider.notifier)
                                  .setPlan(StudyPlanDuration.standard),
                            ),
                            const SizedBox(height: 4),
                            _GoalRow(
                              title: AppStrings.studyPlanDeepTitleEs,
                              description: AppStrings.studyPlanDeepDescEs,
                              minutes: '30+ min',
                              isSelected: currentPlan == StudyPlanDuration.deep,
                              isSenior: isSenior,
                              bodySize: bodySize,
                              onTap: () => ref
                                  .read(studyPlanProvider.notifier)
                                  .setPlan(StudyPlanDuration.deep),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Reminder Section ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.profileReminderSectionEs,
                        style: TextStyle(
                          fontSize: sectionSize,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassTextMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _pickReminderTime(context, persona, reminderHour, reminderMinute),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Icon(Icons.alarm_rounded,
                                  color: AppColors.glowTerracotta,
                                  size: isSenior ? 28 : 24),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.profileReminderLabelEs,
                                      style: TextStyle(
                                        fontSize: bodySize,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.glassText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      reminderHour != null
                                          ? '${AppStrings.profileReminderSetEs} ${reminderHour.toString().padLeft(2, '0')}:${(reminderMinute ?? 0).toString().padLeft(2, '0')}'
                                          : AppStrings.profileReminderOffEs,
                                      style: TextStyle(
                                        fontSize: bodySize - 4,
                                        color: reminderHour != null
                                            ? AppColors.glowTerracotta
                                            : AppColors.glassTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (reminderHour != null)
                                IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      color: AppColors.glassTextMuted, size: 20),
                                  tooltip: AppStrings.profileReminderRemoveEs,
                                  onPressed: () => _removeReminder(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Sound + Dark Mode Section ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.profileSettingsSectionEs,
                        style: TextStyle(
                          fontSize: sectionSize,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassTextMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            _ToggleRow(
                              icon: Icons.volume_up_rounded,
                              title: AppStrings.profileTtsToggleTitleEs,
                              desc: AppStrings.profileTtsToggleDescEs,
                              value: ref.watch(settingsProvider).isAudioEnabled,
                              isSenior: isSenior,
                              bodySize: bodySize,
                              onChanged: (v) => ref
                                  .read(settingsProvider.notifier)
                                  .setAudioEnabled(v),
                            ),
                            Divider(color: AppColors.glassBorder, height: 1),
                            _ToggleRow(
                              icon: Icons.dark_mode_rounded,
                              title: AppStrings.profileDarkModeToggleTitleEs,
                              desc: AppStrings.profileDarkModeToggleDescEs,
                              value: ref.watch(settingsProvider).isDarkMode,
                              isSenior: isSenior,
                              bodySize: bodySize,
                              onChanged: (v) => ref
                                  .read(settingsProvider.notifier)
                                  .setDarkMode(v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Danger Zone ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.profileDangerSectionEs,
                        style: TextStyle(
                          fontSize: sectionSize,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () =>
                            _showResetDialog(context, isSenior, bodySize),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.redAccent, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.delete_forever_rounded,
                                  color: Colors.redAccent, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppStrings.profileResetButtonEs,
                                  style: TextStyle(
                                    fontSize: bodySize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    dynamic persona,
    int? currentHour,
    int? currentMinute,
  ) async {
    final initial = TimeOfDay(
      hour: currentHour ?? 19,
      minute: currentMinute ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.glowTerracotta,
            surface: AppColors.glassGradientMid,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('reminder_hour', picked.hour);
    await prefs.setInt('reminder_minute', picked.minute);

    if (persona != null) {
      await NotificationService.instance.scheduleDailyReminder(
        persona: persona,
        hour: picked.hour,
        minute: picked.minute,
      );
    }

    setState(() {});
  }

  Future<void> _removeReminder() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('reminder_hour');
    await prefs.remove('reminder_minute');
    await NotificationService.instance.cancelAll();
    setState(() {});
  }

  Future<void> _showResetDialog(
    BuildContext context,
    bool isSenior,
    double bodySize,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.glassGradientMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.profileResetConfirmTitleEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle,
            fontWeight: FontWeight.w800,
            color: AppColors.glassText,
          ),
        ),
        content: Text(
          AppStrings.profileResetConfirmBodyEs,
          style: TextStyle(
            fontSize: bodySize,
            color: AppColors.glassTextMuted,
            height: 1.5,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.glassText,
              side: BorderSide(color: AppColors.glassBorder),
            ),
            child: Text(AppStrings.profileResetConfirmNoEs,
                style: TextStyle(fontSize: bodySize)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(AppStrings.profileResetConfirmYesEs,
                style: TextStyle(fontSize: bodySize)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // Clear all Hive boxes
    await ref.read(vocabBoxProvider).clear();
    await ref.read(bookPagesBoxProvider).clear();
    await ref.read(lessonProgressBoxProvider).clear();
    ref.read(gamificationProvider.notifier).resetAll();

    // Clear SharedPreferences
    await ref.read(sharedPreferencesProvider).clear();

    if (!context.mounted) return;

    // Navigate to WelcomeScreen, clearing the entire back stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.desc,
    required this.value,
    required this.isSenior,
    required this.bodySize,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String desc;
  final bool value;
  final bool isSenior;
  final double bodySize;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.glowTerracotta, size: isSenior ? 26 : 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: bodySize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glassText,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: bodySize - 4,
                    color: AppColors.glassTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.glowTerracotta,
            activeTrackColor:
                AppColors.glowTerracotta.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

// ── Persona Chip ──────────────────────────────────────────────────────────────

class _PersonaChip extends StatelessWidget {
  const _PersonaChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.isSenior,
    required this.bodySize,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final bool isSenior;
  final double bodySize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.glowTerracotta.withValues(alpha: 0.18)
                : AppColors.glassSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected ? AppColors.glowTerracotta : AppColors.glassBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji,
                  style: TextStyle(fontSize: isSenior ? 28 : 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: bodySize - 2,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.glowTerracotta
                      : AppColors.glassText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Goal Row ─────────────────────────────────────────────────────────────────

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.title,
    required this.description,
    required this.minutes,
    required this.isSelected,
    required this.isSenior,
    required this.bodySize,
    required this.onTap,
  });

  final String title;
  final String description;
  final String minutes;
  final bool isSelected;
  final bool isSenior;
  final double bodySize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final btnHeight = isSenior ? 72.0 : 60.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(minHeight: btnHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.glowTerracotta.withValues(alpha: 0.12)
              : AppColors.glassSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? AppColors.glowTerracotta : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio dot
            Container(
              width: isSenior ? 26 : 22,
              height: isSenior ? 26 : 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.glowTerracotta
                      : AppColors.glassBorder,
                  width: 2,
                ),
                color: isSelected ? AppColors.glowTerracotta : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: bodySize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.glassText,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: bodySize - 4,
                      color: AppColors.glassTextMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Minutes badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.glowTerracotta.withValues(alpha: 0.2)
                    : AppColors.glassSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.glowTerracotta
                      : AppColors.glassBorder,
                ),
              ),
              child: Text(
                minutes,
                style: TextStyle(
                  fontSize: bodySize - 2,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? AppColors.glowTerracotta
                      : AppColors.glassTextMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
