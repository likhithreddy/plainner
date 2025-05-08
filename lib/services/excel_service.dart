import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;
import '../models/plan.dart';

class ExcelService {
  static Future<void> savePlanAsExcel(
      String planName, List<PlanEntry> entries) async {
    final excel = Excel.createExcel();
    final sheet = excel[planName];

    // Headers
    sheet.appendRow(['Date', 'Title', 'Description']);

    // Content
    for (var entry in entries) {
      sheet.appendRow([
        entry.date.toIso8601String().split('T')[0],
        entry.title,
        entry.description
      ]);
    }

    final bytes = excel.encode()!;
    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "$planName.xlsx")
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
