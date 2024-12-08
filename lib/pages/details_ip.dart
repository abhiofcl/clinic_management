// import 'package:clinic_management_new/database/firestore_database_helper.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PatientFormPage extends StatelessWidget {
  const PatientFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Container(
        // color: FluentTheme.of(context).scaffolvvdBackgroundColor,
        child: const PatientInputForm(),
      ),
    );
  }
}

class PatientInputForm extends StatefulWidget {
  const PatientInputForm({super.key});

  @override
  _PatientInputFormState createState() => _PatientInputFormState();
}

class _PatientInputFormState extends State<PatientInputForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text(
            'Patient Information Form (Incase of foreigner fill the additional form also)'),
      ),
      content: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InfoLabel(
              label: 'Name',
              child: TextFormBox(
                placeholder: 'Enter full name',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Age',
              child: NumberBox(
                placeholder: 'Enter age',
                value: 1,
                onChanged: (value) {},
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Occupation',
              child: TextFormBox(
                placeholder: 'Enter occupation',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Address',
              child: TextFormBox(
                placeholder: 'Enter address',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Nationality',
              child: TextFormBox(
                placeholder: 'Enter nationality',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Marital Status',
              child: ComboBox<String>(
                placeholder: const Text('Select marital status'),
                items: ['Single', 'Married', 'Divorced', 'Widowed']
                    .map((e) => ComboBoxItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Gender',
              child: ComboBox<String>(
                placeholder: const Text('Select gender'),
                items: ['Male', 'Female', 'Other']
                    .map((e) => ComboBoxItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'IP No',
              child: TextFormBox(
                placeholder: 'Enter IP number',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'OP No',
              child: TextFormBox(
                placeholder: 'Enter OP number',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Room No',
              child: TextFormBox(
                placeholder: 'Enter room number',
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Date of Admission',
              child: DatePicker(
                selected: DateTime.now(),
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Date of Discharge',
              child: DatePicker(
                selected: DateTime.now(),
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: 'Diagnosis',
              child: TextFormBox(
                placeholder: 'Enter diagnosis',
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 20),
            Button(
              child: const Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process data
                  // getStarted_addData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
