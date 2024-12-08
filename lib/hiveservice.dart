import 'package:clinic_management_new/database/patient.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  HiveService._internal();

  Box<Patient>? _patientBox;

  Future<Box<Patient>> get patientBox async {
    if (_patientBox != null && _patientBox!.isOpen) {
      return _patientBox!;
    }
    _patientBox = await Hive.openBox<Patient>('patients4_1');
    return _patientBox!;
  }

  ValueListenable<Box<Patient>> getPatientBoxListenable() {
    if (_patientBox == null || !_patientBox!.isOpen) {
      throw HiveError('Patient box not initialized');
    }
    return _patientBox!.listenable();
  }

  Future<void> closeBoxes() async {
    if (_patientBox != null && _patientBox!.isOpen) {
      await _patientBox!.close();
    }
  }
}
