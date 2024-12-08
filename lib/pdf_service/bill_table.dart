import 'dart:io';
// import 'package:fluent_ui/fluent_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../database/patient.dart';

class BillTablePDFService {
  static Future<void> generatePatientPDF(Patient patient) async {
    final pdf = pw.Document();
    // final dateFormat = DateFormat('dd-MM-yyyy');

    // Create patient info section
    // final patientInfo = [
    //   ['Name:', patient.name],
    //   ['Date:', patient.age.toString()],
    // ];

    // Create case sheet table data
    final List<List<Object>> billTableSheetData = [
      ['Sl no.', 'Particulars', 'Rate', 'Qty', 'Amount'], // Header row
    ];

    if (patient.billRegister != null && patient.billRegister!.isNotEmpty) {
      // Prepare data rows
      final dataRows = patient.billRegister!
          .asMap()
          .map((index, entry) => MapEntry(index, [
                index + 1,
                entry.particulars ?? '',
                entry.quantity ?? '',
                entry.rate ?? '',
                entry.price ?? '0',
              ]))
          .values
          .toList();

      // Calculate total with explicit type conversion and error handling
      double total = 0;
      try {
        total = patient.billRegister!
            .map((entry) => double.parse((entry.price ?? '0').toString()))
            .reduce((a, b) => a + b);
      } catch (e) {
        print('Error calculating total: $e');
      }

      // Add data rows
      billTableSheetData.addAll(dataRows);

      // Add total row
      billTableSheetData.add([
        '',
        'Total',
        '',
        '',
        total.toStringAsFixed(2),
      ]);
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
                  pw.Row(children: [pw.Text("Name : ${patient.name}")]),
                  pw.SizedBox(height: 10),
                  pw.Row(children: [pw.Text("Bill No : ${patient.billNo}")]),
                  pw.SizedBox(height: 10),
                  pw.Row(children: [
                    pw.Text(
                        "Date : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}")
                  ]),
                  pw.SizedBox(height: 30),
                  pw.Table.fromTextArray(
                    context: context,
                    data: billTableSheetData,
                    border: pw.TableBorder.all(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      // color: PdfColors.white,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                        // color: PdfColors.blue600,
                        ),
                    cellHeight: 30,
                    cellStyle: const pw.TextStyle(fontSize: 10),
                    cellAlignment: pw.Alignment.centerLeft,
                    // columnWidths: {
                    //   0: pw.FlexColumnWidth(1), // Date
                    //   1: pw.FlexColumnWidth(2), // Symptoms
                    //   2: pw.FlexColumnWidth(2), // Treatments
                    //   3: pw.FlexColumnWidth(1),
                    //   4: pw.FlexColumnWidth(1)
                    //   // BP
                    // },
                    cellAlignments: {
                      0: pw.Alignment.center,
                      1: pw.Alignment.centerLeft,
                      2: pw.Alignment.centerLeft,
                      3: pw.Alignment.center,
                      4: pw.Alignment.center
                    },
                  ),
                  pw.SizedBox(height: 20),
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
            pw.Text("\nPh : +91 9846889793 | 8075749619"),
          ]),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }
}
