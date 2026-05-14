import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/core/widgets/gradient_container.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/repositories/app_meta_repository.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class ExpectingHeader extends ConsumerWidget {
  const ExpectingHeader({required this.activeChild, super.key});

  final ChildProfile activeChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(allChildrenProvider);

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
            GestureDetector(
              onTap: () async {
                final children = await _loadActiveChildren(ref);
                if (!context.mounted) return;
                _showChildPicker(context, ref, children);
              },
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

  Future<void> _showChildPicker(
    BuildContext context,
    WidgetRef ref,
    List<ChildProfile> children,
  ) async {
    final action = await showModalBottomSheet<_ChildPickerAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHILD PROFILE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Switch Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Source Serif 4',
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(sheetContext).pop(),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: children.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final child = children[index];
                      final isSelected = child.id == activeChild.id;
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 2,
                        ),
                        title: Text(
                          child.name,
                          style: TextStyle(
                            fontFamily: "Playwright",
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            : null,
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          if (isSelected) return;
                          await ref
                              .read(settingsRepositoryProvider)
                              .updateSelectedChildId(child.id);
                          ref.invalidate(activeChildContextProvider);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: context.appColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext, _ChildPickerAction.addChild);
                    },
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Add Child', style: TextStyle(fontFamily: "Inconsolata"),),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == _ChildPickerAction.addChild && context.mounted) {
      context.push('/onboarding?addChild=1');
    }
  }

  Future<List<ChildProfile>> _loadActiveChildren(WidgetRef ref) async {
    final children = await ref.read(childRepositoryProvider).watchAll().first;
    final deletedRaw = await ref
        .read(appMetaRepositoryProvider)
        .getValue(deletedChildIdsKey);
    if (deletedRaw == null || deletedRaw.isEmpty) return children;

    try {
      final decoded = jsonDecode(deletedRaw);
      if (decoded is! List) return children;
      final deletedIds = decoded.whereType<String>().toSet();
      return children.where((child) => !deletedIds.contains(child.id)).toList();
    } catch (_) {
      if (kDebugMode) {
        debugPrint('Invalid deleted child ids payload: $deletedRaw');
      }
      return children;
    }
  }
}

enum _ChildPickerAction { addChild }

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
