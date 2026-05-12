import 'package:flutter/material.dart';

class TabScaffold extends StatelessWidget{
  const TabScaffold({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: children,
    );
  }
}