import 'package:clinic_management_new/database/employee.dart';
import 'package:clinic_management_new/database/patient.dart';

import 'package:clinic_management_new/pages/test.dart';

import 'package:fluent_ui/fluent_ui.dart';

import 'package:hive_flutter/adapters.dart';

// Future<void> initHive() async {
//   if (Platform.isWindows) {
//     final appDocDir = await getApplicationDocumentsDirectory();
//     Hive.init(appDocDir.path);
//     await Hive.openBox("patients4_3");
//   } else {
//     await Hive.initFlutter();
//     await Hive.openBox("patients4_3");
//   }

//   // Register the generated adapter
//   Hive.registerAdapter(PatientAdapter());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initHive();
  await Hive.initFlutter();

  // Register the adapter
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(CaseSheetEntryAdapter());
  Hive.registerAdapter(BillEntryAdapter());
  Hive.registerAdapter(MedicationsEntryAdapter());
  Hive.registerAdapter(ConsumablesEntryAdapter());
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(DutySheetEntryAdapter());

  // Open the box
  final patientBox = await Hive.openBox<Patient>('patients4_3');
  final employeeBox = await Hive.openBox<Employee>('employees_1_1');

  // runApp(MyApp());
  runApp(MyApp(patientBox: patientBox, employeeBox: employeeBox));
}

class MyApp extends StatefulWidget {
  final Box patientBox;
  final Box employeeBox;

  const MyApp({super.key, required this.patientBox, required this.employeeBox});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Shanti Ayureda Ashram',
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
        // Light theme custom colors
        scaffoldBackgroundColor: Colors.teal.light,
        cardColor: Colors.grey[10],
      ),

      home: MyWidget(
        patientBox: widget.patientBox,
        employeeBox: widget.employeeBox,
      ),
      // home: PatientListPage(),
    );
  }
}
