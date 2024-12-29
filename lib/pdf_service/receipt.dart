import 'dart:io';
// import 'package:fluent_ui/fluent_ui.dart';
import 'package:clinic_management_new/pdf_service/number_serice.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../database/patient.dart';

class ReceiptPDFService {
  static Future<void> generatePatientPDF(Patient patient) async {
    final pdf = pw.Document();

    // Add page to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        //orientation: pw.PageOrientation.landscape,
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
                  pw.SizedBox(height: 10),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now()))
                      ]),
                  _buildHeader2(),
                  _buildPatientInfo(patient),
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
            pw.Text('Ariyoor Venga,Kottoppadom,Mannarkkad,Palakkad',
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

  static pw.Widget _buildHeader2() {
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
          pw.SizedBox(height: 10),
          pw.Text(
            'Receipt',
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
    String title;
    if (patient.gender.toLowerCase() == 'male') {
      title = 'Mr';
    } else if (patient.gender.toLowerCase() == 'female') {
      title = 'Mrs';
    } else {
      title = 'Mx'; // Neutral title for other genders
    }
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
          pw.SizedBox(height: 30),
          pw.Text(
            style: const pw.TextStyle(
                fontSize: 13, height: 12, lineSpacing: 5, wordSpacing: 1.5),
            'Received Rs. ${patient.totalBill} ( ${NumberToWords.convertToWords(patient.totalBill.toInt())} only ) from  $title ${patient.name},  being the ayurveda  treatment  charges  and  stay etc. for ${patient.days} days in Shanthi Ayurveda Ashram ,Ariyoor Venga,Kottoppadom,Mannarkkad,Palakkad,Kerala-678583',
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
        ],
      ),
    );
  }

  // static pw.Widget _buildSection(String title, String children) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       if (title.isNotEmpty) ...[
  //         pw.Text(
  //           title,
  //           style: pw.TextStyle(
  //             fontSize: 18,
  //             fontWeight: pw.FontWeight.bold,
  //           ),
  //         ),
  //         pw.SizedBox(height: 10),
  //       ],
  //       pw.Text(

  //       ),
  //     ],
  //   );
  // }
}
