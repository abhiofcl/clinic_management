// main.dart or your form file
import 'dart:io';

import 'package:clinic_management_new/database/patient.dart';
import 'package:clinic_management_new/patient_details.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class PatientFormPage extends StatelessWidget {
  const PatientFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PatientListPage(),
                ),
              );
            },
            child: const Text('Show All'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseCleanup.cleanDatabase();
              // Optionally show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database reset successfully')),
              );
            },
            child: const Text('Reset Database'),
          ),
        ],
      ),
      content: Container(
        child: const PatientInputForm(),
      ),
    );
  }
}

class PatientInputForm extends StatefulWidget {
  const PatientInputForm({super.key});

  @override
  _PatientInputFormState createState() => _PatientInputFormState();
}

class _PatientInputFormState extends State<PatientInputForm> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  int _age = 1;
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  String? _maritalStatus;
  String? _gender;
  final TextEditingController _ipNoController = TextEditingController();
  final TextEditingController _opNoController = TextEditingController();
  final TextEditingController _roomNoController = TextEditingController();
  DateTime _dateOfAdmission = DateTime.now();
  DateTime _dateOfDischarge = DateTime.now();
  final TextEditingController _diagnosisController = TextEditingController();

  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _dietController = TextEditingController();
  final TextEditingController _apetiteController = TextEditingController();
  final TextEditingController _bowelController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _urineController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _ipNoController.dispose();
    _opNoController.dispose();
    _roomNoController.dispose();
    _diagnosisController.dispose();
    _historyController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _dietController.dispose();
    _apetiteController.dispose();
    _bowelController.dispose();
    _sleepController.dispose();
    _urineController.dispose();
    _bpController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    final patient = Patient(
      name: _nameController.text,
      age: _age,
      occupation: _occupationController.text,
      address: _addressController.text,
      nationality: _nationalityController.text,
      maritalStatus: _maritalStatus ?? '',
      gender: _gender ?? '',
      ipNo: _ipNoController.text,
      opNo: _opNoController.text,
      roomNo: _roomNoController.text,
      dateOfAdmission: _dateOfAdmission,
      dateOfDischarge: _dateOfDischarge,
      diagnosis: _diagnosisController.text,
      history: _historyController.text,
      heartRate: _heartRateController.text,
      weight: _weightController.text,
      height: _heightController.text,
      diet: _dietController.text,
      apetite: _apetiteController.text,
      bowel: _bowelController.text,
      sleep: _sleepController.text,
      urine: _urineController.text,
      bp: _bpController.text,
      status: "active",
    );

    final box = await Hive.openBox<Patient>('patients4_1');
    await box.add(patient);

    // Show success message
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Success'),
          content: const Text('Patient information saved successfully'),
          severity: InfoBarSeverity.success,
          action: Button(
            child: const Text('OK'),
            onPressed: () {
              close();
              // Reset form
              _formKey.currentState?.reset();
              _nameController.clear();
              _age = 1;
              _occupationController.clear();
              _addressController.clear();
              _nationalityController.clear();
              _maritalStatus = null;
              _gender = null;
              _ipNoController.clear();
              _opNoController.clear();
              _roomNoController.clear();
              setState(() {
                _dateOfAdmission = DateTime.now();
                _dateOfDischarge = DateTime.now();
              });
              _diagnosisController.clear();

              _historyController.clear();
              _heartRateController.clear();
              _weightController.clear();
              _heightController.clear();
              _dietController.clear();
              _apetiteController.clear();
              _bowelController.clear();
              _sleepController.clear();
              _urineController.clear();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Patient Information Form '),
      ),
      content: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InfoLabel(
              label: 'Name',
              child: TextFormBox(
                controller: _nameController,
                placeholder: 'Enter full name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Age',
              child: NumberBox(
                value: _age,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _age = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Occupation',
              child: TextFormBox(
                controller: _occupationController,
                placeholder: 'Enter occupation',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Address',
              child: TextFormBox(
                controller: _addressController,
                placeholder: 'Enter address',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Nationality',
              child: TextFormBox(
                controller: _nationalityController,
                placeholder: 'Enter nationality',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Marital Status',
              child: ComboBox<String>(
                value: _maritalStatus,
                placeholder: const Text('Select marital status'),
                items: ['Single', 'Married', 'Divorced', 'Widowed']
                    .map((e) => ComboBoxItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _maritalStatus = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Gender',
              child: ComboBox<String>(
                value: _gender,
                placeholder: const Text('Select gender'),
                items: ['Male', 'Female', 'Other']
                    .map((e) => ComboBoxItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'IP No',
              child: TextFormBox(
                controller: _ipNoController,
                placeholder: 'Enter IP number',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'OP No',
              child: TextFormBox(
                controller: _opNoController,
                placeholder: 'Enter OP number',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Room No',
              child: TextFormBox(
                controller: _roomNoController,
                placeholder: 'Enter room number',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Date of Admission',
              child: DatePicker(
                selected: _dateOfAdmission,
                onChanged: (date) {
                  setState(() {
                    _dateOfAdmission = date;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Date of Discharge',
              child: DatePicker(
                selected: _dateOfDischarge,
                onChanged: (date) {
                  setState(() {
                    _dateOfDischarge = date;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Diagnosis',
              child: TextFormBox(
                controller: _diagnosisController,
                placeholder: 'Enter diagnosis',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'History',
              child: TextFormBox(
                controller: _historyController,
                placeholder: 'Enter History',
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Heart rate',
              child: TextFormBox(
                controller: _heartRateController,
                placeholder: 'Enter heart rate',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'BP',
              child: TextFormBox(
                controller: _bpController,
                placeholder: 'Enter BP',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Weight',
              child: TextFormBox(
                controller: _weightController,
                placeholder: 'Enter weight',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Height',
              child: TextFormBox(
                controller: _heightController,
                placeholder: 'Enter height',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Diet',
              child: TextFormBox(
                controller: _dietController,
                placeholder: 'Enter diet status',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Apetite',
              child: TextFormBox(
                controller: _apetiteController,
                placeholder: 'Enter apetite condtition',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Bowel',
              child: TextFormBox(
                controller: _bowelController,
                placeholder: 'Enter Bowel condition',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Sleep',
              child: TextFormBox(
                controller: _sleepController,
                placeholder: 'Enter sleep status',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Urine',
              child: TextFormBox(
                controller: _urineController,
                placeholder: 'Enter urine status ',
              ),
            ),
            const SizedBox(height: 20),
            Button(
              child: const Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _savePatient();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseCleanup {
  static Future<void> cleanDatabase() async {
    try {
      // 1. Close all Hive boxes
      await Hive.close();

      // 2. Delete from disk
      await Hive.deleteFromDisk();

      // 3. Get application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();

      // 4. Get application support directory
      final Directory appSupportDir = await getApplicationSupportDirectory();

      // 5. Delete any remaining Hive-related files from both directories
      for (final dir in [appDocDir, appSupportDir]) {
        final hivePath = dir.path;
        try {
          if (await Directory(hivePath).exists()) {
            final files = Directory(hivePath).listSync();
            for (final file in files) {
              if (file.path.contains('.hive') || file.path.contains('.lock')) {
                await file.delete();
                print('Deleted: ${file.path}');
              }
            }
          }
        } catch (e) {
          print('Error cleaning directory ${dir.path}: $e');
        }
      }

      // 6. Reinitialize Hive
      await Hive.initFlutter();

      // 7. Register adapters
      Hive.registerAdapter(PatientAdapter());

      // 8. Reopen boxes
      await Hive.openBox<Patient>('patients4_1');

      print('Database cleanup completed successfully');
    } catch (e) {
      print('Error during database cleanup: $e');
      rethrow;
    }
  }
}
