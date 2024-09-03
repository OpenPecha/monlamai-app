import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monlamai_app/screens/home.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:monlamai_app/widgets/translation_input.dart';

class TransaltionScreen extends StatefulWidget {
  const TransaltionScreen({super.key});

  @override
  State<TransaltionScreen> createState() => _TransaltionScreenState();
}

class _TransaltionScreenState extends State<TransaltionScreen> {
  late TextEditingController _inputController = TextEditingController();
  bool _isTextEmpty = true;
  bool _isTranslating = false;
  bool _isTranslated = false;

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

  void handleSubmit(String value) {
    // should send the input to api for translation
    log('Submitted: $value');
    setState(() {
      _isTranslating = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTranslating = false;
        _isTranslated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              // do something
            },
            tooltip: 'Favorite',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TranslationInput(
            handleSubmit: handleSubmit,
            isTextEmpty: _isTextEmpty,
            inputController: _inputController,
          ),
          const SizedBox(height: 8.0),
          !_isTextEmpty && _isTranslated
              ? Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
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
          !_isTextEmpty && _isTranslating
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
          !_isTextEmpty && _isTranslated
              ? Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      child: Text(
                        "ང་ཚོ་ཡུལ་ལ་མ་ལོག་པའི་སྔོན་ལ་ང་ཚོས་ངེས་པར་དུ་བྱ་བ་ཁ་ཤས ང་ཚོ་ཡུལ་ལ་མ་ལོག་པའི་སྔོན་ལ་ང་ཚོས་ངེས་པར་དུ་བྱ་བ་ཁ་ཤས",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: const Icon(Icons.volume_up),
                        ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: const Icon(Icons.copy_outlined),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
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
      bottomSheet: !_isTextEmpty && _isTranslated
          ? Container(
              margin: const EdgeInsets.all(16.0),
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
          : const LanguageToggle(),
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
