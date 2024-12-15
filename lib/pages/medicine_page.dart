// import 'package:flutter/material.dart';
import 'package:clinic_management_new/database/patient.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MedicineUpdateWidget extends StatefulWidget {
  final Patient patient;
  final int index;
  const MedicineUpdateWidget(
      {super.key, required this.patient, required this.index});

  @override
  State<MedicineUpdateWidget> createState() => _MedicineUpdateWidgetState();
}

class _MedicineUpdateWidgetState extends State<MedicineUpdateWidget> {
  late Box<Patient> patientBox;
  // late Patient? patienT;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    // print("Starting");
    try {
      // print("Trying");
      if (!Hive.isBoxOpen('patients4_2')) {
        patientBox = await Hive.openBox<Patient>('patients4_2');
        // print("Opening");
      } else {
        patientBox = Hive.box<Patient>('patients4_2');
        // print("found");
      }
    } catch (e) {
      debugPrint('Error opening Hive box: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text("Internal Medicine Given to ${widget.patient.name}"),
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
              const SizedBox(
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
                    onPressed: () {
                      patientBox = Hive.box<Patient>('patients4_2');
                      setState(() {});
                    }),
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
                    decoration: BoxDecoration(
                        // color: FluentTheme.of(context).resources.accentBackgroundColor,
                        ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Name',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data Rows
                  ...widget.patient.medicationsEntry
                          ?.asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final medicineRecord = entry.value;
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(medicineRecord.name ?? '-'),
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
                                    onPressed: () =>
                                        _deleteMedicineRecord(index),
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

  Future<void> _deleteMedicineRecord(int medicineIndex) async {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Confirm Deletion'),
        content:
            const Text('Are you sure you want to delete this medicine entry?'),
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
                widget.patient.medicationsEntry?.removeAt(medicineIndex);
              });
              await widget.patient.save();
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Deleted'),
                    content: const Text('Medicine entry deleted successfully'),
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

  Future<void> _showEditDialog(BuildContext context, Patient patient,
      int patientIndex, int medicineIndex) async {
    final medicineRecord = patient.medicationsEntry?[medicineIndex];
    if (medicineRecord != null) {
      await showDialog<String>(
        context: context,
        builder: (context) => NewWidgetDialog(
          patient: patient,
          index: patientIndex,
          initialMedicineEntry: medicineRecord,
          medicineIndex: medicineIndex,
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
}

class NewWidgetDialog extends StatefulWidget {
  final Patient patient;
  final int index;
  final MedicationsEntry? initialMedicineEntry;
  final int? medicineIndex;
  const NewWidgetDialog({
    super.key,
    required this.patient,
    required this.index,
    this.initialMedicineEntry,
    this.medicineIndex,
  });

  @override
  State<NewWidgetDialog> createState() => _NewWidgetDialogState();
}

class _NewWidgetDialogState extends State<NewWidgetDialog> {
  late TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialMedicineEntry?.name ?? "");
  }

  Future<void> saveCaseSheet(Box<Patient> patientBox) async {
    // print("STARTED");
    Patient? patient = patientBox.get(widget.index);
    // print(patient);
    if (patient != null) {
      final name = _nameController.text;
      // final double price = double.parse(_priceController.text);
      const quantity = 0.0;
      // final quantity = double.parse(_quantityController.text ?? "0");

      final medicineRegister = MedicationsEntry(name: name, quantity: quantity);

      if (widget.medicineIndex != null) {
        // Editing an existing case sheet
        patient.medicationsEntry?[widget.medicineIndex!] = medicineRegister;
      } else {
        // Adding a new case sheet
        patient.medicationsEntry = [
          ...?patient.medicationsEntry,
          medicineRegister
        ];
      }

      // patient.medicationsEntry = [
      //   ...?patient.medicationsEntry,
      //   medicineRegister
      // ];
      await patient.save();

      // print(patient);
      // print(caseSheet);

      _nameController.clear();
      // _quantityController.clear();

      setState(() {
        patientBox = Hive.box<Patient>('patients4_2');
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
      title: const Text('Add Bill Record'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Particular',
              child: TextFormBox(
                controller: _nameController,
                placeholder: 'Medicine name ',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 10),
            // InfoLabel(
            //   label: 'Quantity',
            //   child: TextFormBox(
            //     controller: _quantityController,
            //     placeholder: 'Enter Quantity',
            //     maxLines: 3,
            //   ),
            // ),
            // const SizedBox(height: 10),

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
            final box = Hive.box<Patient>('patients4_2');
            await saveCaseSheet(box);
            // await box.putAt(widget.index, widget.patient);

            if (context.mounted) {
              Navigator.pop(context);
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Success'),
                    content: const Text('Bill updated successfully'),
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
