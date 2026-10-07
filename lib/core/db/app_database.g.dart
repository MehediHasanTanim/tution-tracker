// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class Students extends Table with TableInfo<Students, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Students(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _classLevelMeta = const VerificationMeta(
    'classLevel',
  );
  late final GeneratedColumn<String> classLevel = GeneratedColumn<String>(
    'class_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _schoolMeta = const VerificationMeta('school');
  late final GeneratedColumn<String> school = GeneratedColumn<String>(
    'school',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _guardianNameMeta = const VerificationMeta(
    'guardianName',
  );
  late final GeneratedColumn<String> guardianName = GeneratedColumn<String>(
    'guardian_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _guardianPhoneMeta = const VerificationMeta(
    'guardianPhone',
  );
  late final GeneratedColumn<String> guardianPhone = GeneratedColumn<String>(
    'guardian_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _studentPhoneMeta = const VerificationMeta(
    'studentPhone',
  );
  late final GeneratedColumn<String> studentPhone = GeneratedColumn<String>(
    'student_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _subjectsMeta = const VerificationMeta(
    'subjects',
  );
  late final GeneratedColumn<String> subjects = GeneratedColumn<String>(
    'subjects',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _classDaysMeta = const VerificationMeta(
    'classDays',
  );
  late final GeneratedColumn<String> classDays = GeneratedColumn<String>(
    'class_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _classTimeMeta = const VerificationMeta(
    'classTime',
  );
  late final GeneratedColumn<String> classTime = GeneratedColumn<String>(
    'class_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _joinedOnMeta = const VerificationMeta(
    'joinedOn',
  );
  late final GeneratedColumn<String> joinedOn = GeneratedColumn<String>(
    'joined_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'active\' CHECK (status IN (\'active\', \'paused\', \'left\'))',
    defaultValue: const CustomExpression('\'active\''),
  );
  static const VerificationMeta _monthlyFeeMeta = const VerificationMeta(
    'monthlyFee',
  );
  late final GeneratedColumn<int> monthlyFee = GeneratedColumn<int>(
    'monthly_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (monthly_fee >= 0)',
  );
  static const VerificationMeta _feeDueDayMeta = const VerificationMeta(
    'feeDueDay',
  );
  late final GeneratedColumn<int> feeDueDay = GeneratedColumn<int>(
    'fee_due_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT 10 CHECK (fee_due_day BETWEEN 1 AND 31)',
    defaultValue: const CustomExpression('10'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    classLevel,
    school,
    guardianName,
    guardianPhone,
    studentPhone,
    address,
    photoPath,
    subjects,
    classDays,
    classTime,
    joinedOn,
    status,
    monthlyFee,
    feeDueDay,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
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
    if (data.containsKey('class_level')) {
      context.handle(
        _classLevelMeta,
        classLevel.isAcceptableOrUnknown(data['class_level']!, _classLevelMeta),
      );
    }
    if (data.containsKey('school')) {
      context.handle(
        _schoolMeta,
        school.isAcceptableOrUnknown(data['school']!, _schoolMeta),
      );
    }
    if (data.containsKey('guardian_name')) {
      context.handle(
        _guardianNameMeta,
        guardianName.isAcceptableOrUnknown(
          data['guardian_name']!,
          _guardianNameMeta,
        ),
      );
    }
    if (data.containsKey('guardian_phone')) {
      context.handle(
        _guardianPhoneMeta,
        guardianPhone.isAcceptableOrUnknown(
          data['guardian_phone']!,
          _guardianPhoneMeta,
        ),
      );
    }
    if (data.containsKey('student_phone')) {
      context.handle(
        _studentPhoneMeta,
        studentPhone.isAcceptableOrUnknown(
          data['student_phone']!,
          _studentPhoneMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('subjects')) {
      context.handle(
        _subjectsMeta,
        subjects.isAcceptableOrUnknown(data['subjects']!, _subjectsMeta),
      );
    }
    if (data.containsKey('class_days')) {
      context.handle(
        _classDaysMeta,
        classDays.isAcceptableOrUnknown(data['class_days']!, _classDaysMeta),
      );
    }
    if (data.containsKey('class_time')) {
      context.handle(
        _classTimeMeta,
        classTime.isAcceptableOrUnknown(data['class_time']!, _classTimeMeta),
      );
    }
    if (data.containsKey('joined_on')) {
      context.handle(
        _joinedOnMeta,
        joinedOn.isAcceptableOrUnknown(data['joined_on']!, _joinedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedOnMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('monthly_fee')) {
      context.handle(
        _monthlyFeeMeta,
        monthlyFee.isAcceptableOrUnknown(data['monthly_fee']!, _monthlyFeeMeta),
      );
    } else if (isInserting) {
      context.missing(_monthlyFeeMeta);
    }
    if (data.containsKey('fee_due_day')) {
      context.handle(
        _feeDueDayMeta,
        feeDueDay.isAcceptableOrUnknown(data['fee_due_day']!, _feeDueDayMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      classLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_level'],
      ),
      school: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school'],
      ),
      guardianName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guardian_name'],
      ),
      guardianPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guardian_phone'],
      ),
      studentPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      subjects: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subjects'],
      ),
      classDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_days'],
      ),
      classTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_time'],
      ),
      joinedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}joined_on'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      monthlyFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_fee'],
      )!,
      feeDueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_due_day'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Students createAlias(String alias) {
    return Students(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Student extends DataClass implements Insertable<Student> {
  final String id;
  final String name;
  final String? classLevel;
  final String? school;
  final String? guardianName;
  final String? guardianPhone;
  final String? studentPhone;
  final String? address;
  final String? photoPath;
  final String? subjects;

  /// JSON array
  final String? classDays;

  /// JSON [1,3,5] ISO weekdays (one-to-one classes)
  final String? classTime;

  /// HH:mm
  final String joinedOn;
  final String status;
  final int monthlyFee;
  final int feeDueDay;
  final String? notes;
  final int createdAt;
  final int updatedAt;
  const Student({
    required this.id,
    required this.name,
    this.classLevel,
    this.school,
    this.guardianName,
    this.guardianPhone,
    this.studentPhone,
    this.address,
    this.photoPath,
    this.subjects,
    this.classDays,
    this.classTime,
    required this.joinedOn,
    required this.status,
    required this.monthlyFee,
    required this.feeDueDay,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || classLevel != null) {
      map['class_level'] = Variable<String>(classLevel);
    }
    if (!nullToAbsent || school != null) {
      map['school'] = Variable<String>(school);
    }
    if (!nullToAbsent || guardianName != null) {
      map['guardian_name'] = Variable<String>(guardianName);
    }
    if (!nullToAbsent || guardianPhone != null) {
      map['guardian_phone'] = Variable<String>(guardianPhone);
    }
    if (!nullToAbsent || studentPhone != null) {
      map['student_phone'] = Variable<String>(studentPhone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || subjects != null) {
      map['subjects'] = Variable<String>(subjects);
    }
    if (!nullToAbsent || classDays != null) {
      map['class_days'] = Variable<String>(classDays);
    }
    if (!nullToAbsent || classTime != null) {
      map['class_time'] = Variable<String>(classTime);
    }
    map['joined_on'] = Variable<String>(joinedOn);
    map['status'] = Variable<String>(status);
    map['monthly_fee'] = Variable<int>(monthlyFee);
    map['fee_due_day'] = Variable<int>(feeDueDay);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      name: Value(name),
      classLevel: classLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(classLevel),
      school: school == null && nullToAbsent
          ? const Value.absent()
          : Value(school),
      guardianName: guardianName == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianName),
      guardianPhone: guardianPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianPhone),
      studentPhone: studentPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(studentPhone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      subjects: subjects == null && nullToAbsent
          ? const Value.absent()
          : Value(subjects),
      classDays: classDays == null && nullToAbsent
          ? const Value.absent()
          : Value(classDays),
      classTime: classTime == null && nullToAbsent
          ? const Value.absent()
          : Value(classTime),
      joinedOn: Value(joinedOn),
      status: Value(status),
      monthlyFee: Value(monthlyFee),
      feeDueDay: Value(feeDueDay),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      classLevel: serializer.fromJson<String?>(json['class_level']),
      school: serializer.fromJson<String?>(json['school']),
      guardianName: serializer.fromJson<String?>(json['guardian_name']),
      guardianPhone: serializer.fromJson<String?>(json['guardian_phone']),
      studentPhone: serializer.fromJson<String?>(json['student_phone']),
      address: serializer.fromJson<String?>(json['address']),
      photoPath: serializer.fromJson<String?>(json['photo_path']),
      subjects: serializer.fromJson<String?>(json['subjects']),
      classDays: serializer.fromJson<String?>(json['class_days']),
      classTime: serializer.fromJson<String?>(json['class_time']),
      joinedOn: serializer.fromJson<String>(json['joined_on']),
      status: serializer.fromJson<String>(json['status']),
      monthlyFee: serializer.fromJson<int>(json['monthly_fee']),
      feeDueDay: serializer.fromJson<int>(json['fee_due_day']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'class_level': serializer.toJson<String?>(classLevel),
      'school': serializer.toJson<String?>(school),
      'guardian_name': serializer.toJson<String?>(guardianName),
      'guardian_phone': serializer.toJson<String?>(guardianPhone),
      'student_phone': serializer.toJson<String?>(studentPhone),
      'address': serializer.toJson<String?>(address),
      'photo_path': serializer.toJson<String?>(photoPath),
      'subjects': serializer.toJson<String?>(subjects),
      'class_days': serializer.toJson<String?>(classDays),
      'class_time': serializer.toJson<String?>(classTime),
      'joined_on': serializer.toJson<String>(joinedOn),
      'status': serializer.toJson<String>(status),
      'monthly_fee': serializer.toJson<int>(monthlyFee),
      'fee_due_day': serializer.toJson<int>(feeDueDay),
      'notes': serializer.toJson<String?>(notes),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  Student copyWith({
    String? id,
    String? name,
    Value<String?> classLevel = const Value.absent(),
    Value<String?> school = const Value.absent(),
    Value<String?> guardianName = const Value.absent(),
    Value<String?> guardianPhone = const Value.absent(),
    Value<String?> studentPhone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<String?> subjects = const Value.absent(),
    Value<String?> classDays = const Value.absent(),
    Value<String?> classTime = const Value.absent(),
    String? joinedOn,
    String? status,
    int? monthlyFee,
    int? feeDueDay,
    Value<String?> notes = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => Student(
    id: id ?? this.id,
    name: name ?? this.name,
    classLevel: classLevel.present ? classLevel.value : this.classLevel,
    school: school.present ? school.value : this.school,
    guardianName: guardianName.present ? guardianName.value : this.guardianName,
    guardianPhone: guardianPhone.present
        ? guardianPhone.value
        : this.guardianPhone,
    studentPhone: studentPhone.present ? studentPhone.value : this.studentPhone,
    address: address.present ? address.value : this.address,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    subjects: subjects.present ? subjects.value : this.subjects,
    classDays: classDays.present ? classDays.value : this.classDays,
    classTime: classTime.present ? classTime.value : this.classTime,
    joinedOn: joinedOn ?? this.joinedOn,
    status: status ?? this.status,
    monthlyFee: monthlyFee ?? this.monthlyFee,
    feeDueDay: feeDueDay ?? this.feeDueDay,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      classLevel: data.classLevel.present
          ? data.classLevel.value
          : this.classLevel,
      school: data.school.present ? data.school.value : this.school,
      guardianName: data.guardianName.present
          ? data.guardianName.value
          : this.guardianName,
      guardianPhone: data.guardianPhone.present
          ? data.guardianPhone.value
          : this.guardianPhone,
      studentPhone: data.studentPhone.present
          ? data.studentPhone.value
          : this.studentPhone,
      address: data.address.present ? data.address.value : this.address,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      subjects: data.subjects.present ? data.subjects.value : this.subjects,
      classDays: data.classDays.present ? data.classDays.value : this.classDays,
      classTime: data.classTime.present ? data.classTime.value : this.classTime,
      joinedOn: data.joinedOn.present ? data.joinedOn.value : this.joinedOn,
      status: data.status.present ? data.status.value : this.status,
      monthlyFee: data.monthlyFee.present
          ? data.monthlyFee.value
          : this.monthlyFee,
      feeDueDay: data.feeDueDay.present ? data.feeDueDay.value : this.feeDueDay,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('classLevel: $classLevel, ')
          ..write('school: $school, ')
          ..write('guardianName: $guardianName, ')
          ..write('guardianPhone: $guardianPhone, ')
          ..write('studentPhone: $studentPhone, ')
          ..write('address: $address, ')
          ..write('photoPath: $photoPath, ')
          ..write('subjects: $subjects, ')
          ..write('classDays: $classDays, ')
          ..write('classTime: $classTime, ')
          ..write('joinedOn: $joinedOn, ')
          ..write('status: $status, ')
          ..write('monthlyFee: $monthlyFee, ')
          ..write('feeDueDay: $feeDueDay, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    classLevel,
    school,
    guardianName,
    guardianPhone,
    studentPhone,
    address,
    photoPath,
    subjects,
    classDays,
    classTime,
    joinedOn,
    status,
    monthlyFee,
    feeDueDay,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.name == this.name &&
          other.classLevel == this.classLevel &&
          other.school == this.school &&
          other.guardianName == this.guardianName &&
          other.guardianPhone == this.guardianPhone &&
          other.studentPhone == this.studentPhone &&
          other.address == this.address &&
          other.photoPath == this.photoPath &&
          other.subjects == this.subjects &&
          other.classDays == this.classDays &&
          other.classTime == this.classTime &&
          other.joinedOn == this.joinedOn &&
          other.status == this.status &&
          other.monthlyFee == this.monthlyFee &&
          other.feeDueDay == this.feeDueDay &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> classLevel;
  final Value<String?> school;
  final Value<String?> guardianName;
  final Value<String?> guardianPhone;
  final Value<String?> studentPhone;
  final Value<String?> address;
  final Value<String?> photoPath;
  final Value<String?> subjects;
  final Value<String?> classDays;
  final Value<String?> classTime;
  final Value<String> joinedOn;
  final Value<String> status;
  final Value<int> monthlyFee;
  final Value<int> feeDueDay;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.classLevel = const Value.absent(),
    this.school = const Value.absent(),
    this.guardianName = const Value.absent(),
    this.guardianPhone = const Value.absent(),
    this.studentPhone = const Value.absent(),
    this.address = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.subjects = const Value.absent(),
    this.classDays = const Value.absent(),
    this.classTime = const Value.absent(),
    this.joinedOn = const Value.absent(),
    this.status = const Value.absent(),
    this.monthlyFee = const Value.absent(),
    this.feeDueDay = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String id,
    required String name,
    this.classLevel = const Value.absent(),
    this.school = const Value.absent(),
    this.guardianName = const Value.absent(),
    this.guardianPhone = const Value.absent(),
    this.studentPhone = const Value.absent(),
    this.address = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.subjects = const Value.absent(),
    this.classDays = const Value.absent(),
    this.classTime = const Value.absent(),
    required String joinedOn,
    this.status = const Value.absent(),
    required int monthlyFee,
    this.feeDueDay = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       joinedOn = Value(joinedOn),
       monthlyFee = Value(monthlyFee),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Student> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? classLevel,
    Expression<String>? school,
    Expression<String>? guardianName,
    Expression<String>? guardianPhone,
    Expression<String>? studentPhone,
    Expression<String>? address,
    Expression<String>? photoPath,
    Expression<String>? subjects,
    Expression<String>? classDays,
    Expression<String>? classTime,
    Expression<String>? joinedOn,
    Expression<String>? status,
    Expression<int>? monthlyFee,
    Expression<int>? feeDueDay,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (classLevel != null) 'class_level': classLevel,
      if (school != null) 'school': school,
      if (guardianName != null) 'guardian_name': guardianName,
      if (guardianPhone != null) 'guardian_phone': guardianPhone,
      if (studentPhone != null) 'student_phone': studentPhone,
      if (address != null) 'address': address,
      if (photoPath != null) 'photo_path': photoPath,
      if (subjects != null) 'subjects': subjects,
      if (classDays != null) 'class_days': classDays,
      if (classTime != null) 'class_time': classTime,
      if (joinedOn != null) 'joined_on': joinedOn,
      if (status != null) 'status': status,
      if (monthlyFee != null) 'monthly_fee': monthlyFee,
      if (feeDueDay != null) 'fee_due_day': feeDueDay,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? classLevel,
    Value<String?>? school,
    Value<String?>? guardianName,
    Value<String?>? guardianPhone,
    Value<String?>? studentPhone,
    Value<String?>? address,
    Value<String?>? photoPath,
    Value<String?>? subjects,
    Value<String?>? classDays,
    Value<String?>? classTime,
    Value<String>? joinedOn,
    Value<String>? status,
    Value<int>? monthlyFee,
    Value<int>? feeDueDay,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      classLevel: classLevel ?? this.classLevel,
      school: school ?? this.school,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      studentPhone: studentPhone ?? this.studentPhone,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
      subjects: subjects ?? this.subjects,
      classDays: classDays ?? this.classDays,
      classTime: classTime ?? this.classTime,
      joinedOn: joinedOn ?? this.joinedOn,
      status: status ?? this.status,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      feeDueDay: feeDueDay ?? this.feeDueDay,
      notes: notes ?? this.notes,
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
    if (classLevel.present) {
      map['class_level'] = Variable<String>(classLevel.value);
    }
    if (school.present) {
      map['school'] = Variable<String>(school.value);
    }
    if (guardianName.present) {
      map['guardian_name'] = Variable<String>(guardianName.value);
    }
    if (guardianPhone.present) {
      map['guardian_phone'] = Variable<String>(guardianPhone.value);
    }
    if (studentPhone.present) {
      map['student_phone'] = Variable<String>(studentPhone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (subjects.present) {
      map['subjects'] = Variable<String>(subjects.value);
    }
    if (classDays.present) {
      map['class_days'] = Variable<String>(classDays.value);
    }
    if (classTime.present) {
      map['class_time'] = Variable<String>(classTime.value);
    }
    if (joinedOn.present) {
      map['joined_on'] = Variable<String>(joinedOn.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (monthlyFee.present) {
      map['monthly_fee'] = Variable<int>(monthlyFee.value);
    }
    if (feeDueDay.present) {
      map['fee_due_day'] = Variable<int>(feeDueDay.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('classLevel: $classLevel, ')
          ..write('school: $school, ')
          ..write('guardianName: $guardianName, ')
          ..write('guardianPhone: $guardianPhone, ')
          ..write('studentPhone: $studentPhone, ')
          ..write('address: $address, ')
          ..write('photoPath: $photoPath, ')
          ..write('subjects: $subjects, ')
          ..write('classDays: $classDays, ')
          ..write('classTime: $classTime, ')
          ..write('joinedOn: $joinedOn, ')
          ..write('status: $status, ')
          ..write('monthlyFee: $monthlyFee, ')
          ..write('feeDueDay: $feeDueDay, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Batches extends Table with TableInfo<Batches, Batch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Batches(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _classLevelMeta = const VerificationMeta(
    'classLevel',
  );
  late final GeneratedColumn<String> classLevel = GeneratedColumn<String>(
    'class_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _scheduleDaysMeta = const VerificationMeta(
    'scheduleDays',
  );
  late final GeneratedColumn<String> scheduleDays = GeneratedColumn<String>(
    'schedule_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _defaultFeeMeta = const VerificationMeta(
    'defaultFee',
  );
  late final GeneratedColumn<int> defaultFee = GeneratedColumn<int>(
    'default_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (default_fee >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'active\' CHECK (status IN (\'active\', \'archived\'))',
    defaultValue: const CustomExpression('\'active\''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    subject,
    classLevel,
    scheduleDays,
    startTime,
    durationMin,
    defaultFee,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Batch> instance, {
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
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('class_level')) {
      context.handle(
        _classLevelMeta,
        classLevel.isAcceptableOrUnknown(data['class_level']!, _classLevelMeta),
      );
    }
    if (data.containsKey('schedule_days')) {
      context.handle(
        _scheduleDaysMeta,
        scheduleDays.isAcceptableOrUnknown(
          data['schedule_days']!,
          _scheduleDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleDaysMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('default_fee')) {
      context.handle(
        _defaultFeeMeta,
        defaultFee.isAcceptableOrUnknown(data['default_fee']!, _defaultFeeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  Batch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Batch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      ),
      classLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_level'],
      ),
      scheduleDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_days'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
      defaultFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_fee'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Batches createAlias(String alias) {
    return Batches(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Batch extends DataClass implements Insertable<Batch> {
  final String id;
  final String name;
  final String? subject;
  final String? classLevel;
  final String scheduleDays;

  /// JSON [1,3,5] ISO weekdays
  final String? startTime;

  /// HH:mm
  final int? durationMin;
  final int defaultFee;
  final String status;
  final int createdAt;
  final int updatedAt;
  const Batch({
    required this.id,
    required this.name,
    this.subject,
    this.classLevel,
    required this.scheduleDays,
    this.startTime,
    this.durationMin,
    required this.defaultFee,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || classLevel != null) {
      map['class_level'] = Variable<String>(classLevel);
    }
    map['schedule_days'] = Variable<String>(scheduleDays);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    map['default_fee'] = Variable<int>(defaultFee);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      name: Value(name),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      classLevel: classLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(classLevel),
      scheduleDays: Value(scheduleDays),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      durationMin: durationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMin),
      defaultFee: Value(defaultFee),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Batch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Batch(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      subject: serializer.fromJson<String?>(json['subject']),
      classLevel: serializer.fromJson<String?>(json['class_level']),
      scheduleDays: serializer.fromJson<String>(json['schedule_days']),
      startTime: serializer.fromJson<String?>(json['start_time']),
      durationMin: serializer.fromJson<int?>(json['duration_min']),
      defaultFee: serializer.fromJson<int>(json['default_fee']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'subject': serializer.toJson<String?>(subject),
      'class_level': serializer.toJson<String?>(classLevel),
      'schedule_days': serializer.toJson<String>(scheduleDays),
      'start_time': serializer.toJson<String?>(startTime),
      'duration_min': serializer.toJson<int?>(durationMin),
      'default_fee': serializer.toJson<int>(defaultFee),
      'status': serializer.toJson<String>(status),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  Batch copyWith({
    String? id,
    String? name,
    Value<String?> subject = const Value.absent(),
    Value<String?> classLevel = const Value.absent(),
    String? scheduleDays,
    Value<String?> startTime = const Value.absent(),
    Value<int?> durationMin = const Value.absent(),
    int? defaultFee,
    String? status,
    int? createdAt,
    int? updatedAt,
  }) => Batch(
    id: id ?? this.id,
    name: name ?? this.name,
    subject: subject.present ? subject.value : this.subject,
    classLevel: classLevel.present ? classLevel.value : this.classLevel,
    scheduleDays: scheduleDays ?? this.scheduleDays,
    startTime: startTime.present ? startTime.value : this.startTime,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    defaultFee: defaultFee ?? this.defaultFee,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Batch copyWithCompanion(BatchesCompanion data) {
    return Batch(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      subject: data.subject.present ? data.subject.value : this.subject,
      classLevel: data.classLevel.present
          ? data.classLevel.value
          : this.classLevel,
      scheduleDays: data.scheduleDays.present
          ? data.scheduleDays.value
          : this.scheduleDays,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      defaultFee: data.defaultFee.present
          ? data.defaultFee.value
          : this.defaultFee,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Batch(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subject: $subject, ')
          ..write('classLevel: $classLevel, ')
          ..write('scheduleDays: $scheduleDays, ')
          ..write('startTime: $startTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('defaultFee: $defaultFee, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    subject,
    classLevel,
    scheduleDays,
    startTime,
    durationMin,
    defaultFee,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Batch &&
          other.id == this.id &&
          other.name == this.name &&
          other.subject == this.subject &&
          other.classLevel == this.classLevel &&
          other.scheduleDays == this.scheduleDays &&
          other.startTime == this.startTime &&
          other.durationMin == this.durationMin &&
          other.defaultFee == this.defaultFee &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BatchesCompanion extends UpdateCompanion<Batch> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> subject;
  final Value<String?> classLevel;
  final Value<String> scheduleDays;
  final Value<String?> startTime;
  final Value<int?> durationMin;
  final Value<int> defaultFee;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.subject = const Value.absent(),
    this.classLevel = const Value.absent(),
    this.scheduleDays = const Value.absent(),
    this.startTime = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.defaultFee = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchesCompanion.insert({
    required String id,
    required String name,
    this.subject = const Value.absent(),
    this.classLevel = const Value.absent(),
    required String scheduleDays,
    this.startTime = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.defaultFee = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       scheduleDays = Value(scheduleDays),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Batch> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? subject,
    Expression<String>? classLevel,
    Expression<String>? scheduleDays,
    Expression<String>? startTime,
    Expression<int>? durationMin,
    Expression<int>? defaultFee,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (subject != null) 'subject': subject,
      if (classLevel != null) 'class_level': classLevel,
      if (scheduleDays != null) 'schedule_days': scheduleDays,
      if (startTime != null) 'start_time': startTime,
      if (durationMin != null) 'duration_min': durationMin,
      if (defaultFee != null) 'default_fee': defaultFee,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? subject,
    Value<String?>? classLevel,
    Value<String>? scheduleDays,
    Value<String?>? startTime,
    Value<int?>? durationMin,
    Value<int>? defaultFee,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      classLevel: classLevel ?? this.classLevel,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      startTime: startTime ?? this.startTime,
      durationMin: durationMin ?? this.durationMin,
      defaultFee: defaultFee ?? this.defaultFee,
      status: status ?? this.status,
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
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (classLevel.present) {
      map['class_level'] = Variable<String>(classLevel.value);
    }
    if (scheduleDays.present) {
      map['schedule_days'] = Variable<String>(scheduleDays.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (defaultFee.present) {
      map['default_fee'] = Variable<int>(defaultFee.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subject: $subject, ')
          ..write('classLevel: $classLevel, ')
          ..write('scheduleDays: $scheduleDays, ')
          ..write('startTime: $startTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('defaultFee: $defaultFee, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BatchMembers extends Table with TableInfo<BatchMembers, BatchMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BatchMembers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES batches(id)',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES students(id)',
  );
  static const VerificationMeta _feeOverrideMeta = const VerificationMeta(
    'feeOverride',
  );
  late final GeneratedColumn<int> feeOverride = GeneratedColumn<int>(
    'fee_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (fee_override IS NULL OR fee_override >= 0)',
  );
  static const VerificationMeta _joinedOnMeta = const VerificationMeta(
    'joinedOn',
  );
  late final GeneratedColumn<String> joinedOn = GeneratedColumn<String>(
    'joined_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _leftOnMeta = const VerificationMeta('leftOn');
  late final GeneratedColumn<String> leftOn = GeneratedColumn<String>(
    'left_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    studentId,
    feeOverride,
    joinedOn,
    leftOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batch_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('fee_override')) {
      context.handle(
        _feeOverrideMeta,
        feeOverride.isAcceptableOrUnknown(
          data['fee_override']!,
          _feeOverrideMeta,
        ),
      );
    }
    if (data.containsKey('joined_on')) {
      context.handle(
        _joinedOnMeta,
        joinedOn.isAcceptableOrUnknown(data['joined_on']!, _joinedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedOnMeta);
    }
    if (data.containsKey('left_on')) {
      context.handle(
        _leftOnMeta,
        leftOn.isAcceptableOrUnknown(data['left_on']!, _leftOnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {batchId, studentId},
  ];
  @override
  BatchMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      feeOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_override'],
      ),
      joinedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}joined_on'],
      )!,
      leftOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}left_on'],
      ),
    );
  }

  @override
  BatchMembers createAlias(String alias) {
    return BatchMembers(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(batch_id, student_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class BatchMember extends DataClass implements Insertable<BatchMember> {
  final String id;
  final String batchId;
  final String studentId;
  final int? feeOverride;
  final String joinedOn;
  final String? leftOn;
  const BatchMember({
    required this.id,
    required this.batchId,
    required this.studentId,
    this.feeOverride,
    required this.joinedOn,
    this.leftOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['batch_id'] = Variable<String>(batchId);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || feeOverride != null) {
      map['fee_override'] = Variable<int>(feeOverride);
    }
    map['joined_on'] = Variable<String>(joinedOn);
    if (!nullToAbsent || leftOn != null) {
      map['left_on'] = Variable<String>(leftOn);
    }
    return map;
  }

  BatchMembersCompanion toCompanion(bool nullToAbsent) {
    return BatchMembersCompanion(
      id: Value(id),
      batchId: Value(batchId),
      studentId: Value(studentId),
      feeOverride: feeOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(feeOverride),
      joinedOn: Value(joinedOn),
      leftOn: leftOn == null && nullToAbsent
          ? const Value.absent()
          : Value(leftOn),
    );
  }

  factory BatchMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchMember(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String>(json['batch_id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      feeOverride: serializer.fromJson<int?>(json['fee_override']),
      joinedOn: serializer.fromJson<String>(json['joined_on']),
      leftOn: serializer.fromJson<String?>(json['left_on']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batch_id': serializer.toJson<String>(batchId),
      'student_id': serializer.toJson<String>(studentId),
      'fee_override': serializer.toJson<int?>(feeOverride),
      'joined_on': serializer.toJson<String>(joinedOn),
      'left_on': serializer.toJson<String?>(leftOn),
    };
  }

  BatchMember copyWith({
    String? id,
    String? batchId,
    String? studentId,
    Value<int?> feeOverride = const Value.absent(),
    String? joinedOn,
    Value<String?> leftOn = const Value.absent(),
  }) => BatchMember(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    studentId: studentId ?? this.studentId,
    feeOverride: feeOverride.present ? feeOverride.value : this.feeOverride,
    joinedOn: joinedOn ?? this.joinedOn,
    leftOn: leftOn.present ? leftOn.value : this.leftOn,
  );
  BatchMember copyWithCompanion(BatchMembersCompanion data) {
    return BatchMember(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      feeOverride: data.feeOverride.present
          ? data.feeOverride.value
          : this.feeOverride,
      joinedOn: data.joinedOn.present ? data.joinedOn.value : this.joinedOn,
      leftOn: data.leftOn.present ? data.leftOn.value : this.leftOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchMember(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('studentId: $studentId, ')
          ..write('feeOverride: $feeOverride, ')
          ..write('joinedOn: $joinedOn, ')
          ..write('leftOn: $leftOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, batchId, studentId, feeOverride, joinedOn, leftOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchMember &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.studentId == this.studentId &&
          other.feeOverride == this.feeOverride &&
          other.joinedOn == this.joinedOn &&
          other.leftOn == this.leftOn);
}

class BatchMembersCompanion extends UpdateCompanion<BatchMember> {
  final Value<String> id;
  final Value<String> batchId;
  final Value<String> studentId;
  final Value<int?> feeOverride;
  final Value<String> joinedOn;
  final Value<String?> leftOn;
  final Value<int> rowid;
  const BatchMembersCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.feeOverride = const Value.absent(),
    this.joinedOn = const Value.absent(),
    this.leftOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchMembersCompanion.insert({
    required String id,
    required String batchId,
    required String studentId,
    this.feeOverride = const Value.absent(),
    required String joinedOn,
    this.leftOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       batchId = Value(batchId),
       studentId = Value(studentId),
       joinedOn = Value(joinedOn);
  static Insertable<BatchMember> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<String>? studentId,
    Expression<int>? feeOverride,
    Expression<String>? joinedOn,
    Expression<String>? leftOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (studentId != null) 'student_id': studentId,
      if (feeOverride != null) 'fee_override': feeOverride,
      if (joinedOn != null) 'joined_on': joinedOn,
      if (leftOn != null) 'left_on': leftOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? batchId,
    Value<String>? studentId,
    Value<int?>? feeOverride,
    Value<String>? joinedOn,
    Value<String?>? leftOn,
    Value<int>? rowid,
  }) {
    return BatchMembersCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      studentId: studentId ?? this.studentId,
      feeOverride: feeOverride ?? this.feeOverride,
      joinedOn: joinedOn ?? this.joinedOn,
      leftOn: leftOn ?? this.leftOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (feeOverride.present) {
      map['fee_override'] = Variable<int>(feeOverride.value);
    }
    if (joinedOn.present) {
      map['joined_on'] = Variable<String>(joinedOn.value);
    }
    if (leftOn.present) {
      map['left_on'] = Variable<String>(leftOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchMembersCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('studentId: $studentId, ')
          ..write('feeOverride: $feeOverride, ')
          ..write('joinedOn: $joinedOn, ')
          ..write('leftOn: $leftOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ClassSessions extends Table with TableInfo<ClassSessions, ClassSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ClassSessions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES batches(id)',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES students(id)',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'held\' CHECK (status IN (\'held\', \'cancelled\', \'holiday\'))',
    defaultValue: const CustomExpression('\'held\''),
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    studentId,
    date,
    startTime,
    status,
    topic,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  ClassSessions createAlias(String alias) {
    return ClassSessions(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK(batch_id IS NOT NULL OR student_id IS NOT NULL)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ClassSession extends DataClass implements Insertable<ClassSession> {
  final String id;
  final String? batchId;
  final String? studentId;

  /// one-to-one classes
  final String date;
  final String? startTime;
  final String status;
  final String? topic;
  final String? note;
  const ClassSession({
    required this.id,
    this.batchId,
    this.studentId,
    required this.date,
    this.startTime,
    required this.status,
    this.topic,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || studentId != null) {
      map['student_id'] = Variable<String>(studentId);
    }
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ClassSessionsCompanion toCompanion(bool nullToAbsent) {
    return ClassSessionsCompanion(
      id: Value(id),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      studentId: studentId == null && nullToAbsent
          ? const Value.absent()
          : Value(studentId),
      date: Value(date),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      status: Value(status),
      topic: topic == null && nullToAbsent
          ? const Value.absent()
          : Value(topic),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ClassSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassSession(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String?>(json['batch_id']),
      studentId: serializer.fromJson<String?>(json['student_id']),
      date: serializer.fromJson<String>(json['date']),
      startTime: serializer.fromJson<String?>(json['start_time']),
      status: serializer.fromJson<String>(json['status']),
      topic: serializer.fromJson<String?>(json['topic']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batch_id': serializer.toJson<String?>(batchId),
      'student_id': serializer.toJson<String?>(studentId),
      'date': serializer.toJson<String>(date),
      'start_time': serializer.toJson<String?>(startTime),
      'status': serializer.toJson<String>(status),
      'topic': serializer.toJson<String?>(topic),
      'note': serializer.toJson<String?>(note),
    };
  }

  ClassSession copyWith({
    String? id,
    Value<String?> batchId = const Value.absent(),
    Value<String?> studentId = const Value.absent(),
    String? date,
    Value<String?> startTime = const Value.absent(),
    String? status,
    Value<String?> topic = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => ClassSession(
    id: id ?? this.id,
    batchId: batchId.present ? batchId.value : this.batchId,
    studentId: studentId.present ? studentId.value : this.studentId,
    date: date ?? this.date,
    startTime: startTime.present ? startTime.value : this.startTime,
    status: status ?? this.status,
    topic: topic.present ? topic.value : this.topic,
    note: note.present ? note.value : this.note,
  );
  ClassSession copyWithCompanion(ClassSessionsCompanion data) {
    return ClassSession(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      status: data.status.present ? data.status.value : this.status,
      topic: data.topic.present ? data.topic.value : this.topic,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassSession(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('status: $status, ')
          ..write('topic: $topic, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, batchId, studentId, date, startTime, status, topic, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassSession &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.studentId == this.studentId &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.status == this.status &&
          other.topic == this.topic &&
          other.note == this.note);
}

class ClassSessionsCompanion extends UpdateCompanion<ClassSession> {
  final Value<String> id;
  final Value<String?> batchId;
  final Value<String?> studentId;
  final Value<String> date;
  final Value<String?> startTime;
  final Value<String> status;
  final Value<String?> topic;
  final Value<String?> note;
  final Value<int> rowid;
  const ClassSessionsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.status = const Value.absent(),
    this.topic = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassSessionsCompanion.insert({
    required String id,
    this.batchId = const Value.absent(),
    this.studentId = const Value.absent(),
    required String date,
    this.startTime = const Value.absent(),
    this.status = const Value.absent(),
    this.topic = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date);
  static Insertable<ClassSession> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<String>? studentId,
    Expression<String>? date,
    Expression<String>? startTime,
    Expression<String>? status,
    Expression<String>? topic,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (studentId != null) 'student_id': studentId,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (status != null) 'status': status,
      if (topic != null) 'topic': topic,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassSessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? batchId,
    Value<String?>? studentId,
    Value<String>? date,
    Value<String?>? startTime,
    Value<String>? status,
    Value<String?>? topic,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return ClassSessionsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      topic: topic ?? this.topic,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassSessionsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('status: $status, ')
          ..write('topic: $topic, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Attendance extends Table with TableInfo<Attendance, AttendanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Attendance(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES class_sessions(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES students(id)',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'present\', \'absent\', \'late\', \'excused\'))',
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, studentId, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, studentId},
  ];
  @override
  AttendanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  Attendance createAlias(String alias) {
    return Attendance(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(session_id, student_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class AttendanceRecord extends DataClass
    implements Insertable<AttendanceRecord> {
  final String id;
  final String sessionId;
  final String studentId;
  final String status;
  const AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['student_id'] = Variable<String>(studentId);
    map['status'] = Variable<String>(status);
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      studentId: Value(studentId),
      status: Value(status),
    );
  }

  factory AttendanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceRecord(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['session_id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'session_id': serializer.toJson<String>(sessionId),
      'student_id': serializer.toJson<String>(studentId),
      'status': serializer.toJson<String>(status),
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? status,
  }) => AttendanceRecord(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    studentId: studentId ?? this.studentId,
    status: status ?? this.status,
  );
  AttendanceRecord copyWithCompanion(AttendanceCompanion data) {
    return AttendanceRecord(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecord(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('studentId: $studentId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, studentId, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRecord &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.studentId == this.studentId &&
          other.status == this.status);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceRecord> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> studentId;
  final Value<String> status;
  final Value<int> rowid;
  const AttendanceCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceCompanion.insert({
    required String id,
    required String sessionId,
    required String studentId,
    required String status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       studentId = Value(studentId),
       status = Value(status);
  static Insertable<AttendanceRecord> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? studentId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (studentId != null) 'student_id': studentId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? studentId,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return AttendanceCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('studentId: $studentId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class FeeRecords extends Table with TableInfo<FeeRecords, FeeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FeeRecords(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES students(id)',
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'monthly\' CHECK (kind IN (\'monthly\', \'one_time\'))',
    defaultValue: const CustomExpression('\'monthly\''),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _amountDueMeta = const VerificationMeta(
    'amountDue',
  );
  late final GeneratedColumn<int> amountDue = GeneratedColumn<int>(
    'amount_due',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_due >= 0)',
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  late final GeneratedColumn<int> discount = GeneratedColumn<int>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (discount >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _waivedMeta = const VerificationMeta('waived');
  late final GeneratedColumn<int> waived = GeneratedColumn<int>(
    'waived',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (waived IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    month,
    kind,
    label,
    amountDue,
    discount,
    waived,
    dueDate,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fee_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeeRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('amount_due')) {
      context.handle(
        _amountDueMeta,
        amountDue.isAcceptableOrUnknown(data['amount_due']!, _amountDueMeta),
      );
    } else if (isInserting) {
      context.missing(_amountDueMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('waived')) {
      context.handle(
        _waivedMeta,
        waived.isAcceptableOrUnknown(data['waived']!, _waivedMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      amountDue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_due'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount'],
      )!,
      waived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}waived'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  FeeRecords createAlias(String alias) {
    return FeeRecords(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class FeeRecord extends DataClass implements Insertable<FeeRecord> {
  final String id;
  final String studentId;
  final String month;

  /// YYYY-MM
  final String kind;
  final String? label;

  /// for one_time fees
  final int amountDue;
  final int discount;
  final int waived;
  final String dueDate;
  final String? note;

  /// reason for a waiver or discount
  final int createdAt;
  const FeeRecord({
    required this.id,
    required this.studentId,
    required this.month,
    required this.kind,
    this.label,
    required this.amountDue,
    required this.discount,
    required this.waived,
    required this.dueDate,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['month'] = Variable<String>(month);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['amount_due'] = Variable<int>(amountDue);
    map['discount'] = Variable<int>(discount);
    map['waived'] = Variable<int>(waived);
    map['due_date'] = Variable<String>(dueDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FeeRecordsCompanion toCompanion(bool nullToAbsent) {
    return FeeRecordsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      month: Value(month),
      kind: Value(kind),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      amountDue: Value(amountDue),
      discount: Value(discount),
      waived: Value(waived),
      dueDate: Value(dueDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory FeeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeRecord(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      month: serializer.fromJson<String>(json['month']),
      kind: serializer.fromJson<String>(json['kind']),
      label: serializer.fromJson<String?>(json['label']),
      amountDue: serializer.fromJson<int>(json['amount_due']),
      discount: serializer.fromJson<int>(json['discount']),
      waived: serializer.fromJson<int>(json['waived']),
      dueDate: serializer.fromJson<String>(json['due_date']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'student_id': serializer.toJson<String>(studentId),
      'month': serializer.toJson<String>(month),
      'kind': serializer.toJson<String>(kind),
      'label': serializer.toJson<String?>(label),
      'amount_due': serializer.toJson<int>(amountDue),
      'discount': serializer.toJson<int>(discount),
      'waived': serializer.toJson<int>(waived),
      'due_date': serializer.toJson<String>(dueDate),
      'note': serializer.toJson<String?>(note),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  FeeRecord copyWith({
    String? id,
    String? studentId,
    String? month,
    String? kind,
    Value<String?> label = const Value.absent(),
    int? amountDue,
    int? discount,
    int? waived,
    String? dueDate,
    Value<String?> note = const Value.absent(),
    int? createdAt,
  }) => FeeRecord(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    month: month ?? this.month,
    kind: kind ?? this.kind,
    label: label.present ? label.value : this.label,
    amountDue: amountDue ?? this.amountDue,
    discount: discount ?? this.discount,
    waived: waived ?? this.waived,
    dueDate: dueDate ?? this.dueDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  FeeRecord copyWithCompanion(FeeRecordsCompanion data) {
    return FeeRecord(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      month: data.month.present ? data.month.value : this.month,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      amountDue: data.amountDue.present ? data.amountDue.value : this.amountDue,
      discount: data.discount.present ? data.discount.value : this.discount,
      waived: data.waived.present ? data.waived.value : this.waived,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeeRecord(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('month: $month, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('amountDue: $amountDue, ')
          ..write('discount: $discount, ')
          ..write('waived: $waived, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    month,
    kind,
    label,
    amountDue,
    discount,
    waived,
    dueDate,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeRecord &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.month == this.month &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.amountDue == this.amountDue &&
          other.discount == this.discount &&
          other.waived == this.waived &&
          other.dueDate == this.dueDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class FeeRecordsCompanion extends UpdateCompanion<FeeRecord> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> month;
  final Value<String> kind;
  final Value<String?> label;
  final Value<int> amountDue;
  final Value<int> discount;
  final Value<int> waived;
  final Value<String> dueDate;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> rowid;
  const FeeRecordsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.month = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.amountDue = const Value.absent(),
    this.discount = const Value.absent(),
    this.waived = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeeRecordsCompanion.insert({
    required String id,
    required String studentId,
    required String month,
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    required int amountDue,
    this.discount = const Value.absent(),
    this.waived = const Value.absent(),
    required String dueDate,
    this.note = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       month = Value(month),
       amountDue = Value(amountDue),
       dueDate = Value(dueDate),
       createdAt = Value(createdAt);
  static Insertable<FeeRecord> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? month,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<int>? amountDue,
    Expression<int>? discount,
    Expression<int>? waived,
    Expression<String>? dueDate,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (month != null) 'month': month,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (amountDue != null) 'amount_due': amountDue,
      if (discount != null) 'discount': discount,
      if (waived != null) 'waived': waived,
      if (dueDate != null) 'due_date': dueDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeeRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? month,
    Value<String>? kind,
    Value<String?>? label,
    Value<int>? amountDue,
    Value<int>? discount,
    Value<int>? waived,
    Value<String>? dueDate,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return FeeRecordsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      month: month ?? this.month,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      amountDue: amountDue ?? this.amountDue,
      discount: discount ?? this.discount,
      waived: waived ?? this.waived,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amountDue.present) {
      map['amount_due'] = Variable<int>(amountDue.value);
    }
    if (discount.present) {
      map['discount'] = Variable<int>(discount.value);
    }
    if (waived.present) {
      map['waived'] = Variable<int>(waived.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('month: $month, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('amountDue: $amountDue, ')
          ..write('discount: $discount, ')
          ..write('waived: $waived, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Payments extends Table with TableInfo<Payments, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Payments(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES students(id)',
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount > 0)',
  );
  static const VerificationMeta _receivedOnMeta = const VerificationMeta(
    'receivedOn',
  );
  late final GeneratedColumn<String> receivedOn = GeneratedColumn<String>(
    'received_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'cash\' CHECK (method IN (\'cash\', \'bkash\', \'nagad\', \'rocket\', \'bank\', \'other\'))',
    defaultValue: const CustomExpression('\'cash\''),
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _receiptNoMeta = const VerificationMeta(
    'receiptNo',
  );
  late final GeneratedColumn<int> receiptNo = GeneratedColumn<int>(
    'receipt_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _receiptSharedAtMeta = const VerificationMeta(
    'receiptSharedAt',
  );
  late final GeneratedColumn<int> receiptSharedAt = GeneratedColumn<int>(
    'receipt_shared_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    amount,
    receivedOn,
    method,
    reference,
    receiptNo,
    note,
    createdAt,
    deletedAt,
    receiptSharedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('received_on')) {
      context.handle(
        _receivedOnMeta,
        receivedOn.isAcceptableOrUnknown(data['received_on']!, _receivedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedOnMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('receipt_no')) {
      context.handle(
        _receiptNoMeta,
        receiptNo.isAcceptableOrUnknown(data['receipt_no']!, _receiptNoMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptNoMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('receipt_shared_at')) {
      context.handle(
        _receiptSharedAtMeta,
        receiptSharedAt.isAcceptableOrUnknown(
          data['receipt_shared_at']!,
          _receiptSharedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      receivedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_on'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      receiptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receipt_no'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      receiptSharedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receipt_shared_at'],
      ),
    );
  }

  @override
  Payments createAlias(String alias) {
    return Payments(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String studentId;
  final int amount;
  final String receivedOn;
  final String method;
  final String? reference;
  final int receiptNo;
  final String? note;
  final int createdAt;
  final int? deletedAt;
  final int? receiptSharedAt;
  const Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.receivedOn,
    required this.method,
    this.reference,
    required this.receiptNo,
    this.note,
    required this.createdAt,
    this.deletedAt,
    this.receiptSharedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['amount'] = Variable<int>(amount);
    map['received_on'] = Variable<String>(receivedOn);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['receipt_no'] = Variable<int>(receiptNo);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || receiptSharedAt != null) {
      map['receipt_shared_at'] = Variable<int>(receiptSharedAt);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      amount: Value(amount),
      receivedOn: Value(receivedOn),
      method: Value(method),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      receiptNo: Value(receiptNo),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      receiptSharedAt: receiptSharedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptSharedAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      amount: serializer.fromJson<int>(json['amount']),
      receivedOn: serializer.fromJson<String>(json['received_on']),
      method: serializer.fromJson<String>(json['method']),
      reference: serializer.fromJson<String?>(json['reference']),
      receiptNo: serializer.fromJson<int>(json['receipt_no']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      receiptSharedAt: serializer.fromJson<int?>(json['receipt_shared_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'student_id': serializer.toJson<String>(studentId),
      'amount': serializer.toJson<int>(amount),
      'received_on': serializer.toJson<String>(receivedOn),
      'method': serializer.toJson<String>(method),
      'reference': serializer.toJson<String?>(reference),
      'receipt_no': serializer.toJson<int>(receiptNo),
      'note': serializer.toJson<String?>(note),
      'created_at': serializer.toJson<int>(createdAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'receipt_shared_at': serializer.toJson<int?>(receiptSharedAt),
    };
  }

  Payment copyWith({
    String? id,
    String? studentId,
    int? amount,
    String? receivedOn,
    String? method,
    Value<String?> reference = const Value.absent(),
    int? receiptNo,
    Value<String?> note = const Value.absent(),
    int? createdAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<int?> receiptSharedAt = const Value.absent(),
  }) => Payment(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    amount: amount ?? this.amount,
    receivedOn: receivedOn ?? this.receivedOn,
    method: method ?? this.method,
    reference: reference.present ? reference.value : this.reference,
    receiptNo: receiptNo ?? this.receiptNo,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    receiptSharedAt: receiptSharedAt.present
        ? receiptSharedAt.value
        : this.receiptSharedAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      amount: data.amount.present ? data.amount.value : this.amount,
      receivedOn: data.receivedOn.present
          ? data.receivedOn.value
          : this.receivedOn,
      method: data.method.present ? data.method.value : this.method,
      reference: data.reference.present ? data.reference.value : this.reference,
      receiptNo: data.receiptNo.present ? data.receiptNo.value : this.receiptNo,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      receiptSharedAt: data.receiptSharedAt.present
          ? data.receiptSharedAt.value
          : this.receiptSharedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('amount: $amount, ')
          ..write('receivedOn: $receivedOn, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('receiptSharedAt: $receiptSharedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    amount,
    receivedOn,
    method,
    reference,
    receiptNo,
    note,
    createdAt,
    deletedAt,
    receiptSharedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.amount == this.amount &&
          other.receivedOn == this.receivedOn &&
          other.method == this.method &&
          other.reference == this.reference &&
          other.receiptNo == this.receiptNo &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.receiptSharedAt == this.receiptSharedAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<int> amount;
  final Value<String> receivedOn;
  final Value<String> method;
  final Value<String?> reference;
  final Value<int> receiptNo;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<int?> receiptSharedAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.amount = const Value.absent(),
    this.receivedOn = const Value.absent(),
    this.method = const Value.absent(),
    this.reference = const Value.absent(),
    this.receiptNo = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.receiptSharedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String studentId,
    required int amount,
    required String receivedOn,
    this.method = const Value.absent(),
    this.reference = const Value.absent(),
    required int receiptNo,
    this.note = const Value.absent(),
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.receiptSharedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       amount = Value(amount),
       receivedOn = Value(receivedOn),
       receiptNo = Value(receiptNo),
       createdAt = Value(createdAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<int>? amount,
    Expression<String>? receivedOn,
    Expression<String>? method,
    Expression<String>? reference,
    Expression<int>? receiptNo,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<int>? receiptSharedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (amount != null) 'amount': amount,
      if (receivedOn != null) 'received_on': receivedOn,
      if (method != null) 'method': method,
      if (reference != null) 'reference': reference,
      if (receiptNo != null) 'receipt_no': receiptNo,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (receiptSharedAt != null) 'receipt_shared_at': receiptSharedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<int>? amount,
    Value<String>? receivedOn,
    Value<String>? method,
    Value<String?>? reference,
    Value<int>? receiptNo,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int?>? deletedAt,
    Value<int?>? receiptSharedAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      receivedOn: receivedOn ?? this.receivedOn,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      receiptNo: receiptNo ?? this.receiptNo,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      receiptSharedAt: receiptSharedAt ?? this.receiptSharedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (receivedOn.present) {
      map['received_on'] = Variable<String>(receivedOn.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (receiptNo.present) {
      map['receipt_no'] = Variable<int>(receiptNo.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (receiptSharedAt.present) {
      map['receipt_shared_at'] = Variable<int>(receiptSharedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('amount: $amount, ')
          ..write('receivedOn: $receivedOn, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('receiptSharedAt: $receiptSharedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PaymentAllocations extends Table
    with TableInfo<PaymentAllocations, PaymentAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PaymentAllocations(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES payments(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _feeRecordIdMeta = const VerificationMeta(
    'feeRecordId',
  );
  late final GeneratedColumn<String> feeRecordId = GeneratedColumn<String>(
    'fee_record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES fee_records(id)',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES students(id)',
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount > 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    paymentId,
    feeRecordId,
    studentId,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentAllocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('fee_record_id')) {
      context.handle(
        _feeRecordIdMeta,
        feeRecordId.isAcceptableOrUnknown(
          data['fee_record_id']!,
          _feeRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentAllocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentAllocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      feeRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fee_record_id'],
      ),
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  PaymentAllocations createAlias(String alias) {
    return PaymentAllocations(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PaymentAllocation extends DataClass
    implements Insertable<PaymentAllocation> {
  final String id;
  final String paymentId;
  final String? feeRecordId;

  /// NULL = unapplied advance credit
  final String studentId;
  final int amount;
  const PaymentAllocation({
    required this.id,
    required this.paymentId,
    this.feeRecordId,
    required this.studentId,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payment_id'] = Variable<String>(paymentId);
    if (!nullToAbsent || feeRecordId != null) {
      map['fee_record_id'] = Variable<String>(feeRecordId);
    }
    map['student_id'] = Variable<String>(studentId);
    map['amount'] = Variable<int>(amount);
    return map;
  }

  PaymentAllocationsCompanion toCompanion(bool nullToAbsent) {
    return PaymentAllocationsCompanion(
      id: Value(id),
      paymentId: Value(paymentId),
      feeRecordId: feeRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(feeRecordId),
      studentId: Value(studentId),
      amount: Value(amount),
    );
  }

  factory PaymentAllocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentAllocation(
      id: serializer.fromJson<String>(json['id']),
      paymentId: serializer.fromJson<String>(json['payment_id']),
      feeRecordId: serializer.fromJson<String?>(json['fee_record_id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      amount: serializer.fromJson<int>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payment_id': serializer.toJson<String>(paymentId),
      'fee_record_id': serializer.toJson<String?>(feeRecordId),
      'student_id': serializer.toJson<String>(studentId),
      'amount': serializer.toJson<int>(amount),
    };
  }

  PaymentAllocation copyWith({
    String? id,
    String? paymentId,
    Value<String?> feeRecordId = const Value.absent(),
    String? studentId,
    int? amount,
  }) => PaymentAllocation(
    id: id ?? this.id,
    paymentId: paymentId ?? this.paymentId,
    feeRecordId: feeRecordId.present ? feeRecordId.value : this.feeRecordId,
    studentId: studentId ?? this.studentId,
    amount: amount ?? this.amount,
  );
  PaymentAllocation copyWithCompanion(PaymentAllocationsCompanion data) {
    return PaymentAllocation(
      id: data.id.present ? data.id.value : this.id,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      feeRecordId: data.feeRecordId.present
          ? data.feeRecordId.value
          : this.feeRecordId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAllocation(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('feeRecordId: $feeRecordId, ')
          ..write('studentId: $studentId, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, paymentId, feeRecordId, studentId, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentAllocation &&
          other.id == this.id &&
          other.paymentId == this.paymentId &&
          other.feeRecordId == this.feeRecordId &&
          other.studentId == this.studentId &&
          other.amount == this.amount);
}

class PaymentAllocationsCompanion extends UpdateCompanion<PaymentAllocation> {
  final Value<String> id;
  final Value<String> paymentId;
  final Value<String?> feeRecordId;
  final Value<String> studentId;
  final Value<int> amount;
  final Value<int> rowid;
  const PaymentAllocationsCompanion({
    this.id = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.feeRecordId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentAllocationsCompanion.insert({
    required String id,
    required String paymentId,
    this.feeRecordId = const Value.absent(),
    required String studentId,
    required int amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       paymentId = Value(paymentId),
       studentId = Value(studentId),
       amount = Value(amount);
  static Insertable<PaymentAllocation> custom({
    Expression<String>? id,
    Expression<String>? paymentId,
    Expression<String>? feeRecordId,
    Expression<String>? studentId,
    Expression<int>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paymentId != null) 'payment_id': paymentId,
      if (feeRecordId != null) 'fee_record_id': feeRecordId,
      if (studentId != null) 'student_id': studentId,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentAllocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? paymentId,
    Value<String?>? feeRecordId,
    Value<String>? studentId,
    Value<int>? amount,
    Value<int>? rowid,
  }) {
    return PaymentAllocationsCompanion(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      feeRecordId: feeRecordId ?? this.feeRecordId,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (feeRecordId.present) {
      map['fee_record_id'] = Variable<String>(feeRecordId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('feeRecordId: $feeRecordId, ')
          ..write('studentId: $studentId, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class FeeBalance extends DataClass {
  final String feeRecordId;
  final String studentId;
  final String month;
  final String kind;
  final String? label;
  final String dueDate;
  final int waived;
  final int amountDue;
  final int discount;
  final int payable;
  final int paid;
  final int balance;
  const FeeBalance({
    required this.feeRecordId,
    required this.studentId,
    required this.month,
    required this.kind,
    this.label,
    required this.dueDate,
    required this.waived,
    required this.amountDue,
    required this.discount,
    required this.payable,
    required this.paid,
    required this.balance,
  });
  factory FeeBalance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeBalance(
      feeRecordId: serializer.fromJson<String>(json['fee_record_id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      month: serializer.fromJson<String>(json['month']),
      kind: serializer.fromJson<String>(json['kind']),
      label: serializer.fromJson<String?>(json['label']),
      dueDate: serializer.fromJson<String>(json['due_date']),
      waived: serializer.fromJson<int>(json['waived']),
      amountDue: serializer.fromJson<int>(json['amount_due']),
      discount: serializer.fromJson<int>(json['discount']),
      payable: serializer.fromJson<int>(json['payable']),
      paid: serializer.fromJson<int>(json['paid']),
      balance: serializer.fromJson<int>(json['balance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fee_record_id': serializer.toJson<String>(feeRecordId),
      'student_id': serializer.toJson<String>(studentId),
      'month': serializer.toJson<String>(month),
      'kind': serializer.toJson<String>(kind),
      'label': serializer.toJson<String?>(label),
      'due_date': serializer.toJson<String>(dueDate),
      'waived': serializer.toJson<int>(waived),
      'amount_due': serializer.toJson<int>(amountDue),
      'discount': serializer.toJson<int>(discount),
      'payable': serializer.toJson<int>(payable),
      'paid': serializer.toJson<int>(paid),
      'balance': serializer.toJson<int>(balance),
    };
  }

  FeeBalance copyWith({
    String? feeRecordId,
    String? studentId,
    String? month,
    String? kind,
    Value<String?> label = const Value.absent(),
    String? dueDate,
    int? waived,
    int? amountDue,
    int? discount,
    int? payable,
    int? paid,
    int? balance,
  }) => FeeBalance(
    feeRecordId: feeRecordId ?? this.feeRecordId,
    studentId: studentId ?? this.studentId,
    month: month ?? this.month,
    kind: kind ?? this.kind,
    label: label.present ? label.value : this.label,
    dueDate: dueDate ?? this.dueDate,
    waived: waived ?? this.waived,
    amountDue: amountDue ?? this.amountDue,
    discount: discount ?? this.discount,
    payable: payable ?? this.payable,
    paid: paid ?? this.paid,
    balance: balance ?? this.balance,
  );
  @override
  String toString() {
    return (StringBuffer('FeeBalance(')
          ..write('feeRecordId: $feeRecordId, ')
          ..write('studentId: $studentId, ')
          ..write('month: $month, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('dueDate: $dueDate, ')
          ..write('waived: $waived, ')
          ..write('amountDue: $amountDue, ')
          ..write('discount: $discount, ')
          ..write('payable: $payable, ')
          ..write('paid: $paid, ')
          ..write('balance: $balance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    feeRecordId,
    studentId,
    month,
    kind,
    label,
    dueDate,
    waived,
    amountDue,
    discount,
    payable,
    paid,
    balance,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeBalance &&
          other.feeRecordId == this.feeRecordId &&
          other.studentId == this.studentId &&
          other.month == this.month &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.dueDate == this.dueDate &&
          other.waived == this.waived &&
          other.amountDue == this.amountDue &&
          other.discount == this.discount &&
          other.payable == this.payable &&
          other.paid == this.paid &&
          other.balance == this.balance);
}

class FeeBalances extends ViewInfo<FeeBalances, FeeBalance>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$AppDatabase attachedDatabase;
  FeeBalances(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    feeRecordId,
    studentId,
    month,
    kind,
    label,
    dueDate,
    waived,
    amountDue,
    discount,
    payable,
    paid,
    balance,
  ];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'fee_balances';
  @override
  Map<SqlDialect, String> get createViewStatements => {
    SqlDialect.sqlite: 'CREATE VIEW fee_balances AS SELECT *, CASE WHEN waived = 1 THEN 0 ELSE payable - paid END AS balance FROM (SELECT f.id AS fee_record_id, f.student_id, f.month, f.kind, f.label, f.due_date, f.waived, f.amount_due, f.discount, f.amount_due - f.discount AS payable, COALESCE((SELECT SUM(a.amount) FROM payment_allocations AS a INNER JOIN payments AS p ON p.id = a.payment_id WHERE a.fee_record_id = f.id AND p.deleted_at IS NULL), 0) AS paid FROM fee_records AS f) AS FeeBalance',
  };
  @override
  FeeBalances get asDslTable => this;
  @override
  FeeBalance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeBalance(
      feeRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fee_record_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      waived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}waived'],
      )!,
      amountDue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_due'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount'],
      )!,
      payable: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payable'],
      )!,
      paid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
    );
  }

  late final GeneratedColumn<String> feeRecordId = GeneratedColumn<String>(
    'fee_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<int> waived = GeneratedColumn<int>(
    'waived',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<int> amountDue = GeneratedColumn<int>(
    'amount_due',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<int> discount = GeneratedColumn<int>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<int> payable = GeneratedColumn<int>(
    'payable',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<int> paid = GeneratedColumn<int>(
    'paid',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  @override
  FeeBalances createAlias(String alias) {
    return FeeBalances(attachedDatabase, alias);
  }

  @override
  Query? get query => null;
  @override
  Set<String> get readTables => const {
    'fee_records',
    'payment_allocations',
    'payments',
    'students',
  };
}

class FeeChanges extends Table with TableInfo<FeeChanges, FeeChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FeeChanges(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES students(id)',
  );
  static const VerificationMeta _effectiveMonthMeta = const VerificationMeta(
    'effectiveMonth',
  );
  late final GeneratedColumn<String> effectiveMonth = GeneratedColumn<String>(
    'effective_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _newAmountMeta = const VerificationMeta(
    'newAmount',
  );
  late final GeneratedColumn<int> newAmount = GeneratedColumn<int>(
    'new_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (new_amount >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    effectiveMonth,
    newAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fee_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeeChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('effective_month')) {
      context.handle(
        _effectiveMonthMeta,
        effectiveMonth.isAcceptableOrUnknown(
          data['effective_month']!,
          _effectiveMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveMonthMeta);
    }
    if (data.containsKey('new_amount')) {
      context.handle(
        _newAmountMeta,
        newAmount.isAcceptableOrUnknown(data['new_amount']!, _newAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_newAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, effectiveMonth},
  ];
  @override
  FeeChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      effectiveMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_month'],
      )!,
      newAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_amount'],
      )!,
    );
  }

  @override
  FeeChanges createAlias(String alias) {
    return FeeChanges(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(student_id, effective_month)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class FeeChange extends DataClass implements Insertable<FeeChange> {
  final String id;
  final String studentId;
  final String effectiveMonth;
  final int newAmount;
  const FeeChange({
    required this.id,
    required this.studentId,
    required this.effectiveMonth,
    required this.newAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['effective_month'] = Variable<String>(effectiveMonth);
    map['new_amount'] = Variable<int>(newAmount);
    return map;
  }

  FeeChangesCompanion toCompanion(bool nullToAbsent) {
    return FeeChangesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      effectiveMonth: Value(effectiveMonth),
      newAmount: Value(newAmount),
    );
  }

  factory FeeChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeChange(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      effectiveMonth: serializer.fromJson<String>(json['effective_month']),
      newAmount: serializer.fromJson<int>(json['new_amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'student_id': serializer.toJson<String>(studentId),
      'effective_month': serializer.toJson<String>(effectiveMonth),
      'new_amount': serializer.toJson<int>(newAmount),
    };
  }

  FeeChange copyWith({
    String? id,
    String? studentId,
    String? effectiveMonth,
    int? newAmount,
  }) => FeeChange(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    effectiveMonth: effectiveMonth ?? this.effectiveMonth,
    newAmount: newAmount ?? this.newAmount,
  );
  FeeChange copyWithCompanion(FeeChangesCompanion data) {
    return FeeChange(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      effectiveMonth: data.effectiveMonth.present
          ? data.effectiveMonth.value
          : this.effectiveMonth,
      newAmount: data.newAmount.present ? data.newAmount.value : this.newAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeeChange(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('effectiveMonth: $effectiveMonth, ')
          ..write('newAmount: $newAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, effectiveMonth, newAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeChange &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.effectiveMonth == this.effectiveMonth &&
          other.newAmount == this.newAmount);
}

class FeeChangesCompanion extends UpdateCompanion<FeeChange> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> effectiveMonth;
  final Value<int> newAmount;
  final Value<int> rowid;
  const FeeChangesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.effectiveMonth = const Value.absent(),
    this.newAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeeChangesCompanion.insert({
    required String id,
    required String studentId,
    required String effectiveMonth,
    required int newAmount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       effectiveMonth = Value(effectiveMonth),
       newAmount = Value(newAmount);
  static Insertable<FeeChange> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? effectiveMonth,
    Expression<int>? newAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (effectiveMonth != null) 'effective_month': effectiveMonth,
      if (newAmount != null) 'new_amount': newAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeeChangesCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? effectiveMonth,
    Value<int>? newAmount,
    Value<int>? rowid,
  }) {
    return FeeChangesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      effectiveMonth: effectiveMonth ?? this.effectiveMonth,
      newAmount: newAmount ?? this.newAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (effectiveMonth.present) {
      map['effective_month'] = Variable<String>(effectiveMonth.value);
    }
    if (newAmount.present) {
      map['new_amount'] = Variable<int>(newAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeeChangesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('effectiveMonth: $effectiveMonth, ')
          ..write('newAmount: $newAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Pauses extends Table with TableInfo<Pauses, Pause> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Pauses(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES students(id)',
  );
  static const VerificationMeta _fromMonthMeta = const VerificationMeta(
    'fromMonth',
  );
  late final GeneratedColumn<String> fromMonth = GeneratedColumn<String>(
    'from_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _toMonthMeta = const VerificationMeta(
    'toMonth',
  );
  late final GeneratedColumn<String> toMonth = GeneratedColumn<String>(
    'to_month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [id, studentId, fromMonth, toMonth];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pauses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pause> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('from_month')) {
      context.handle(
        _fromMonthMeta,
        fromMonth.isAcceptableOrUnknown(data['from_month']!, _fromMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_fromMonthMeta);
    }
    if (data.containsKey('to_month')) {
      context.handle(
        _toMonthMeta,
        toMonth.isAcceptableOrUnknown(data['to_month']!, _toMonthMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pause map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pause(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      fromMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_month'],
      )!,
      toMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_month'],
      ),
    );
  }

  @override
  Pauses createAlias(String alias) {
    return Pauses(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Pause extends DataClass implements Insertable<Pause> {
  final String id;
  final String studentId;
  final String fromMonth;
  final String? toMonth;
  const Pause({
    required this.id,
    required this.studentId,
    required this.fromMonth,
    this.toMonth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['from_month'] = Variable<String>(fromMonth);
    if (!nullToAbsent || toMonth != null) {
      map['to_month'] = Variable<String>(toMonth);
    }
    return map;
  }

  PausesCompanion toCompanion(bool nullToAbsent) {
    return PausesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      fromMonth: Value(fromMonth),
      toMonth: toMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(toMonth),
    );
  }

  factory Pause.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pause(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      fromMonth: serializer.fromJson<String>(json['from_month']),
      toMonth: serializer.fromJson<String?>(json['to_month']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'student_id': serializer.toJson<String>(studentId),
      'from_month': serializer.toJson<String>(fromMonth),
      'to_month': serializer.toJson<String?>(toMonth),
    };
  }

  Pause copyWith({
    String? id,
    String? studentId,
    String? fromMonth,
    Value<String?> toMonth = const Value.absent(),
  }) => Pause(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    fromMonth: fromMonth ?? this.fromMonth,
    toMonth: toMonth.present ? toMonth.value : this.toMonth,
  );
  Pause copyWithCompanion(PausesCompanion data) {
    return Pause(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      fromMonth: data.fromMonth.present ? data.fromMonth.value : this.fromMonth,
      toMonth: data.toMonth.present ? data.toMonth.value : this.toMonth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pause(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('fromMonth: $fromMonth, ')
          ..write('toMonth: $toMonth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, fromMonth, toMonth);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pause &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.fromMonth == this.fromMonth &&
          other.toMonth == this.toMonth);
}

class PausesCompanion extends UpdateCompanion<Pause> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> fromMonth;
  final Value<String?> toMonth;
  final Value<int> rowid;
  const PausesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.fromMonth = const Value.absent(),
    this.toMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PausesCompanion.insert({
    required String id,
    required String studentId,
    required String fromMonth,
    this.toMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       fromMonth = Value(fromMonth);
  static Insertable<Pause> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? fromMonth,
    Expression<String>? toMonth,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (fromMonth != null) 'from_month': fromMonth,
      if (toMonth != null) 'to_month': toMonth,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PausesCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? fromMonth,
    Value<String?>? toMonth,
    Value<int>? rowid,
  }) {
    return PausesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      fromMonth: fromMonth ?? this.fromMonth,
      toMonth: toMonth ?? this.toMonth,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (fromMonth.present) {
      map['from_month'] = Variable<String>(fromMonth.value);
    }
    if (toMonth.present) {
      map['to_month'] = Variable<String>(toMonth.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PausesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('fromMonth: $fromMonth, ')
          ..write('toMonth: $toMonth, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Settings extends Table with TableInfo<Settings, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
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
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
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
  Settings createAlias(String alias) {
    return Settings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
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

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
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
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
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

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
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
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MessageTemplates extends Table
    with TableInfo<MessageTemplates, MessageTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MessageTemplates(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, language, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  MessageTemplates createAlias(String alias) {
    return MessageTemplates(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class MessageTemplate extends DataClass implements Insertable<MessageTemplate> {
  final String id;
  final String kind;
  final String language;
  final String body;
  const MessageTemplate({
    required this.id,
    required this.kind,
    required this.language,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['language'] = Variable<String>(language);
    map['body'] = Variable<String>(body);
    return map;
  }

  MessageTemplatesCompanion toCompanion(bool nullToAbsent) {
    return MessageTemplatesCompanion(
      id: Value(id),
      kind: Value(kind),
      language: Value(language),
      body: Value(body),
    );
  }

  factory MessageTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageTemplate(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      language: serializer.fromJson<String>(json['language']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'language': serializer.toJson<String>(language),
      'body': serializer.toJson<String>(body),
    };
  }

  MessageTemplate copyWith({
    String? id,
    String? kind,
    String? language,
    String? body,
  }) => MessageTemplate(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    language: language ?? this.language,
    body: body ?? this.body,
  );
  MessageTemplate copyWithCompanion(MessageTemplatesCompanion data) {
    return MessageTemplate(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      language: data.language.present ? data.language.value : this.language,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageTemplate(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('language: $language, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, language, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageTemplate &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.language == this.language &&
          other.body == this.body);
}

class MessageTemplatesCompanion extends UpdateCompanion<MessageTemplate> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> language;
  final Value<String> body;
  final Value<int> rowid;
  const MessageTemplatesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.language = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageTemplatesCompanion.insert({
    required String id,
    required String kind,
    required String language,
    required String body,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       language = Value(language),
       body = Value(body);
  static Insertable<MessageTemplate> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? language,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (language != null) 'language': language,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? language,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return MessageTemplatesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      language: language ?? this.language,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('language: $language, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AuditLog extends Table with TableInfo<AuditLog, AuditLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AuditLog(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    entityId,
    action,
    details,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  AuditLog createAlias(String alias) {
    return AuditLog(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AuditLogEntry extends DataClass implements Insertable<AuditLogEntry> {
  final String id;
  final String entity;
  final String entityId;
  final String action;
  final String? details;
  final int at;
  const AuditLogEntry({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.action,
    this.details,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['at'] = Variable<int>(at);
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      entity: Value(entity),
      entityId: Value(entityId),
      action: Value(action),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      at: Value(at),
    );
  }

  factory AuditLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogEntry(
      id: serializer.fromJson<String>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      action: serializer.fromJson<String>(json['action']),
      details: serializer.fromJson<String?>(json['details']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entity': serializer.toJson<String>(entity),
      'entity_id': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'details': serializer.toJson<String?>(details),
      'at': serializer.toJson<int>(at),
    };
  }

  AuditLogEntry copyWith({
    String? id,
    String? entity,
    String? entityId,
    String? action,
    Value<String?> details = const Value.absent(),
    int? at,
  }) => AuditLogEntry(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    details: details.present ? details.value : this.details,
    at: at ?? this.at,
  );
  AuditLogEntry copyWithCompanion(AuditLogCompanion data) {
    return AuditLogEntry(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      details: data.details.present ? data.details.value : this.details,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogEntry(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('details: $details, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entity, entityId, action, details, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogEntry &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.details == this.details &&
          other.at == this.at);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogEntry> {
  final Value<String> id;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> details;
  final Value<int> at;
  final Value<int> rowid;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.details = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogCompanion.insert({
    required String id,
    required String entity,
    required String entityId,
    required String action,
    this.details = const Value.absent(),
    required int at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entity = Value(entity),
       entityId = Value(entityId),
       action = Value(action),
       at = Value(at);
  static Insertable<AuditLogEntry> custom({
    Expression<String>? id,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? details,
    Expression<int>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (details != null) 'details': details,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogCompanion copyWith({
    Value<String>? id,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? action,
    Value<String?>? details,
    Value<int>? at,
    Value<int>? rowid,
  }) {
    return AuditLogCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      details: details ?? this.details,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('details: $details, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Students students = Students(this);
  late final Index idxStudentsStatus = Index(
    'idx_students_status',
    'CREATE INDEX idx_students_status ON students (status)',
  );
  late final Index idxStudentsName = Index(
    'idx_students_name',
    'CREATE INDEX idx_students_name ON students (name COLLATE NOCASE)',
  );
  late final Batches batches = Batches(this);
  late final BatchMembers batchMembers = BatchMembers(this);
  late final Index idxMembersStudent = Index(
    'idx_members_student',
    'CREATE INDEX idx_members_student ON batch_members (student_id)',
  );
  late final ClassSessions classSessions = ClassSessions(this);
  late final Index idxSessionsDate = Index(
    'idx_sessions_date',
    'CREATE INDEX idx_sessions_date ON class_sessions (date)',
  );
  late final Index uqSessionBatchDay = Index(
    'uq_session_batch_day',
    'CREATE UNIQUE INDEX uq_session_batch_day ON class_sessions (batch_id, date, COALESCE(start_time, \'\')) WHERE batch_id IS NOT NULL',
  );
  late final Index uqSessionStudentDay = Index(
    'uq_session_student_day',
    'CREATE UNIQUE INDEX uq_session_student_day ON class_sessions (student_id, date, COALESCE(start_time, \'\')) WHERE student_id IS NOT NULL',
  );
  late final Attendance attendance = Attendance(this);
  late final Index idxAttStudent = Index(
    'idx_att_student',
    'CREATE INDEX idx_att_student ON attendance (student_id)',
  );
  late final FeeRecords feeRecords = FeeRecords(this);
  late final Index uqFeeMonthly = Index(
    'uq_fee_monthly',
    'CREATE UNIQUE INDEX uq_fee_monthly ON fee_records (student_id, month) WHERE kind = \'monthly\'',
  );
  late final Index idxFeeMonth = Index(
    'idx_fee_month',
    'CREATE INDEX idx_fee_month ON fee_records (month)',
  );
  late final Index idxFeeStudent = Index(
    'idx_fee_student',
    'CREATE INDEX idx_fee_student ON fee_records (student_id)',
  );
  late final Payments payments = Payments(this);
  late final Index idxPayStudent = Index(
    'idx_pay_student',
    'CREATE INDEX idx_pay_student ON payments (student_id)',
  );
  late final Index idxPayDate = Index(
    'idx_pay_date',
    'CREATE INDEX idx_pay_date ON payments (received_on)',
  );
  late final PaymentAllocations paymentAllocations = PaymentAllocations(this);
  late final Index idxAllocFee = Index(
    'idx_alloc_fee',
    'CREATE INDEX idx_alloc_fee ON payment_allocations (fee_record_id)',
  );
  late final Index idxAllocPayment = Index(
    'idx_alloc_payment',
    'CREATE INDEX idx_alloc_payment ON payment_allocations (payment_id)',
  );
  late final Index idxAllocStudent = Index(
    'idx_alloc_student',
    'CREATE INDEX idx_alloc_student ON payment_allocations (student_id)',
  );
  late final FeeBalances feeBalances = FeeBalances(this);
  late final FeeChanges feeChanges = FeeChanges(this);
  late final Pauses pauses = Pauses(this);
  late final Index idxPausesStudent = Index(
    'idx_pauses_student',
    'CREATE INDEX idx_pauses_student ON pauses (student_id)',
  );
  late final Settings settings = Settings(this);
  late final MessageTemplates messageTemplates = MessageTemplates(this);
  late final AuditLog auditLog = AuditLog(this);
  late final Index idxAuditEntity = Index(
    'idx_audit_entity',
    'CREATE INDEX idx_audit_entity ON audit_log (entity, entity_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    students,
    idxStudentsStatus,
    idxStudentsName,
    batches,
    batchMembers,
    idxMembersStudent,
    classSessions,
    idxSessionsDate,
    uqSessionBatchDay,
    uqSessionStudentDay,
    attendance,
    idxAttStudent,
    feeRecords,
    uqFeeMonthly,
    idxFeeMonth,
    idxFeeStudent,
    payments,
    idxPayStudent,
    idxPayDate,
    paymentAllocations,
    idxAllocFee,
    idxAllocPayment,
    idxAllocStudent,
    feeBalances,
    feeChanges,
    pauses,
    idxPausesStudent,
    settings,
    messageTemplates,
    auditLog,
    idxAuditEntity,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'class_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'payments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payment_allocations', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $StudentsCreateCompanionBuilder = StudentsCompanion Function({
  required String id,
  required String name,
  Value<String?> classLevel,
  Value<String?> school,
  Value<String?> guardianName,
  Value<String?> guardianPhone,
  Value<String?> studentPhone,
  Value<String?> address,
  Value<String?> photoPath,
  Value<String?> subjects,
  Value<String?> classDays,
  Value<String?> classTime,
  required String joinedOn,
  Value<String> status,
  required int monthlyFee,
  Value<int> feeDueDay,
  Value<String?> notes,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $StudentsUpdateCompanionBuilder = StudentsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> classLevel,
  Value<String?> school,
  Value<String?> guardianName,
  Value<String?> guardianPhone,
  Value<String?> studentPhone,
  Value<String?> address,
  Value<String?> photoPath,
  Value<String?> subjects,
  Value<String?> classDays,
  Value<String?> classTime,
  Value<String> joinedOn,
  Value<String> status,
  Value<int> monthlyFee,
  Value<int> feeDueDay,
  Value<String?> notes,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $StudentsReferences
    extends BaseReferences<_$AppDatabase, Students, Student> {
  $StudentsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<BatchMembers, List<BatchMember>>
  _batchMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.batchMembers,
    aliasName: 'students__id__batch_members__student_id',
  );

  $BatchMembersProcessedTableManager get batchMembersRefs {
    final manager = $BatchMembersTableManager(
      $_db,
      $_db.batchMembers,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ClassSessions, List<ClassSession>>
  _classSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.classSessions,
    aliasName: 'students__id__class_sessions__student_id',
  );

  $ClassSessionsProcessedTableManager get classSessionsRefs {
    final manager = $ClassSessionsTableManager(
      $_db,
      $_db.classSessions,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_classSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Attendance, List<AttendanceRecord>>
  _attendanceRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendance,
    aliasName: 'students__id__attendance__student_id',
  );

  $AttendanceProcessedTableManager get attendanceRefs {
    final manager = $AttendanceTableManager(
      $_db,
      $_db.attendance,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendanceRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<FeeRecords, List<FeeRecord>> _feeRecordsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.feeRecords,
    aliasName: 'students__id__fee_records__student_id',
  );

  $FeeRecordsProcessedTableManager get feeRecordsRefs {
    final manager = $FeeRecordsTableManager(
      $_db,
      $_db.feeRecords,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_feeRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Payments, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'students__id__payments__student_id',
  );

  $PaymentsProcessedTableManager get paymentsRefs {
    final manager = $PaymentsTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<PaymentAllocations, List<PaymentAllocation>>
  _paymentAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentAllocations,
        aliasName: 'students__id__payment_allocations__student_id',
      );

  $PaymentAllocationsProcessedTableManager get paymentAllocationsRefs {
    final manager = $PaymentAllocationsTableManager(
      $_db,
      $_db.paymentAllocations,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<FeeChanges, List<FeeChange>> _feeChangesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.feeChanges,
    aliasName: 'students__id__fee_changes__student_id',
  );

  $FeeChangesProcessedTableManager get feeChangesRefs {
    final manager = $FeeChangesTableManager(
      $_db,
      $_db.feeChanges,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_feeChangesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Pauses, List<Pause>> _pausesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pauses,
    aliasName: 'students__id__pauses__student_id',
  );

  $PausesProcessedTableManager get pausesRefs {
    final manager = $PausesTableManager(
      $_db,
      $_db.pauses,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pausesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $StudentsFilterComposer extends Composer<_$AppDatabase, Students> {
  $StudentsFilterComposer({
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

  ColumnFilters<String> get classLevel => $composableBuilder(
    column: $table.classLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get school => $composableBuilder(
    column: $table.school,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guardianName => $composableBuilder(
    column: $table.guardianName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guardianPhone => $composableBuilder(
    column: $table.guardianPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentPhone => $composableBuilder(
    column: $table.studentPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjects => $composableBuilder(
    column: $table.subjects,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classDays => $composableBuilder(
    column: $table.classDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classTime => $composableBuilder(
    column: $table.classTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get joinedOn => $composableBuilder(
    column: $table.joinedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyFee => $composableBuilder(
    column: $table.monthlyFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feeDueDay => $composableBuilder(
    column: $table.feeDueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> batchMembersRefs(
    Expression<bool> Function($BatchMembersFilterComposer f) f,
  ) {
    final $BatchMembersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batchMembers,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchMembersFilterComposer(
            $db: $db,
            $table: $db.batchMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> classSessionsRefs(
    Expression<bool> Function($ClassSessionsFilterComposer f) f,
  ) {
    final $ClassSessionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classSessions,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClassSessionsFilterComposer(
            $db: $db,
            $table: $db.classSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendanceRefs(
    Expression<bool> Function($AttendanceFilterComposer f) f,
  ) {
    final $AttendanceFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendance,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttendanceFilterComposer(
            $db: $db,
            $table: $db.attendance,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feeRecordsRefs(
    Expression<bool> Function($FeeRecordsFilterComposer f) f,
  ) {
    final $FeeRecordsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeRecords,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeeRecordsFilterComposer(
            $db: $db,
            $table: $db.feeRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($PaymentsFilterComposer f) f,
  ) {
    final $PaymentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentsFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentAllocationsRefs(
    Expression<bool> Function($PaymentAllocationsFilterComposer f) f,
  ) {
    final $PaymentAllocationsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentAllocationsFilterComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feeChangesRefs(
    Expression<bool> Function($FeeChangesFilterComposer f) f,
  ) {
    final $FeeChangesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeChanges,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeeChangesFilterComposer(
            $db: $db,
            $table: $db.feeChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pausesRefs(
    Expression<bool> Function($PausesFilterComposer f) f,
  ) {
    final $PausesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pauses,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PausesFilterComposer(
            $db: $db,
            $table: $db.pauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $StudentsOrderingComposer extends Composer<_$AppDatabase, Students> {
  $StudentsOrderingComposer({
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

  ColumnOrderings<String> get classLevel => $composableBuilder(
    column: $table.classLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get school => $composableBuilder(
    column: $table.school,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guardianName => $composableBuilder(
    column: $table.guardianName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guardianPhone => $composableBuilder(
    column: $table.guardianPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentPhone => $composableBuilder(
    column: $table.studentPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjects => $composableBuilder(
    column: $table.subjects,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classDays => $composableBuilder(
    column: $table.classDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classTime => $composableBuilder(
    column: $table.classTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get joinedOn => $composableBuilder(
    column: $table.joinedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyFee => $composableBuilder(
    column: $table.monthlyFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feeDueDay => $composableBuilder(
    column: $table.feeDueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $StudentsAnnotationComposer extends Composer<_$AppDatabase, Students> {
  $StudentsAnnotationComposer({
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

  GeneratedColumn<String> get classLevel => $composableBuilder(
    column: $table.classLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get school =>
      $composableBuilder(column: $table.school, builder: (column) => column);

  GeneratedColumn<String> get guardianName => $composableBuilder(
    column: $table.guardianName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guardianPhone => $composableBuilder(
    column: $table.guardianPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentPhone => $composableBuilder(
    column: $table.studentPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get subjects =>
      $composableBuilder(column: $table.subjects, builder: (column) => column);

  GeneratedColumn<String> get classDays =>
      $composableBuilder(column: $table.classDays, builder: (column) => column);

  GeneratedColumn<String> get classTime =>
      $composableBuilder(column: $table.classTime, builder: (column) => column);

  GeneratedColumn<String> get joinedOn =>
      $composableBuilder(column: $table.joinedOn, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get monthlyFee => $composableBuilder(
    column: $table.monthlyFee,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feeDueDay =>
      $composableBuilder(column: $table.feeDueDay, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> batchMembersRefs<T extends Object>(
    Expression<T> Function($BatchMembersAnnotationComposer a) f,
  ) {
    final $BatchMembersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batchMembers,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchMembersAnnotationComposer(
            $db: $db,
            $table: $db.batchMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> classSessionsRefs<T extends Object>(
    Expression<T> Function($ClassSessionsAnnotationComposer a) f,
  ) {
    final $ClassSessionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classSessions,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClassSessionsAnnotationComposer(
            $db: $db,
            $table: $db.classSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attendanceRefs<T extends Object>(
    Expression<T> Function($AttendanceAnnotationComposer a) f,
  ) {
    final $AttendanceAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendance,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttendanceAnnotationComposer(
            $db: $db,
            $table: $db.attendance,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feeRecordsRefs<T extends Object>(
    Expression<T> Function($FeeRecordsAnnotationComposer a) f,
  ) {
    final $FeeRecordsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeRecords,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeeRecordsAnnotationComposer(
            $db: $db,
            $table: $db.feeRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($PaymentsAnnotationComposer a) f,
  ) {
    final $PaymentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentsAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
    Expression<T> Function($PaymentAllocationsAnnotationComposer a) f,
  ) {
    final $PaymentAllocationsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentAllocationsAnnotationComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feeChangesRefs<T extends Object>(
    Expression<T> Function($FeeChangesAnnotationComposer a) f,
  ) {
    final $FeeChangesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeChanges,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeeChangesAnnotationComposer(
            $db: $db,
            $table: $db.feeChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pausesRefs<T extends Object>(
    Expression<T> Function($PausesAnnotationComposer a) f,
  ) {
    final $PausesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pauses,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PausesAnnotationComposer(
            $db: $db,
            $table: $db.pauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $StudentsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Students,
          Student,
          $StudentsFilterComposer,
          $StudentsOrderingComposer,
          $StudentsAnnotationComposer,
          $StudentsCreateCompanionBuilder,
          $StudentsUpdateCompanionBuilder,
          (Student, $StudentsReferences),
          Student,
          PrefetchHooks Function({
            bool batchMembersRefs,
            bool classSessionsRefs,
            bool attendanceRefs,
            bool feeRecordsRefs,
            bool paymentsRefs,
            bool paymentAllocationsRefs,
            bool feeChangesRefs,
            bool pausesRefs,
          })
        > {
  $StudentsTableManager(_$AppDatabase db, Students table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $StudentsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $StudentsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $StudentsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> classLevel = const Value.absent(),
                Value<String?> school = const Value.absent(),
                Value<String?> guardianName = const Value.absent(),
                Value<String?> guardianPhone = const Value.absent(),
                Value<String?> studentPhone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> subjects = const Value.absent(),
                Value<String?> classDays = const Value.absent(),
                Value<String?> classTime = const Value.absent(),
                Value<String> joinedOn = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> monthlyFee = const Value.absent(),
                Value<int> feeDueDay = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                name: name,
                classLevel: classLevel,
                school: school,
                guardianName: guardianName,
                guardianPhone: guardianPhone,
                studentPhone: studentPhone,
                address: address,
                photoPath: photoPath,
                subjects: subjects,
                classDays: classDays,
                classTime: classTime,
                joinedOn: joinedOn,
                status: status,
                monthlyFee: monthlyFee,
                feeDueDay: feeDueDay,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> classLevel = const Value.absent(),
                Value<String?> school = const Value.absent(),
                Value<String?> guardianName = const Value.absent(),
                Value<String?> guardianPhone = const Value.absent(),
                Value<String?> studentPhone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> subjects = const Value.absent(),
                Value<String?> classDays = const Value.absent(),
                Value<String?> classTime = const Value.absent(),
                required String joinedOn,
                Value<String> status = const Value.absent(),
                required int monthlyFee,
                Value<int> feeDueDay = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                name: name,
                classLevel: classLevel,
                school: school,
                guardianName: guardianName,
                guardianPhone: guardianPhone,
                studentPhone: studentPhone,
                address: address,
                photoPath: photoPath,
                subjects: subjects,
                classDays: classDays,
                classTime: classTime,
                joinedOn: joinedOn,
                status: status,
                monthlyFee: monthlyFee,
                feeDueDay: feeDueDay,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Students, Student>(table),
                  $StudentsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                batchMembersRefs = false,
                classSessionsRefs = false,
                attendanceRefs = false,
                feeRecordsRefs = false,
                paymentsRefs = false,
                paymentAllocationsRefs = false,
                feeChangesRefs = false,
                pausesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (batchMembersRefs) db.batchMembers,
                    if (classSessionsRefs) db.classSessions,
                    if (attendanceRefs) db.attendance,
                    if (feeRecordsRefs) db.feeRecords,
                    if (paymentsRefs) db.payments,
                    if (paymentAllocationsRefs) db.paymentAllocations,
                    if (feeChangesRefs) db.feeChanges,
                    if (pausesRefs) db.pauses,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (batchMembersRefs)
                        await $_getPrefetchedData<
                          Student,
                          Students,
                          BatchMember
                        >(
                          currentTable: table,
                          referencedTable: $StudentsReferences
                              ._batchMembersRefsTable(db),
                          managerFromTypedResult: (p0) => $StudentsReferences(
                            db,
                            table,
                            p0,
                          ).batchMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (classSessionsRefs)
                        await $_getPrefetchedData<
                          Student,
                          Students,
                          ClassSession
                        >(
                          currentTable: table,
                          referencedTable: $StudentsReferences
                              ._classSessionsRefsTable(db),
                          managerFromTypedResult: (p0) => $StudentsReferences(
                            db,
                            table,
                            p0,
                          ).classSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendanceRefs)
                        await $_getPrefetchedData<
                          Student,
                          Students,
                          AttendanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $StudentsReferences
                              ._attendanceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $StudentsReferences(db, table, p0).attendanceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (feeRecordsRefs)
                        await $_getPrefetchedData<Student, Students, FeeRecord>(
                          currentTable: table,
                          referencedTable: $StudentsReferences
                              ._feeRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $StudentsReferences(db, table, p0).feeRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<Student, Students, Payment>(
                          currentTable: table,
                          referencedTable: $StudentsReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $StudentsReferences(db, table, p0).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentAllocationsRefs)
                        await $_getPrefetchedData<
                          Student,
                          Students,
                          PaymentAllocation
                        >(
                          currentTable: table,
                          referencedTable: $StudentsReferences
                              ._paymentAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) => $StudentsReferences(
                            db,
                            table,
                            p0,
                          ).paymentAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (feeChangesRefs)
                        await $_getPrefetchedData<Student, Students, FeeChange>(
                          currentTable: table,
                          referencedTable: $StudentsReferences
                              ._feeChangesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $StudentsReferences(db, table, p0).feeChangesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pausesRefs)
                        await $_getPrefetchedData<Student, Students, Pause>(
                          currentTable: table,
                          referencedTable: $StudentsReferences._pausesRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $StudentsReferences(db, table, p0).pausesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $StudentsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Students,
      Student,
      $StudentsFilterComposer,
      $StudentsOrderingComposer,
      $StudentsAnnotationComposer,
      $StudentsCreateCompanionBuilder,
      $StudentsUpdateCompanionBuilder,
      (Student, $StudentsReferences),
      Student,
      PrefetchHooks Function({
        bool batchMembersRefs,
        bool classSessionsRefs,
        bool attendanceRefs,
        bool feeRecordsRefs,
        bool paymentsRefs,
        bool paymentAllocationsRefs,
        bool feeChangesRefs,
        bool pausesRefs,
      })
    >;
typedef $BatchesCreateCompanionBuilder = BatchesCompanion Function({
  required String id,
  required String name,
  Value<String?> subject,
  Value<String?> classLevel,
  required String scheduleDays,
  Value<String?> startTime,
  Value<int?> durationMin,
  Value<int> defaultFee,
  Value<String> status,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $BatchesUpdateCompanionBuilder = BatchesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> subject,
  Value<String?> classLevel,
  Value<String> scheduleDays,
  Value<String?> startTime,
  Value<int?> durationMin,
  Value<int> defaultFee,
  Value<String> status,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $BatchesReferences
    extends BaseReferences<_$AppDatabase, Batches, Batch> {
  $BatchesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<BatchMembers, List<BatchMember>>
  _batchMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.batchMembers,
    aliasName: 'batches__id__batch_members__batch_id',
  );

  $BatchMembersProcessedTableManager get batchMembersRefs {
    final manager = $BatchMembersTableManager(
      $_db,
      $_db.batchMembers,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ClassSessions, List<ClassSession>>
  _classSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.classSessions,
    aliasName: 'batches__id__class_sessions__batch_id',
  );

  $ClassSessionsProcessedTableManager get classSessionsRefs {
    final manager = $ClassSessionsTableManager(
      $_db,
      $_db.classSessions,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_classSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $BatchesFilterComposer extends Composer<_$AppDatabase, Batches> {
  $BatchesFilterComposer({
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

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classLevel => $composableBuilder(
    column: $table.classLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleDays => $composableBuilder(
    column: $table.scheduleDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultFee => $composableBuilder(
    column: $table.defaultFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> batchMembersRefs(
    Expression<bool> Function($BatchMembersFilterComposer f) f,
  ) {
    final $BatchMembersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batchMembers,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchMembersFilterComposer(
            $db: $db,
            $table: $db.batchMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> classSessionsRefs(
    Expression<bool> Function($ClassSessionsFilterComposer f) f,
  ) {
    final $ClassSessionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classSessions,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClassSessionsFilterComposer(
            $db: $db,
            $table: $db.classSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $BatchesOrderingComposer extends Composer<_$AppDatabase, Batches> {
  $BatchesOrderingComposer({
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

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classLevel => $composableBuilder(
    column: $table.classLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleDays => $composableBuilder(
    column: $table.scheduleDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultFee => $composableBuilder(
    column: $table.defaultFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $BatchesAnnotationComposer extends Composer<_$AppDatabase, Batches> {
  $BatchesAnnotationComposer({
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

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get classLevel => $composableBuilder(
    column: $table.classLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleDays => $composableBuilder(
    column: $table.scheduleDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultFee => $composableBuilder(
    column: $table.defaultFee,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> batchMembersRefs<T extends Object>(
    Expression<T> Function($BatchMembersAnnotationComposer a) f,
  ) {
    final $BatchMembersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batchMembers,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchMembersAnnotationComposer(
            $db: $db,
            $table: $db.batchMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> classSessionsRefs<T extends Object>(
    Expression<T> Function($ClassSessionsAnnotationComposer a) f,
  ) {
    final $ClassSessionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classSessions,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClassSessionsAnnotationComposer(
            $db: $db,
            $table: $db.classSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $BatchesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Batches,
          Batch,
          $BatchesFilterComposer,
          $BatchesOrderingComposer,
          $BatchesAnnotationComposer,
          $BatchesCreateCompanionBuilder,
          $BatchesUpdateCompanionBuilder,
          (Batch, $BatchesReferences),
          Batch,
          PrefetchHooks Function({
            bool batchMembersRefs,
            bool classSessionsRefs,
          })
        > {
  $BatchesTableManager(_$AppDatabase db, Batches table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BatchesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BatchesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BatchesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String?> classLevel = const Value.absent(),
                Value<String> scheduleDays = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int> defaultFee = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                name: name,
                subject: subject,
                classLevel: classLevel,
                scheduleDays: scheduleDays,
                startTime: startTime,
                durationMin: durationMin,
                defaultFee: defaultFee,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> subject = const Value.absent(),
                Value<String?> classLevel = const Value.absent(),
                required String scheduleDays,
                Value<String?> startTime = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int> defaultFee = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                name: name,
                subject: subject,
                classLevel: classLevel,
                scheduleDays: scheduleDays,
                startTime: startTime,
                durationMin: durationMin,
                defaultFee: defaultFee,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Batches, Batch>(table),
                  $BatchesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({batchMembersRefs = false, classSessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (batchMembersRefs) db.batchMembers,
                    if (classSessionsRefs) db.classSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (batchMembersRefs)
                        await $_getPrefetchedData<Batch, Batches, BatchMember>(
                          currentTable: table,
                          referencedTable: $BatchesReferences
                              ._batchMembersRefsTable(db),
                          managerFromTypedResult: (p0) => $BatchesReferences(
                            db,
                            table,
                            p0,
                          ).batchMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (classSessionsRefs)
                        await $_getPrefetchedData<Batch, Batches, ClassSession>(
                          currentTable: table,
                          referencedTable: $BatchesReferences
                              ._classSessionsRefsTable(db),
                          managerFromTypedResult: (p0) => $BatchesReferences(
                            db,
                            table,
                            p0,
                          ).classSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $BatchesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Batches,
      Batch,
      $BatchesFilterComposer,
      $BatchesOrderingComposer,
      $BatchesAnnotationComposer,
      $BatchesCreateCompanionBuilder,
      $BatchesUpdateCompanionBuilder,
      (Batch, $BatchesReferences),
      Batch,
      PrefetchHooks Function({bool batchMembersRefs, bool classSessionsRefs})
    >;
typedef $BatchMembersCreateCompanionBuilder = BatchMembersCompanion Function({
  required String id,
  required String batchId,
  required String studentId,
  Value<int?> feeOverride,
  required String joinedOn,
  Value<String?> leftOn,
  Value<int> rowid,
});
typedef $BatchMembersUpdateCompanionBuilder = BatchMembersCompanion Function({
  Value<String> id,
  Value<String> batchId,
  Value<String> studentId,
  Value<int?> feeOverride,
  Value<String> joinedOn,
  Value<String?> leftOn,
  Value<int> rowid,
});

final class $BatchMembersReferences
    extends BaseReferences<_$AppDatabase, BatchMembers, BatchMember> {
  $BatchMembersReferences(super.$_db, super.$_table, super.$_typedResult);

  static Batches _batchIdTable(_$AppDatabase db) =>
      db.batches.createAlias('batch_members__batch_id__batches__id');

  $BatchesProcessedTableManager get batchId {
    final $_column = $_itemColumn<String>('batch_id')!;

    final manager = $BatchesTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Students _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('batch_members__student_id__students__id');

  $StudentsProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $StudentsTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $BatchMembersFilterComposer
    extends Composer<_$AppDatabase, BatchMembers> {
  $BatchMembersFilterComposer({
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

  ColumnFilters<int> get feeOverride => $composableBuilder(
    column: $table.feeOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get joinedOn => $composableBuilder(
    column: $table.joinedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leftOn => $composableBuilder(
    column: $table.leftOn,
    builder: (column) => ColumnFilters(column),
  );

  $BatchesFilterComposer get batchId {
    final $BatchesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchesFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsFilterComposer get studentId {
    final $StudentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BatchMembersOrderingComposer
    extends Composer<_$AppDatabase, BatchMembers> {
  $BatchMembersOrderingComposer({
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

  ColumnOrderings<int> get feeOverride => $composableBuilder(
    column: $table.feeOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get joinedOn => $composableBuilder(
    column: $table.joinedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leftOn => $composableBuilder(
    column: $table.leftOn,
    builder: (column) => ColumnOrderings(column),
  );

  $BatchesOrderingComposer get batchId {
    final $BatchesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchesOrderingComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsOrderingComposer get studentId {
    final $StudentsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BatchMembersAnnotationComposer
    extends Composer<_$AppDatabase, BatchMembers> {
  $BatchMembersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get feeOverride => $composableBuilder(
    column: $table.feeOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get joinedOn =>
      $composableBuilder(column: $table.joinedOn, builder: (column) => column);

  GeneratedColumn<String> get leftOn =>
      $composableBuilder(column: $table.leftOn, builder: (column) => column);

  $BatchesAnnotationComposer get batchId {
    final $BatchesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchesAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsAnnotationComposer get studentId {
    final $StudentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BatchMembersTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          BatchMembers,
          BatchMember,
          $BatchMembersFilterComposer,
          $BatchMembersOrderingComposer,
          $BatchMembersAnnotationComposer,
          $BatchMembersCreateCompanionBuilder,
          $BatchMembersUpdateCompanionBuilder,
          (BatchMember, $BatchMembersReferences),
          BatchMember,
          PrefetchHooks Function({bool batchId, bool studentId})
        > {
  $BatchMembersTableManager(_$AppDatabase db, BatchMembers table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BatchMembersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BatchMembersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BatchMembersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int?> feeOverride = const Value.absent(),
                Value<String> joinedOn = const Value.absent(),
                Value<String?> leftOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchMembersCompanion(
                id: id,
                batchId: batchId,
                studentId: studentId,
                feeOverride: feeOverride,
                joinedOn: joinedOn,
                leftOn: leftOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String batchId,
                required String studentId,
                Value<int?> feeOverride = const Value.absent(),
                required String joinedOn,
                Value<String?> leftOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchMembersCompanion.insert(
                id: id,
                batchId: batchId,
                studentId: studentId,
                feeOverride: feeOverride,
                joinedOn: joinedOn,
                leftOn: leftOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<BatchMembers, BatchMember>(table),
                  $BatchMembersReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({batchId = false, studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (batchId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.batchId,
                        referencedTable: $BatchMembersReferences._batchIdTable(
                          db,
                        ),
                        referencedColumn: $BatchMembersReferences
                            ._batchIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (studentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.studentId,
                        referencedTable: $BatchMembersReferences
                            ._studentIdTable(db),
                        referencedColumn: $BatchMembersReferences
                            ._studentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $BatchMembersProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      BatchMembers,
      BatchMember,
      $BatchMembersFilterComposer,
      $BatchMembersOrderingComposer,
      $BatchMembersAnnotationComposer,
      $BatchMembersCreateCompanionBuilder,
      $BatchMembersUpdateCompanionBuilder,
      (BatchMember, $BatchMembersReferences),
      BatchMember,
      PrefetchHooks Function({bool batchId, bool studentId})
    >;
typedef $ClassSessionsCreateCompanionBuilder = ClassSessionsCompanion Function({
  required String id,
  Value<String?> batchId,
  Value<String?> studentId,
  required String date,
  Value<String?> startTime,
  Value<String> status,
  Value<String?> topic,
  Value<String?> note,
  Value<int> rowid,
});
typedef $ClassSessionsUpdateCompanionBuilder = ClassSessionsCompanion Function({
  Value<String> id,
  Value<String?> batchId,
  Value<String?> studentId,
  Value<String> date,
  Value<String?> startTime,
  Value<String> status,
  Value<String?> topic,
  Value<String?> note,
  Value<int> rowid,
});

final class $ClassSessionsReferences
    extends BaseReferences<_$AppDatabase, ClassSessions, ClassSession> {
  $ClassSessionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Batches _batchIdTable(_$AppDatabase db) =>
      db.batches.createAlias('class_sessions__batch_id__batches__id');

  $BatchesProcessedTableManager? get batchId {
    final $_column = $_itemColumn<String>('batch_id');
    if ($_column == null) return null;
    final manager = $BatchesTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Students _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('class_sessions__student_id__students__id');

  $StudentsProcessedTableManager? get studentId {
    final $_column = $_itemColumn<String>('student_id');
    if ($_column == null) return null;
    final manager = $StudentsTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Attendance, List<AttendanceRecord>>
  _attendanceRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendance,
    aliasName: 'class_sessions__id__attendance__session_id',
  );

  $AttendanceProcessedTableManager get attendanceRefs {
    final manager = $AttendanceTableManager(
      $_db,
      $_db.attendance,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendanceRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ClassSessionsFilterComposer
    extends Composer<_$AppDatabase, ClassSessions> {
  $ClassSessionsFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $BatchesFilterComposer get batchId {
    final $BatchesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchesFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsFilterComposer get studentId {
    final $StudentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attendanceRefs(
    Expression<bool> Function($AttendanceFilterComposer f) f,
  ) {
    final $AttendanceFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendance,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttendanceFilterComposer(
            $db: $db,
            $table: $db.attendance,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ClassSessionsOrderingComposer
    extends Composer<_$AppDatabase, ClassSessions> {
  $ClassSessionsOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $BatchesOrderingComposer get batchId {
    final $BatchesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchesOrderingComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsOrderingComposer get studentId {
    final $StudentsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ClassSessionsAnnotationComposer
    extends Composer<_$AppDatabase, ClassSessions> {
  $ClassSessionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $BatchesAnnotationComposer get batchId {
    final $BatchesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BatchesAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsAnnotationComposer get studentId {
    final $StudentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attendanceRefs<T extends Object>(
    Expression<T> Function($AttendanceAnnotationComposer a) f,
  ) {
    final $AttendanceAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendance,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttendanceAnnotationComposer(
            $db: $db,
            $table: $db.attendance,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ClassSessionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ClassSessions,
          ClassSession,
          $ClassSessionsFilterComposer,
          $ClassSessionsOrderingComposer,
          $ClassSessionsAnnotationComposer,
          $ClassSessionsCreateCompanionBuilder,
          $ClassSessionsUpdateCompanionBuilder,
          (ClassSession, $ClassSessionsReferences),
          ClassSession,
          PrefetchHooks Function({
            bool batchId,
            bool studentId,
            bool attendanceRefs,
          })
        > {
  $ClassSessionsTableManager(_$AppDatabase db, ClassSessions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ClassSessionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ClassSessionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ClassSessionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> studentId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> topic = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassSessionsCompanion(
                id: id,
                batchId: batchId,
                studentId: studentId,
                date: date,
                startTime: startTime,
                status: status,
                topic: topic,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> batchId = const Value.absent(),
                Value<String?> studentId = const Value.absent(),
                required String date,
                Value<String?> startTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> topic = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassSessionsCompanion.insert(
                id: id,
                batchId: batchId,
                studentId: studentId,
                date: date,
                startTime: startTime,
                status: status,
                topic: topic,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ClassSessions, ClassSession>(table),
                  $ClassSessionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({batchId = false, studentId = false, attendanceRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (attendanceRefs) db.attendance],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (batchId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.batchId,
                            referencedTable: $ClassSessionsReferences
                                ._batchIdTable(db),
                            referencedColumn: $ClassSessionsReferences
                                ._batchIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (studentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.studentId,
                            referencedTable: $ClassSessionsReferences
                                ._studentIdTable(db),
                            referencedColumn: $ClassSessionsReferences
                                ._studentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceRefs)
                        await $_getPrefetchedData<
                          ClassSession,
                          ClassSessions,
                          AttendanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $ClassSessionsReferences
                              ._attendanceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ClassSessionsReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ClassSessionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ClassSessions,
      ClassSession,
      $ClassSessionsFilterComposer,
      $ClassSessionsOrderingComposer,
      $ClassSessionsAnnotationComposer,
      $ClassSessionsCreateCompanionBuilder,
      $ClassSessionsUpdateCompanionBuilder,
      (ClassSession, $ClassSessionsReferences),
      ClassSession,
      PrefetchHooks Function({
        bool batchId,
        bool studentId,
        bool attendanceRefs,
      })
    >;
typedef $AttendanceCreateCompanionBuilder = AttendanceCompanion Function({
  required String id,
  required String sessionId,
  required String studentId,
  required String status,
  Value<int> rowid,
});
typedef $AttendanceUpdateCompanionBuilder = AttendanceCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> studentId,
  Value<String> status,
  Value<int> rowid,
});

final class $AttendanceReferences
    extends BaseReferences<_$AppDatabase, Attendance, AttendanceRecord> {
  $AttendanceReferences(super.$_db, super.$_table, super.$_typedResult);

  static ClassSessions _sessionIdTable(_$AppDatabase db) => db.classSessions
      .createAlias('attendance__session_id__class_sessions__id');

  $ClassSessionsProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $ClassSessionsTableManager(
      $_db,
      $_db.classSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Students _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('attendance__student_id__students__id');

  $StudentsProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $StudentsTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $AttendanceFilterComposer extends Composer<_$AppDatabase, Attendance> {
  $AttendanceFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $ClassSessionsFilterComposer get sessionId {
    final $ClassSessionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.classSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClassSessionsFilterComposer(
            $db: $db,
            $table: $db.classSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsFilterComposer get studentId {
    final $StudentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttendanceOrderingComposer extends Composer<_$AppDatabase, Attendance> {
  $AttendanceOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $ClassSessionsOrderingComposer get sessionId {
    final $ClassSessionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.classSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClassSessionsOrderingComposer(
            $db: $db,
            $table: $db.classSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsOrderingComposer get studentId {
    final $StudentsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttendanceAnnotationComposer
    extends Composer<_$AppDatabase, Attendance> {
  $AttendanceAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $ClassSessionsAnnotationComposer get sessionId {
    final $ClassSessionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.classSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClassSessionsAnnotationComposer(
            $db: $db,
            $table: $db.classSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsAnnotationComposer get studentId {
    final $StudentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttendanceTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Attendance,
          AttendanceRecord,
          $AttendanceFilterComposer,
          $AttendanceOrderingComposer,
          $AttendanceAnnotationComposer,
          $AttendanceCreateCompanionBuilder,
          $AttendanceUpdateCompanionBuilder,
          (AttendanceRecord, $AttendanceReferences),
          AttendanceRecord,
          PrefetchHooks Function({bool sessionId, bool studentId})
        > {
  $AttendanceTableManager(_$AppDatabase db, Attendance table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AttendanceFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AttendanceOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AttendanceAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceCompanion(
                id: id,
                sessionId: sessionId,
                studentId: studentId,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String studentId,
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => AttendanceCompanion.insert(
                id: id,
                sessionId: sessionId,
                studentId: studentId,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Attendance, AttendanceRecord>(table),
                  $AttendanceReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $AttendanceReferences._sessionIdTable(
                          db,
                        ),
                        referencedColumn: $AttendanceReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (studentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.studentId,
                        referencedTable: $AttendanceReferences._studentIdTable(
                          db,
                        ),
                        referencedColumn: $AttendanceReferences
                            ._studentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $AttendanceProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Attendance,
      AttendanceRecord,
      $AttendanceFilterComposer,
      $AttendanceOrderingComposer,
      $AttendanceAnnotationComposer,
      $AttendanceCreateCompanionBuilder,
      $AttendanceUpdateCompanionBuilder,
      (AttendanceRecord, $AttendanceReferences),
      AttendanceRecord,
      PrefetchHooks Function({bool sessionId, bool studentId})
    >;
typedef $FeeRecordsCreateCompanionBuilder = FeeRecordsCompanion Function({
  required String id,
  required String studentId,
  required String month,
  Value<String> kind,
  Value<String?> label,
  required int amountDue,
  Value<int> discount,
  Value<int> waived,
  required String dueDate,
  Value<String?> note,
  required int createdAt,
  Value<int> rowid,
});
typedef $FeeRecordsUpdateCompanionBuilder = FeeRecordsCompanion Function({
  Value<String> id,
  Value<String> studentId,
  Value<String> month,
  Value<String> kind,
  Value<String?> label,
  Value<int> amountDue,
  Value<int> discount,
  Value<int> waived,
  Value<String> dueDate,
  Value<String?> note,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $FeeRecordsReferences
    extends BaseReferences<_$AppDatabase, FeeRecords, FeeRecord> {
  $FeeRecordsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Students _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('fee_records__student_id__students__id');

  $StudentsProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $StudentsTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<PaymentAllocations, List<PaymentAllocation>>
  _paymentAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentAllocations,
        aliasName: 'fee_records__id__payment_allocations__fee_record_id',
      );

  $PaymentAllocationsProcessedTableManager get paymentAllocationsRefs {
    final manager = $PaymentAllocationsTableManager(
      $_db,
      $_db.paymentAllocations,
    ).filter((f) => f.feeRecordId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $FeeRecordsFilterComposer extends Composer<_$AppDatabase, FeeRecords> {
  $FeeRecordsFilterComposer({
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

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountDue => $composableBuilder(
    column: $table.amountDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waived => $composableBuilder(
    column: $table.waived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $StudentsFilterComposer get studentId {
    final $StudentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentAllocationsRefs(
    Expression<bool> Function($PaymentAllocationsFilterComposer f) f,
  ) {
    final $PaymentAllocationsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.feeRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentAllocationsFilterComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FeeRecordsOrderingComposer extends Composer<_$AppDatabase, FeeRecords> {
  $FeeRecordsOrderingComposer({
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

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountDue => $composableBuilder(
    column: $table.amountDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waived => $composableBuilder(
    column: $table.waived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $StudentsOrderingComposer get studentId {
    final $StudentsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FeeRecordsAnnotationComposer
    extends Composer<_$AppDatabase, FeeRecords> {
  $FeeRecordsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get amountDue =>
      $composableBuilder(column: $table.amountDue, builder: (column) => column);

  GeneratedColumn<int> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get waived =>
      $composableBuilder(column: $table.waived, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $StudentsAnnotationComposer get studentId {
    final $StudentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
    Expression<T> Function($PaymentAllocationsAnnotationComposer a) f,
  ) {
    final $PaymentAllocationsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.feeRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentAllocationsAnnotationComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FeeRecordsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          FeeRecords,
          FeeRecord,
          $FeeRecordsFilterComposer,
          $FeeRecordsOrderingComposer,
          $FeeRecordsAnnotationComposer,
          $FeeRecordsCreateCompanionBuilder,
          $FeeRecordsUpdateCompanionBuilder,
          (FeeRecord, $FeeRecordsReferences),
          FeeRecord,
          PrefetchHooks Function({bool studentId, bool paymentAllocationsRefs})
        > {
  $FeeRecordsTableManager(_$AppDatabase db, FeeRecords table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FeeRecordsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FeeRecordsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FeeRecordsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> amountDue = const Value.absent(),
                Value<int> discount = const Value.absent(),
                Value<int> waived = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeeRecordsCompanion(
                id: id,
                studentId: studentId,
                month: month,
                kind: kind,
                label: label,
                amountDue: amountDue,
                discount: discount,
                waived: waived,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String month,
                Value<String> kind = const Value.absent(),
                Value<String?> label = const Value.absent(),
                required int amountDue,
                Value<int> discount = const Value.absent(),
                Value<int> waived = const Value.absent(),
                required String dueDate,
                Value<String?> note = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FeeRecordsCompanion.insert(
                id: id,
                studentId: studentId,
                month: month,
                kind: kind,
                label: label,
                amountDue: amountDue,
                discount: discount,
                waived: waived,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<FeeRecords, FeeRecord>(table),
                  $FeeRecordsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({studentId = false, paymentAllocationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentAllocationsRefs) db.paymentAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (studentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.studentId,
                            referencedTable: $FeeRecordsReferences
                                ._studentIdTable(db),
                            referencedColumn: $FeeRecordsReferences
                                ._studentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentAllocationsRefs)
                        await $_getPrefetchedData<
                          FeeRecord,
                          FeeRecords,
                          PaymentAllocation
                        >(
                          currentTable: table,
                          referencedTable: $FeeRecordsReferences
                              ._paymentAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) => $FeeRecordsReferences(
                            db,
                            table,
                            p0,
                          ).paymentAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.feeRecordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $FeeRecordsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      FeeRecords,
      FeeRecord,
      $FeeRecordsFilterComposer,
      $FeeRecordsOrderingComposer,
      $FeeRecordsAnnotationComposer,
      $FeeRecordsCreateCompanionBuilder,
      $FeeRecordsUpdateCompanionBuilder,
      (FeeRecord, $FeeRecordsReferences),
      FeeRecord,
      PrefetchHooks Function({bool studentId, bool paymentAllocationsRefs})
    >;
typedef $PaymentsCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String studentId,
  required int amount,
  required String receivedOn,
  Value<String> method,
  Value<String?> reference,
  required int receiptNo,
  Value<String?> note,
  required int createdAt,
  Value<int?> deletedAt,
  Value<int?> receiptSharedAt,
  Value<int> rowid,
});
typedef $PaymentsUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> studentId,
  Value<int> amount,
  Value<String> receivedOn,
  Value<String> method,
  Value<String?> reference,
  Value<int> receiptNo,
  Value<String?> note,
  Value<int> createdAt,
  Value<int?> deletedAt,
  Value<int?> receiptSharedAt,
  Value<int> rowid,
});

final class $PaymentsReferences
    extends BaseReferences<_$AppDatabase, Payments, Payment> {
  $PaymentsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Students _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('payments__student_id__students__id');

  $StudentsProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $StudentsTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<PaymentAllocations, List<PaymentAllocation>>
  _paymentAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentAllocations,
        aliasName: 'payments__id__payment_allocations__payment_id',
      );

  $PaymentAllocationsProcessedTableManager get paymentAllocationsRefs {
    final manager = $PaymentAllocationsTableManager(
      $_db,
      $_db.paymentAllocations,
    ).filter((f) => f.paymentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $PaymentsFilterComposer extends Composer<_$AppDatabase, Payments> {
  $PaymentsFilterComposer({
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

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedOn => $composableBuilder(
    column: $table.receivedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receiptSharedAt => $composableBuilder(
    column: $table.receiptSharedAt,
    builder: (column) => ColumnFilters(column),
  );

  $StudentsFilterComposer get studentId {
    final $StudentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentAllocationsRefs(
    Expression<bool> Function($PaymentAllocationsFilterComposer f) f,
  ) {
    final $PaymentAllocationsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.paymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentAllocationsFilterComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PaymentsOrderingComposer extends Composer<_$AppDatabase, Payments> {
  $PaymentsOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedOn => $composableBuilder(
    column: $table.receivedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receiptSharedAt => $composableBuilder(
    column: $table.receiptSharedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $StudentsOrderingComposer get studentId {
    final $StudentsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PaymentsAnnotationComposer extends Composer<_$AppDatabase, Payments> {
  $PaymentsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get receivedOn => $composableBuilder(
    column: $table.receivedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<int> get receiptNo =>
      $composableBuilder(column: $table.receiptNo, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get receiptSharedAt => $composableBuilder(
    column: $table.receiptSharedAt,
    builder: (column) => column,
  );

  $StudentsAnnotationComposer get studentId {
    final $StudentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
    Expression<T> Function($PaymentAllocationsAnnotationComposer a) f,
  ) {
    final $PaymentAllocationsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.paymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentAllocationsAnnotationComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PaymentsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Payments,
          Payment,
          $PaymentsFilterComposer,
          $PaymentsOrderingComposer,
          $PaymentsAnnotationComposer,
          $PaymentsCreateCompanionBuilder,
          $PaymentsUpdateCompanionBuilder,
          (Payment, $PaymentsReferences),
          Payment,
          PrefetchHooks Function({bool studentId, bool paymentAllocationsRefs})
        > {
  $PaymentsTableManager(_$AppDatabase db, Payments table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PaymentsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PaymentsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PaymentsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> receivedOn = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<int> receiptNo = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> receiptSharedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                studentId: studentId,
                amount: amount,
                receivedOn: receivedOn,
                method: method,
                reference: reference,
                receiptNo: receiptNo,
                note: note,
                createdAt: createdAt,
                deletedAt: deletedAt,
                receiptSharedAt: receiptSharedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required int amount,
                required String receivedOn,
                Value<String> method = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                required int receiptNo,
                Value<String?> note = const Value.absent(),
                required int createdAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> receiptSharedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                studentId: studentId,
                amount: amount,
                receivedOn: receivedOn,
                method: method,
                reference: reference,
                receiptNo: receiptNo,
                note: note,
                createdAt: createdAt,
                deletedAt: deletedAt,
                receiptSharedAt: receiptSharedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Payments, Payment>(table),
                  $PaymentsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({studentId = false, paymentAllocationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentAllocationsRefs) db.paymentAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (studentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.studentId,
                            referencedTable: $PaymentsReferences
                                ._studentIdTable(db),
                            referencedColumn: $PaymentsReferences
                                ._studentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentAllocationsRefs)
                        await $_getPrefetchedData<
                          Payment,
                          Payments,
                          PaymentAllocation
                        >(
                          currentTable: table,
                          referencedTable: $PaymentsReferences
                              ._paymentAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) => $PaymentsReferences(
                            db,
                            table,
                            p0,
                          ).paymentAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.paymentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $PaymentsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Payments,
      Payment,
      $PaymentsFilterComposer,
      $PaymentsOrderingComposer,
      $PaymentsAnnotationComposer,
      $PaymentsCreateCompanionBuilder,
      $PaymentsUpdateCompanionBuilder,
      (Payment, $PaymentsReferences),
      Payment,
      PrefetchHooks Function({bool studentId, bool paymentAllocationsRefs})
    >;
typedef $PaymentAllocationsCreateCompanionBuilder =
    PaymentAllocationsCompanion Function({
      required String id,
      required String paymentId,
      Value<String?> feeRecordId,
      required String studentId,
      required int amount,
      Value<int> rowid,
    });
typedef $PaymentAllocationsUpdateCompanionBuilder =
    PaymentAllocationsCompanion Function({
      Value<String> id,
      Value<String> paymentId,
      Value<String?> feeRecordId,
      Value<String> studentId,
      Value<int> amount,
      Value<int> rowid,
    });

final class $PaymentAllocationsReferences
    extends
        BaseReferences<_$AppDatabase, PaymentAllocations, PaymentAllocation> {
  $PaymentAllocationsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Payments _paymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias('payment_allocations__payment_id__payments__id');

  $PaymentsProcessedTableManager get paymentId {
    final $_column = $_itemColumn<String>('payment_id')!;

    final manager = $PaymentsTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static FeeRecords _feeRecordIdTable(_$AppDatabase db) => db.feeRecords
      .createAlias('payment_allocations__fee_record_id__fee_records__id');

  $FeeRecordsProcessedTableManager? get feeRecordId {
    final $_column = $_itemColumn<String>('fee_record_id');
    if ($_column == null) return null;
    final manager = $FeeRecordsTableManager(
      $_db,
      $_db.feeRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feeRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Students _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('payment_allocations__student_id__students__id');

  $StudentsProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $StudentsTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $PaymentAllocationsFilterComposer
    extends Composer<_$AppDatabase, PaymentAllocations> {
  $PaymentAllocationsFilterComposer({
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

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $PaymentsFilterComposer get paymentId {
    final $PaymentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentsFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FeeRecordsFilterComposer get feeRecordId {
    final $FeeRecordsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feeRecordId,
      referencedTable: $db.feeRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeeRecordsFilterComposer(
            $db: $db,
            $table: $db.feeRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsFilterComposer get studentId {
    final $StudentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PaymentAllocationsOrderingComposer
    extends Composer<_$AppDatabase, PaymentAllocations> {
  $PaymentAllocationsOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $PaymentsOrderingComposer get paymentId {
    final $PaymentsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentsOrderingComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FeeRecordsOrderingComposer get feeRecordId {
    final $FeeRecordsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feeRecordId,
      referencedTable: $db.feeRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeeRecordsOrderingComposer(
            $db: $db,
            $table: $db.feeRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsOrderingComposer get studentId {
    final $StudentsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PaymentAllocationsAnnotationComposer
    extends Composer<_$AppDatabase, PaymentAllocations> {
  $PaymentAllocationsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $PaymentsAnnotationComposer get paymentId {
    final $PaymentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PaymentsAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FeeRecordsAnnotationComposer get feeRecordId {
    final $FeeRecordsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feeRecordId,
      referencedTable: $db.feeRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeeRecordsAnnotationComposer(
            $db: $db,
            $table: $db.feeRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $StudentsAnnotationComposer get studentId {
    final $StudentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PaymentAllocationsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          PaymentAllocations,
          PaymentAllocation,
          $PaymentAllocationsFilterComposer,
          $PaymentAllocationsOrderingComposer,
          $PaymentAllocationsAnnotationComposer,
          $PaymentAllocationsCreateCompanionBuilder,
          $PaymentAllocationsUpdateCompanionBuilder,
          (PaymentAllocation, $PaymentAllocationsReferences),
          PaymentAllocation,
          PrefetchHooks Function({
            bool paymentId,
            bool feeRecordId,
            bool studentId,
          })
        > {
  $PaymentAllocationsTableManager(_$AppDatabase db, PaymentAllocations table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PaymentAllocationsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PaymentAllocationsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PaymentAllocationsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String?> feeRecordId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentAllocationsCompanion(
                id: id,
                paymentId: paymentId,
                feeRecordId: feeRecordId,
                studentId: studentId,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String paymentId,
                Value<String?> feeRecordId = const Value.absent(),
                required String studentId,
                required int amount,
                Value<int> rowid = const Value.absent(),
              }) => PaymentAllocationsCompanion.insert(
                id: id,
                paymentId: paymentId,
                feeRecordId: feeRecordId,
                studentId: studentId,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PaymentAllocations, PaymentAllocation>(table),
                  $PaymentAllocationsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({paymentId = false, feeRecordId = false, studentId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (paymentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paymentId,
                            referencedTable: $PaymentAllocationsReferences
                                ._paymentIdTable(db),
                            referencedColumn: $PaymentAllocationsReferences
                                ._paymentIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (feeRecordId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.feeRecordId,
                            referencedTable: $PaymentAllocationsReferences
                                ._feeRecordIdTable(db),
                            referencedColumn: $PaymentAllocationsReferences
                                ._feeRecordIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (studentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.studentId,
                            referencedTable: $PaymentAllocationsReferences
                                ._studentIdTable(db),
                            referencedColumn: $PaymentAllocationsReferences
                                ._studentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $PaymentAllocationsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      PaymentAllocations,
      PaymentAllocation,
      $PaymentAllocationsFilterComposer,
      $PaymentAllocationsOrderingComposer,
      $PaymentAllocationsAnnotationComposer,
      $PaymentAllocationsCreateCompanionBuilder,
      $PaymentAllocationsUpdateCompanionBuilder,
      (PaymentAllocation, $PaymentAllocationsReferences),
      PaymentAllocation,
      PrefetchHooks Function({bool paymentId, bool feeRecordId, bool studentId})
    >;
typedef $FeeChangesCreateCompanionBuilder = FeeChangesCompanion Function({
  required String id,
  required String studentId,
  required String effectiveMonth,
  required int newAmount,
  Value<int> rowid,
});
typedef $FeeChangesUpdateCompanionBuilder = FeeChangesCompanion Function({
  Value<String> id,
  Value<String> studentId,
  Value<String> effectiveMonth,
  Value<int> newAmount,
  Value<int> rowid,
});

final class $FeeChangesReferences
    extends BaseReferences<_$AppDatabase, FeeChanges, FeeChange> {
  $FeeChangesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Students _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('fee_changes__student_id__students__id');

  $StudentsProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $StudentsTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $FeeChangesFilterComposer extends Composer<_$AppDatabase, FeeChanges> {
  $FeeChangesFilterComposer({
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

  ColumnFilters<String> get effectiveMonth => $composableBuilder(
    column: $table.effectiveMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newAmount => $composableBuilder(
    column: $table.newAmount,
    builder: (column) => ColumnFilters(column),
  );

  $StudentsFilterComposer get studentId {
    final $StudentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FeeChangesOrderingComposer extends Composer<_$AppDatabase, FeeChanges> {
  $FeeChangesOrderingComposer({
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

  ColumnOrderings<String> get effectiveMonth => $composableBuilder(
    column: $table.effectiveMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newAmount => $composableBuilder(
    column: $table.newAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $StudentsOrderingComposer get studentId {
    final $StudentsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FeeChangesAnnotationComposer
    extends Composer<_$AppDatabase, FeeChanges> {
  $FeeChangesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get effectiveMonth => $composableBuilder(
    column: $table.effectiveMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newAmount =>
      $composableBuilder(column: $table.newAmount, builder: (column) => column);

  $StudentsAnnotationComposer get studentId {
    final $StudentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FeeChangesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          FeeChanges,
          FeeChange,
          $FeeChangesFilterComposer,
          $FeeChangesOrderingComposer,
          $FeeChangesAnnotationComposer,
          $FeeChangesCreateCompanionBuilder,
          $FeeChangesUpdateCompanionBuilder,
          (FeeChange, $FeeChangesReferences),
          FeeChange,
          PrefetchHooks Function({bool studentId})
        > {
  $FeeChangesTableManager(_$AppDatabase db, FeeChanges table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FeeChangesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FeeChangesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FeeChangesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> effectiveMonth = const Value.absent(),
                Value<int> newAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeeChangesCompanion(
                id: id,
                studentId: studentId,
                effectiveMonth: effectiveMonth,
                newAmount: newAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String effectiveMonth,
                required int newAmount,
                Value<int> rowid = const Value.absent(),
              }) => FeeChangesCompanion.insert(
                id: id,
                studentId: studentId,
                effectiveMonth: effectiveMonth,
                newAmount: newAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<FeeChanges, FeeChange>(table),
                  $FeeChangesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (studentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.studentId,
                        referencedTable: $FeeChangesReferences._studentIdTable(
                          db,
                        ),
                        referencedColumn: $FeeChangesReferences
                            ._studentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $FeeChangesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      FeeChanges,
      FeeChange,
      $FeeChangesFilterComposer,
      $FeeChangesOrderingComposer,
      $FeeChangesAnnotationComposer,
      $FeeChangesCreateCompanionBuilder,
      $FeeChangesUpdateCompanionBuilder,
      (FeeChange, $FeeChangesReferences),
      FeeChange,
      PrefetchHooks Function({bool studentId})
    >;
typedef $PausesCreateCompanionBuilder = PausesCompanion Function({
  required String id,
  required String studentId,
  required String fromMonth,
  Value<String?> toMonth,
  Value<int> rowid,
});
typedef $PausesUpdateCompanionBuilder = PausesCompanion Function({
  Value<String> id,
  Value<String> studentId,
  Value<String> fromMonth,
  Value<String?> toMonth,
  Value<int> rowid,
});

final class $PausesReferences
    extends BaseReferences<_$AppDatabase, Pauses, Pause> {
  $PausesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Students _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('pauses__student_id__students__id');

  $StudentsProcessedTableManager get studentId {
    final $_column = $_itemColumn<String>('student_id')!;

    final manager = $StudentsTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $PausesFilterComposer extends Composer<_$AppDatabase, Pauses> {
  $PausesFilterComposer({
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

  ColumnFilters<String> get fromMonth => $composableBuilder(
    column: $table.fromMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toMonth => $composableBuilder(
    column: $table.toMonth,
    builder: (column) => ColumnFilters(column),
  );

  $StudentsFilterComposer get studentId {
    final $StudentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PausesOrderingComposer extends Composer<_$AppDatabase, Pauses> {
  $PausesOrderingComposer({
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

  ColumnOrderings<String> get fromMonth => $composableBuilder(
    column: $table.fromMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toMonth => $composableBuilder(
    column: $table.toMonth,
    builder: (column) => ColumnOrderings(column),
  );

  $StudentsOrderingComposer get studentId {
    final $StudentsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PausesAnnotationComposer extends Composer<_$AppDatabase, Pauses> {
  $PausesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromMonth =>
      $composableBuilder(column: $table.fromMonth, builder: (column) => column);

  GeneratedColumn<String> get toMonth =>
      $composableBuilder(column: $table.toMonth, builder: (column) => column);

  $StudentsAnnotationComposer get studentId {
    final $StudentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $StudentsAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PausesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Pauses,
          Pause,
          $PausesFilterComposer,
          $PausesOrderingComposer,
          $PausesAnnotationComposer,
          $PausesCreateCompanionBuilder,
          $PausesUpdateCompanionBuilder,
          (Pause, $PausesReferences),
          Pause,
          PrefetchHooks Function({bool studentId})
        > {
  $PausesTableManager(_$AppDatabase db, Pauses table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PausesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PausesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PausesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> fromMonth = const Value.absent(),
                Value<String?> toMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PausesCompanion(
                id: id,
                studentId: studentId,
                fromMonth: fromMonth,
                toMonth: toMonth,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String fromMonth,
                Value<String?> toMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PausesCompanion.insert(
                id: id,
                studentId: studentId,
                fromMonth: fromMonth,
                toMonth: toMonth,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Pauses, Pause>(table),
                  $PausesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (studentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.studentId,
                        referencedTable: $PausesReferences._studentIdTable(db),
                        referencedColumn: $PausesReferences
                            ._studentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $PausesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Pauses,
      Pause,
      $PausesFilterComposer,
      $PausesOrderingComposer,
      $PausesAnnotationComposer,
      $PausesCreateCompanionBuilder,
      $PausesUpdateCompanionBuilder,
      (Pause, $PausesReferences),
      Pause,
      PrefetchHooks Function({bool studentId})
    >;
typedef $SettingsCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $SettingsUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $SettingsFilterComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsFilterComposer({
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

class $SettingsOrderingComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsOrderingComposer({
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

class $SettingsAnnotationComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsAnnotationComposer({
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

class $SettingsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Settings,
          Setting,
          $SettingsFilterComposer,
          $SettingsOrderingComposer,
          $SettingsAnnotationComposer,
          $SettingsCreateCompanionBuilder,
          $SettingsUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, Settings, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $SettingsTableManager(_$AppDatabase db, Settings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Settings, Setting>(table),
                  BaseReferences<_$AppDatabase, Settings, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettingsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Settings,
      Setting,
      $SettingsFilterComposer,
      $SettingsOrderingComposer,
      $SettingsAnnotationComposer,
      $SettingsCreateCompanionBuilder,
      $SettingsUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, Settings, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $MessageTemplatesCreateCompanionBuilder =
    MessageTemplatesCompanion Function({
      required String id,
      required String kind,
      required String language,
      required String body,
      Value<int> rowid,
    });
typedef $MessageTemplatesUpdateCompanionBuilder =
    MessageTemplatesCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> language,
      Value<String> body,
      Value<int> rowid,
    });

class $MessageTemplatesFilterComposer
    extends Composer<_$AppDatabase, MessageTemplates> {
  $MessageTemplatesFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $MessageTemplatesOrderingComposer
    extends Composer<_$AppDatabase, MessageTemplates> {
  $MessageTemplatesOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $MessageTemplatesAnnotationComposer
    extends Composer<_$AppDatabase, MessageTemplates> {
  $MessageTemplatesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $MessageTemplatesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          MessageTemplates,
          MessageTemplate,
          $MessageTemplatesFilterComposer,
          $MessageTemplatesOrderingComposer,
          $MessageTemplatesAnnotationComposer,
          $MessageTemplatesCreateCompanionBuilder,
          $MessageTemplatesUpdateCompanionBuilder,
          (
            MessageTemplate,
            BaseReferences<_$AppDatabase, MessageTemplates, MessageTemplate>,
          ),
          MessageTemplate,
          PrefetchHooks Function()
        > {
  $MessageTemplatesTableManager(_$AppDatabase db, MessageTemplates table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MessageTemplatesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MessageTemplatesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MessageTemplatesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageTemplatesCompanion(
                id: id,
                kind: kind,
                language: language,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String language,
                required String body,
                Value<int> rowid = const Value.absent(),
              }) => MessageTemplatesCompanion.insert(
                id: id,
                kind: kind,
                language: language,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<MessageTemplates, MessageTemplate>(table),
                  BaseReferences<
                    _$AppDatabase,
                    MessageTemplates,
                    MessageTemplate
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $MessageTemplatesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      MessageTemplates,
      MessageTemplate,
      $MessageTemplatesFilterComposer,
      $MessageTemplatesOrderingComposer,
      $MessageTemplatesAnnotationComposer,
      $MessageTemplatesCreateCompanionBuilder,
      $MessageTemplatesUpdateCompanionBuilder,
      (
        MessageTemplate,
        BaseReferences<_$AppDatabase, MessageTemplates, MessageTemplate>,
      ),
      MessageTemplate,
      PrefetchHooks Function()
    >;
typedef $AuditLogCreateCompanionBuilder = AuditLogCompanion Function({
  required String id,
  required String entity,
  required String entityId,
  required String action,
  Value<String?> details,
  required int at,
  Value<int> rowid,
});
typedef $AuditLogUpdateCompanionBuilder = AuditLogCompanion Function({
  Value<String> id,
  Value<String> entity,
  Value<String> entityId,
  Value<String> action,
  Value<String?> details,
  Value<int> at,
  Value<int> rowid,
});

class $AuditLogFilterComposer extends Composer<_$AppDatabase, AuditLog> {
  $AuditLogFilterComposer({
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

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $AuditLogOrderingComposer extends Composer<_$AppDatabase, AuditLog> {
  $AuditLogOrderingComposer({
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

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AuditLogAnnotationComposer extends Composer<_$AppDatabase, AuditLog> {
  $AuditLogAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $AuditLogTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          AuditLog,
          AuditLogEntry,
          $AuditLogFilterComposer,
          $AuditLogOrderingComposer,
          $AuditLogAnnotationComposer,
          $AuditLogCreateCompanionBuilder,
          $AuditLogUpdateCompanionBuilder,
          (
            AuditLogEntry,
            BaseReferences<_$AppDatabase, AuditLog, AuditLogEntry>,
          ),
          AuditLogEntry,
          PrefetchHooks Function()
        > {
  $AuditLogTableManager(_$AppDatabase db, AuditLog table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AuditLogFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AuditLogOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AuditLogAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion(
                id: id,
                entity: entity,
                entityId: entityId,
                action: action,
                details: details,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entity,
                required String entityId,
                required String action,
                Value<String?> details = const Value.absent(),
                required int at,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion.insert(
                id: id,
                entity: entity,
                entityId: entityId,
                action: action,
                details: details,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AuditLog, AuditLogEntry>(table),
                  BaseReferences<_$AppDatabase, AuditLog, AuditLogEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AuditLogProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      AuditLog,
      AuditLogEntry,
      $AuditLogFilterComposer,
      $AuditLogOrderingComposer,
      $AuditLogAnnotationComposer,
      $AuditLogCreateCompanionBuilder,
      $AuditLogUpdateCompanionBuilder,
      (AuditLogEntry, BaseReferences<_$AppDatabase, AuditLog, AuditLogEntry>),
      AuditLogEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $StudentsTableManager get students =>
      $StudentsTableManager(_db, _db.students);
  $BatchesTableManager get batches => $BatchesTableManager(_db, _db.batches);
  $BatchMembersTableManager get batchMembers =>
      $BatchMembersTableManager(_db, _db.batchMembers);
  $ClassSessionsTableManager get classSessions =>
      $ClassSessionsTableManager(_db, _db.classSessions);
  $AttendanceTableManager get attendance =>
      $AttendanceTableManager(_db, _db.attendance);
  $FeeRecordsTableManager get feeRecords =>
      $FeeRecordsTableManager(_db, _db.feeRecords);
  $PaymentsTableManager get payments =>
      $PaymentsTableManager(_db, _db.payments);
  $PaymentAllocationsTableManager get paymentAllocations =>
      $PaymentAllocationsTableManager(_db, _db.paymentAllocations);
  $FeeChangesTableManager get feeChanges =>
      $FeeChangesTableManager(_db, _db.feeChanges);
  $PausesTableManager get pauses => $PausesTableManager(_db, _db.pauses);
  $SettingsTableManager get settings =>
      $SettingsTableManager(_db, _db.settings);
  $MessageTemplatesTableManager get messageTemplates =>
      $MessageTemplatesTableManager(_db, _db.messageTemplates);
  $AuditLogTableManager get auditLog =>
      $AuditLogTableManager(_db, _db.auditLog);
}
