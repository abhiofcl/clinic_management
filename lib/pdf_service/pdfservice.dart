// lib/services/pdf_service.dart
import 'dart:io';
// import 'package:fluent_ui/fluent_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../database/patient.dart';

class PDFService {
  static Future<void> generatePatientPDF(Patient patient) async {
    final pdf = pw.Document();

    // Add page to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          _buildHeader(),
          _buildPatientInfo(patient),
          _buildAdmissionInfo(patient),
          _buildMedicalInfo(patient),
          // _buildTreatmentInfo(patient),
          // _buildBillInfo(patient),
        ],
      ),
    );

    // Save the PDF
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'patient_${patient.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    final file = File('${directory.path}\\$fileName');
    await file.writeAsBytes(await pdf.save());

    // Open the PDF
    await OpenFile.open(file.path);
  }

  static pw.Widget _buildHeader() {
    return pw.Header(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Medical Record',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfo(Patient patient) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        _buildSection('Personal Information', [
          _buildInfoRow('Name', patient.name),
          _buildInfoRow('Age', '${patient.age} years'),
          _buildInfoRow('Gender', patient.gender),
          _buildInfoRow('Marital Status', patient.maritalStatus),
          _buildInfoRow('Nationality', patient.nationality),
          _buildInfoRow('Occupation', patient.occupation),
          _buildInfoRow('Address', patient.address),
        ]),
      ],
    );
  }

  static pw.Widget _buildAdmissionInfo(Patient patient) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        _buildSection('Admission Information', [
          _buildInfoRow('IP No', patient.ipNo),
          _buildInfoRow('OP No', patient.opNo),
          _buildInfoRow('Room No', patient.roomNo),
          _buildInfoRow('Date of Admission',
              DateFormat('dd/MM/yyyy').format(patient.dateOfAdmission)),
          _buildInfoRow('Date of Discharge',
              DateFormat('dd/MM/yyyy').format(patient.dateOfDischarge)),
          _buildInfoRow('Diagnosis', patient.diagnosis),
        ]),
      ],
    );
  }

  static pw.Widget _buildMedicalInfo(Patient patient) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        _buildSection('Medical Information', [
          _buildInfoRow('Diagnosis', patient.diagnosis),
          _buildInfoRow('History', patient.history),
          _buildInfoRow('Heart Rate', patient.heartRate),
          _buildInfoRow('Weight', patient.weight),
          _buildInfoRow('Height', patient.height),
          _buildInfoRow('Diet', patient.diet),
          _buildInfoRow('Apetite', patient.apetite),
          _buildInfoRow('Bowel', patient.bowel),
          _buildInfoRow('Sleep', patient.sleep),
          _buildInfoRow('Urine', patient.urine),
        ]),
      ],
    );
  }

  // static pw.Widget _buildTreatmentInfo(Patient patient) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       pw.SizedBox(height: 20),
  //       _buildSection('Treatment Information', [
  //         _buildInfoRow('Treatment provided', patient.treatment),
  //       ]),
  //     ],
  //   );
  // }

  // static pw.Widget _buildBillInfo(Patient patient) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       pw.SizedBox(height: 20),
  //       _buildSection('Bill Information', [
  //         _buildInfoRow('Total Bill', patient.bill),
  //       ]),
  //     ],
  //   );
  // }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        ...children,
        pw.SizedBox(height: 10),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }
}

// Update the PatientListPage to add PDF generation button
// Add this button in the actions row of the Expander widget:

