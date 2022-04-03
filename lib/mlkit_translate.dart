import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MlkitTranslate {
  static const MethodChannel _channel = const MethodChannel('mlkit_translate');

  static Future<String> detectLanguage({
    required String text,
  }) async {
    try {
      return await _channel.invokeMethod(
        'detectLanguage',
        {
          'text': text,
        },
      );
    } on Exception catch (e) {
      debugPrint('$e');
      return text;
    }
  }

  static Future<String> translateText({
    required String target,
    required String text,
    required String source,
  }) async {
    try {
      return await _channel.invokeMethod(
        'translate',
        {
          'source': source,
          'target': target,
          'text': text,
        },
      );
    } on Exception catch (e) {
      debugPrint('$e');
      return text;
    }
  }

  static Future<List<String>> getDownloadedModels() async {
    final result = await _channel.invokeMethod('getDownloadedModels');
    var _languages = <String>[];

    for (dynamic data in result) {
      _languages.add(data.toString());
    }
    return _languages;
  }

  static Future<void> deleteDownloadedModel(String model) async {
    try {
      await _channel.invokeMethod(
        'deleteDownloadedModel',
        {
          'model': model,
        },
      );
    } on Exception catch (e) {
      debugPrint('$e');
    }
  }

  static Future<void> downloadModel(String model) async {
    try {
      await _channel.invokeMethod(
        'downloadModel',
        {
          'model': model,
        },
      );
    } on Exception catch (e) {
      debugPrint('$e');
    }
  }

  // static Future<void> close() async {
  //   try {
  //     await _channel.invokeMethod('closeLanguageTranslator');
  //   } on Exception catch (e) {
  //     debugPrint('$e');
  //   }
  // }
}
