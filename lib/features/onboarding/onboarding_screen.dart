import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/core/widgets/onboarding/onboarding_cards.dart';
import 'package:aegi/core/widgets/onboarding/onboarding_shell.dart';
import 'package:aegi/core/widgets/onboarding/primary_cta_button.dart';
import 'package:aegi/features/onboarding/onboarding_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('MMMM d, y');

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);
    final hasBack = state.pageIndex > 0;

    if (_pageController.hasClients &&
        (_pageController.page?.round() ?? 0) != state.pageIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_pageController.hasClients) return;
        _pageController.animateToPage(
          state.pageIndex,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
    }

    if (_phoneController.text != state.medicalProviderPhone) {
      _phoneController.text = state.medicalProviderPhone;
      _phoneController.selection = TextSelection.collapsed(
        offset: _phoneController.text.length,
      );
    }
    if (_nameController.text != state.babyName) {
      _nameController.text = state.babyName;
      _nameController.selection = TextSelection.collapsed(
        offset: _nameController.text.length,
      );
    }

    return OnboardingShell(
      currentStepIndex: state.pageIndex,
      onBack: hasBack
          ? () {
              viewModel.previousPage();
            }
          : null,
      footer: PrimaryCtaButton(
        label: _ctaLabel(state.pageIndex),
        isBusy: state.isSubmitting,
        onPressed: viewModel.canProceedCurrentStep()
            ? () async {
                if (state.pageIndex <= 1) {
                  viewModel.nextPage();
                  return;
                }
                final ok = await viewModel.completeOnboarding();
                if (ok && context.mounted) context.go('/home');
              }
            : null,
      ),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (_) {},
        children: [
          _JourneyStep(
            state: state,
            dateFormat: _dateFormat,
            phoneController: _phoneController,
            onModeSelected: viewModel.setMode,
            onDueDatePressed: () async {
              final now = DateTime.now();
              final selected = await showDatePicker(
                context: context,
                initialDate: state.dueDate ?? now,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now.add(const Duration(days: 365)),
              );
              if (selected != null) viewModel.setDueDate(selected);
            },
            onBirthDatePressed: () async {
              final now = DateTime.now();
              final selected = await showDatePicker(
                context: context,
                initialDate: state.birthDate ?? now,
                firstDate: DateTime(now.year - 5),
                lastDate: now,
              );
              if (selected != null) viewModel.setBirthDate(selected);
            },
            onPhoneChanged: viewModel.setMedicalProviderPhone,
          ),
          _BabyDetailsStep(
            state: state,
            nameController: _nameController,
            onNameChanged: viewModel.setBabyName,
            onGenderSelected: viewModel.setGender,
          ),
          _WelcomeStep(state: state),
        ],
      ),
    );
  }

  String _ctaLabel(int index) {
    switch (index) {
      case 0:
        return 'Continue';
      case 1:
        return 'Next';
      default:
        return 'Get Started';
    }
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.state,
    required this.dateFormat,
    required this.phoneController,
    required this.onModeSelected,
    required this.onDueDatePressed,
    required this.onBirthDatePressed,
    required this.onPhoneChanged,
  });

  final OnboardingUiState state;
  final DateFormat dateFormat;
  final TextEditingController phoneController;
  final ValueChanged<AppMode> onModeSelected;
  final VoidCallback onDueDatePressed;
  final VoidCallback onBirthDatePressed;
  final ValueChanged<String> onPhoneChanged;

  @override
  Widget build(BuildContext context) {
    final expecting = state.mode == AppMode.expecting;
    final arrived = state.mode == AppMode.arrived;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: Column(
        children: [
          Text(
            'Where are you in\nyour journey?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "We'll tailor aegi for your needs.",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: context.appColors.weakText),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 190,
            child: Row(
              children: [
                Expanded(
                  child: SelectableCard(
                    title: 'Expecting',
                    icon: Icons.pregnant_woman,
                    selected: expecting,
                    onTap: () => onModeSelected(AppMode.expecting),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SelectableCard(
                    title: 'Arrived',
                    icon: Icons.child_care,
                    selected: arrived,
                    onTap: () => onModeSelected(AppMode.arrived),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (state.mode != null)
            InputSectionCard(
              children: [
                Text(
                  expecting ? "Baby's Due Date" : "Baby's Birth Date",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.appColors.weakText,
                  ),
                ),
                const SizedBox(height: 10),
                DateFieldButton(
                  text: expecting
                      ? (state.dueDate == null
                            ? 'Select due date'
                            : dateFormat.format(state.dueDate!))
                      : (state.birthDate == null
                            ? 'Select birth date'
                            : dateFormat.format(state.birthDate!)),
                  onTap: expecting ? onDueDatePressed : onBirthDatePressed,
                ),
                if (expecting) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Medical Provider Phone Number',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.appColors.weakText,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Optional',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.appColors.weakText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: onPhoneChanged,
                    onTapOutside: (_) => {
                      FocusScope.of(context).unfocus()
                    },
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.appColors.weakText,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g., (555) 000-0000',
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _BabyDetailsStep extends StatelessWidget {
  const _BabyDetailsStep({
    required this.state,
    required this.nameController,
    required this.onNameChanged,
    required this.onGenderSelected,
  });

  final OnboardingUiState state;
  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<Gender> onGenderSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: Column(
        children: [
          Text(
            'Tell us about\nyour little one',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your tracking experience.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: context.appColors.weakText),
          ),
          const SizedBox(height: 28),
          InputSectionCard(
            children: [
              Text(
                "Baby's Name",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.appColors.weakText,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                onChanged: onNameChanged,
                onTapOutside: (_) => {
                  FocusScope.of(context).unfocus()
                },
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.appColors.weakText,
                ),
                decoration: const InputDecoration(hintText: 'Enter name'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Gender',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.appColors.weakText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: Row(
              children: [
                Expanded(
                  child: SelectableCard(
                    title: 'Boy',
                    icon: Icons.child_care,
                    selected: state.gender == Gender.male,
                    iconTint: const Color(0xFF8CA6E2),
                    onTap: () => onGenderSelected(Gender.male),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectableCard(
                    title: 'Girl',
                    icon: Icons.child_care,
                    selected: state.gender == Gender.female,
                    iconTint: const Color(0xFFE88C8C),
                    onTap: () => onGenderSelected(Gender.female),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectableCard(
                    title: 'Skip',
                    icon: Icons.close,
                    selected: state.gender == Gender.unspecified,
                    onTap: () => onGenderSelected(Gender.unspecified),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const InfoHintCard(
            text: 'You can always change these details later in settings.',
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.state});

  final OnboardingUiState state;

  @override
  Widget build(BuildContext context) {
    final mode = state.mode;
    final subtitle = mode == AppMode.expecting
        ? "Congratulations on this beautiful blessing. May your journey to motherhood be filled with joy, comfort, and cherished memories. We'll keep you in our prayers."
        : "We're here to help you and your parents every step of the way. Calm nights and happy mornings await.";

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Column(
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE9EEF9),
                  Color(0xFFFCE8D8),
                  Color(0xFFF5EDF9),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.favorite, size: 42, color: Color(0xFFEF8D98)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to the family, ${state.normalizedBabyName}!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: context.appColors.weakText),
          ),
          const SizedBox(height: 22),
          Row(
            children: const [
              Expanded(
                child: MiniFeatureCard(
                  subtitle: 'Ready to',
                  title: 'Track Sleep',
                  icon: Icons.dark_mode_outlined,
                  iconColor: Color(0xFF8CA6E2),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: MiniFeatureCard(
                  subtitle: 'Ready to',
                  title: 'Log Feeds',
                  icon: Icons.child_care,
                  iconColor: Color(0xFF8ECFD1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your data is encrypted and secure',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.appColors.weakText),
          ),
        ],
      ),
    );
  }
}
