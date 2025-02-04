// lib/services/pdf_service.dart
import 'dart:io';
// import 'package:fluent_ui/fluent_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../database/patient.dart';

class DischarSummaryPDFService {
  static Future<void> generatePatientPDF(Patient patient) async {
    final pdf = pw.Document();

    final List<List<Object>> caseSheetData = [
      // Header row
    ];
    if (patient.medicationsEntry != null &&
        patient.medicationsEntry!.isNotEmpty) {
      caseSheetData.addAll(
        patient.medicationsEntry!
            .map((entry) => [
                  entry.name ?? '',
                  entry.quantity ?? '',
                ])
            .toList(),
      );
    }
    // Add page to the PDF

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin:
            pw.EdgeInsets.zero, // No margin for the page to accommodate border
        build: (pw.Context context) => [
          pw.Container(
            margin: const pw.EdgeInsets.all(16), // Margin inside the border
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                  color: PdfColors.black, width: 2), // Fixed border
            ),
            padding: const pw.EdgeInsets.all(16), // Padding inside the border
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPatientInfo(patient),
                    _buildAdmissionInfo(patient),
                  ],
                ),
                pw.SizedBox(height: 20),
                _buildMedicalInfo(patient),
                pw.SizedBox(height: 10),
                pw.Text("Case History",
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                pw.Text(patient.historyOfPresentComplaints),
                pw.SizedBox(height: 10),
                pw.Text("Treatments given",
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                pw.Text(patient.treatment ?? ""),
                pw.SizedBox(height: 10),
                pw.Text("Internal Medicines",
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    )),
                _buildTreatmentInfo(patient),
                pw.SizedBox(height: 20),
                pw.Text("Condition at the time of Discharge",
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                _buildInfoRow("Bowel", patient.bowel),
                _buildInfoRow("Appetite", patient.apetite),
                _buildInfoRow("Sleep", patient.sleep),
                _buildInfoRow("Blood Pressure", patient.bp),
                pw.SizedBox(height: 20),
                pw.Text("Advice on Discharge",
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                pw.Text(patient.adice ?? ""),
                pw.SizedBox(height: 20),
                pw.Text("Medications",
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                pw.Text(patient.otherMedication ?? "No other medications"),
                pw.SizedBox(height: 30),
                // pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text("Dr Nisha P\n\n Chief physician"),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
            ),
          ),
        ],
        footer: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 8, right: 16, bottom: 16),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          );
        },
      ),
    );

    // pdf.addPage(
    //   pw.MultiPage(
    //     pageFormat: PdfPageFormat.a4,
    //     margin: const pw.EdgeInsets.all(32),
    //     build: (pw.Context context) => [
    //       _buildHeader(),
    //       pw.SizedBox(height: 20),

    //       pw.Text("Condition at the time of Discharge",
    //           style: pw.TextStyle(
    //             fontSize: 15,
    //             fontWeight: pw.FontWeight.bold,
    //           )),
    //       pw.SizedBox(height: 10),
    //       _buildInfoRow("Bowel", patient.bowel),
    //       _buildInfoRow("Apeite", patient.apetite),
    //       _buildInfoRow("Sleep", patient.sleep),
    //       _buildInfoRow("Blood Pressure", patient.bp),
    //       pw.SizedBox(height: 20),
    //       pw.Text("Advice on Discharge",
    //           style: pw.TextStyle(
    //             fontSize: 15,
    //             fontWeight: pw.FontWeight.bold,
    //           )),
    //       pw.SizedBox(height: 10),
    //       pw.Text(patient.adice ?? ""),
    //       pw.SizedBox(height: 20),
    //       pw.Text("Medications",
    //           style: pw.TextStyle(
    //             fontSize: 15,
    //             fontWeight: pw.FontWeight.bold,
    //           )),
    //       pw.SizedBox(height: 10),
    //       pw.Text(patient.otherMedication ?? ""),
    //       // pw.SizedBox(height: 20),
    //       pw.Spacer(),
    //       pw.Row(
    //         mainAxisAlignment: pw.MainAxisAlignment.end,
    //         children: [
    //           pw.Text("Dr Nisha P\n\n Chief physician"),
    //         ],
    //       ),
    //       pw.SizedBox(height: 20)
    //     ],
    //   ),
    // );
    // Save the PDF
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'patient_${patient.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    final file = File('${directory.path}\\$fileName');
    await file.writeAsBytes(await pdf.save());

    // Open the PDF
    await OpenFile.open(file.path);
  }

  static pw.Widget _buildPatientInfo(Patient patient) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        _buildSection(
          'Personal Information',
          [
            _buildInfoRow('Name', patient.name),
            _buildInfoRow('Age', '${patient.age} years'),
            _buildInfoRow('Gender', patient.gender),
            _buildInfoRow('Address', patient.address),
          ],
        ),
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
          // _buildInfoRow('OP No', patient.opNo),
          _buildInfoRow('Room No', patient.roomNo),
          _buildInfoRow('Date of Admission',
              DateFormat('dd/MM/yyyy').format(patient.dateOfAdmission)),
          _buildInfoRow('Date of Discharge',
              DateFormat('dd/MM/yyyy').format(patient.dateOfDischarge)),
          // _buildInfoRow('Diagnosis', patient.diagnosis),
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
        ]),
      ],
    );
  }

  static pw.Widget _buildTreatmentInfo(Patient patient) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        // First check if medicationsEntry is null or empty
        if (patient.medicationsEntry != null &&
            patient.medicationsEntry!.isNotEmpty)
          ...patient.medicationsEntry!
              .map((item) => pw.Text(item?.name ?? "No medication name")),
        if (patient.medicationsEntry == null ||
            patient.medicationsEntry!.isEmpty)
          pw.Text("No medications recorded"),
      ],
    );
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        ...children,
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: 1.0,
          ),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Shanthi Ayurveda Ashram',
                style: pw.TextStyle(
                  color: const PdfColor(0, .5, 0),
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
            pw.Text(
                'Ariyoor Venga,Kottoppadom,Mannarkkad,Palakkad,Kerala-678583',
                textAlign: pw.TextAlign.center),
          ]),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              pw.Row(
                children: [
                  pw.Text("www.shanthiayurvedam.in"),
                  pw.SizedBox(width: 50),
                  pw.Text("email: shanthiayurvedam@gmail.com"),
                ],
              ),
            ],
          ),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
            pw.Text("\nPh : +91 9495172295 | 8075749619"),
          ]),
          pw.SizedBox(height: 10),
        ],
      ),
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
          pw.Text(value)
          // pw.Expanded(
          //   child: pw.Text(value),
          // ),
        ],
      ),
    );
  }
}

// Update the PatientListPage to add PDF generation button
// Add this button in the actions row of the Expander widget:

