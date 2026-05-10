import 'package:aegi/core/widgets/gradient_container.dart';
import 'package:aegi/features/expecting/widgets/kick_counter_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class KickCounterCard extends StatelessWidget {
  const KickCounterCard({required this.childId, super.key});

  final String childId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => KickCounterPage(childId: childId),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => GradientContainer(
          colors: [const Color.fromARGB(255, 243, 173, 59), const Color.fromARGB(255, 220, 118, 23)],
          width: constraints.maxWidth,
          height: 60,
          borderRadius: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Symbols.footprint_rounded, color: Colors.white, size: 28),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Text(
                    'Kick Count →',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
