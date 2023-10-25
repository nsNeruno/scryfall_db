import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:scryfall_db/models/card.dart';
import 'package:scryfall_db/scryfall_db.dart' as scryfall_db;

void main(List<String> arguments) {
  
  final excel = Excel.createExcel();
  final defaultSheetName = excel.getDefaultSheet();
  final sheet = excel.sheets[defaultSheetName!]!;
  sheet.appendRow(
    [
      'ID', 'Name', 'USD', 'USD (Foil)', 'USD (Etched)', 'EUR', 'EUR (Foil)', 'Tix',
    ],
  );
  late final StreamSubscription<Card> cardListener;
  cardListener = scryfall_db.fetchCards().listen(
    (card) {
      final prices = card.prices;
      print(
        'Writing Card "${card.name}" (${card.id})...',
      );
      sheet.appendRow(
        [
          card.id,
          card.name,
          prices?.usd,
          prices?.usdFoil,
          prices?.usdEtched,
          prices?.eur,
          prices?.eurFoil,
          prices?.tix,
        ],
      );
    },
    onDone: () {
      cardListener.cancel();
      print('Saving file...',);
      const fileName = 'all-cards-prices.xlsx';
      final excelBytes = excel.save(fileName: fileName,);
      if (excelBytes == null) {
        print('Failed to save file: Null Bytes',);
        return;
      }
      File(fileName,).writeAsBytes(excelBytes,).then(
        (file) {
          print('File saved at ${file.path}',);
        },
      );
    },
    onError: (err, stackTrace,) {
      print(err,);
      print(stackTrace,);
      cardListener.cancel();
    },
  );
}