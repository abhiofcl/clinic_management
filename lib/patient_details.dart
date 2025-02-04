import 'dart:typed_data';

import 'package:clinic_management_new/database/patient.dart';
import 'package:clinic_management_new/pages/consumables_page.dart';
import 'package:clinic_management_new/pages/daily_casesheet.dart';
import 'package:clinic_management_new/pages/medicine_page.dart';
import 'package:clinic_management_new/pages/update_bill_details.dart';
import 'package:clinic_management_new/pdf_service/admission_note.dart';
import 'package:clinic_management_new/pdf_service/bill_table.dart';
import 'package:clinic_management_new/pdf_service/case_sheet.dart';
import 'package:clinic_management_new/pdf_service/daily_casesheet_pdf.dart';
import 'package:clinic_management_new/pdf_service/discharge_summary.dart';
import 'package:clinic_management_new/pdf_service/receipt.dart';
import 'package:fluent_ui/fluent_ui.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PatientListPage extends StatefulWidget {
  final Box patientBox;
  const PatientListPage({super.key, required this.patientBox});

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
      if (!Hive.isBoxOpen('patients4_5')) {
        _patientBox = await Hive.openBox<Patient>('patients4_5');
      } else {
        _patientBox = Hive.box<Patient>('patients4_5');
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
                    // Navigator.pop(context);
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
            final Uint8List? image = patient.image;
            // print(image);
            return Card(
              backgroundColor: const Color.fromARGB(255, 200, 145, 90),
              margin: const EdgeInsets.only(bottom: 16),
              child: Expander(
                // icon: const Icon(FluentIcons.add_friend),
                leading: image != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                        child: Image.memory(
                          image!,
                          width: 90, // Adjust to desired size
                          height: 90,
                          fit: BoxFit
                              .contain, // Ensures the image fits within the box
                        ),
                      )
                    : const Icon(
                        FluentIcons.contact), // Fallback icon if image is null,
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
                                      Text('Case Sheet PDF'),
                                    ],
                                  ),
                                  onPressed: () {
                                    _generateCaseSheetPDF(patient);
                                  },
                                ),
                                const SizedBox(width: 8),
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
                                      _generateDailyCaseSheetPDF(patient),
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
                                        _showBillTableDialog(
                                            context, patient, index)),
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
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                FilledButton(
                                  child: const Text('Update Consumables'),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        FluentPageRoute(
                                          builder: (context) =>
                                              ConsumablesUpdateWidget(
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
                                        _showNewDialog(context, patient, index)
                                    // _showEditDialog(context, patient, index),
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
                    _buildInfoRow('Past History', patient.pastHistory),
                    _buildInfoRow('Heart Rate', patient.heartRate),
                    _buildInfoRow('Weight', patient.weight),
                    _buildInfoRow('Height', patient.height),
                    _buildInfoRow('Diet', patient.diet),
                    _buildInfoRow('Apetite', patient.apetite),
                    _buildInfoRow('Bowel', patient.bowel),
                    _buildInfoRow('Sleep', patient.sleep),
                    _buildInfoRow('urine', patient.urine),
                    _buildInfoRow('Habits/addictions', patient.habits),
                    _buildInfoRow('Hyper sensitivity', patient.sensitivity),
                    _buildInfoRow('Hereditary', patient.hereditary),
                    _buildInfoRow(
                        'Menstrual history', patient.menstrualHistory),
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
              final box = Hive.box<Patient>('patients4_5');
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
    final ageController = TextEditingController(text: patient.age.toString());
    final dischargeController =
        TextEditingController(text: patient.dateOfDischarge.toString());
    final admissionController =
        TextEditingController(text: patient.dateOfAdmission.toString());
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
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Age',
                child: TextFormBox(
                  controller: occupationController,
                  placeholder: 'Enter occupation',
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
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Occupation',
                child: TextFormBox(
                  controller: occupationController,
                  placeholder: 'Enter occupation',
                ),
              ),
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
              final box = Hive.box<Patient>('patients4_5');
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
    DateTime dateOfDischarge = patient.dateOfDischarge;
    // ... add other controllers as needed

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Discharge Patient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              InfoLabel(
                label: 'Date of Discharge',
                child: DatePicker(
                  selected: dateOfDischarge,
                  onChanged: (date) {
                    setState(() {
                      dateOfDischarge = date;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
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
                label: 'Advice on discharge',
                child: TextFormBox(
                  controller: adiceController,
                  placeholder: 'Enter the advice at discharge',
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
              patient.dateOfDischarge = dateOfDischarge;

              // Update other fields...

              // Save to Hive
              final box = Hive.box<Patient>('patients4_5');
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
    final totalBillController =
        TextEditingController(text: patient.totalBill.toString());
    final totalDaysController =
        TextEditingController(text: patient.days.toString());

    DateTime selectedDate = DateTime.now(); // Always starts fresh

    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // This keeps state inside the dialog
            return ContentDialog(
              title: const Text('Total Bill Amount'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    const SizedBox(height: 10),
                    InfoLabel(
                      label: 'Date of Bill',
                      child: DatePicker(
                        selected: selectedDate,
                        onChanged: (date) {
                          setState(() {
                            // This updates the widget inside the dialog
                            selectedDate = date;
                          });
                        },
                      ),
                    ),
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
                    patient.totalBill = double.parse(totalBillController.text);
                    patient.days = int.parse(totalDaysController.text);

                    await _generateReceiptPDF(patient, selectedDate);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showBillTableDialog(
      BuildContext context, Patient patient, int index) async {
    // Create controllers with existing values
    final billNoController = TextEditingController(text: patient.billNo);
    DateTime selectedDate = DateTime.now(); // Always starts fresh

    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Ensures state updates inside the dialog
            return ContentDialog(
              title: const Text('Total Bill Table'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    InfoLabel(
                      label: 'Bill Number',
                      child: TextFormBox(
                        controller: billNoController,
                        placeholder: 'Enter Bill Number',
                      ),
                    ),
                    const SizedBox(height: 10),
                    InfoLabel(
                      label: 'Date of Bill',
                      child: DatePicker(
                        selected: selectedDate,
                        onChanged: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                    ),
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
                    patient.billNo = billNoController.text;

                    // Save to Hive
                    final box = Hive.box<Patient>('patients4_5');
                    await box.putAt(index, patient);
                    await _generateBillTableSheetPDF(patient, selectedDate);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generateReceiptPDF(Patient patient, DateTime date) async {
    try {
      await ReceiptPDFService.generatePatientPDF(patient, date);
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
      await CaseSheetPDFService.generatePatientPDF(patient);
      if (mounted) {
        _showSuccessMessage('Case Sheet PDF generated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to generate Case Sheet: ${e.toString()}');
      }
    }
  }

  Future<void> _generateDailyCaseSheetPDF(Patient patient) async {
    try {
      await DailyCaseSheetPDFService.generatePatientPDF(patient);
      if (mounted) {
        _showSuccessMessage('Daily Case Sheet PDF generated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(
            'Failed to generate Daily Case Sheet: ${e.toString()}');
      }
    }
  }

  Future<void> _generateDischargeSheetPDF(Patient patient) async {
    await DischarSummaryPDFService.generatePatientPDF(patient);
    // await DischargeSummaryPdf.generateDischargeSummary(context);
  }

  Future<void> _generateBillTableSheetPDF(
      Patient patient, DateTime date) async {
    await BillTablePDFService.generatePatientPDF(patient, date);
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
}

Future<void> _showNewDialog(
    BuildContext context, Patient patient, int index) async {
  await showDialog<String>(
    context: context,
    builder: (context) => NewWidgetDialog(patient: patient, index: index),
  );
}

class NewWidgetDialog extends StatefulWidget {
  final Patient patient;
  final int index;
  const NewWidgetDialog({
    super.key,
    required this.patient,
    required this.index,
  });

  @override
  State<NewWidgetDialog> createState() => _NewWidgetDialogState();
}

class _NewWidgetDialogState extends State<NewWidgetDialog> {
  late final TextEditingController nameController;
  late final TextEditingController occupationController;
  late final TextEditingController addressController;
  late final TextEditingController ageController;
  late final TextEditingController dischargeController;
  late final TextEditingController admissionController;

  late DateTime dateOfAdmission;
  late DateTime dateOfDischarge;

  // new controllers
  late final TextEditingController _nationalityController;
  late final TextEditingController _ipNoController;
  late final TextEditingController _opNoController;
  late final TextEditingController _roomNoController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _presentComplaintsController;
  late final TextEditingController _historyOfPresentComplaintsController;
  late final TextEditingController _pastHistoryController;
  late final TextEditingController _heartRateController;
  late final TextEditingController _bpController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _dietController;
  late final TextEditingController _apetiteController;
  late final TextEditingController _bowelController;
  late final TextEditingController _sleepController;
  late final TextEditingController _urineController;
  late final TextEditingController _habitsController;
  late final TextEditingController _hyperController;
  late final TextEditingController _hereditaryController;
  late final TextEditingController _menstrualController;
  late final TextEditingController _naadiController;
  late final TextEditingController _mutraController;
  late final TextEditingController _malamController;
  late final TextEditingController _jihwaController;
  late final TextEditingController _sabdaController;
  late final TextEditingController _sparsaController;
  late final TextEditingController _drikController;
  late final TextEditingController _akritiController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller in initState
    nameController = TextEditingController(text: widget.patient.name);
    occupationController =
        TextEditingController(text: widget.patient.occupation);

    addressController = TextEditingController(text: widget.patient.address);

    ageController = TextEditingController(text: widget.patient.age.toString());

    dischargeController =
        TextEditingController(text: widget.patient.dateOfDischarge.toString());
    admissionController =
        TextEditingController(text: widget.patient.dateOfAdmission.toString());
    dateOfDischarge = widget.patient.dateOfDischarge;
    dateOfAdmission = widget.patient.dateOfAdmission;

    // new ones

    // Initialize the new controllers
    _nationalityController =
        TextEditingController(text: widget.patient.nationality);
    _ipNoController = TextEditingController(text: widget.patient.ipNo);
    _opNoController = TextEditingController(text: widget.patient.opNo);
    _roomNoController = TextEditingController(text: widget.patient.roomNo);
    _diagnosisController =
        TextEditingController(text: widget.patient.diagnosis);
    _presentComplaintsController =
        TextEditingController(text: widget.patient.presentComplaints);
    _historyOfPresentComplaintsController =
        TextEditingController(text: widget.patient.historyOfPresentComplaints);
    _pastHistoryController =
        TextEditingController(text: widget.patient.pastHistory);
    _heartRateController =
        TextEditingController(text: widget.patient.heartRate);
    _bpController = TextEditingController(text: widget.patient.bp);
    _weightController = TextEditingController(text: widget.patient.weight);
    _heightController = TextEditingController(text: widget.patient.height);
    _dietController = TextEditingController(text: widget.patient.diet);
    _apetiteController = TextEditingController(text: widget.patient.apetite);
    _bowelController = TextEditingController(text: widget.patient.bowel);
    _sleepController = TextEditingController(text: widget.patient.sleep);
    _urineController = TextEditingController(text: widget.patient.urine);
    _habitsController = TextEditingController(text: widget.patient.habits);
    _hyperController = TextEditingController(text: widget.patient.sensitivity);
    _hereditaryController =
        TextEditingController(text: widget.patient.hereditary);
    _menstrualController =
        TextEditingController(text: widget.patient.menstrualHistory);
    _naadiController = TextEditingController(text: widget.patient.naadi);
    _mutraController = TextEditingController(text: widget.patient.mutra);
    _malamController = TextEditingController(text: widget.patient.malam);
    _jihwaController = TextEditingController(text: widget.patient.jihwa);
    _sabdaController = TextEditingController(text: widget.patient.sabda);
    _sparsaController = TextEditingController(text: widget.patient.sparsa);
    _drikController = TextEditingController(text: widget.patient.drik);
    _akritiController = TextEditingController(text: widget.patient.akriti);
  }

  Future<void> saveCaseSheet(Box<Patient> patientBox, int index) async {
    // print("STARTED");
    Patient? patient = patientBox.get(widget.index);
    // print(patient);
    if (patient != null) {
      patient.name = nameController.text;
      patient.occupation = occupationController.text;
      patient.address = addressController.text;
      patient.age = int.parse(ageController.text);
      patient.dateOfAdmission = dateOfAdmission;
      patient.dateOfDischarge = dateOfDischarge;
      // Update other fields...
      patient.nationality = _nationalityController.text;
      patient.ipNo = _ipNoController.text;
      patient.opNo = _opNoController.text;
      patient.roomNo = _roomNoController.text;
      patient.diagnosis = _diagnosisController.text;
      patient.presentComplaints = _presentComplaintsController.text;
      patient.historyOfPresentComplaints =
          _historyOfPresentComplaintsController.text;
      patient.pastHistory = _pastHistoryController.text;
      patient.heartRate = _heartRateController.text;
      patient.bp = _bpController.text;
      patient.weight = _weightController.text;
      patient.height = _heightController.text;
      patient.diet = _dietController.text;
      patient.apetite = _apetiteController.text;
      patient.bowel = _bowelController.text;
      patient.sleep = _sleepController.text;
      patient.urine = _urineController.text;
      patient.habits = _habitsController.text;
      patient.sensitivity = _hyperController.text;
      patient.hereditary = _hereditaryController.text;
      patient.menstrualHistory = _menstrualController.text;
      patient.naadi = _naadiController.text;
      patient.mutra = _mutraController.text;
      patient.malam = _malamController.text;
      patient.jihwa = _jihwaController.text;
      patient.sabda = _sabdaController.text;
      patient.sparsa = _sparsaController.text;
      patient.drik = _drikController.text;
      patient.akriti = _akritiController.text;

      // Save to Hive
      final box = Hive.box<Patient>('patients4_5');
      await box.putAt(index, patient);

      if (context.mounted) {
        // s
        displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Success'),
              content: const Text('Patient record updated successfully'),
              severity: InfoBarSeverity.success,
              action: IconButton(
                icon: const Icon(FluentIcons.clear),
                onPressed: close,
              ),
            );
          },
        );
      }

      await patient.save();

      nameController.dispose();
      ageController.dispose();
      occupationController.dispose();
      addressController.dispose();
      dischargeController.dispose();
      admissionController.dispose();

      setState(() {
        patientBox = Hive.box<Patient>('patients4_5');
        patient = patientBox.get(widget.index);
      });
      // _initializeHiveDatas();
    } else {
      // print("ERROR");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Edit Patient Details'),
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
            const SizedBox(height: 8),
            InfoLabel(
              label: 'Age',
              child: TextFormBox(
                controller: ageController,
                placeholder: 'Enter Age',
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'Date of Admission',
              child: DatePicker(
                selected: dateOfAdmission,
                onChanged: (date) {
                  setState(() {
                    dateOfAdmission = date;
                  });
                },
              ),
            ),
            InfoLabel(
              label: 'Date of Discharge',
              child: DatePicker(
                selected: dateOfDischarge,
                onChanged: (date) {
                  setState(() {
                    dateOfDischarge = date;
                  });
                },
              ),
            ),
            // Add other fields as needed
            const SizedBox(height: 8),
            // New fields added
            InfoLabel(
              label: 'Nationality',
              child: TextFormBox(
                controller: _nationalityController,
                placeholder: 'Enter nationality',
              ),
            ),
            InfoLabel(
              label: 'IP No',
              child: TextFormBox(
                controller: _ipNoController,
                placeholder: 'Enter IP No',
              ),
            ),
            InfoLabel(
              label: 'OP No',
              child: TextFormBox(
                controller: _opNoController,
                placeholder: 'Enter OP No',
              ),
            ),
            InfoLabel(
              label: 'Room No',
              child: TextFormBox(
                controller: _roomNoController,
                placeholder: 'Enter Room No',
              ),
            ),
            InfoLabel(
              label: 'Diagnosis',
              child: TextFormBox(
                maxLines: 3,
                controller: _diagnosisController,
                placeholder: 'Enter diagnosis',
              ),
            ),
            InfoLabel(
              label: 'Present Complaints',
              child: TextFormBox(
                maxLines: 3,
                controller: _presentComplaintsController,
                placeholder: 'Enter present complaints',
              ),
            ),
            InfoLabel(
              label: 'History of Present Complaints',
              child: TextFormBox(
                maxLines: 3,
                controller: _historyOfPresentComplaintsController,
                placeholder: 'Enter history of present complaints',
              ),
            ),
            InfoLabel(
              label: 'Past History',
              child: TextFormBox(
                maxLines: 3,
                controller: _pastHistoryController,
                placeholder: 'Enter past history',
              ),
            ),
            InfoLabel(
              label: 'Heart Rate',
              child: TextFormBox(
                controller: _heartRateController,
                placeholder: 'Enter heart rate',
              ),
            ),
            InfoLabel(
              label: 'BP',
              child: TextFormBox(
                controller: _bpController,
                placeholder: 'Enter BP',
              ),
            ),
            InfoLabel(
              label: 'Weight',
              child: TextFormBox(
                controller: _weightController,
                placeholder: 'Enter weight',
              ),
            ),
            InfoLabel(
              label: 'Height',
              child: TextFormBox(
                controller: _heightController,
                placeholder: 'Enter height',
              ),
            ),
            InfoLabel(
              label: 'Diet',
              child: TextFormBox(
                controller: _dietController,
                placeholder: 'Enter diet',
              ),
            ),
            InfoLabel(
              label: 'Apetite',
              child: TextFormBox(
                controller: _apetiteController,
                placeholder: 'Enter appetite details',
              ),
            ),
            InfoLabel(
              label: 'Bowel',
              child: TextFormBox(
                controller: _bowelController,
                placeholder: 'Enter bowel details',
              ),
            ),
            InfoLabel(
              label: 'Sleep',
              child: TextFormBox(
                controller: _sleepController,
                placeholder: 'Enter sleep pattern',
              ),
            ),
            InfoLabel(
              label: 'Urine',
              child: TextFormBox(
                controller: _urineController,
                placeholder: 'Enter urine details',
              ),
            ),
            InfoLabel(
              label: 'Habits',
              child: TextFormBox(
                controller: _habitsController,
                placeholder: 'Enter habits',
              ),
            ),
            InfoLabel(
              label: 'Hypersensitivity',
              child: TextFormBox(
                controller: _hyperController,
                placeholder: 'Enter hypersensitivity details',
              ),
            ),
            InfoLabel(
              label: 'Hereditary',
              child: TextFormBox(
                controller: _hereditaryController,
                placeholder: 'Enter hereditary details',
              ),
            ),
            InfoLabel(
              label: 'Menstrual History',
              child: TextFormBox(
                controller: _menstrualController,
                placeholder: 'Enter menstrual history',
              ),
            ),
            InfoLabel(
              label: 'Naadi',
              child: TextFormBox(
                controller: _naadiController,
                placeholder: 'Enter naadi details',
              ),
            ),
            InfoLabel(
              label: 'Mutra',
              child: TextFormBox(
                controller: _mutraController,
                placeholder: 'Enter mutra details',
              ),
            ),
            InfoLabel(
              label: 'Malam',
              child: TextFormBox(
                controller: _malamController,
                placeholder: 'Enter malam details',
              ),
            ),
            InfoLabel(
              label: 'Jihwa',
              child: TextFormBox(
                controller: _jihwaController,
                placeholder: 'Enter jihwa details',
              ),
            ),
            InfoLabel(
              label: 'Sabda',
              child: TextFormBox(
                controller: _sabdaController,
                placeholder: 'Enter sabda details',
              ),
            ),
            InfoLabel(
              label: 'Sparsa',
              child: TextFormBox(
                controller: _sparsaController,
                placeholder: 'Enter sparsa details',
              ),
            ),
            InfoLabel(
              label: 'Drik',
              child: TextFormBox(
                controller: _drikController,
                placeholder: 'Enter drik details',
              ),
            ),
            InfoLabel(
              label: 'Akriti',
              child: TextFormBox(
                controller: _akritiController,
                placeholder: 'Enter akriti details',
              ),
            ),
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
            final box = Hive.box<Patient>('patients4_5');
            await saveCaseSheet(box, widget.index);
            // await box.putAt(widget.index, widget.patient);

            if (context.mounted) {
              Navigator.pop(context);
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Success'),
                    content: const Text('Patient record updated successfully'),
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
    );
  }
}
