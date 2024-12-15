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
  late Box<Patient> patientBox;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      if (!Hive.isBoxOpen('patients4_2')) {
        patientBox = await Hive.openBox<Patient>('patients4_2');
      } else {
        patientBox = Hive.box<Patient>('patients4_2');
      }
    } catch (e) {
      print('Error opening Hive box: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text("Daily Case Sheet of ${widget.patient.name}"),
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
                      SizedBox(width: 8),
                      Text("New")
                    ],
                  ),
                  onPressed: () =>
                      _showNewDialog(context, widget.patient, widget.index),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: FilledButton(
                  child: const Row(
                    children: [Text("Reload")],
                  ),
                  onPressed: () {
                    patientBox = Hive.box<Patient>('patients4_2');
                    setState(() {});
                  },
                ),
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
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Date',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('AM/PM',
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
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...widget.patient.caseSheets?.asMap().entries.map((entry) {
                        final index = entry.key;
                        final caseSheet = entry.value;
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(DateFormat('dd/MM/yyyy')
                                  .format(caseSheet.date ?? DateTime.now())),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(caseSheet.time ?? '-'),
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
                              child: Text(caseSheet.treatments ?? ''),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(FluentIcons.edit),
                                    onPressed: () => _showEditDialog(context,
                                        widget.patient, widget.index, index),
                                  ),
                                  IconButton(
                                    icon: const Icon(FluentIcons.delete),
                                    onPressed: () => _deleteCaseSheet(index),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList() ??
                      [],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNewDialog(
      BuildContext context, Patient patient, int index) async {
    await showDialog<String>(
      context: context,
      builder: (context) => NewWidgetDialog(patient: patient, index: index),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Patient patient,
      int patientIndex, int caseSheetIndex) async {
    final caseSheet = patient.caseSheets?[caseSheetIndex];
    if (caseSheet != null) {
      await showDialog<String>(
        context: context,
        builder: (context) => NewWidgetDialog(
          patient: patient,
          index: patientIndex,
          initialCaseSheet: caseSheet,
          caseSheetIndex: caseSheetIndex,
        ),
      );
    }
  }

  Future<void> _deleteCaseSheet(int caseSheetIndex) async {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to delete this case sheet entry?'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                widget.patient.caseSheets?.removeAt(caseSheetIndex);
              });
              await widget.patient.save();
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Deleted'),
                    content:
                        const Text('Case sheet entry deleted successfully'),
                    severity: InfoBarSeverity.warning,
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
}

class NewWidgetDialog extends StatefulWidget {
  final Patient patient;
  final int index;
  final CaseSheetEntry? initialCaseSheet;
  final int? caseSheetIndex;

  const NewWidgetDialog({
    super.key,
    required this.patient,
    required this.index,
    this.initialCaseSheet,
    this.caseSheetIndex,
  });

  @override
  State<NewWidgetDialog> createState() => _NewWidgetDialogState();
}

class _NewWidgetDialogState extends State<NewWidgetDialog> {
  late TextEditingController _treatmentController;
  late TextEditingController _symptomsController;
  late TextEditingController _bpController;
  String _time = "AM";
  late DateTime _dateOfCheck;

  @override
  void initState() {
    super.initState();
    _treatmentController =
        TextEditingController(text: widget.initialCaseSheet?.treatments ?? "");
    _symptomsController =
        TextEditingController(text: widget.initialCaseSheet?.symptoms ?? "");
    _bpController =
        TextEditingController(text: widget.initialCaseSheet?.bp ?? "");
    _time = widget.initialCaseSheet?.time ?? "AM";
    _dateOfCheck = widget.initialCaseSheet?.date ?? DateTime.now();
  }

  Future<void> saveCaseSheet(Box<Patient> patientBox) async {
    Patient? patient = patientBox.get(widget.index);
    if (patient != null) {
      final symptoms = _symptomsController.text;
      final treatments = _treatmentController.text;
      final bp = _bpController.text;
      final caseSheet = CaseSheetEntry(
        date: _dateOfCheck,
        symptoms: symptoms,
        treatments: treatments,
        bp: bp,
        time: _time,
      );

      if (widget.caseSheetIndex != null) {
        // Editing an existing case sheet
        patient.caseSheets?[widget.caseSheetIndex!] = caseSheet;
      } else {
        // Adding a new case sheet
        patient.caseSheets = [...?patient.caseSheets, caseSheet];
      }

      await patient.save();
      setState(() {
        patientBox = Hive.box<Patient>('patients4_2');
        patient = patientBox.get(widget.index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.caseSheetIndex != null
          ? 'Edit Case Sheet Entry'
          : 'Add Daily Case Sheet Record'),
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
              label: 'Time slot',
              child: ComboBox<String>(
                value: _time,
                placeholder: const Text('Select time slot'),
                items: ['AM', 'PM']
                    .map((e) => ComboBoxItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _time = value!;
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
            InfoLabel(
              label: 'Symptoms',
              child: TextFormBox(
                controller: _symptomsController,
                placeholder: 'Enter Symptoms',
                maxLines: 3,
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
            final box = Hive.box<Patient>('patients4_2');
            await saveCaseSheet(box);

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
