import 'package:flutter/material.dart';
import 'package:monlamai_app/services/translation_service.dart';
import 'dart:developer' as developer;

class EachMark extends StatefulWidget {
  EachMark(
      {super.key,
      required this.text,
      required this.translatedTexts,
      required this.addTranslatedText,
      required this.fontSize,
      required this.isSelected,
      required this.targetLang});

  final String text;
  final List<String> translatedTexts;
  final Function addTranslatedText;
  final double fontSize;
  final List<bool> isSelected;
  final String targetLang;

  @override
  State<EachMark> createState() => _EachMarkState();
}

class _EachMarkState extends State<EachMark> {
  final TranslationService _translationService = TranslationService();
  String? _translatedText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _translateText();
  }

  Future<void> _translateText() async {
    setState(() => _isLoading = true);
    try {
      // send the text to the translation service
      Map<String, dynamic> translationResponse = await _translationService
          .translateText(widget.text, widget.targetLang);

      if (translationResponse['success'] == true) {
        developer.log(
            "Ocr Translation result: ${translationResponse['translatedText']}");
        final translatedText = translationResponse['translatedText'];

        widget.addTranslatedText(translatedText);

        _translatedText = translatedText;

        setState(() {
          _isLoading = false;
        });
      } else {
        _handleTranslationError(translationResponse['error']);
      }
    } catch (e) {
      _handleTranslationError(e.toString());
    }
  }

  void _handleTranslationError(String error) {
    developer.log("Failed to translate text: $error");
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to translate text')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.isSelected[1]
        ? (_isLoading ? 'Translating...' : _translatedText)
        : widget.text;

    return Text(
      displayText ?? '',
      style: TextStyle(
        color: Colors.white,
        fontSize: widget.fontSize,
        fontWeight: FontWeight.bold,
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
      ),
    );
  }
}
