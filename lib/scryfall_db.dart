import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:scryfall_db/utils.dart';

import 'models/card.dart';

const _fileName = 'all-cards-20231025091942.json';

Future<File?> _getCachedCardsFile() async {
  final file = File(_fileName,);
  if (await file.exists()) {
    print('Found $_fileName',);
    return file;
  }
  print('File $_fileName not found',);
  return null;
}

Future<File> _createCacheFile() async {
  final client = http.Client();
  final uri = Uri.parse(
    'https://data.scryfall.io/all-cards/$_fileName',
  );
  final request = http.Request(
    'GET', uri,
  );
  print('Downloading $_fileName ...',);
  final streamedResponse = await client.send(request,);
  var file = File(_fileName,);
  if (!await file.exists()) {
    file = await file.create();
  }
  final writer = file.openWrite();
  int downloadedBytes = 0;
  await streamedResponse.stream.map(
    (bytes) {
      downloadedBytes += bytes.length;
      print('Downloaded Bytes: $downloadedBytes bytes',);
      return bytes;
    },
  ).pipe(writer,);
  await writer.flush();
  await writer.close();
  print('Download completed: $downloadedBytes bytes',);
  return file;
}

Stream<Card> fetchCards() async* {
  print('Fetching Cards...',);
  File? file = await _getCachedCardsFile();
  file ??= await _createCacheFile();

  yield* file.openRead().transform(utf8.decoder,).transform(
    const LineSplitter(),
  ).asyncMap(
    (line) async {
      line = line.trim();
      if (line.endsWith(',',)) {
        try {
          final decoded = await jsonDecodeAsync(
            line.substring(0, line.length - 1,),
          );
          return Card.fromMap(decoded,);
        } catch (_) {}
      }
      return null;
    },
  ).where((card) => card != null,).cast<Card>();
}