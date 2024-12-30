// patient.g.dart - Generate this file using: flutter pub run build_runner build
import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 5)
class Employee extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String gender;

  @HiveField(3)
  String address;

  @HiveField(4)
  String phoneNumber;

  @HiveField(5)
  String idProofType;

  @HiveField(6)
  String idProof;

  @HiveField(7)
  Uint8List? image;

  @HiveField(8)
  List<DutySheetEntry>? dutySheet;

  @HiveField(9)
  String? status;

  Employee({
    required this.name,
    required this.age,
    required this.address,
    required this.gender,
    required this.phoneNumber,
    required this.idProofType,
    required this.idProof,
    this.image,
    this.dutySheet,
    this.status,
  });
}

@HiveType(typeId: 6)
class DutySheetEntry extends HiveObject {
  @HiveField(0)
  DateTime? date;

  @HiveField(1)
  String? timeSlot;

  @HiveField(2)
  String? patientName;

  @HiveField(3)
  String? qty;

  @HiveField(4)
  String? rate;

  @HiveField(5)
  String? amount;

  @HiveField(6)
  String? remarks;

  @HiveField(7)
  String? dutyPerformed;

  DutySheetEntry({
    this.patientName,
    this.date,
    this.timeSlot,
    this.qty,
    this.rate,
    this.amount,
    this.remarks,
    this.dutyPerformed,
  });
}
