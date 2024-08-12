import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monlamai_app/screens/home.dart';

class TransaltionScreen extends StatefulWidget {
  const TransaltionScreen({super.key});

  @override
  State<TransaltionScreen> createState() => _TransaltionScreenState();
}

class _TransaltionScreenState extends State<TransaltionScreen> {
  late TextEditingController _inputController = TextEditingController();
  bool _isTextEmpty = true;
  bool _isTranslating = false;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 4,
        ),
        child: Column(children: [
          TextField(
            autofocus: true,
            controller: _inputController,
            decoration: const InputDecoration(
              hintText: 'Enter text',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.normal,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (String value) {
              print('Submitted: ${_inputController.text}');
              setState(() {
                _isTranslating = true;
              });
            },
            inputFormatters: [
              EnterDisablerInputFormatter(_isTextEmpty),
            ],
          ),
          !_isTextEmpty && _isTranslating
              ? const Text(
                  'Enter text',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.normal,
                  ),
                )
              : Container(),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              LanguageButton(language: "English"),
              SizedBox(width: 16.0),
              Icon(
                Icons.swap_horiz,
                size: 30,
              ),
              SizedBox(width: 16.0),
              LanguageButton(language: "Tibetan"),
            ],
          ),
          const SizedBox(height: 16.0),
        ]),
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
