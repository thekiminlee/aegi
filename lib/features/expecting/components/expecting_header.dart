import 'package:aegi/app/providers.dart';
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
        ref.watch(allChildrenProvider).valueOrNull ?? const <ChildProfile>[];

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.child_care, size: 20),
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
