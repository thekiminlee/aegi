import 'package:aegi/app/onboarding_gate.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/child_profile.dart';
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
    this.isSubmitting = false,
  });

  final int pageIndex;
  final AppMode? mode;
  final DateTime? dueDate;
  final DateTime? birthDate;
  final String medicalProviderPhone;
  final String babyName;
  final Gender gender;
  final bool isSubmitting;

  OnboardingStep get step => OnboardingStep.values[pageIndex];

  bool get canContinueStep1 {
    if (mode == null) return false;
    if (mode == AppMode.expecting) return dueDate != null;
    return birthDate != null;
  }

  bool get canContinueStep2 => true;

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
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final onboardingViewModelProvider =
    NotifierProvider<OnboardingViewModel, OnboardingUiState>(
      OnboardingViewModel.new,
    );

class OnboardingViewModel extends Notifier<OnboardingUiState> {
  static const _uuid = Uuid();

  @override
  OnboardingUiState build() => const OnboardingUiState(mode: AppMode.expecting);

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
    state = state.copyWith(gender: value);
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

  Future<bool> completeOnboarding() async {
    if (state.mode == null || state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true);

    try {
      final childRepo = ref.read(childRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final gate = ref.read(onboardingGateProvider.notifier);
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

      await childRepo.createInitialChild(child);
      await settingsRepo.saveInitialSettings(settings);
      await gate.markComplete();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}
