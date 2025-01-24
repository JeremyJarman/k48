import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

Future<List<List<dynamic>>> loadCsv(String path) async {
  final rawData = await rootBundle.loadString(path);
  List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(rawData);
  // Skip the first row (column headings)
  return rowsAsListOfValues.skip(1).toList();
}