import 'package:aegi/app/onboarding_gate.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

enum OnboardingStep { journey, details, welcome }

class OnboardingUiState {
  const OnboardingUiState({
    this.pageIndex = 0,
    this.mode,
    this.dueDate,
    this.birthDate,
    this.medicalProviderPhone = '',
    this.babyName = '',
    this.gender = Gender.unspecified,
    this.hasChosenGender = false,
    this.isSubmitting = false,
  });

  final int pageIndex;
  final AppMode? mode;
  final DateTime? dueDate;
  final DateTime? birthDate;
  final String medicalProviderPhone;
  final String babyName;
  final Gender gender;
  final bool hasChosenGender;
  final bool isSubmitting;

  OnboardingStep get step => OnboardingStep.values[pageIndex];

  bool get canContinueStep1 {
    if (mode == null) return false;
    if (mode == AppMode.expecting) return _isValidDueDate(dueDate);
    return _isValidBirthDate(birthDate);
  }

  bool get hasValidBabyName => babyName.trim().isNotEmpty;

  bool get hasSelectedGender => hasChosenGender;

  bool get canContinueStep2 => hasValidBabyName && hasSelectedGender;

  String get normalizedBabyName {
    final trimmed = babyName.trim();
    return trimmed.isEmpty ? 'Baby' : trimmed;
  }

  OnboardingUiState copyWith({
    int? pageIndex,
    AppMode? mode,
    DateTime? dueDate,
    DateTime? birthDate,
    String? medicalProviderPhone,
    String? babyName,
    Gender? gender,
    bool? hasChosenGender,
    bool? isSubmitting,
    bool resetDueDate = false,
    bool resetBirthDate = false,
  }) {
    return OnboardingUiState(
      pageIndex: pageIndex ?? this.pageIndex,
      mode: mode ?? this.mode,
      dueDate: resetDueDate ? null : dueDate ?? this.dueDate,
      birthDate: resetBirthDate ? null : birthDate ?? this.birthDate,
      medicalProviderPhone: medicalProviderPhone ?? this.medicalProviderPhone,
      babyName: babyName ?? this.babyName,
      gender: gender ?? this.gender,
      hasChosenGender: hasChosenGender ?? this.hasChosenGender,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

bool _isValidDueDate(DateTime? value) {
  if (value == null) return false;
  final now = DateTime.now();
  final minDate = _dateOnly(now.subtract(const Duration(days: 30)));
  final maxDate = _dateOnly(now.add(const Duration(days: 365)));
  final selected = _dateOnly(value);
  return !selected.isBefore(minDate) && !selected.isAfter(maxDate);
}

bool _isValidBirthDate(DateTime? value) {
  if (value == null) return false;
  final now = DateTime.now();
  final minDate = DateTime(now.year - 5, now.month, now.day);
  final maxDate = _dateOnly(now);
  final selected = _dateOnly(value);
  return !selected.isBefore(minDate) && !selected.isAfter(maxDate);
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

final onboardingViewModelProvider =
    NotifierProvider<OnboardingViewModel, OnboardingUiState>(
      OnboardingViewModel.new,
    );

class OnboardingViewModel extends Notifier<OnboardingUiState> {
  static const _uuid = Uuid();

  @override
  OnboardingUiState build() => const OnboardingUiState();

  void reset() {
    state = const OnboardingUiState();
  }

  void setMode(AppMode mode) {
    if (mode == AppMode.expecting) {
      state = state.copyWith(mode: mode, resetBirthDate: true);
    } else {
      state = state.copyWith(mode: mode, resetDueDate: true);
    }
  }

  void setDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }

  void setBirthDate(DateTime date) {
    state = state.copyWith(birthDate: date);
  }

  void setMedicalProviderPhone(String value) {
    state = state.copyWith(medicalProviderPhone: value);
  }

  void setBabyName(String value) {
    state = state.copyWith(babyName: value);
  }

  void setGender(Gender value) {
    state = state.copyWith(gender: value, hasChosenGender: true);
  }

  void nextPage() {
    state = state.copyWith(pageIndex: (state.pageIndex + 1).clamp(0, 2));
  }

  void previousPage() {
    state = state.copyWith(pageIndex: (state.pageIndex - 1).clamp(0, 2));
  }

  bool canProceedCurrentStep() {
    switch (state.step) {
      case OnboardingStep.journey:
        return state.canContinueStep1;
      case OnboardingStep.details:
        return state.canContinueStep2;
      case OnboardingStep.welcome:
        return !state.isSubmitting;
    }
  }

  Future<bool> completeOnboarding({bool isAddChildFlow = false}) async {
    if (!state.canContinueStep1 ||
        !state.canContinueStep2 ||
        state.isSubmitting) {
      return false;
    }
    state = state.copyWith(isSubmitting: true);

    try {
      final childRepo = ref.read(childRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final now = DateTime.now();
      final childId = _uuid.v4();
      final mode = state.mode!;

      final child = ChildProfile(
        id: childId,
        name: state.normalizedBabyName,
        gender: state.gender,
        mode: mode,
        dueDate: mode == AppMode.expecting ? state.dueDate : null,
        birthDate: mode == AppMode.arrived ? state.birthDate : null,
        medicalProviderPhone:
            mode == AppMode.expecting &&
                state.medicalProviderPhone.trim().isNotEmpty
            ? state.medicalProviderPhone.trim()
            : null,
        createdAt: now,
        updatedAt: now,
      );

      await childRepo.createInitialChild(child);

      if (isAddChildFlow) {
        await settingsRepo.updateSelectedChildId(childId);
      } else {
        final gate = ref.read(onboardingGateProvider.notifier);
        final settings = AppSettings(
          selectedChildId: childId,
          volumeUnit: VolumeUnit.ml,
          weightUnit: WeightUnit.kg,
          lengthUnit: LengthUnit.cm,
          temperatureUnit: TemperatureUnit.celsius,
          notificationsEnabled: true,
          weeklyPregnancyReminderEnabled: mode == AppMode.expecting,
          trackingReminderEnabled: false,
        );
        await settingsRepo.saveInitialSettings(settings);
        await gate.markComplete();
      }
      ref.invalidate(activeChildContextProvider);
      ref.invalidate(allChildrenProvider);
      ref.invalidate(analyticsIdentitySyncProvider);
      await ref
          .read(analyticsServiceProvider)
          .onboardingCompleted(mode: mode, addChildFlow: isAddChildFlow);

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}
