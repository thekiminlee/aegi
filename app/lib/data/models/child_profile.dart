import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/enums/gender.dart';

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.mode,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.birthDate,
    this.medicalProviderPhone,
  });

  final String id;
  final String name;
  final Gender gender;
  final AppMode mode;
  final DateTime? dueDate;
  final DateTime? birthDate;
  final String? medicalProviderPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
}
