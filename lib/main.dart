import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:clinic_management_new/database/patient.dart';

import 'package:clinic_management_new/pages/test.dart';

import 'package:fluent_ui/fluent_ui.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive() async {
  if (Platform.isWindows) {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    await Hive.openBox("patients4_3");
  } else {
    await Hive.initFlutter();
    await Hive.openBox("patients4_3");
  }

  // Register the generated adapter
  Hive.registerAdapter(PatientAdapter());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initHive();
  await Hive.initFlutter();

  // Register the adapter
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(CaseSheetEntryAdapter());
  Hive.registerAdapter(BillEntryAdapter());
  Hive.registerAdapter(MedicationsEntryAdapter());

  // Open the box
  await Hive.openBox<Patient>('patients4_3');

  // runApp(MyApp());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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
      // Define dark theme settings
      // darkTheme: FluentThemeData(
      //   brightness: Brightness.dark,
      //   accentColor: Colors.blue,
      //   visualDensity: VisualDensity.standard,
      //   focusTheme: FocusThemeData(
      //     glowFactor: is10footScreen(context) ? 2.0 : 0.0,
      //   ),
      //   // Dark theme custom colors
      //   scaffoldBackgroundColor: Colors.grey[180],
      //   cardColor: Colors.grey[160],
      // ),
      home: MyWidget(isDark: isDark, toggleTheme: toggleTheme),
      // home: PatientListPage(),
    );
  }
}
