import 'dart:convert';

import 'package:compute/compute.dart';

List<T>? asList<T>(dynamic object,) {
  if (object is List) {
    return object.whereType<T>().toList();
  }
  return null;
}

Map<String, dynamic>? asMap(dynamic object,) {
  if (object is Map<String, dynamic>) {
    return object;
  }
  return null;
}

T? asMapAndCast<T>(dynamic object, T Function(Map<String, dynamic> map,) caster,) {
  final map = asMap(object,);
  if (map != null) {
    return caster(map,);
  }
  return null;
}

dynamic _jsonDecodeBackground(String source,) {
  try {
    return jsonDecode(source,);
  } catch (_) {
    if (_ is JsonUnsupportedObjectError) {
      return {
        'type': _.runtimeType.toString(),
        'cause': _.cause?.toString(),
        'partialResult': _.partialResult,
        'unsupportedObject': _.unsupportedObject?.toString(),
      };
    }
    return null;
  }
}

Future<dynamic> jsonDecodeAsync(String source,) async {
  final result = await compute(_jsonDecodeBackground, source,);
  if (result is Map<String, dynamic>) {
    if (result['type'] == '$JsonUnsupportedObjectError') {
      throw result;
    }
  }
  return result;
}