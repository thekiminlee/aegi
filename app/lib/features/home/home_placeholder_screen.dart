import 'package:flutter/material.dart';

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Home shell placeholder',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
