// main.dart or your form file
import 'dart:io';
import 'dart:typed_data';

import 'package:clinic_management_new/database/patient.dart';
import 'package:clinic_management_new/patient_details.dart';
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PatientFormPage extends StatelessWidget {
  final Box patientBox;

  const PatientFormPage({super.key, required this.patientBox});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          material.ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                material.MaterialPageRoute(
                  builder: (context) => PatientListPage(
                    patientBox: patientBox,
                  ),
                ),
              );
            },
            child: const Text('Show All'),
          ),
          material.ElevatedButton(
            onPressed: () async {
              await DatabaseCleanup.cleanDatabase();
              // Optionally show a success message
              material.ScaffoldMessenger.of(context).showSnackBar(
                const material.SnackBar(
                    content: Text('Database reset successfully')),
              );
            },
            child: const Text('Reset Database'),
          ),
        ],
      ),
      content: PatientInputForm(
        patientBox: patientBox,
      ),
    );
  }
}

class PatientInputForm extends StatefulWidget {
  final Box patientBox;
  const PatientInputForm({super.key, required this.patientBox});

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

  final TextEditingController _presentComplaintsController =
      TextEditingController();
  final TextEditingController _historyOfPresentComplaintsController =
      TextEditingController();
  final TextEditingController _pastHistoryController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _dietController = TextEditingController();
  final TextEditingController _apetiteController = TextEditingController();
  final TextEditingController _bowelController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _urineController = TextEditingController();
  final TextEditingController _habitsController = TextEditingController();
  final TextEditingController _hyperController = TextEditingController();
  final TextEditingController _hereditaryController = TextEditingController();
  final TextEditingController _menstrualController = TextEditingController();

  final TextEditingController _naadiController = TextEditingController();
  final TextEditingController _mutraController = TextEditingController();
  final TextEditingController _malamController = TextEditingController();
  final TextEditingController _jihwaController = TextEditingController();
  final TextEditingController _sabdaController = TextEditingController();
  final TextEditingController _sparsaController = TextEditingController();
  final TextEditingController _drikController = TextEditingController();
  final TextEditingController _akritiController = TextEditingController();

  Uint8List? _selectedImage; // To store the uploaded image

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
    _presentComplaintsController.dispose();
    _historyOfPresentComplaintsController.dispose();
    _pastHistoryController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _dietController.dispose();
    _apetiteController.dispose();
    _bowelController.dispose();
    _sleepController.dispose();
    _urineController.dispose();
    _bpController.dispose();
    _menstrualController.dispose();
    _habitsController.dispose();
    _hereditaryController.dispose();
    _hyperController.dispose();
    _naadiController.dispose();
    _mutraController.dispose();
    _malamController.dispose();
    _jihwaController.dispose();
    _sabdaController.dispose();
    _sparsaController.dispose();
    _drikController.dispose();
    _akritiController.dispose();
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
        presentComplaints: _presentComplaintsController.text,
        historyOfPresentComplaints: _historyOfPresentComplaintsController.text,
        pastHistory: _pastHistoryController.text,
        heartRate: _heartRateController.text,
        weight: _weightController.text,
        height: _heightController.text,
        diet: _dietController.text,
        apetite: _apetiteController.text,
        bowel: _bowelController.text,
        sleep: _sleepController.text,
        urine: _urineController.text,
        bp: _bpController.text,
        habits: _habitsController.text,
        hereditary: _hereditaryController.text,
        sensitivity: _hyperController.text,
        menstrualHistory: _menstrualController.text,
        status: "active",
        image: _selectedImage,
        naadi: _naadiController.text,
        mutra: _mutraController.text,
        malam: _malamController.text,
        jihwa: _jihwaController.text,
        sabda: _sabdaController.text,
        sparsa: _sparsaController.text,
        drik: _drikController.text,
        akriti: _akritiController.text);

    // final box = await Hive.openBox<Patient>('patients4_4');
    await widget.patientBox.add(patient);

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

              _pastHistoryController.clear();
              _presentComplaintsController.clear();
              _historyOfPresentComplaintsController.clear();
              _heartRateController.clear();
              _weightController.clear();
              _heightController.clear();
              _dietController.clear();
              _apetiteController.clear();
              _bowelController.clear();
              _sleepController.clear();
              _urineController.clear();
              _hyperController.dispose();
              _naadiController.clear();
              _mutraController.clear();
              _malamController.clear();
              _jihwaController.clear();
              _sabdaController.clear();
              _sparsaController.clear();
              _drikController.clear();
              _akritiController.clear();
            },
          ),
        );
      },
    );
  }

  // Image picking logic
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (image != null) {
      final bytes = await image.readAsBytes(); // Corrected to async method
      setState(() {
        _selectedImage = bytes;
      });
    }
  }

  // Future<void> _captureImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.camera);
  //   if (image != null) {
  //     final bytes = await image.readAsBytes(); // Corrected to async method
  //     setState(() {
  //       _selectedImage = bytes;
  //     });
  //   }
  // }

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
              label: 'Present Complaints',
              child: TextFormBox(
                controller: _presentComplaintsController,
                placeholder: 'Enter Present Complaints',
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'History of Present Complaints',
              child: TextFormBox(
                controller: _historyOfPresentComplaintsController,
                placeholder: 'Enter History of Present Complaints',
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Past History',
              child: TextFormBox(
                controller: _pastHistoryController,
                placeholder: 'Enter Past History',
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
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Habits/Addictions',
              child: TextFormBox(
                controller: _habitsController,
                placeholder: 'Enter urine status ',
                maxLines: 2,
              ),
            ),
            InfoLabel(
              label: 'Naadi',
              child: TextFormBox(
                controller: _naadiController,
                placeholder: 'Enter naadi condtition',
              ),
            ),
            InfoLabel(
              label: 'Mutra',
              child: TextFormBox(
                controller: _mutraController,
                placeholder: 'Enter mutra condtition',
              ),
            ),
            InfoLabel(
              label: 'Malam',
              child: TextFormBox(
                controller: _malamController,
                placeholder: 'Enter malam condtition',
              ),
            ),
            InfoLabel(
              label: 'Jihwa',
              child: TextFormBox(
                controller: _jihwaController,
                placeholder: 'Enter jihwa condtition',
              ),
            ),
            InfoLabel(
              label: 'Sabda',
              child: TextFormBox(
                controller: _sabdaController,
                placeholder: 'Enter sabda condtition',
              ),
            ),
            InfoLabel(
              label: 'Sparsa',
              child: TextFormBox(
                controller: _sparsaController,
                placeholder: 'Enter sparsa condtition',
              ),
            ),
            InfoLabel(
              label: 'Drik',
              child: TextFormBox(
                controller: _drikController,
                placeholder: 'Enter drik condtition',
              ),
            ),
            InfoLabel(
              label: 'Askriti',
              child: TextFormBox(
                controller: _akritiController,
                placeholder: 'Enter akriti condtition',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Hyper Sensitivity',
              child: TextFormBox(
                controller: _hyperController,
                placeholder: 'Enter hyper sensitivity status ',
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Hereditary',
              child: TextFormBox(
                controller: _hereditaryController,
                placeholder: 'Enter hereditary status ',
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Menstrual history',
              child: TextFormBox(
                controller: _menstrualController,
                placeholder: 'Enter menstrual history ',
                maxLines: 2,
              ),
            ),
            InfoLabel(
              label: 'Attach Image',
              child: Column(
                children: [
                  if (_selectedImage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Image.memory(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _pickImage,
                        child: const Text('Pick Image'),
                      ),
                    ],
                  ),
                ],
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
      await Hive.openBox<Patient>('patients4_4');

      print('Database cleanup completed successfully');
    } catch (e) {
      print('Error during database cleanup: $e');
      rethrow;
    }
  }
}
