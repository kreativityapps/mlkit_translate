import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MlkitTranslate {
  static const MethodChannel _channel = const MethodChannel('mlkit_translate');

  static Future<String> translateText({
    @required String target,
    @required String text,
    String source,
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
}
