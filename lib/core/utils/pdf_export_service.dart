import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/home/data/models/account_model.dart';
import '../../features/home/data/models/transaction_model.dart';

class PdfExportService {
  static Future<void> exportTransactionHistory(
    Account? account,
    List<TransactionModel> transactions,
    String filter,
  ) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(symbol: '\$');

    double checkIn = 0;
    double checkOut = 0;

    for (var t in transactions) {
      if (t.type == 'INCOME') {
        checkIn += t.amount;
      } else {
        checkOut += t.amount;
      }
    }

    final balance = checkIn - checkOut;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Finance Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateFormat('MMM dd, yyyy').format(DateTime.now()), style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Account: ${account != null ? account.name : 'All Accounts'}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Filter Applied: $filter'),
                  pw.SizedBox(height: 10),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Check-In:', style: const pw.TextStyle(color: PdfColors.green)),
                      pw.Text(formatter.format(checkIn), style: const pw.TextStyle(color: PdfColors.green)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Check-Out:', style: const pw.TextStyle(color: PdfColors.red)),
                      pw.Text(formatter.format(checkOut), style: const pw.TextStyle(color: PdfColors.red)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Net Balance:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(formatter.format(balance), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text('Transaction History', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Date', 'Title', 'Type', 'Amount'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
              data: transactions.map((t) {
                return [
                  DateFormat('yyyy-MM-dd').format(t.createdAt),
                  t.title,
                  t.type,
                  '${t.type == 'INCOME' ? '+' : '-'}${formatter.format(t.amount)}',
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'finance_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
