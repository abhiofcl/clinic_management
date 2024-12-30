// import 'package:flutter/material.dart';
import 'package:clinic_management_new/database/employee.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class DutySheetWidget extends StatefulWidget {
  final Employee employee;
  final int index;
  const DutySheetWidget(
      {super.key, required this.employee, required this.index});

  @override
  State<DutySheetWidget> createState() => _DutySheetWidgetState();
}

class _DutySheetWidgetState extends State<DutySheetWidget> {
  late Box<Employee> patientBox;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      if (!Hive.isBoxOpen('employees_1_1')) {
        patientBox = await Hive.openBox<Employee>('employees_1_1');
      } else {
        patientBox = Hive.box<Employee>('employees_1_1');
      }
    } catch (e) {
      print('Error opening Hive box: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text("Daily Duty Case Sheet of ${widget.employee.name}"),
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
                      _showNewDialog(context, widget.employee, widget.index),
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
                    patientBox = Hive.box<Employee>('employees_1_1');
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
                        child: Text('Duty Performed',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Patient Name',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Qty',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rate',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Amount',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Remarks',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...widget.employee.dutySheet?.asMap().entries.map((entry) {
                        final index = entry.key;
                        final dutySheet = entry.value;
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(DateFormat('dd/MM/yyyy')
                                  .format(dutySheet.date ?? DateTime.now())),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(dutySheet.timeSlot ?? '-'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(dutySheet.dutyPerformed ?? '-'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(dutySheet.patientName ?? '-'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(dutySheet.qty ?? '-'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(dutySheet.rate ?? ''),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(dutySheet.amount ?? ''),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(dutySheet.remarks ?? ''),
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
                                        widget.employee, widget.index, index),
                                  ),
                                  IconButton(
                                    icon: const Icon(FluentIcons.delete),
                                    onPressed: () => _deleteDutySheet(index),
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
      BuildContext context, Employee employee, int index) async {
    await showDialog<String>(
      context: context,
      builder: (context) => NewWidgetDialog(patient: employee, index: index),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Employee employee,
      int employeeIndex, int dutySheetIndex) async {
    final dutySheet = employee.dutySheet?[dutySheetIndex];
    if (dutySheet != null) {
      await showDialog<String>(
        context: context,
        builder: (context) => NewWidgetDialog(
          patient: employee,
          index: employeeIndex,
          initialDutySheet: dutySheet,
          dutySheetIndex: dutySheetIndex,
        ),
      );
    }
  }

  Future<void> _deleteDutySheet(int dutySheetIndex) async {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to delete this duty sheet entry?'),
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
                widget.employee.dutySheet?.removeAt(dutySheetIndex);
              });
              await widget.employee.save();
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Deleted'),
                    content:
                        const Text('Duty sheet entry deleted successfully'),
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
  final Employee patient;
  final int index;
  final DutySheetEntry? initialDutySheet;
  final int? dutySheetIndex;

  const NewWidgetDialog({
    super.key,
    required this.patient,
    required this.index,
    this.initialDutySheet,
    this.dutySheetIndex,
  });

  @override
  State<NewWidgetDialog> createState() => _NewWidgetDialogState();
}

class _NewWidgetDialogState extends State<NewWidgetDialog> {
  late TextEditingController _patientNameController;
  late TextEditingController _qtyController;
  late TextEditingController _rateController;
  late TextEditingController _amountController;
  late TextEditingController _remarkController;
  late TextEditingController _dutyPerformedController;
  String _time = "AM";
  late DateTime _dateOfCheck;

  @override
  void initState() {
    super.initState();
    _patientNameController =
        TextEditingController(text: widget.initialDutySheet?.patientName ?? "");
    _qtyController =
        TextEditingController(text: widget.initialDutySheet?.qty ?? "");
    _rateController =
        TextEditingController(text: widget.initialDutySheet?.rate ?? "");
    _dutyPerformedController = TextEditingController(
        text: widget.initialDutySheet?.dutyPerformed ?? "");
    _amountController =
        TextEditingController(text: widget.initialDutySheet?.amount ?? "");
    _remarkController =
        TextEditingController(text: widget.initialDutySheet?.remarks ?? "");
    _time = widget.initialDutySheet?.timeSlot ?? "AM";
    _dateOfCheck = widget.initialDutySheet?.date ?? DateTime.now();
  }

  Future<void> saveDutySheet(Box<Employee> employeeBox) async {
    Employee? employee = employeeBox.get(widget.index);
    if (employee != null) {
      final patientName = _patientNameController.text;
      final dutyPerformed = _dutyPerformedController.text;
      final qty = _qtyController.text;
      final rate = _rateController.text;
      final amount = _amountController.text;
      final remarks = _remarkController.text;
      final dutySheet = DutySheetEntry(
        patientName: patientName,
        dutyPerformed: dutyPerformed,
        qty: qty,
        rate: rate,
        amount: amount,
        remarks: remarks,
        date: _dateOfCheck,
        timeSlot: _time,
      );
      print(dutySheet);

      if (widget.dutySheetIndex != null) {
        // Editing an existing case sheet
        employee.dutySheet?[widget.dutySheetIndex!] = dutySheet;
      } else {
        // Adding a new case sheet
        employee.dutySheet = [...?employee.dutySheet, dutySheet];
      }

      await employee.save();
      setState(() {
        employeeBox = Hive.box<Employee>('employees_1_1');
        employee = employeeBox.get(widget.index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.dutySheetIndex != null
          ? 'Edit Duty Sheet Entry'
          : 'Add Duty Sheet Record'),
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
              label: 'Patient Name',
              child: TextFormBox(
                controller: _patientNameController,
                placeholder: 'Enter patient name ',
                // maxLines: 3,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Duty Performed',
              child: TextFormBox(
                controller: _dutyPerformedController,
                placeholder: 'Enter duty performed ',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Quantity',
              child: TextFormBox(
                controller: _qtyController,
                placeholder: 'Enter Quantity ',
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'Rate',
              child: TextFormBox(
                controller: _rateController,
                placeholder: 'Enter rate',
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Amount',
              child: TextFormBox(
                controller: _amountController,
                placeholder: 'Enter amount',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Remarks',
              child: TextFormBox(
                controller: _remarkController,
                placeholder: 'Enter remarks if any',
              ),
            ),
            const SizedBox(height: 10),
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
            final box = Hive.box<Employee>('employees_1_1');

            await saveDutySheet(box);

            if (context.mounted) {
              Navigator.pop(context);
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Success'),
                    content: const Text('Duty Sheet updated successfully'),
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
