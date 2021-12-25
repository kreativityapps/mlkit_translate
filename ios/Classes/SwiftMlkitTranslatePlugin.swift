import Flutter
import UIKit
import MLKitTranslate
import MLKitLanguageID

public class SwiftMlkitTranslatePlugin: NSObject, FlutterPlugin {
  let locale = Locale.current
  lazy var allLanguages = TranslateLanguage.allLanguages().sorted {
    return locale.localizedString(forLanguageCode: $0.rawValue)!
      < locale.localizedString(forLanguageCode: $1.rawValue)!
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mlkit_translate", binaryMessenger: registrar.messenger())
    let instance = SwiftMlkitTranslatePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
            case "translate":
                let args = call.arguments as? [String: Any]
                let source = args?["source"] as? String
                let target = args?["target"] as? String ?? "en"
                let text = args?["text"] as? String ?? ""

                if (source == nil) {
                    LanguageIdentification.languageIdentification(options: LanguageIdentificationOptions(confidenceThreshold: 0.0)).identifyLanguage(for: text) { (languageCode, error) in
                        if (error != nil) {
                            self.translateText(result: result, source: "en", target: target, text: text)
                        } else {
                            self.translateText(result: result, source: languageCode ?? "en", target: target, text: text)
                        }
                    }
                } else {
                    translateText(result: result, source: source!, target: target, text: text)
                }

                break;


            case "downloadModel":
                if let args = call.arguments as? [String: Any],
                    let model = args["model"] as? String {
                    ModelManager.modelManager().download(
                        TranslateRemoteModel.translateRemoteModel(
                            language: TranslateLanguage.allLanguages().first(where: {$0.rawValue == model}) ?? .english
                        ),
                        conditions: ModelDownloadConditions(
                            allowsCellularAccess: true,
                            allowsBackgroundDownloading: true
                        )
                    )
                } else {
                    result(FlutterError(code: "-1", message: "iOS could not extract " +
                        "flutter arguments in method: (downloadModel)", details: nil))
                }
                result("Success")
                break;

//             case: "closeLanguageTranslator":
//                 break;
            default:
                result(FlutterMethodNotImplemented);
            }
  }


private func translateText(result: @escaping FlutterResult, source: String, target: String, text: String) {
    let translator = Translator.translator(options: TranslatorOptions(
        sourceLanguage: TranslateLanguage.allLanguages().first(where: {$0.rawValue == source}) ?? .english,
        targetLanguage: TranslateLanguage.allLanguages().first(where: {$0.rawValue == target}) ?? .english
    ))
    translator.downloadModelIfNeeded(with: ModelDownloadConditions(
        allowsCellularAccess: true,
        allowsBackgroundDownloading: true
    )) { error in
        if (error != nil) {
            result(text)
        } else {
            translator.translate(text) { translatedText, error in
                guard error == nil, let translatedText = translatedText else { return }
                result(translatedText)
            }
        }
    }
}
}
