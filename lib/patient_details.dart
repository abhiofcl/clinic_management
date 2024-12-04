import 'dart:ffi';

import 'package:clinic_management_new/database/patient.dart';
import 'package:clinic_management_new/pages/daily_casesheet.dart';
import 'package:clinic_management_new/pages/medicine_page.dart';
import 'package:clinic_management_new/pages/update_bill_details.dart';
import 'package:clinic_management_new/pdf_service/admission_note.dart';
import 'package:clinic_management_new/pdf_service/bill_table.dart';
import 'package:clinic_management_new/pdf_service/daily_casesheet_pdf.dart';
import 'package:clinic_management_new/pdf_service/discharge_summary.dart';
import 'package:clinic_management_new/pdf_service/pdfservice.dart';
import 'package:clinic_management_new/pdf_service/receipt.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  Box<Patient>? _patientBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      if (!Hive.isBoxOpen('patients4')) {
        _patientBox = await Hive.openBox<Patient>('patients4');
      } else {
        _patientBox = Hive.box<Patient>('patients4');
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
        header: PageHeader(
          title: const Text('Patient Records'),
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
              child: const Text('Retry'),
              onPressed: _initializeHive,
            ),
          ],
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: _patientBox!.listenable(),
      builder: (context, Box<Patient> box, _) {
        if (box.isEmpty) {
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
          itemCount: box.length,
          itemBuilder: (context, index) {
            final patient = box.getAt(index);
            if (patient == null) return const SizedBox.shrink();

            return Card(
              backgroundColor: Colors.grey,
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
                        Column(
                          children: [
                            Row(
                              children: [
                                FilledButton(
                                  child: const Row(
                                    children: [
                                      Icon(FluentIcons.pdf),
                                      SizedBox(width: 8),
                                      Text('Discharge sheet PDF'),
                                    ],
                                  ),
                                  onPressed: () {
                                    _showDischargeDialog(
                                        context, patient, index);
                                  },
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
                                  onPressed: () =>
                                      _generateAdmissionNote(patient),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                FilledButton(
                                  child: const Row(
                                    children: [
                                      Icon(FluentIcons.pdf),
                                      SizedBox(width: 8),
                                      Text('Daily Case sheet PDF'),
                                    ],
                                  ),
                                  onPressed: () =>
                                      _generateCaseSheetPDF(patient),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                    child: const Row(
                                      children: [
                                        Icon(FluentIcons.pdf),
                                        SizedBox(width: 8),
                                        Text('Receipt'),
                                      ],
                                    ),
                                    onPressed: () =>
                                        _showBillDialog(context, patient, index)
                                    // _generateDischargeSheetPDF(patient),
                                    ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  child: const Row(
                                    children: [
                                      Icon(FluentIcons.pdf),
                                      SizedBox(width: 8),
                                      Text('Bill Table'),
                                    ],
                                  ),
                                  onPressed: () =>
                                      // _showBillDialog(context, patient, index)
                                      _generateBillTableSheetPDF(patient),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
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
                                          builder: (context) =>
                                              BillUpdateWidget(
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
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
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
                        )
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
              final box = Hive.box<Patient>('patients4');
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
              final box = Hive.box<Patient>('patients4');
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

  Future<void> _showDischargeDialog(
      BuildContext context, Patient patient, int index) async {
    // Create controllers with existing values
    final conditionController = TextEditingController(text: patient.condition);
    final bowelController = TextEditingController(text: patient.bowel);
    final apetiteController = TextEditingController(text: patient.apetite);
    final sleepController = TextEditingController(text: patient.sleep);
    final bpController = TextEditingController(text: patient.bp);
    final adiceController = TextEditingController(text: patient.adice);
    final treatmentController = TextEditingController(text: patient.treatment);
    final medicationController =
        TextEditingController(text: patient.otherMedication);
    // ... add other controllers as needed

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Discharge Patient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoLabel(
                label: 'Treatments given',
                child: TextFormBox(
                  controller: treatmentController,
                  placeholder: 'Enter in this format \n Abhyanga \t 20days',
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Condition',
                child: TextFormBox(
                  controller: conditionController,
                  placeholder: 'Enter the condition at discharge',
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Bowel',
                child: TextFormBox(
                  controller: bowelController,
                  placeholder: 'Enter Bowel condition',
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Apetite',
                child: TextFormBox(
                  controller: apetiteController,
                  placeholder: 'Enter apetite',
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Sleep',
                child: TextFormBox(
                  controller: sleepController,
                  placeholder: 'Enter Sleep condition',
                ),
              ),
              const SizedBox(height: 8),

              InfoLabel(
                label: 'BP',
                child: TextFormBox(
                  controller: bpController,
                  placeholder: 'Enter BP',
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Adice on discharge',
                child: TextFormBox(
                  controller: adiceController,
                  placeholder: 'Enter the adice at discharge',
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Other medications',
                child: TextFormBox(
                  controller: medicationController,
                  placeholder: 'Enter any other medicatios to use',
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
            child: const Text('Generate'),
            onPressed: () async {
              // Update patient object
              patient.bowel = bowelController.text;
              patient.bp = bpController.text;
              patient.apetite = apetiteController.text;
              patient.sleep = sleepController.text;
              patient.adice = adiceController.text;
              patient.otherMedication = medicationController.text;
              patient.condition = conditionController.text;
              patient.treatment = treatmentController.text;

              // Update other fields...

              // Save to Hive
              final box = Hive.box<Patient>('patients4');
              await box.putAt(index, patient);
              await _generateDischargeSheetPDF(patient);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showBillDialog(
      BuildContext context, Patient patient, int index) async {
    // Create controllers with existing values
    final totalBillController =
        TextEditingController(text: patient.totalBill.toString());
    final totalDaysController =
        TextEditingController(text: patient.days.toString());

    // ... add other controllers as needed

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Total Bill Amount'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              InfoLabel(
                label: 'Bill Amount',
                child: TextFormBox(
                  controller: totalBillController,
                  placeholder: 'Enter Total Amount',
                ),
              ),
              InfoLabel(
                label: 'Total Days',
                child: TextFormBox(
                  controller: totalDaysController,
                  placeholder: 'Enter Total Days stayed',
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
            child: const Text('Generate'),
            onPressed: () async {
              // Update patient object

              patient.totalBill = double.parse(totalBillController.text);
              patient.days = int.parse(totalDaysController.text);
              // Update other fields...

              // Save to Hive
              final box = Hive.box<Patient>('patients4');
              await box.putAt(index, patient);
              await _generateReceiptPDF(patient);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generateReceiptPDF(Patient patient) async {
    try {
      await ReceiptPDFService.generatePatientPDF(patient);
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

  Future<void> _generateCaseSheetPDF(Patient patient) async {
    try {
      await DailyCaseSheetPDFService.generatePatientPDF(patient);
      if (mounted) {
        _showSuccessMessage('Case Sheet PDF generated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to generate Case Sheet: ${e.toString()}');
      }
    }
  }

  Future<void> _generateDischargeSheetPDF(Patient patient) async {
    await DischarSummaryPDFService.generatePatientPDF(patient);
    // await DischargeSummaryPdf.generateDischargeSummary(context);
  }

  Future<void> _generateBillTableSheetPDF(Patient patient) async {
    await BillTablePDFService.generatePatientPDF(patient);
    // await DischargeSummaryPdf.generateDischargeSummary(context);
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
