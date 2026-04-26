import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/data/models/child_profile.dart' as model;
import 'package:drift/drift.dart';

abstract class ChildRepository {
  Future<void> createInitialChild(model.ChildProfile child);
  Future<model.ChildProfile?> getById(String id);
}

class DriftChildRepository implements ChildRepository {
  DriftChildRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<void> createInitialChild(model.ChildProfile child) {
    return _database
        .into(_database.childProfiles)
        .insert(
          ChildProfilesCompanion.insert(
            id: child.id,
            name: child.name,
            gender: child.gender.index,
            mode: child.mode.index,
            dueDate: Value(child.dueDate),
            birthDate: Value(child.birthDate),
            medicalProviderPhone: Value(child.medicalProviderPhone),
            createdAt: child.createdAt,
            updatedAt: child.updatedAt,
          ),
        );
  }

  @override
  Future<model.ChildProfile?> getById(String id) async {
    final row = await (_database.select(
      _database.childProfiles,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return model.ChildProfile(
      id: row.id,
      name: row.name,
      gender: Gender.values[row.gender],
      mode: AppMode.values[row.mode],
      dueDate: row.dueDate,
      birthDate: row.birthDate,
      medicalProviderPhone: row.medicalProviderPhone,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
