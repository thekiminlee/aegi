import 'package:aegi/app/theme/app_theme.dart';
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: context.appColors.accent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
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
    );
  }
}
