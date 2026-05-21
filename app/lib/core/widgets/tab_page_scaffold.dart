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

class TabPageScaffold extends StatelessWidget {
  const TabPageScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      child: child
    );
  }
}