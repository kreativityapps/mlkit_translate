import 'package:flutter/material.dart';
import 'package:mlkit_translate/mlkit_translate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<String>(
                  future: MlkitTranslate.translateText(
                    source: 'en',
                    text: 'hello',
                    target: 'es',
                  ),
                  builder: (context, snapshot) =>
                      Text(snapshot.data ?? 'Loading...'),
                ),
                RaisedButton(
                  child: Text('Preload Spanish'),
                  onPressed: () {
                    MlkitTranslate.downloadModel('es');
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
