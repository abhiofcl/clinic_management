import 'dart:typed_data';

import 'package:clinic_management_new/database/employee.dart';
import 'package:clinic_management_new/pages/duty_sheet.dart';
import 'package:fluent_ui/fluent_ui.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmployeeListPage extends StatefulWidget {
  final Box employeesBox;
  const EmployeeListPage({super.key, required this.employeesBox});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  Box<Employee>? _patientBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      if (!Hive.isBoxOpen('employees_1_1')) {
        _patientBox = await Hive.openBox<Employee>('employees_1_1');
      } else {
        _patientBox = Hive.box<Employee>('employees_1_1');
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
          title: Text('Employee Records'),
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
            const Text('Error loading employee records'),
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
      builder: (context, Box<Employee> box, _) {
        if (box.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FluentIcons.document_set, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'No Employees found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start by adding a new employee record',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  child: const Text('Add Employee'),
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
                    Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            // const SizedBox(width: 8),
                            FilledButton(
                              child: const Text('Update Daily DutySheet'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    FluentPageRoute(
                                      builder: (context) => DutySheetWidget(
                                        index: index,
                                        employee: patient,
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
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Age', '${patient.age} years'),
                    _buildInfoRow('Gender', patient.gender),
                    _buildInfoRow('Address', patient.address),
                    _buildInfoRow('Phone Number', patient.phoneNumber),
                    _buildInfoRow('Another Phone Number', patient.phoneNumber),
                    _buildInfoRow('Identity Card Type', patient.idProofType),
                    _buildInfoRow('Identity card No:', patient.idProof),
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
            'Are you sure you want to delete this employee record? This action cannot be undone.'),
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
              final box = Hive.box<Employee>('employees_1_1');
              await box.deleteAt(index);
              Navigator.pop(context);
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Success'),
                    content: const Text('Employee record deleted successfully'),
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
      BuildContext context, Employee patient, int index) async {
    // Create controllers with existing values
    final nameController = TextEditingController(text: patient.name);

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

              patient.address = addressController.text;
              // Update other fields...

              // Save to Hive
              final box = Hive.box<Employee>('employees_1_1');
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

  // @override
  // void dispose() {
  //   if (_patientBox != null && _patientBox!.isOpen) {
  //     _patientBox!.close();
  //   }
  //   super.dispose();
  // }
}

Future<void> _showNewDialog(
    BuildContext context, Employee employee, int index) async {
  await showDialog<String>(
    context: context,
    builder: (context) => NewWidgetDialog(employee: employee, index: index),
  );
}

class NewWidgetDialog extends StatefulWidget {
  final Employee employee;
  final int index;
  const NewWidgetDialog({
    super.key,
    required this.employee,
    required this.index,
  });

  @override
  State<NewWidgetDialog> createState() => _NewWidgetDialogState();
}

class _NewWidgetDialogState extends State<NewWidgetDialog> {
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late final TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller in initState
    nameController = TextEditingController(text: widget.employee.name);

    addressController = TextEditingController(text: widget.employee.address);

    ageController = TextEditingController(text: widget.employee.age.toString());
  }

  @override
  void dispose() {
    // Don't forget to dispose of controllers to prevent memory leaks
    nameController.dispose();
    ageController.dispose();

    addressController.dispose();

    super.dispose();
  }

  Future<void> saveCaseSheet(Box<Employee> employeeBox, int index) async {
    Employee? employee = employeeBox.get(widget.index);

    if (employee != null) {
      // Update patient object
      employee.name = nameController.text;

      employee.address = addressController.text;
      employee.age = int.parse(ageController.text);

      // Update other fields...

      // Save to Hive
      final box = Hive.box<Employee>('employees_1_1');
      await box.putAt(index, employee);

      if (context.mounted) {
        Navigator.pop(context);
        displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Success'),
              content: const Text('Employee record updated successfully'),
              severity: InfoBarSeverity.success,
              action: IconButton(
                icon: const Icon(FluentIcons.clear),
                onPressed: close,
              ),
            );
          },
        );
      }

      // patient.caseSheets = [...?patient.caseSheets, caseSheet];
      await employee.save();

      // print(patient);
      // print(caseSheet);

      // _bpController.clear();
      // _symptomsController.clear();
      // _treatmentController.clear();
      // _timeController.clear();
      nameController.dispose();
      ageController.dispose();

      addressController.dispose();

      setState(() {
        employeeBox = Hive.box<Employee>('employees_1_1');
        employee = employeeBox.get(widget.index);
      });
      // _initializeHiveDatas();
    } else {
      // print("ERROR");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add Daily Duty Sheet Record'),
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
            final box = Hive.box<Employee>('employees_1_1');
            await saveCaseSheet(box, widget.index);
            // await box.putAt(widget.index, widget.patient);

            if (context.mounted) {
              Navigator.pop(context);
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Success'),
                    content: const Text('Employee record updated successfully'),
                    severity: InfoBarSeverity.success,
                    action: IconButton(
                      icon: const Icon(FluentIcons.clear),
                      onPressed: close,
                    ),
                  );
                },
              );
            }
            if (context.mounted) {
              Navigator.pop(context);
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Success'),
                    content: const Text('Duty updated successfully'),
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
