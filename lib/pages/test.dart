import 'package:clinic_management_new/pages/details_ip_new.dart';
import 'package:clinic_management_new/patient_details.dart';
import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart';

class ThemeConfig extends ChangeNotifier {
  bool isDark = false;

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}

class MyWidget extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;
  const MyWidget({super.key, required this.isDark, required this.toggleTheme});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  PaneDisplayMode displayMode = PaneDisplayMode.open;
  int topIndex = 0;
  // bool isDark = false;

  List<NavigationPaneItem> items = [
    PaneItem(
      icon: const Icon(FluentIcons.home),
      title: const Text('Forms'),
      body: const PatientFormPage(),
    ),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.list),
      title: const Text('Patient List'),
      body: const PatientListPage(),
    ),
    // PaneItemSeparator(),
    // PaneItem(
    //   icon: const Icon(FluentIcons.list),
    //   title: const Text('Patient List'),
    //   body: PatientListPage(),
    // ),
    // PaneItemExpander(
    //   icon: const Icon(FluentIcons.account_management),
    //   title: const Text('Patients'),
    //   initiallyExpanded: true,
    //   body: const _NavigationBodyItem(
    //     header: 'PaneItemExpander',
    //   ),
    //   items: [
    //     // PaneItemHeader(header: const Text('Apps')),
    //     PaneItem(
    //       icon: const Icon(FluentIcons.contact),
    //       title: const Text('Active'),
    //       body: ActiePatientListPage(),
    //     ),
    //     PaneItem(
    //       icon: const Icon(FluentIcons.employee_self_service),
    //       title: const Text('Discharged'),
    //       body: DischargedPatientListPage(),
    //     ),
    //   ],
    // ),
    // PaneItemWidgetAdapter(
    //   child: Builder(builder: (context) {
    // Build the widget depending on the current display mode.
    //
    // This already returns the resolved auto display mode.
    //     if (NavigationView.of(context).displayMode == PaneDisplayMode.compact) {
    //       return const FlutterLogo();
    //     }
    //     return ConstrainedBox(
    //       // Constraints are required for top display mode, otherwise the Row will
    //       // expand to the available space.
    //       constraints: const BoxConstraints(maxWidth: 200.0),
    //       child: const Row(children: [
    //         FlutterLogo(),
    //         SizedBox(width: 6.0),
    //         Text('This is a custom widget'),
    //       ]),
    //     );
    //   }),
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        // backgroundColor: Colors.teal.lighter,
        title: Text('Shanthi Ayurveda Ashram Patient Record Application'),
      ),
      pane: NavigationPane(
        selected: topIndex,
        // onChanged: (index) {
        //   // Do anything you want to do, such as:
        //   if (index == topIndex) {
        //     if (displayMode == PaneDisplayMode.open) {
        //       setState(() => this.displayMode = PaneDisplayMode.compact);
        //     } else if (displayMode == PaneDisplayMode.compact) {
        //       setState(() => this.displayMode = PaneDisplayMode.open);
        //     }
        //   }
        // },
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: displayMode,
        items: items,
        // footerItems: [
        //   PaneItem(
        //     icon: const Icon(FluentIcons.settings),
        //     title: const Text('Settings'),
        //     body: const _NavigationBodyItem(),
        //   ),
        //   PaneItemAction(
        //     icon: const Icon(FluentIcons.add),
        //     title: const Text('Add New Item'),
        //     onTap: () {
        //       // Your Logic to Add New `NavigationPaneItem`
        //       items.add(
        //         PaneItem(
        //           icon: const Icon(FluentIcons.new_folder),
        //           title: const Text('New Item'),
        //           body: const Center(
        //             child: Text(
        //               'This is a newly added Item',
        //             ),
        //           ),
        //         ),
        //       );
        //       setState(() {});
        //     },
        //   ),
        // ],
      ),
    );
  }
}
