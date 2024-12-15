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
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: displayMode,
        items: items,
      ),
    );
  }
}
