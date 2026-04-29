import 'package:aegi/app/providers.dart';
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveChildContext {
  const ActiveChildContext({required this.settings, required this.child});

  final AppSettings settings;
  final ChildProfile child;
}

final activeChildContextProvider = FutureProvider<ActiveChildContext>((
  ref,
) async {
  final settings = await ref.read(settingsRepositoryProvider).getSettings();
  if (settings == null) throw StateError('App settings not found');

  final child = await ref
      .read(childRepositoryProvider)
      .getById(settings.selectedChildId);
  if (child == null) throw StateError('Selected child not found');

  return ActiveChildContext(settings: settings, child: child);
});

final allChildrenProvider = StreamProvider<List<ChildProfile>>((ref) {
  return ref.watch(childRepositoryProvider).watchAll();
});
