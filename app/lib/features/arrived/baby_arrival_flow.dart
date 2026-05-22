import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/widgets/onboarding/onboarding_cards.dart';
import 'package:aegi/core/widgets/onboarding/onboarding_shell.dart';
import 'package:aegi/core/widgets/onboarding/primary_cta_button.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BabyArrivalFlow extends ConsumerStatefulWidget {
  const BabyArrivalFlow({required this.child, super.key});

  final ChildProfile child;

  @override
  ConsumerState<BabyArrivalFlow> createState() => _BabyArrivalFlowState();
}

class _BabyArrivalFlowState extends ConsumerState<BabyArrivalFlow> {
  final PageController _pageController = PageController();
  final DateFormat _dateFormat = DateFormat('MMMM d, y');

  int _pageIndex = 0;
  DateTime? _birthDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    setState(() => _pageIndex = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _complete() async {
    if (_birthDate == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final childRepo = ref.read(childRepositoryProvider);
      final now = DateTime.now();

      final updated = ChildProfile(
        id: widget.child.id,
        name: widget.child.name,
        gender: widget.child.gender,
        mode: AppMode.arrived,
        dueDate: widget.child.dueDate,
        birthDate: _birthDate,
        medicalProviderPhone: widget.child.medicalProviderPhone,
        createdAt: widget.child.createdAt,
        updatedAt: now,
      );

      await childRepo.updateChild(updated);
      ref.invalidate(activeChildContextProvider);

      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _isSubmitting = false);
    }
  }

  void _showBirthDatePicker() {
    final now = DateTime.now();
    DateTime picked = _birthDate ?? now;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: Text('Done', style: TextStyle(color: Colors.grey[600])),
                  onPressed: () {
                    setState(() => _birthDate = picked);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _birthDate ?? now,
                minimumDate: DateTime(now.year - 1),
                maximumDate: now,
                onDateTimeChanged: (dt) => picked = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _pageIndex == 0 ? _birthDate != null : !_isSubmitting;
    final babyName = widget.child.name;

    return OnboardingShell(
      totalSteps: 2,
      currentStepIndex: _pageIndex,
      onBack: _pageIndex > 0 ? () => _goToPage(0) : () => Navigator.of(context).pop(),
      footer: PrimaryCtaButton(
        label: _pageIndex == 0 ? 'Next' : 'Get Started',
        isBusy: _isSubmitting,
        onPressed: canProceed
            ? () {
                if (_pageIndex == 0) {
                  _goToPage(1);
                } else {
                  _complete();
                }
              }
            : null,
      ),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Step 1: Birthday
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Happy ',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Birthday!',
                            style: TextStyle(
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "When did $babyName arrive?",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                DateFieldButton(
                  text: _birthDate == null
                      ? 'Birth date'
                      : _dateFormat.format(_birthDate!),
                  onTap: _showBirthDatePicker,
                  hasDate: _birthDate != null,
                ),
              ],
            ),
          ),

          // Step 2: Welcome
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome to the world,\n$babyName!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontFamily: "Instrument Serif",
                  ),
                ),
                Image.asset("assets/img/birthday.png", height: 280),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "We're so happy $babyName is here! May every moment be filled with joy, wonder, love, and blessing.\n\nWelcome to the next chapter!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Image.asset("assets/img/cursive_signature.png", width: 70),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
