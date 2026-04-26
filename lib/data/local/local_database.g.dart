// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $ChildProfilesTable extends ChildProfiles
    with TableInfo<$ChildProfilesTable, ChildProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<int> gender = GeneratedColumn<int>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<int> mode = GeneratedColumn<int>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicalProviderPhoneMeta =
      const VerificationMeta('medicalProviderPhone');
  @override
  late final GeneratedColumn<String> medicalProviderPhone =
      GeneratedColumn<String>(
        'medical_provider_phone',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    gender,
    mode,
    dueDate,
    birthDate,
    medicalProviderPhone,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'child_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChildProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('medical_provider_phone')) {
      context.handle(
        _medicalProviderPhoneMeta,
        medicalProviderPhone.isAcceptableOrUnknown(
          data['medical_provider_phone']!,
          _medicalProviderPhoneMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gender'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mode'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      medicalProviderPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medical_provider_phone'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChildProfilesTable createAlias(String alias) {
    return $ChildProfilesTable(attachedDatabase, alias);
  }
}

class ChildProfile extends DataClass implements Insertable<ChildProfile> {
  final String id;
  final String name;
  final int gender;
  final int mode;
  final DateTime? dueDate;
  final DateTime? birthDate;
  final String? medicalProviderPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ChildProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.mode,
    this.dueDate,
    this.birthDate,
    this.medicalProviderPhone,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['gender'] = Variable<int>(gender);
    map['mode'] = Variable<int>(mode);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || medicalProviderPhone != null) {
      map['medical_provider_phone'] = Variable<String>(medicalProviderPhone);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChildProfilesCompanion toCompanion(bool nullToAbsent) {
    return ChildProfilesCompanion(
      id: Value(id),
      name: Value(name),
      gender: Value(gender),
      mode: Value(mode),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      medicalProviderPhone: medicalProviderPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(medicalProviderPhone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChildProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      gender: serializer.fromJson<int>(json['gender']),
      mode: serializer.fromJson<int>(json['mode']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      medicalProviderPhone: serializer.fromJson<String?>(
        json['medicalProviderPhone'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'gender': serializer.toJson<int>(gender),
      'mode': serializer.toJson<int>(mode),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'medicalProviderPhone': serializer.toJson<String?>(medicalProviderPhone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChildProfile copyWith({
    String? id,
    String? name,
    int? gender,
    int? mode,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> medicalProviderPhone = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ChildProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    gender: gender ?? this.gender,
    mode: mode ?? this.mode,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    medicalProviderPhone: medicalProviderPhone.present
        ? medicalProviderPhone.value
        : this.medicalProviderPhone,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChildProfile copyWithCompanion(ChildProfilesCompanion data) {
    return ChildProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      gender: data.gender.present ? data.gender.value : this.gender,
      mode: data.mode.present ? data.mode.value : this.mode,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      medicalProviderPhone: data.medicalProviderPhone.present
          ? data.medicalProviderPhone.value
          : this.medicalProviderPhone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gender: $gender, ')
          ..write('mode: $mode, ')
          ..write('dueDate: $dueDate, ')
          ..write('birthDate: $birthDate, ')
          ..write('medicalProviderPhone: $medicalProviderPhone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    gender,
    mode,
    dueDate,
    birthDate,
    medicalProviderPhone,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.gender == this.gender &&
          other.mode == this.mode &&
          other.dueDate == this.dueDate &&
          other.birthDate == this.birthDate &&
          other.medicalProviderPhone == this.medicalProviderPhone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChildProfilesCompanion extends UpdateCompanion<ChildProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> gender;
  final Value<int> mode;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> birthDate;
  final Value<String?> medicalProviderPhone;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChildProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.gender = const Value.absent(),
    this.mode = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.medicalProviderPhone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildProfilesCompanion.insert({
    required String id,
    required String name,
    required int gender,
    required int mode,
    this.dueDate = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.medicalProviderPhone = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       gender = Value(gender),
       mode = Value(mode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChildProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? gender,
    Expression<int>? mode,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? birthDate,
    Expression<String>? medicalProviderPhone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender,
      if (mode != null) 'mode': mode,
      if (dueDate != null) 'due_date': dueDate,
      if (birthDate != null) 'birth_date': birthDate,
      if (medicalProviderPhone != null)
        'medical_provider_phone': medicalProviderPhone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? gender,
    Value<int>? mode,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? birthDate,
    Value<String?>? medicalProviderPhone,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChildProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      mode: mode ?? this.mode,
      dueDate: dueDate ?? this.dueDate,
      birthDate: birthDate ?? this.birthDate,
      medicalProviderPhone: medicalProviderPhone ?? this.medicalProviderPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gender.present) {
      map['gender'] = Variable<int>(gender.value);
    }
    if (mode.present) {
      map['mode'] = Variable<int>(mode.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (medicalProviderPhone.present) {
      map['medical_provider_phone'] = Variable<String>(
        medicalProviderPhone.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gender: $gender, ')
          ..write('mode: $mode, ')
          ..write('dueDate: $dueDate, ')
          ..write('birthDate: $birthDate, ')
          ..write('medicalProviderPhone: $medicalProviderPhone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _selectedChildIdMeta = const VerificationMeta(
    'selectedChildId',
  );
  @override
  late final GeneratedColumn<String> selectedChildId = GeneratedColumn<String>(
    'selected_child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeUnitMeta = const VerificationMeta(
    'volumeUnit',
  );
  @override
  late final GeneratedColumn<int> volumeUnit = GeneratedColumn<int>(
    'volume_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightUnitMeta = const VerificationMeta(
    'weightUnit',
  );
  @override
  late final GeneratedColumn<int> weightUnit = GeneratedColumn<int>(
    'weight_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthUnitMeta = const VerificationMeta(
    'lengthUnit',
  );
  @override
  late final GeneratedColumn<int> lengthUnit = GeneratedColumn<int>(
    'length_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureUnitMeta = const VerificationMeta(
    'temperatureUnit',
  );
  @override
  late final GeneratedColumn<int> temperatureUnit = GeneratedColumn<int>(
    'temperature_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _weeklyPregnancyReminderEnabledMeta =
      const VerificationMeta('weeklyPregnancyReminderEnabled');
  @override
  late final GeneratedColumn<bool> weeklyPregnancyReminderEnabled =
      GeneratedColumn<bool>(
        'weekly_pregnancy_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("weekly_pregnancy_reminder_enabled" IN (0, 1))',
        ),
      );
  static const VerificationMeta _trackingReminderEnabledMeta =
      const VerificationMeta('trackingReminderEnabled');
  @override
  late final GeneratedColumn<bool> trackingReminderEnabled =
      GeneratedColumn<bool>(
        'tracking_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("tracking_reminder_enabled" IN (0, 1))',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    selectedChildId,
    volumeUnit,
    weightUnit,
    lengthUnit,
    temperatureUnit,
    notificationsEnabled,
    weeklyPregnancyReminderEnabled,
    trackingReminderEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('selected_child_id')) {
      context.handle(
        _selectedChildIdMeta,
        selectedChildId.isAcceptableOrUnknown(
          data['selected_child_id']!,
          _selectedChildIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedChildIdMeta);
    }
    if (data.containsKey('volume_unit')) {
      context.handle(
        _volumeUnitMeta,
        volumeUnit.isAcceptableOrUnknown(data['volume_unit']!, _volumeUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeUnitMeta);
    }
    if (data.containsKey('weight_unit')) {
      context.handle(
        _weightUnitMeta,
        weightUnit.isAcceptableOrUnknown(data['weight_unit']!, _weightUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_weightUnitMeta);
    }
    if (data.containsKey('length_unit')) {
      context.handle(
        _lengthUnitMeta,
        lengthUnit.isAcceptableOrUnknown(data['length_unit']!, _lengthUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_lengthUnitMeta);
    }
    if (data.containsKey('temperature_unit')) {
      context.handle(
        _temperatureUnitMeta,
        temperatureUnit.isAcceptableOrUnknown(
          data['temperature_unit']!,
          _temperatureUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureUnitMeta);
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationsEnabledMeta);
    }
    if (data.containsKey('weekly_pregnancy_reminder_enabled')) {
      context.handle(
        _weeklyPregnancyReminderEnabledMeta,
        weeklyPregnancyReminderEnabled.isAcceptableOrUnknown(
          data['weekly_pregnancy_reminder_enabled']!,
          _weeklyPregnancyReminderEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weeklyPregnancyReminderEnabledMeta);
    }
    if (data.containsKey('tracking_reminder_enabled')) {
      context.handle(
        _trackingReminderEnabledMeta,
        trackingReminderEnabled.isAcceptableOrUnknown(
          data['tracking_reminder_enabled']!,
          _trackingReminderEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackingReminderEnabledMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      selectedChildId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_child_id'],
      )!,
      volumeUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume_unit'],
      )!,
      weightUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_unit'],
      )!,
      lengthUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}length_unit'],
      )!,
      temperatureUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temperature_unit'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      weeklyPregnancyReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekly_pregnancy_reminder_enabled'],
      )!,
      trackingReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tracking_reminder_enabled'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final int id;
  final String selectedChildId;
  final int volumeUnit;
  final int weightUnit;
  final int lengthUnit;
  final int temperatureUnit;
  final bool notificationsEnabled;
  final bool weeklyPregnancyReminderEnabled;
  final bool trackingReminderEnabled;
  const AppSettingsTableData({
    required this.id,
    required this.selectedChildId,
    required this.volumeUnit,
    required this.weightUnit,
    required this.lengthUnit,
    required this.temperatureUnit,
    required this.notificationsEnabled,
    required this.weeklyPregnancyReminderEnabled,
    required this.trackingReminderEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['selected_child_id'] = Variable<String>(selectedChildId);
    map['volume_unit'] = Variable<int>(volumeUnit);
    map['weight_unit'] = Variable<int>(weightUnit);
    map['length_unit'] = Variable<int>(lengthUnit);
    map['temperature_unit'] = Variable<int>(temperatureUnit);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['weekly_pregnancy_reminder_enabled'] = Variable<bool>(
      weeklyPregnancyReminderEnabled,
    );
    map['tracking_reminder_enabled'] = Variable<bool>(trackingReminderEnabled);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      selectedChildId: Value(selectedChildId),
      volumeUnit: Value(volumeUnit),
      weightUnit: Value(weightUnit),
      lengthUnit: Value(lengthUnit),
      temperatureUnit: Value(temperatureUnit),
      notificationsEnabled: Value(notificationsEnabled),
      weeklyPregnancyReminderEnabled: Value(weeklyPregnancyReminderEnabled),
      trackingReminderEnabled: Value(trackingReminderEnabled),
    );
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      selectedChildId: serializer.fromJson<String>(json['selectedChildId']),
      volumeUnit: serializer.fromJson<int>(json['volumeUnit']),
      weightUnit: serializer.fromJson<int>(json['weightUnit']),
      lengthUnit: serializer.fromJson<int>(json['lengthUnit']),
      temperatureUnit: serializer.fromJson<int>(json['temperatureUnit']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      weeklyPregnancyReminderEnabled: serializer.fromJson<bool>(
        json['weeklyPregnancyReminderEnabled'],
      ),
      trackingReminderEnabled: serializer.fromJson<bool>(
        json['trackingReminderEnabled'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'selectedChildId': serializer.toJson<String>(selectedChildId),
      'volumeUnit': serializer.toJson<int>(volumeUnit),
      'weightUnit': serializer.toJson<int>(weightUnit),
      'lengthUnit': serializer.toJson<int>(lengthUnit),
      'temperatureUnit': serializer.toJson<int>(temperatureUnit),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'weeklyPregnancyReminderEnabled': serializer.toJson<bool>(
        weeklyPregnancyReminderEnabled,
      ),
      'trackingReminderEnabled': serializer.toJson<bool>(
        trackingReminderEnabled,
      ),
    };
  }

  AppSettingsTableData copyWith({
    int? id,
    String? selectedChildId,
    int? volumeUnit,
    int? weightUnit,
    int? lengthUnit,
    int? temperatureUnit,
    bool? notificationsEnabled,
    bool? weeklyPregnancyReminderEnabled,
    bool? trackingReminderEnabled,
  }) => AppSettingsTableData(
    id: id ?? this.id,
    selectedChildId: selectedChildId ?? this.selectedChildId,
    volumeUnit: volumeUnit ?? this.volumeUnit,
    weightUnit: weightUnit ?? this.weightUnit,
    lengthUnit: lengthUnit ?? this.lengthUnit,
    temperatureUnit: temperatureUnit ?? this.temperatureUnit,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    weeklyPregnancyReminderEnabled:
        weeklyPregnancyReminderEnabled ?? this.weeklyPregnancyReminderEnabled,
    trackingReminderEnabled:
        trackingReminderEnabled ?? this.trackingReminderEnabled,
  );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      selectedChildId: data.selectedChildId.present
          ? data.selectedChildId.value
          : this.selectedChildId,
      volumeUnit: data.volumeUnit.present
          ? data.volumeUnit.value
          : this.volumeUnit,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      lengthUnit: data.lengthUnit.present
          ? data.lengthUnit.value
          : this.lengthUnit,
      temperatureUnit: data.temperatureUnit.present
          ? data.temperatureUnit.value
          : this.temperatureUnit,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      weeklyPregnancyReminderEnabled:
          data.weeklyPregnancyReminderEnabled.present
          ? data.weeklyPregnancyReminderEnabled.value
          : this.weeklyPregnancyReminderEnabled,
      trackingReminderEnabled: data.trackingReminderEnabled.present
          ? data.trackingReminderEnabled.value
          : this.trackingReminderEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('id: $id, ')
          ..write('selectedChildId: $selectedChildId, ')
          ..write('volumeUnit: $volumeUnit, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('temperatureUnit: $temperatureUnit, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write(
            'weeklyPregnancyReminderEnabled: $weeklyPregnancyReminderEnabled, ',
          )
          ..write('trackingReminderEnabled: $trackingReminderEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    selectedChildId,
    volumeUnit,
    weightUnit,
    lengthUnit,
    temperatureUnit,
    notificationsEnabled,
    weeklyPregnancyReminderEnabled,
    trackingReminderEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.id == this.id &&
          other.selectedChildId == this.selectedChildId &&
          other.volumeUnit == this.volumeUnit &&
          other.weightUnit == this.weightUnit &&
          other.lengthUnit == this.lengthUnit &&
          other.temperatureUnit == this.temperatureUnit &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.weeklyPregnancyReminderEnabled ==
              this.weeklyPregnancyReminderEnabled &&
          other.trackingReminderEnabled == this.trackingReminderEnabled);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<int> id;
  final Value<String> selectedChildId;
  final Value<int> volumeUnit;
  final Value<int> weightUnit;
  final Value<int> lengthUnit;
  final Value<int> temperatureUnit;
  final Value<bool> notificationsEnabled;
  final Value<bool> weeklyPregnancyReminderEnabled;
  final Value<bool> trackingReminderEnabled;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.selectedChildId = const Value.absent(),
    this.volumeUnit = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.lengthUnit = const Value.absent(),
    this.temperatureUnit = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.weeklyPregnancyReminderEnabled = const Value.absent(),
    this.trackingReminderEnabled = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required String selectedChildId,
    required int volumeUnit,
    required int weightUnit,
    required int lengthUnit,
    required int temperatureUnit,
    required bool notificationsEnabled,
    required bool weeklyPregnancyReminderEnabled,
    required bool trackingReminderEnabled,
  }) : selectedChildId = Value(selectedChildId),
       volumeUnit = Value(volumeUnit),
       weightUnit = Value(weightUnit),
       lengthUnit = Value(lengthUnit),
       temperatureUnit = Value(temperatureUnit),
       notificationsEnabled = Value(notificationsEnabled),
       weeklyPregnancyReminderEnabled = Value(weeklyPregnancyReminderEnabled),
       trackingReminderEnabled = Value(trackingReminderEnabled);
  static Insertable<AppSettingsTableData> custom({
    Expression<int>? id,
    Expression<String>? selectedChildId,
    Expression<int>? volumeUnit,
    Expression<int>? weightUnit,
    Expression<int>? lengthUnit,
    Expression<int>? temperatureUnit,
    Expression<bool>? notificationsEnabled,
    Expression<bool>? weeklyPregnancyReminderEnabled,
    Expression<bool>? trackingReminderEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (selectedChildId != null) 'selected_child_id': selectedChildId,
      if (volumeUnit != null) 'volume_unit': volumeUnit,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (lengthUnit != null) 'length_unit': lengthUnit,
      if (temperatureUnit != null) 'temperature_unit': temperatureUnit,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (weeklyPregnancyReminderEnabled != null)
        'weekly_pregnancy_reminder_enabled': weeklyPregnancyReminderEnabled,
      if (trackingReminderEnabled != null)
        'tracking_reminder_enabled': trackingReminderEnabled,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? selectedChildId,
    Value<int>? volumeUnit,
    Value<int>? weightUnit,
    Value<int>? lengthUnit,
    Value<int>? temperatureUnit,
    Value<bool>? notificationsEnabled,
    Value<bool>? weeklyPregnancyReminderEnabled,
    Value<bool>? trackingReminderEnabled,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      selectedChildId: selectedChildId ?? this.selectedChildId,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      weightUnit: weightUnit ?? this.weightUnit,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weeklyPregnancyReminderEnabled:
          weeklyPregnancyReminderEnabled ?? this.weeklyPregnancyReminderEnabled,
      trackingReminderEnabled:
          trackingReminderEnabled ?? this.trackingReminderEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (selectedChildId.present) {
      map['selected_child_id'] = Variable<String>(selectedChildId.value);
    }
    if (volumeUnit.present) {
      map['volume_unit'] = Variable<int>(volumeUnit.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<int>(weightUnit.value);
    }
    if (lengthUnit.present) {
      map['length_unit'] = Variable<int>(lengthUnit.value);
    }
    if (temperatureUnit.present) {
      map['temperature_unit'] = Variable<int>(temperatureUnit.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (weeklyPregnancyReminderEnabled.present) {
      map['weekly_pregnancy_reminder_enabled'] = Variable<bool>(
        weeklyPregnancyReminderEnabled.value,
      );
    }
    if (trackingReminderEnabled.present) {
      map['tracking_reminder_enabled'] = Variable<bool>(
        trackingReminderEnabled.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('selectedChildId: $selectedChildId, ')
          ..write('volumeUnit: $volumeUnit, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('temperatureUnit: $temperatureUnit, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write(
            'weeklyPregnancyReminderEnabled: $weeklyPregnancyReminderEnabled, ',
          )
          ..write('trackingReminderEnabled: $trackingReminderEnabled')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTableTable extends AppMetaTable
    with TableInfo<$AppMetaTableTable, AppMetaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTableTable createAlias(String alias) {
    return $AppMetaTableTable(attachedDatabase, alias);
  }
}

class AppMetaTableData extends DataClass
    implements Insertable<AppMetaTableData> {
  final String key;
  final String value;
  const AppMetaTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaTableCompanion toCompanion(bool nullToAbsent) {
    return AppMetaTableCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaTableData copyWith({String? key, String? value}) =>
      AppMetaTableData(key: key ?? this.key, value: value ?? this.value);
  AppMetaTableData copyWithCompanion(AppMetaTableCompanion data) {
    return AppMetaTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaTableCompanion extends UpdateCompanion<AppMetaTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $ChildProfilesTable childProfiles = $ChildProfilesTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final $AppMetaTableTable appMetaTable = $AppMetaTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    childProfiles,
    appSettingsTable,
    appMetaTable,
  ];
}

typedef $$ChildProfilesTableCreateCompanionBuilder =
    ChildProfilesCompanion Function({
      required String id,
      required String name,
      required int gender,
      required int mode,
      Value<DateTime?> dueDate,
      Value<DateTime?> birthDate,
      Value<String?> medicalProviderPhone,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ChildProfilesTableUpdateCompanionBuilder =
    ChildProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> gender,
      Value<int> mode,
      Value<DateTime?> dueDate,
      Value<DateTime?> birthDate,
      Value<String?> medicalProviderPhone,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ChildProfilesTableFilterComposer
    extends Composer<_$LocalDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicalProviderPhone => $composableBuilder(
    column: $table.medicalProviderPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChildProfilesTableOrderingComposer
    extends Composer<_$LocalDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicalProviderPhone => $composableBuilder(
    column: $table.medicalProviderPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChildProfilesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get medicalProviderPhone => $composableBuilder(
    column: $table.medicalProviderPhone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChildProfilesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $ChildProfilesTable,
          ChildProfile,
          $$ChildProfilesTableFilterComposer,
          $$ChildProfilesTableOrderingComposer,
          $$ChildProfilesTableAnnotationComposer,
          $$ChildProfilesTableCreateCompanionBuilder,
          $$ChildProfilesTableUpdateCompanionBuilder,
          (
            ChildProfile,
            BaseReferences<_$LocalDatabase, $ChildProfilesTable, ChildProfile>,
          ),
          ChildProfile,
          PrefetchHooks Function()
        > {
  $$ChildProfilesTableTableManager(
    _$LocalDatabase db,
    $ChildProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> gender = const Value.absent(),
                Value<int> mode = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> medicalProviderPhone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChildProfilesCompanion(
                id: id,
                name: name,
                gender: gender,
                mode: mode,
                dueDate: dueDate,
                birthDate: birthDate,
                medicalProviderPhone: medicalProviderPhone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int gender,
                required int mode,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> medicalProviderPhone = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChildProfilesCompanion.insert(
                id: id,
                name: name,
                gender: gender,
                mode: mode,
                dueDate: dueDate,
                birthDate: birthDate,
                medicalProviderPhone: medicalProviderPhone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChildProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $ChildProfilesTable,
      ChildProfile,
      $$ChildProfilesTableFilterComposer,
      $$ChildProfilesTableOrderingComposer,
      $$ChildProfilesTableAnnotationComposer,
      $$ChildProfilesTableCreateCompanionBuilder,
      $$ChildProfilesTableUpdateCompanionBuilder,
      (
        ChildProfile,
        BaseReferences<_$LocalDatabase, $ChildProfilesTable, ChildProfile>,
      ),
      ChildProfile,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      required String selectedChildId,
      required int volumeUnit,
      required int weightUnit,
      required int lengthUnit,
      required int temperatureUnit,
      required bool notificationsEnabled,
      required bool weeklyPregnancyReminderEnabled,
      required bool trackingReminderEnabled,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      Value<String> selectedChildId,
      Value<int> volumeUnit,
      Value<int> weightUnit,
      Value<int> lengthUnit,
      Value<int> temperatureUnit,
      Value<bool> notificationsEnabled,
      Value<bool> weeklyPregnancyReminderEnabled,
      Value<bool> trackingReminderEnabled,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$LocalDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedChildId => $composableBuilder(
    column: $table.selectedChildId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lengthUnit => $composableBuilder(
    column: $table.lengthUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temperatureUnit => $composableBuilder(
    column: $table.temperatureUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weeklyPregnancyReminderEnabled => $composableBuilder(
    column: $table.weeklyPregnancyReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackingReminderEnabled => $composableBuilder(
    column: $table.trackingReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$LocalDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedChildId => $composableBuilder(
    column: $table.selectedChildId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lengthUnit => $composableBuilder(
    column: $table.lengthUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temperatureUnit => $composableBuilder(
    column: $table.temperatureUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weeklyPregnancyReminderEnabled =>
      $composableBuilder(
        column: $table.weeklyPregnancyReminderEnabled,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get trackingReminderEnabled => $composableBuilder(
    column: $table.trackingReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$LocalDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get selectedChildId => $composableBuilder(
    column: $table.selectedChildId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lengthUnit => $composableBuilder(
    column: $table.lengthUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get temperatureUnit => $composableBuilder(
    column: $table.temperatureUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weeklyPregnancyReminderEnabled =>
      $composableBuilder(
        column: $table.weeklyPregnancyReminderEnabled,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get trackingReminderEnabled => $composableBuilder(
    column: $table.trackingReminderEnabled,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$LocalDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$LocalDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> selectedChildId = const Value.absent(),
                Value<int> volumeUnit = const Value.absent(),
                Value<int> weightUnit = const Value.absent(),
                Value<int> lengthUnit = const Value.absent(),
                Value<int> temperatureUnit = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> weeklyPregnancyReminderEnabled =
                    const Value.absent(),
                Value<bool> trackingReminderEnabled = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                selectedChildId: selectedChildId,
                volumeUnit: volumeUnit,
                weightUnit: weightUnit,
                lengthUnit: lengthUnit,
                temperatureUnit: temperatureUnit,
                notificationsEnabled: notificationsEnabled,
                weeklyPregnancyReminderEnabled: weeklyPregnancyReminderEnabled,
                trackingReminderEnabled: trackingReminderEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String selectedChildId,
                required int volumeUnit,
                required int weightUnit,
                required int lengthUnit,
                required int temperatureUnit,
                required bool notificationsEnabled,
                required bool weeklyPregnancyReminderEnabled,
                required bool trackingReminderEnabled,
              }) => AppSettingsTableCompanion.insert(
                id: id,
                selectedChildId: selectedChildId,
                volumeUnit: volumeUnit,
                weightUnit: weightUnit,
                lengthUnit: lengthUnit,
                temperatureUnit: temperatureUnit,
                notificationsEnabled: notificationsEnabled,
                weeklyPregnancyReminderEnabled: weeklyPregnancyReminderEnabled,
                trackingReminderEnabled: trackingReminderEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$LocalDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableTableCreateCompanionBuilder =
    AppMetaTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableTableUpdateCompanionBuilder =
    AppMetaTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableTableFilterComposer
    extends Composer<_$LocalDatabase, $AppMetaTableTable> {
  $$AppMetaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableTableOrderingComposer
    extends Composer<_$LocalDatabase, $AppMetaTableTable> {
  $$AppMetaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableTableAnnotationComposer
    extends Composer<_$LocalDatabase, $AppMetaTableTable> {
  $$AppMetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $AppMetaTableTable,
          AppMetaTableData,
          $$AppMetaTableTableFilterComposer,
          $$AppMetaTableTableOrderingComposer,
          $$AppMetaTableTableAnnotationComposer,
          $$AppMetaTableTableCreateCompanionBuilder,
          $$AppMetaTableTableUpdateCompanionBuilder,
          (
            AppMetaTableData,
            BaseReferences<
              _$LocalDatabase,
              $AppMetaTableTable,
              AppMetaTableData
            >,
          ),
          AppMetaTableData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableTableManager(_$LocalDatabase db, $AppMetaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppMetaTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $AppMetaTableTable,
      AppMetaTableData,
      $$AppMetaTableTableFilterComposer,
      $$AppMetaTableTableOrderingComposer,
      $$AppMetaTableTableAnnotationComposer,
      $$AppMetaTableTableCreateCompanionBuilder,
      $$AppMetaTableTableUpdateCompanionBuilder,
      (
        AppMetaTableData,
        BaseReferences<_$LocalDatabase, $AppMetaTableTable, AppMetaTableData>,
      ),
      AppMetaTableData,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$ChildProfilesTableTableManager get childProfiles =>
      $$ChildProfilesTableTableManager(_db, _db.childProfiles);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$AppMetaTableTableTableManager get appMetaTable =>
      $$AppMetaTableTableTableManager(_db, _db.appMetaTable);
}
