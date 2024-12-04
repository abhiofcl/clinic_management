import 'dart:io';
// import 'package:fluent_ui/fluent_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../database/patient.dart';

class DailyCaseSheetPDFService {
  static Future<void> generatePatientPDF(Patient patient) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy');

    // Create patient info section
    final patientInfo = [
      ['Name:', patient.name],
      // ['IP No:', patient.ipNo],
      ['Age:', patient.age.toString()],
      // ['Gender:', patient.gender],
      // ['Date of Admission:', dateFormat.format(patient.dateOfAdmission)],
      // ['Diagnosis:', patient.diagnosis],
    ];

    // Create case sheet table data
    final List<List<String>> caseSheetData = [
      ['Date', 'Symptoms', 'Treatments', 'BP'], // Header row
    ];

    // Add case sheet entries if they exist
    if (patient.caseSheets != null && patient.caseSheets!.isNotEmpty) {
      caseSheetData.addAll(
        patient.caseSheets!
            .map((entry) => [
                  dateFormat.format(entry.date ?? DateTime.now()),
                  entry.symptoms ?? '',
                  entry.treatments ?? '',
                  entry.bp ?? '',
                ])
            .toList(),
      );
    }
    // Add page to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.black,
                width: 2.0,
              ),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                children: [
                  _buildHeader(),
                  pw.SizedBox(height: 30),
                  // _buildHeader2(),
                  // _buildPatientInfo(patient),
                  pw.Row(children: [pw.Text("Name : ${patient.name}")]),
                  pw.SizedBox(height: 10),
                  pw.Row(children: [pw.Text("Age : ${patient.age}")]),

                  pw.SizedBox(height: 10),

                  pw.Table.fromTextArray(
                    context: context,
                    data: caseSheetData,
                    border: pw.TableBorder.all(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      // color: PdfColors.white,
                    ),
                    headerDecoration: pw.BoxDecoration(
                        // color: PdfColors.blue600,
                        ),
                    cellHeight: 20,
                    cellStyle: pw.TextStyle(fontSize: 10),
                    cellAlignment: pw.Alignment.centerLeft,
                    columnWidths: {
                      0: pw.FlexColumnWidth(1), // Date
                      1: pw.FlexColumnWidth(2), // Symptoms
                      2: pw.FlexColumnWidth(2), // Treatments
                      3: pw.FlexColumnWidth(1), // BP
                    },
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.centerLeft,
                      2: pw.Alignment.centerLeft,
                      3: pw.Alignment.center,
                    },
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Name And Signature"),
                      pw.Text("Dr Nisha P\n Chief physician")
                    ],
                  ),
                  pw.SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Save the PDF
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'patient_admission_note_${patient.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    final file = File('${directory.path}\\$fileName');
    await file.writeAsBytes(await pdf.save());

    // Open the PDF
    await OpenFile.open(file.path);
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
                  // color: const PdfColor(0, .5, 0),
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
            pw.Text('Ariyoor,Venga,Kottoppadom,Mannarkkad,Palakkad',
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
            pw.Text("\nPh : +91 9846889793 | 8075749619"),
          ]),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  static pw.Widget _buildHeader2() {
    return pw.Container(
      decoration: pw.BoxDecoration(
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
          pw.SizedBox(height: 10),
          pw.Text(
            'Patient Admission Note',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfo(Patient patient) {
    return pw.Container(
      decoration: pw.BoxDecoration(
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
          pw.SizedBox(height: 20),
          _buildSection('', [
            pw.Text(
              'Mr/Mrs ${patient.name}, aged ${patient.age} suffer from ${patient.diagnosis} was admitted and treated from ${DateFormat('dd/MM/yyyy').format(patient.dateOfAdmission)} to ${DateFormat('dd/MM/yyyy').format(patient.dateOfDischarge)} in Shanthi Ayurveda Ashram,Kottopadam,Mannarkkad,Palakkad,Kerala',
            ),
            pw.SizedBox(height: 40),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Dr.Nisha P'),
                    pw.Text('Chief physician'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
          ]),
        ],
      ),
    );
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
        ],
        ...children,
      ],
    );
  }
}
