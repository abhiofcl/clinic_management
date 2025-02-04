// main.dart or your form file
import 'dart:io';
import 'dart:typed_data';

import 'package:clinic_management_new/database/employee.dart';
import 'package:clinic_management_new/database/patient.dart';
import 'package:clinic_management_new/patient_details.dart';
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EmployeeFormPage extends StatelessWidget {
  final Box employeeBox;
  const EmployeeFormPage({super.key, required this.employeeBox});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        // children: [
        //   material.ElevatedButton(
        //     onPressed: () {
        //       Navigator.of(context).push(
        //         material.MaterialPageRoute(
        //           builder: (context) => PatientListPage(
        //             patientBox: employeeBox,
        //           ),
        //         ),
        //       );
        //     },
        //     child: const Text('Show All'),
        //   ),
        //   material.ElevatedButton(
        //     onPressed: () async {
        //       await DatabaseCleanup.cleanDatabase();
        //       // Optionally show a success message
        //       material.ScaffoldMessenger.of(context).showSnackBar(
        //         const material.SnackBar(
        //             content: Text('Database reset successfully')),
        //       );
        //     },
        //     child: const Text('Reset Database'),
        //   ),
        // ],
      ),
      content: EmployeeInputForm(
        employeeBox: employeeBox,
      ),
    );
  }
}

class EmployeeInputForm extends StatefulWidget {
  final Box employeeBox;
  const EmployeeInputForm({super.key, required this.employeeBox});

  @override
  _EmployeeInputFormState createState() => _EmployeeInputFormState();
}

class _EmployeeInputFormState extends State<EmployeeInputForm> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _idProofController = TextEditingController();

  int _age = 1;
  String? _gender;

  String? idProofType;

  Uint8List? _selectedImage; // To store the uploaded image

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _idProofController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    final employee = Employee(
      name: _nameController.text,
      age: _age,
      address: _addressController.text,
      gender: _gender ?? '',
      status: "active",
      image: _selectedImage,
      phoneNumber: _phoneNumberController.text,
      idProofType: idProofType ?? '',
      idProof: _idProofController.text,
    );

    // final box = await Hive.openBox<Patient>('patients4_5');
    await widget.employeeBox.add(employee);

    // Show success message
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Success'),
          content: const Text('Employee information saved successfully'),
          severity: InfoBarSeverity.success,
          action: Button(
            child: const Text('OK'),
            onPressed: () {
              close();
              // Reset form
              _formKey.currentState?.reset();
              _nameController.clear();
              _age = 1;
              _formKey.currentState?.reset();
              _nameController.clear();
              _age = 1;
              _addressController.clear();
              _gender = null;
              _phoneNumberController.clear();
              _idProofController.clear();
              idProofType = null;
              _selectedImage = null;
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
        title: Text('Employee Information Form '),
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
              label: 'Address',
              child: TextFormBox(
                controller: _addressController,
                placeholder: 'Enter address',
                maxLines: 3,
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
              label: 'Phone Number',
              child: TextFormBox(
                controller: _phoneNumberController,
                placeholder: 'Enter phone number',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'ID PROOF TYPE',
              child: ComboBox<String>(
                value: _gender,
                placeholder: const Text('Select ID proof type'),
                items: ['AADHAR', 'ELECTION ID', 'DRIvERS LICENSE', 'Other']
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
              label: 'ID Proof No:',
              child: TextFormBox(
                controller: _idProofController,
                placeholder: 'Enter ID no',
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
                  _saveEmployee();
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
      await Hive.openBox<Employee>('employees_1_1');

      print('Database cleanup completed successfully');
    } catch (e) {
      print('Error during database cleanup: $e');
      rethrow;
    }
  }
}
