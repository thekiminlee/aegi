import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArrivedTrendsTab extends StatelessWidget {
  const ArrivedTrendsTab({required this.child, super.key});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
        TabHeader(
          subheading: DateFormat.MMMd().format(DateTime.now()).toUpperCase(),
          heading: "Trends",
        ),
        const SizedBox(height: 24),
        EmptyPanel(message: 'Trends & insights coming soon'),
      ],
    );
  }
}
