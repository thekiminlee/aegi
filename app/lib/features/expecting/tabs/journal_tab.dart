import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

class JournalTab extends ConsumerStatefulWidget {
  const JournalTab({required this.child, super.key});

  final ChildProfile child;

  @override
  ConsumerState<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends ConsumerState<JournalTab> {
  bool _showOverview = false;

  @override
  Widget build(BuildContext context) {
    final entriesAsync =
        ref.watch(expectingJournalEntriesProvider(widget.child.id));
    final now = DateTime.now();

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load entries: $e')),
      data: (entries) {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final thisWeekEntries = entries
            .where((e) =>
                e.timestamp.isAfter(weekStart) ||
                (e.timestamp.year == weekStart.year &&
                    e.timestamp.month == weekStart.month &&
                    e.timestamp.day == weekStart.day))
            .toList();

        return TabScaffold(
          children: [
            // // --- Expandable "Journals" header ---
            // GestureDetector(
            //   behavior: HitTestBehavior.opaque,
            //   onTap: () => setState(() => _showOverview = !_showOverview),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         'Journals',
            //         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            //               fontWeight: FontWeight.w500,
            //               fontSize: 20,
            //               color: context.appColors.black,
            //             ),
            //       ),
            //       Row(
            //         children: [
            //           AnimatedRotation(
            //             turns: _showOverview ? 0.5 : 0,
            //             duration: const Duration(milliseconds: 220),
            //             curve: Curves.easeInOut,
            //             child: Icon(
            //               Symbols.arrow_downward,
            //               size: 20,
            //               color: context.appColors.black,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // --- Animated overview ---
            // AnimatedSize(
            //   duration: const Duration(milliseconds: 220),
            //   curve: Curves.easeInOut,
            //   alignment: Alignment.topCenter,
            //   child: _showOverview
            //       ? Padding(
            //           padding: const EdgeInsets.only(top: 12),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               _overviewRow(context, 'Total entries',
            //                   '${entries.length}'),
            //               const SizedBox(height: 6),
            //               _overviewRow(context, 'This week',
            //                   '${thisWeekEntries.length}'),
            //             ],
            //           ),
            //         )
            //       : const SizedBox.shrink(),
            // ),

            // const SizedBox(height: 24),

            // --- Journal entries ---
            if (entries.isEmpty)
              const EmptyPanel(
                message: 'No journal entries yet.\nTap + to leave a memory.',
              )
            else
              Column(
                children: entries
                    .map((entry) => JournalEntryCard(
                          entry: entry,
                          dueDate: widget.child.dueDate,
                          birthDate: widget.child.birthDate,
                        ))
                    .toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _overviewRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontFamily: 'Inconsolata',
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Inconsolata',
              ),
        ),
      ],
    );
  }
}

Future<void> showJournalEntryModal(
  BuildContext context,
  WidgetRef ref,
  ChildProfile child,
) async {
  final controller = TextEditingController();
  final tagController = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.appColors.cardBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Symbols.arrow_back, size: 22, fontWeight: FontWeight.w500,),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.appColors.accent,
                      borderRadius: BorderRadius.circular(999)
                    ),
                    child: IconButton(
                      icon: Icon(Symbols.check, size: 22, color: context.appColors.white, fontWeight: FontWeight.w500,),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, hh:mm a').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500
                      )
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          "Tags",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        // TextField(
                        //   controller: tagController,
                        //   maxLines: 1,
                        //   minLines: 1,
                        //   // expands: true,
                        //   decoration: InputDecoration(
                        //     border: InputBorder.none,
                        //     enabledBorder: InputBorder.none,
                        //     focusedBorder: InputBorder.none,
                        //     fillColor: Colors.transparent,
                        //     hintText: 'comma separated',
                        //     hintStyle: TextStyle(
                        //       color: Colors.grey[400],
                        //       fontSize: 14,
                        //       fontFamily: 'Source Serif 4',
                        //     ),
                        //   ),
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     fontFamily: 'Source Serif 4',
                        //     fontWeight: FontWeight.w400,
                        //     color: context.appColors.black,
                        //     height: 1.6,
                        //   ),
                        // )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    hintText: 'What would you like to remember?',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontFamily: 'Source Serif 4',
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Source Serif 4',
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800],
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  final body = controller.text.trim();
  if (body.isEmpty) return;

  final now = DateTime.now();
  await ref.read(journalRepositoryProvider).addEntry(
        JournalEntryModel(
          id: const Uuid().v4(),
          childId: child.id,
          timestamp: now,
          body: body,
          tags: [],
          createdAt: now,
          updatedAt: now,
        ),
      );
}
