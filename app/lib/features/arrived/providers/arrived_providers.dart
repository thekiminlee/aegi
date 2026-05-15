import 'package:aegi/app/providers.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final arrivedBabyLogsProvider =
    StreamProvider.family<List<BabyLog>, String>((ref, childId) {
      return ref.watch(babyLogRepositoryProvider).watchLogsForChild(childId);
    });
