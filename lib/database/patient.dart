// patient.g.dart - Generate this file using: flutter pub run build_runner build
import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'patient.g.dart';

@HiveType(typeId: 0)
class Patient extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String occupation;

  @HiveField(3)
  String address;

  @HiveField(4)
  String nationality;

  @HiveField(5)
  String maritalStatus;

  @HiveField(6)
  String gender;

  @HiveField(7)
  String ipNo;

  @HiveField(8)
  String opNo;

  @HiveField(9)
  String roomNo;

  @HiveField(10)
  DateTime dateOfAdmission;

  @HiveField(11)
  DateTime dateOfDischarge;

  @HiveField(12)
  String diagnosis;

  @HiveField(13)
  String presentComplaints;

  @HiveField(14)
  String heartRate;

  @HiveField(15)
  String weight;

  @HiveField(16)
  String height;

  @HiveField(17)
  String diet;

  @HiveField(18)
  String apetite;

  @HiveField(19)
  String bowel;

  @HiveField(20)
  String sleep;

  @HiveField(21)
  String urine;

  @HiveField(22)
  List<CaseSheetEntry>? caseSheets;

  @HiveField(23)
  String bp;

  @HiveField(24)
  List<BillEntry>? billRegister;

  @HiveField(25)
  List<MedicationsEntry>? medicationsEntry;

  @HiveField(26)
  String? status;

  @HiveField(27)
  String? condition;

  @HiveField(28)
  String? adice;

  @HiveField(29)
  String? otherMedication;

  @HiveField(30)
  String? treatment;

  @HiveField(31)
  double totalBill = 0.0;

  @HiveField(32)
  int days = 1;

  @HiveField(33)
  String billNo = "";

  @HiveField(34)
  String habits;

  @HiveField(35)
  String sensitivity;

  @HiveField(36)
  String hereditary;

  @HiveField(37)
  String menstrualHistory;

  @HiveField(38)
  Uint8List? image;

  @HiveField(39)
  String historyOfPresentComplaints;
  @HiveField(40)
  String pastHistory;

  @HiveField(41)
  List<ConsumablesEntry>? consumables;

  Patient({
    required this.name,
    required this.age,
    required this.occupation,
    required this.address,
    required this.nationality,
    required this.maritalStatus,
    required this.gender,
    required this.ipNo,
    required this.opNo,
    required this.roomNo,
    required this.dateOfAdmission,
    required this.dateOfDischarge,
    required this.diagnosis,
    required this.presentComplaints,
    required this.historyOfPresentComplaints,
    required this.pastHistory,
    required this.heartRate,
    required this.bp,
    required this.weight,
    required this.height,
    required this.diet,
    required this.apetite,
    required this.bowel,
    required this.sleep,
    required this.urine,
    required this.habits,
    required this.hereditary,
    required this.sensitivity,
    required this.menstrualHistory,
    this.image,
    this.caseSheets,
    this.status,
  });
}

@HiveType(typeId: 1)
class CaseSheetEntry extends HiveObject {
  @HiveField(0)
  DateTime? date;

  @HiveField(1)
  String? symptoms;

  @HiveField(2)
  String? treatments;

  @HiveField(3)
  String? bp;

  @HiveField(4)
  String? time;

  CaseSheetEntry({
    this.date,
    this.symptoms,
    this.treatments,
    this.bp,
    this.time,
  });
}

@HiveType(typeId: 2)
class BillEntry extends HiveObject {
  @HiveField(0)
  double? price;

  @HiveField(1)
  String? particulars;

  @HiveField(2)
  String? quantity;

  @HiveField(3)
  String? rate;

  // @HiveField(3)
  // String? bp;

  BillEntry({
    this.price,
    this.particulars,
    this.quantity,
    this.rate,
  });
}

@HiveType(typeId: 3)
class MedicationsEntry extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  double? quantity;

  MedicationsEntry({
    this.name,
    this.quantity,
  });
}

@HiveType(typeId: 4)
class ConsumablesEntry extends HiveObject {
  @HiveField(0)
  double? price;

  @HiveField(1)
  String? particulars;

  @HiveField(2)
  String? quantity;

  @HiveField(3)
  String? rate;

  @HiveField(4)
  DateTime? date;

  ConsumablesEntry({
    this.price,
    this.particulars,
    this.quantity,
    this.rate,
    this.date,
  });
}
