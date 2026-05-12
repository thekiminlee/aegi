import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArrivedOverviewTab extends StatelessWidget {
  const ArrivedOverviewTab({required this.child, super.key});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
        TabHeader(
          subheading: "TODAY · ${DateFormat('EEEE MMM d').format(DateTime.now()).toUpperCase()}",
          heading: "Overview",
        ),
        const SizedBox(height: 24),
        EmptyPanel(message: 'Overview coming soon'),
      ],
    );
  }
}
