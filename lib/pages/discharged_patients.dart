import 'package:clinic_management_new/database/patient.dart';
import 'package:clinic_management_new/pages/daily_casesheet.dart';
import 'package:clinic_management_new/pages/medicine_page.dart';
import 'package:clinic_management_new/pages/update_bill_details.dart';
import 'package:clinic_management_new/pdf_service/admission_note.dart';
import 'package:clinic_management_new/pdf_service/pdfservice.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:hive_flutter/hive_flutter.dart';

class DischargedPatientListPage extends StatefulWidget {
  const DischargedPatientListPage({super.key});

  @override
  State<DischargedPatientListPage> createState() =>
      _DischargedPatientListPageState();
}

class _DischargedPatientListPageState extends State<DischargedPatientListPage> {
  Box<Patient>? _patientBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      if (!Hive.isBoxOpen('patients4_2')) {
        _patientBox = await Hive.openBox<Patient>('patients4_2');
      } else {
        _patientBox = Hive.box<Patient>('patients4_2');
      }
    } catch (e) {
      print('Error opening Hive box: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: ScaffoldPage(
        header: const PageHeader(
          title: Text('Patient Records'),
          // commandBar: Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     FilledButton(
          //       child: const Text('Go back'),
          //       onPressed: () => Navigator.pop(context),
          //     ),
          //   ],
          // ),
        ),
        content:
            _isLoading ? const Center(child: ProgressRing()) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_patientBox == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.error_badge, size: 32),
            const SizedBox(height: 8),
            const Text('Error loading patient records'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _initializeHive,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: _patientBox!.listenable(),
      builder: (context, Box<Patient> box, _) {
        final activePatients = box.values
            .where((patient) => patient.status == "discharged")
            .toList();
        if (activePatients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FluentIcons.document_set, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'No patients found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start by adding a new patient record',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  child: const Text('Add Patient'),
                  onPressed: () {
                    // Navigate to add patient page
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activePatients.length,
          itemBuilder: (context, index) {
            // final patient = box.getAt(index);
            final patient = activePatients[index];
            if (patient == null) return const SizedBox.shrink();

            return Card(
              backgroundColor: Colors.blue,
              margin: const EdgeInsets.only(bottom: 16),
              child: Expander(
                header: Text(patient.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FilledButton(
                              child: const Row(
                                children: [
                                  Icon(FluentIcons.pdf),
                                  SizedBox(width: 8),
                                  Text('Case sheet PDF'),
                                ],
                              ),
                              onPressed: () => _generatePDF(patient),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              child: const Row(
                                children: [
                                  Icon(FluentIcons.pdf),
                                  SizedBox(width: 8),
                                  Text('Admission Note'),
                                ],
                              ),
                              onPressed: () => _generateAdmissionNote(patient),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            FilledButton(
                              child: const Text('Update Medicine'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    FluentPageRoute(
                                      builder: (context) =>
                                          MedicineUpdateWidget(
                                        patient: patient,
                                        index: index,
                                      ),
                                    ));
                              },
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              child: const Text('Update Bill'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    FluentPageRoute(
                                      builder: (context) => BillUpdateWidget(
                                        patient: patient,
                                        index: index,
                                      ),
                                    ));
                              },
                            ),
                            const SizedBox(width: 8),
                            // const SizedBox(width: 8),
                            FilledButton(
                              child: const Text('Update Daily Casesheet'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    FluentPageRoute(
                                      builder: (context) => CaseSheetWidget(
                                        patient: patient,
                                        index: index,
                                      ),
                                    ));
                              },
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              child: const Text('Edit'),
                              onPressed: () =>
                                  _showEditDialog(context, patient, index),
                            ),
                            const SizedBox(width: 8),
                            Button(
                              child: const Text('Delete'),
                              onPressed: () =>
                                  _showDeleteDialog(context, index),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Age', '${patient.age} years'),
                    _buildInfoRow('Gender', patient.gender),
                    _buildInfoRow('Occupation', patient.occupation),
                    _buildInfoRow('Address', patient.address),
                    _buildInfoRow('Nationality', patient.nationality),
                    _buildInfoRow('Marital Status', patient.maritalStatus),
                    _buildInfoRow('IP No', patient.ipNo),
                    _buildInfoRow('OP No', patient.opNo),
                    _buildInfoRow('Room No', patient.roomNo),
                    _buildInfoRow('Date of Admission',
                        _formatDate(patient.dateOfAdmission)),
                    _buildInfoRow('Date of Discharge',
                        _formatDate(patient.dateOfDischarge)),
                    _buildInfoRow('Diagnosis', patient.diagnosis),
                    _buildInfoRow('History', patient.history),
                    _buildInfoRow('Heart Rate', patient.heartRate),
                    _buildInfoRow('Weight', patient.weight),
                    _buildInfoRow('Height', patient.height),
                    _buildInfoRow('Diet', patient.diet),
                    _buildInfoRow('Apetite', patient.apetite),
                    _buildInfoRow('Bowel', patient.bowel),
                    _buildInfoRow('Sleep', patient.sleep),
                    _buildInfoRow('urine', patient.urine),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDeleteDialog(BuildContext context, int index) async {
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Patient Record'),
        content: const Text(
            'Are you sure you want to delete this patient record? This action cannot be undone.'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: ButtonState.all(Colors.red),
            ),
            child: const Text('Delete'),
            onPressed: () async {
              final box = Hive.box<Patient>('patients4_2');
              await box.deleteAt(index);
              Navigator.pop(context);
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Success'),
                    content: const Text('Patient record deleted successfully'),
                    severity: InfoBarSeverity.success,
                    action: IconButton(
                      icon: const Icon(FluentIcons.clear),
                      onPressed: close,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, Patient patient, int index) async {
    // Create controllers with existing values
    final nameController = TextEditingController(text: patient.name);
    final occupationController =
        TextEditingController(text: patient.occupation);
    final addressController = TextEditingController(text: patient.address);
    // ... add other controllers as needed

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Edit Patient Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoLabel(
                label: 'Name',
                child: TextFormBox(
                  controller: nameController,
                  placeholder: 'Enter full name',
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Occupation',
                child: TextFormBox(
                  controller: occupationController,
                  placeholder: 'Enter occupation',
                ),
              ),
              InfoLabel(
                label: 'Address',
                child: TextFormBox(
                  controller: addressController,
                  placeholder: 'Enter address',
                  maxLines: 3,
                ),
              ),
              // Add other fields as needed
            ],
          ),
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Save'),
            onPressed: () async {
              // Update patient object
              patient.name = nameController.text;
              patient.occupation = occupationController.text;
              patient.address = addressController.text;
              // Update other fields...

              // Save to Hive
              final box = Hive.box<Patient>('patients4_2');
              await box.putAt(index, patient);

              if (context.mounted) {
                Navigator.pop(context);
                displayInfoBar(
                  context,
                  builder: (context, close) {
                    return InfoBar(
                      title: const Text('Success'),
                      content:
                          const Text('Patient record updated successfully'),
                      severity: InfoBarSeverity.success,
                      action: IconButton(
                        icon: const Icon(FluentIcons.clear),
                        onPressed: close,
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Future<void> _showTreatmentDialog(
  //     BuildContext context, Patient patient, int index) async {
  //   // Create controllers with existing values

  //   final treatmentController = TextEditingController(text: patient.treatment);
  //   // ... add other controllers as needed

  //   await showDialog<String>(
  //     context: context,
  //     builder: (context) => ContentDialog(
  //       title: const Text('Add treatment'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             InfoLabel(
  //               label: 'Treatment',
  //               child: TextFormBox(
  //                 controller: treatmentController,
  //                 placeholder: 'Enter treatments provided',
  //                 maxLines: 3,
  //               ),
  //             ),
  //             // Add other fields as needed
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         Button(
  //           child: const Text('Cancel'),
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //         FilledButton(
  //           child: const Text('Save'),
  //           onPressed: () async {
  //             // Update patient object

  //             patient.treatment = treatmentController.text;
  //             // Update other fields...

  //             // Save to Hive
  //             final box = Hive.box<Patient>('patients4_2');
  //             await box.putAt(index, patient);

  //             if (context.mounted) {
  //               Navigator.pop(context);
  //               displayInfoBar(
  //                 context,
  //                 builder: (context, close) {
  //                   return InfoBar(
  //                     title: const Text('Success'),
  //                     content:
  //                         const Text('Patient record updated successfully'),
  //                     severity: InfoBarSeverity.success,
  //                     action: IconButton(
  //                       icon: const Icon(FluentIcons.clear),
  //                       onPressed: close,
  //                     ),
  //                   );
  //                 },
  //               );
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _showBillDialog(
  //     BuildContext context, Patient patient, int index) async {
  //   // Create controllers with existing values

  //   final billController = TextEditingController(text: patient.bill);
  //   // ... add other controllers as needed

  //   await showDialog<String>(
  //     context: context,
  //     builder: (context) => ContentDialog(
  //       title: const Text('Add Bill Amount'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             InfoLabel(
  //               label: 'Bill',
  //               child: TextFormBox(
  //                 controller: billController,
  //                 placeholder: 'Enter the total Bill amount',
  //                 // maxLines: 3,
  //               ),
  //             ),
  //             // Add other fields as needed
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         Button(
  //           child: const Text('Cancel'),
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //         FilledButton(
  //           child: const Text('Save'),
  //           onPressed: () async {
  //             // Update patient object

  //             patient.bill = billController.text;
  //             // Update other fields...

  //             // Save to Hive
  //             final box = Hive.box<Patient>('patients4_2');
  //             await box.putAt(index, patient);

  //             if (context.mounted) {
  //               Navigator.pop(context);
  //               displayInfoBar(
  //                 context,
  //                 builder: (context, close) {
  //                   return InfoBar(
  //                     title: const Text('Success'),
  //                     content:
  //                         const Text('Patient record updated successfully'),
  //                     severity: InfoBarSeverity.success,
  //                     action: IconButton(
  //                       icon: const Icon(FluentIcons.clear),
  //                       onPressed: close,
  //                     ),
  //                   );
  //                 },
  //               );
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _generatePDF(Patient patient) async {
    try {
      await PDFService.generatePatientPDF(patient);
      if (mounted) {
        _showSuccessMessage('PDF generated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to generate PDF: ${e.toString()}');
      }
    }
  }

  Future<void> _generateAdmissionNote(Patient patient) async {
    try {
      await AdmissionNotePDFService.generatePatientPDF(patient);
      if (mounted) {
        _showSuccessMessage('Admission note generated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to generate admission note: ${e.toString()}');
      }
    }
  }

  void _showSuccessMessage(String message) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Success'),
          content: Text(message),
          severity: InfoBarSeverity.success,
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Error'),
          content: Text(message),
          severity: InfoBarSeverity.error,
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (_patientBox != null && _patientBox!.isOpen) {
      _patientBox!.close();
    }
    super.dispose();
  }
}
