// import 'package:flutter/material.dart';
import 'package:clinic_management_new/database/patient.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BillUpdateWidget extends StatefulWidget {
  final Patient patient;
  final int index;
  const BillUpdateWidget(
      {super.key, required this.patient, required this.index});

  @override
  State<BillUpdateWidget> createState() => _BillUpdateWidgetState();
}

class _BillUpdateWidgetState extends State<BillUpdateWidget> {
  // final TextEditingController _particularController = TextEditingController();
  // final TextEditingController _quantityController = TextEditingController();
  // final TextEditingController _priceController = TextEditingController();
  // final TextEditingController _dateController = TextEditingController();
  // DateTime _dateOfAdmission = DateTime.now();

  late Box<Patient> patientBox;
  late Patient? patienT;

  @override
  void initState() {
    super.initState();
    _initializeHive();
    // _initializeHiveDatas();
    // print(patienT?.caseSheets);
  }

  Future<void> _initializeHive() async {
    // print("Starting");
    try {
      // print("Trying");
      if (!Hive.isBoxOpen('patients4_1')) {
        patientBox = await Hive.openBox<Patient>('patients4_1');
        // print("Opening");
      } else {
        patientBox = Hive.box<Patient>('patients4_1');
        // print("found");
      }
    } catch (e) {
      debugPrint('Error opening Hive box: $e');
    }
  }

  @override
  void dispose() {
    // _particularController.dispose();
    // _quantityController.dispose();
    // // _dateController.dispose();
    // _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text("Bill particulars of ${widget.patient.name}"),
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
                      patientBox = Hive.box<Patient>('patients4_1');
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
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Text('Sl No',
                      //       style: TextStyle(fontWeight: FontWeight.bold)),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Particulars',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rate',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Qty',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Amount',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data Rows
                  ...widget.patient.billRegister
                          ?.map((billRecord) => TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(billRecord.particulars ?? '-'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(billRecord.rate ?? '-'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        billRecord.quantity.toString() ?? '-'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                        Text(billRecord.price.toString() ?? ""),
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
  final TextEditingController _particularController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  // DateTime _dateOfCheck = DateTime.now();

  Future<void> saveCaseSheet(Box<Patient> patientBox) async {
    // print("STARTED");
    Patient? patient = patientBox.get(widget.index);
    // print(patient);
    if (patient != null) {
      final particular = _particularController.text;
      final double price = double.parse(_priceController.text);
      final quantity = _quantityController.text;
      final rate = _rateController.text;

      final billRegister = BillEntry(
          price: price,
          particulars: particular,
          quantity: quantity,
          rate: rate);

      patient.billRegister = [...?patient.billRegister, billRegister];
      await patient.save();

      // print(patient);
      // print(caseSheet);

      _quantityController.clear();
      _priceController.clear();
      _particularController.clear();
      _rateController.clear();

      setState(() {
        patientBox = Hive.box<Patient>('patients4_1');
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
                controller: _particularController,
                placeholder: 'Enter Particular ',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Rate',
              child: TextFormBox(
                controller: _rateController,
                placeholder: 'Enter rate ',
              ),
            ),
            const SizedBox(height: 18),
            InfoLabel(
              label: 'Quantity',
              child: TextFormBox(
                controller: _quantityController,
                placeholder: 'Enter Quantity',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: InfoLabel(
                label: 'Amount',
                child: TextFormBox(
                  controller: _priceController,
                  placeholder: 'Enter Amount',
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
            final box = Hive.box<Patient>('patients4_1');
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
