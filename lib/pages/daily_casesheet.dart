// import 'package:flutter/material.dart';
import 'package:clinic_management_new/database/patient.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class CaseSheetWidget extends StatefulWidget {
  final Patient patient;
  final int index;
  const CaseSheetWidget(
      {super.key, required this.patient, required this.index});

  @override
  State<CaseSheetWidget> createState() => _CaseSheetWidgetState();
}

class _CaseSheetWidgetState extends State<CaseSheetWidget> {
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  // final TextEditingController _dateController = TextEditingController();
  DateTime _dateOfAdmission = DateTime.now();
  final TextEditingController _bpController = TextEditingController();
  late Box<Patient> patientBox;
  late Patient? patienT;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeHive();
    // _initializeHiveDatas();
    // print(patienT?.caseSheets);
  }

  // Future<void> _initializeHiveDatas() async {
  //   patientBox = Hive.box<Patient>('patients4');
  //   patienT = patientBox.get(widget.index);
  // }

  Future<void> _initializeHive() async {
    print("Starting");
    try {
      print("Trying");
      if (!Hive.isBoxOpen('patients4')) {
        patientBox = await Hive.openBox<Patient>('patients4');
        print("Opening");
      } else {
        patientBox = Hive.box<Patient>('patients4');
        print("found");
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
  void dispose() {
    _treatmentController.dispose();
    _symptomsController.dispose();
    // _dateController.dispose();
    _bpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text("Daily Case cheet of ${widget.patient.name}"),
      ),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
        child: ScaffoldPage(
          header: Row(
            children: [
              SizedBox(
                width: 100,
                child: FilledButton(
                    child: const Row(
                      children: [
                        Icon(FluentIcons.add),
                        SizedBox(
                          width: 8,
                        ),
                        Text("New")
                      ],
                    ),
                    onPressed: () =>
                        _showNewDialog(context, widget.patient, widget.index)),
              ),
              SizedBox(
                width: 16,
              ),
              SizedBox(
                width: 100,
                child: FilledButton(
                    child: const Row(
                      children: [
                        // Icon(FluentIcons.arrow_down_right8),
                        Text("Reload")
                      ],
                    ),
                    onPressed: () => _initializeHive()),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.all(
                  color: FluentTheme.of(context)
                      .resources
                      .dividerStrokeColorDefault,
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                        // color: FluentTheme.of(context).resources.accentBackgroundColor,
                        ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Date',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('BP',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Symptoms',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Treatment',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data Rows
                  ...widget.patient.caseSheets
                          ?.map((caseSheet) => TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(DateFormat('dd/MM/yyyy').format(
                                        caseSheet.date ?? DateTime.now())),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(caseSheet.bp ?? '-'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(caseSheet.symptoms ?? '-'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(caseSheet.treatments ?? ""),
                                  ),
                                ],
                              ))
                          .toList() ??
                      [],
                ],
              ),
            ),
          ),
        ),
      ),
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
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();

  DateTime _dateOfCheck = DateTime.now();
  final TextEditingController _bpController = TextEditingController();

  Future<void> saveCaseSheet(Box<Patient> patientBox) async {
    // print("STARTED");
    Patient? patient = patientBox.get(widget.index);
    // print(patient);
    if (patient != null) {
      final symptoms = _symptomsController.text;

      final treatments = _treatmentController.text;
      final bp = _bpController.text;
      final caseSheet = CaseSheetEntry(
          date: _dateOfCheck, symptoms: symptoms, treatments: treatments, bp: bp
          // bp:bp,
          );

      patient.caseSheets = [...?patient.caseSheets, caseSheet];
      await patient.save();

      // print(patient);
      // print(caseSheet);

      _bpController.clear();
      _symptomsController.clear();
      _treatmentController.clear();

      setState(() {
        patientBox = Hive.box<Patient>('patients4');
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
      title: const Text('Add Daily Case Sheet Record'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoLabel(
              label: 'Date of Checking',
              child: DatePicker(
                selected: _dateOfCheck,
                onChanged: (date) {
                  setState(() {
                    _dateOfCheck = date;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Treatment',
              child: TextFormBox(
                controller: _treatmentController,
                placeholder: 'Enter Treatment ',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Symptoms',
              child: TextFormBox(
                controller: _symptomsController,
                placeholder: 'Enter Symptoms',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 300,
              child: InfoLabel(
                label: 'BP',
                child: TextFormBox(
                  controller: _bpController,
                  placeholder: 'Enter bp',
                ),
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
            final box = Hive.box<Patient>('patients4');
            await saveCaseSheet(box);
            // await box.putAt(widget.index, widget.patient);

            if (context.mounted) {
              Navigator.pop(context);
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Success'),
                    content: const Text('Case Sheet updated successfully'),
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
