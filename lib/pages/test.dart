import 'package:clinic_management_new/employee_details.dart';
import 'package:clinic_management_new/pages/patient_form_new.dart';
import 'package:clinic_management_new/pages/employee_form.dart';
import 'package:clinic_management_new/patient_details.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  final Box patientBox;
  final Box employeeBox;

  const MyWidget(
      {super.key, required this.patientBox, required this.employeeBox});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  PaneDisplayMode displayMode = PaneDisplayMode.open;
  int topIndex = 0;
  // bool isDark = false;

  // List<NavigationPaneItem> items = [
  //   PaneItemExpander(
  //     icon: const Icon(FluentIcons.account_management),
  //     title: const Text('Forms'),
  //     body: const Text('Forms'),
  //     items: [
  //       // PaneItemHeader(header: const Text('Apps')),
  //       PaneItem(
  //         icon: const Icon(FluentIcons.add_friend),
  //         title: const Text('Patients'),
  //         body: PatientFormPage(
  //           patientBox: widget.patientBox,
  //           employeeBox: widget.employeeBox,
  //         ),
  //       ),
  //       PaneItem(
  //         icon: const Icon(FluentIcons.c_r_m_services),
  //         title: const Text('Employees'),
  //         body: EmployeeFormPage(),
  //       ),
  //     ],
  //   ),
  //   PaneItem(
  //     icon: const Icon(FluentIcons.home),
  //     title: const Text('Forms'),
  //     body: const PatientFormPage(),
  //   ),
  //   PaneItemSeparator(),
  //   PaneItem(
  //     icon: const Icon(FluentIcons.list),
  //     title: const Text('Patient List'),
  //     body: const PatientListPage(),
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        // backgroundColor: Colors.teal.lighter,
        title: Text('Shanthi Ayurveda Ashram Patient Record Application'),
      ),
      pane: NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: displayMode,
        items: [
          PaneItemExpander(
            initiallyExpanded: true,
            icon: const Icon(FluentIcons.account_management),
            title: const Text('Forms'),
            body: const Text('Forms'),
            items: [
              // PaneItemHeader(header: const Text('Apps')),
              PaneItem(
                icon: const Icon(FluentIcons.add_friend),
                title: const Text('Patients'),
                body: PatientFormPage(
                  patientBox: widget.patientBox,
                ),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.c_r_m_services),
                title: const Text('Employees'),
                body: EmployeeFormPage(
                  employeeBox: widget.employeeBox,
                ),
              ),
            ],
          ),
          // PaneItem(
          //   icon: const Icon(FluentIcons.home),
          //   title: const Text('Forms'),
          //   body: PatientFormPage(
          //     patientBox: widget.patientBox,
          //     employeeBox: widget.employeeBox,
          //   ),
          // ),
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.list),
            title: const Text('Patient List'),
            body: PatientListPage(
              patientBox: widget.patientBox,
            ),
          ),
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.list),
            title: const Text('Employee List'),
            body: EmployeeListPage(
              employeesBox: widget.employeeBox,
            ),
          ),
        ],
      ),
    );
  }
}
