package io.flutter.plugins.mlkit_translate

import androidx.annotation.NonNull
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.languageid.LanguageIdentificationOptions
import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.TranslatorOptions.Builder
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** MlkitTranslatePlugin */
class MlkitTranslatePlugin : FlutterPlugin, MethodCallHandler {
    // / The MethodChannel that will the communication between Flutter and native Android
    // /
    // / This local reference serves to register the plugin with the Flutter Engine and unregister it
    // / when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mlkit_translate")
        channel.setMethodCallHandler(this)
    }

    private fun translateText(result: Result, source: String, target: String,
                              text: String) {
        val translator = Translation.getClient(Builder()
                .setSourceLanguage(source)
                .setTargetLanguage(target)
                .build())
        translator.downloadModelIfNeeded(
                DownloadConditions.Builder().build()
        )
                .addOnSuccessListener {
                    translator.translate(text)
                            .addOnSuccessListener { translatedText ->
                                result.success(translatedText)
                            }
                            .addOnFailureListener { exception ->
                                result.error("translationError", exception.localizedMessage, null)
                            }
                }
                .addOnFailureListener { exception ->
                    result.error("downloadModelError", exception.localizedMessage, null)
                }

    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "detectLanguage" -> {
                val text: String = call.argument("text") ?: ""

                LanguageIdentification.getClient(
                    LanguageIdentificationOptions.Builder()
                        .setConfidenceThreshold(0.0f)
                        .build()
                ).identifyLanguage(text)
                    .addOnSuccessListener { languageCode ->
                        if (languageCode != null) {
                            result.success(languageCode)
                        } else {
                            result.success("und")
                        }
                    }
                    .addOnFailureListener { exception ->
                        result.success("und")
                    }
            }
            "translate" -> {
                val source: String? = call.argument("source")
                val target: String = call.argument("target") ?: "en"
                val text: String = call.argument("text") ?: ""

                if (source == null) {
                    LanguageIdentification.getClient(
                            LanguageIdentificationOptions.Builder()
                                    .setConfidenceThreshold(0.0f)
                                    .build()
                    ).identifyLanguage(text)
                            .addOnSuccessListener { languageCode ->
                                if (languageCode != null) {
                                    translateText(result, languageCode, target, text)
                                } else {
                                    translateText(result, "en", target, text)
                                }
                            }
                            .addOnFailureListener { exception ->
                                translateText(result, "en", target, text)
                            }
                } else {
                    translateText(result, source, target, text)
                }
            }
            "downloadModel" -> {
                val model: String? = call.argument("model")
                if (model != null) {
                    RemoteModelManager.getInstance().download(
                            TranslateRemoteModel.Builder(model).build(),
                            DownloadConditions.Builder()
                                    .build()
                    )
                            .addOnSuccessListener {
                                result.success("Success")
                            }
                            .addOnFailureListener { exception ->
                                result.error(
                                        "downloadModelError",
                                        exception
                                                .localizedMessage,
                                        null
                                )
                            }
                }
            }
            "getDownloadedModels" -> {
                RemoteModelManager.getInstance().getDownloadedModels(TranslateRemoteModel::class.java)
                        .addOnSuccessListener { models ->
                            result.success(models.map { model -> model.language })
                        }
                        .addOnFailureListener {
                            result.success(null)
                        }
            }
            "deleteDownloadedModel" -> {
                val model: String? = call.argument("model")
                if (model != null) {
                    RemoteModelManager.getInstance().deleteDownloadedModel(
                            TranslateRemoteModel.Builder(model).build()
                    ).addOnSuccessListener {
                        result.success(true)
                    }.addOnFailureListener {
                        result.success(false)
                    }
                }
            }
//            "closeLanguageTranslator" -> {
//                translator?.close()
//                        .addOnSuccessListener {
//                            result.success("Success")
//                        }
//                        .addOnFailureListener { exception ->
//                            result.error(
//                                    "closeLanguageTranslator",
//                                    exception
//                                            .localizedMessage,
//                                    null
//                            )
//                        }
//            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
