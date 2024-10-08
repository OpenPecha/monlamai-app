import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/db/database_helper.dart';
import 'package:monlamai_app/models/favorite.dart';
import 'package:monlamai_app/screens/home.dart';
import 'package:monlamai_app/services/translation_service.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:monlamai_app/widgets/speaker.dart';
import 'package:monlamai_app/widgets/translation_input.dart';

class TransaltionScreen extends ConsumerStatefulWidget {
  const TransaltionScreen({super.key});

  @override
  ConsumerState<TransaltionScreen> createState() => _TransaltionScreenState();
}

class _TransaltionScreenState extends ConsumerState<TransaltionScreen> {
  late TextEditingController _inputController = TextEditingController();
  final TranslationService _translationService = TranslationService();
  bool _isTextEmpty = true;
  String translatedText = '';
  bool isLoading = false;
  bool isFavorite = false;
  bool _isLiked = false;
  String id = '';
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _inputController.addListener(_updateTextStatus);
  }

  void _updateTextStatus() {
    setState(() {
      _isTextEmpty = _inputController.text.isEmpty;
    });
  }

  @override
  void dispose() {
    _inputController.removeListener(_updateTextStatus);
    _inputController.dispose();
    super.dispose();
  }

  Future<void> translate(String inputText, String targetLanguage) async {
    log('Translating: $inputText to $targetLanguage');
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> translationResult =
          await _translationService.translateText(inputText, targetLanguage);
      setState(() {
        translatedText = translationResult['translatedText'];
        id = translationResult['id'];
      });
    } catch (error) {
      // Handle error
      log("Translation error: $error");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation failed. Please try again.'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleFavorite(String sourceLang, String targetLang) {
    if (isFavorite) {
      dbHelper.deleteFavorite(id);
    } else {
      Favorite newFavorite = Favorite(
        id: id,
        sourceText: _inputController.text,
        targetText: translatedText,
        sourceLang: sourceLang,
        targetLang: targetLang,
        createdAt: DateTime.now(),
      );
      dbHelper.insertFavorite(newFavorite);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final targetLang = ref.watch(targetLanguageProvider);
    final sourceLang = ref.watch(sourceLanguageProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: "Back",
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslationInput(
                translate: translate,
                // handleSubmit: handleSubmit,
                isTextEmpty: _isTextEmpty,
                inputController: _inputController,
                targetLang: targetLang,
              ),
              !_isTextEmpty && translatedText.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        toggleFavorite(sourceLang, targetLang);
                      },
                      child: Icon(
                        Icons.star,
                        color: isFavorite ? Colors.yellow[700] : Colors.grey,
                      ),
                    )
                  : Container(),
            ],
          ),
          !_isTextEmpty && translatedText.isNotEmpty
              ? Row(
                  children: [
                    SpeakerWidget(
                      text: _inputController.text,
                      language: sourceLang,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _inputController.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Text copied')),
                        );
                      },
                      icon: const Icon(Icons.copy_outlined),
                    ),
                  ],
                )
              : Container(),
          const SizedBox(height: 8.0),
          !_isTextEmpty
              ? const Divider(
                  thickness: 1,
                  height: 1,
                  color: Color(0xFF0C53C5),
                  indent: 20,
                  endIndent: 20,
                )
              : Container(),
          !_isTextEmpty && isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'translating...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                )
              : Container(),
          const SizedBox(height: 16.0),
          !_isTextEmpty && translatedText.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // translated text
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 8,
                      ),
                      child: Text(
                        translatedText,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        SpeakerWidget(
                          text: translatedText,
                          language: targetLang,
                        ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: translatedText),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Text copied')),
                            );
                          },
                          icon: const Icon(Icons.copy_outlined),
                        ),
                        IconButton(
                          color: _isLiked
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // send feedback to the server
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Thanks for the feedback')),
                            );
                          },
                          icon: const Icon(Icons.thumb_up),
                        ),
                      ],
                    ),
                  ],
                )
              : Container(),
          // const Spacer(),
        ]),
      ),
      bottomSheet: !_isTextEmpty && translatedText.isNotEmpty
          ? Container(
              margin: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "New translation",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Padding(
              padding: EdgeInsets.all(20.0),
              child: LanguageToggle(),
            ),
    );
  }
}

class EnterDisablerInputFormatter extends TextInputFormatter {
  final bool disableEnter;

  EnterDisablerInputFormatter(this.disableEnter);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (disableEnter && newValue.text.endsWith('\n')) {
      return oldValue;
    }
    return newValue;
  }
}
