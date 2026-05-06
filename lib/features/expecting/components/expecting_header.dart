import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/core/widgets/gradient_container.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpectingHeader extends ConsumerWidget {
  const ExpectingHeader({required this.activeChild, super.key});

  final ChildProfile activeChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children =
        ref.watch(allChildrenProvider).value ?? const <ChildProfile>[];

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            GradientContainer(
              height: 22,
              width: 22,
              borderRadius: 99,
              colors: _genderColors(activeChild.gender),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              onSelected: (childId) async {
                await ref
                    .read(settingsRepositoryProvider)
                    .updateSelectedChildId(childId);
                ref.invalidate(activeChildContextProvider);
              },
              itemBuilder: (context) => children
                  .map(
                    (child) => PopupMenuItem<String>(
                      value: child.id,
                      child: Text(child.name),
                    ),
                  )
                  .toList(),
              child: Row(
                children: [
                  Text(
                    activeChild.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
            const Spacer(),
            if (activeChild.medicalProviderPhone?.isNotEmpty ?? false)
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Provider: ${activeChild.medicalProviderPhone}',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.local_hospital_outlined),
              ),
          ],
        ),
      ),
    );
  }
}

List<Color> _genderColors(Gender gender) {
  return switch (gender) {
    Gender.male => const [
      Color.fromARGB(255, 25, 113, 213),
      Color.fromARGB(255, 9, 72, 155),
      Color(0xFF5AA8FF),
    ],
    Gender.female => const [
      Color(0xFFFFA0B5),
      Color(0xFFFF7A92),
      Color(0xFFD94D6A),
    ],
    Gender.unspecified => const [
      Color(0xFF9FDFB7),
      Color(0xFF66C48C),
      Color(0xFF2E9B66),
    ],
  };
}
