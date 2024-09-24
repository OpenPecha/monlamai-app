import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/providers/favorite_provider.dart';
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
      });
    } catch (error) {
      // Handle error
      log("Translation error: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
            Text(
              "Home",
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leadingWidth: 100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: [
              TranslationInput(
                translate: translate,
                // handleSubmit: handleSubmit,
                isTextEmpty: _isTextEmpty,
                inputController: _inputController,
                targetLang: targetLang,
              ),
              !_isTextEmpty && translatedText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.star),
                      color: isFavorite ? Colors.yellow : Colors.grey,
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                        if (isFavorite) {
                          ref.read(favoriteProvider.notifier).addFavorite(
                            {
                              'text': _inputController.text,
                              'translatedText': translatedText,
                              'sourceLang': sourceLang,
                              'targetLang': targetLang,
                            },
                          );
                        } else {
                          ref.read(favoriteProvider.notifier).removeFavorite(
                            {
                              'text': _inputController.text,
                              'translatedText': translatedText,
                              'sourceLang': sourceLang,
                              'targetLang': targetLang,
                            },
                          );
                        }
                      },
                      tooltip: 'Favorite',
                    )
                  : Container(),
            ],
          ),
          const SizedBox(height: 8.0),
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
          const SizedBox(height: 16.0),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
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
                    const SizedBox(height: 8.0),
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
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // send feedback to the server
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
