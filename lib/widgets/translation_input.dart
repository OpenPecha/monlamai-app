import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslationInput extends StatelessWidget {
  const TranslationInput({
    super.key,
    required this.translate,
    // required this.handleSubmit,
    required this.isTextEmpty,
    required this.inputController,
    required this.targetLang,
  });

  final bool isTextEmpty;
  final TextEditingController inputController;
  // final void Function(String, String) handleSubmit;
  final String targetLang;
  final void Function(String, String) translate;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 8,
            ),
            child: TextField(
              minLines: 1,
              maxLines: 5,
              autofocus: true,
              controller: inputController,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter text',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.normal,
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  translate(value, targetLang);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter text to translate'),
                    ),
                  );
                }
              },
              inputFormatters: [
                EnterDisablerInputFormatter(isTextEmpty),
              ],
            ),
          ),
        ],
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
