import 'dart:async';
import 'dart:io';

import 'package:scryfall_db/models/card.dart';
import 'package:scryfall_db/scryfall_db.dart' as scryfall_db;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

// void main(List<String> arguments) {
  // 
  // final excel = Excel.createExcel();
  // final defaultSheetName = excel.getDefaultSheet();
  // const headers = [
  //   'ID', 'Name', 'USD', 'USD (Foil)', 'USD (Etched)', 'EUR', 'EUR (Foil)', 'Tix',
  // ];
  // final sheet = excel.sheets[defaultSheetName!]!;
  // sheet.appendRow(headers,);
  // late final StreamSubscription<Card> cardListener;
  // cardListener = scryfall_db.fetchCards().listen(
  //   (card) {
  //     final prices = card.prices;
  //     sheet.appendRow(
  //       [
  //         card.id,
  //         card.name,
  //         prices?.usd,
  //         prices?.usdFoil,
  //         prices?.usdEtched,
  //         prices?.eur,
  //         prices?.eurFoil,
  //         prices?.tix,
  //       ],
  //     );
  //   },
  //   onDone: () {
  //     cardListener.cancel();
  //     print('Saving file...',);
  //     const fileName = 'all-cards-prices.xlsx';
  //     final excelBytes = excel.save(fileName: fileName,);
  //     if (excelBytes == null) {
  //       print('Failed to save file: Null Bytes',);
  //       return;
  //     }
  //     File(fileName,).writeAsBytes(excelBytes,).then(
  //       (file) {
  //         print('File saved at ${file.path}',);
  //       },
  //     );
  //   },
  //   onError: (err, stackTrace,) {
  //     print(err,);
  //     print(stackTrace,);
  //     cardListener.cancel();
  //   },
  // );
// }

void main(List<String> arguments) async {
  final workbook = Workbook();
  final sheet = workbook.worksheets[0];
  const headers = [
    'ID', 'Name', 'USD', 'USD (Foil)', 'USD (Etched)', 'EUR', 'EUR (Foil)', 'Tix',
  ];
  for (int i = 0; i < headers.length; i++) {
    sheet.getRangeByIndex(1, 1 + i,).setText(headers[i],);
  }
  late final StreamSubscription<Card> cardListener;
  int row = 2;
  cardListener = scryfall_db.fetchCards().listen(
    (card) {
      final prices = card.prices;
      final id = card.id;
      final cardName = card.name;
      sheet.getRangeByIndex(row, 1,).setText(id,);
      final cardMarketUrl = card.purchaseUris?.cardMarket;
      if (cardMarketUrl != null) {
        sheet.hyperlinks.add(
          sheet.getRangeByIndex(row, 2,),
          HyperlinkType.url,
          cardMarketUrl.toString(),
          'Check out $cardName at CardMarket', cardName,
        );
      } else {
        sheet.getRangeByIndex(row, 2,).setText(cardName,);
      }

      final allPrices = [
        prices?.usd,
        prices?.usdFoil,
        prices?.usdEtched,
        prices?.eur,
        prices?.eurFoil,
        prices?.tix,
      ];

      for (int i = 0; i < allPrices.length; i++) {
        sheet.getRangeByIndex(row, 3 + i,).setNumber(allPrices[i]?.toDouble(),);
      }
      row++;
    },
    onDone: () async {
      cardListener.cancel();
      print('Saving file...',);
      const fileName = 'all-cards-prices.xlsx';
      final excelBytes = await workbook.save();
      print('Writing $excelBytes bytes of data into $fileName...',);
      var file = File(fileName,);
      if (!await file.exists()) {
        file = await file.create();
      }
      file = await file.writeAsBytes(excelBytes,);
      print('File saved at ${file.path}',);
      workbook.dispose();
    },
    onError: (err, stackTrace,) {
      print(err,);
      print(stackTrace,);
      cardListener.cancel();
      workbook.dispose();
    },
  );
}