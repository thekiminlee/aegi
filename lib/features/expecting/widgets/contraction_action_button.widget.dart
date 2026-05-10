import 'package:aegi/app/providers.dart';
import 'package:aegi/core/widgets/gradient_container.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/models/contraction_entry.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContractionActionButton extends ConsumerWidget {
  const ContractionActionButton({
    required this.child,
    required this.openEntry,
    required this.duration,
    super.key,
  });

  final ChildProfile child;
  final ContractionEntry? openEntry;
  final Duration duration;

  bool get isActive => openEntry != null;

  static const _idleColors = [
    Color(0xFFF89A5C), // accent
    Color.fromARGB(255, 227, 160, 106), // lighter accent
    Color(0xFFE07A3C), // darker accent
    Color.fromARGB(255, 212, 109, 75), // mid accent
  ];

  static const _activeColors = [
    Color(0xFFC05050), // primary red
    Color(0xFFE06868), // lighter red
    Color(0xFF9B3333), // darker red
    Color(0xFFD44A4A), // mid red
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = isActive ? _activeColors : _idleColors;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
      child: GestureDetector(
        key: ValueKey(isActive),
        onTap: () async {
          final repo = ref.read(contractionRepositoryProvider);
          if (openEntry == null) {
            await repo.startContraction(child.id);
          } else {
            await repo.stopContraction(child.id);
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GradientContainer(
              colors: colors,
              height: 200,
              width: constraints.maxWidth,
              borderRadius: 24,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isActive) ...[
                    Text(
                      formatDuration(duration),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to stop',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start contraction',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'TAP ANYWHERE',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
