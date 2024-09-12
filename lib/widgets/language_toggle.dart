import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sourceLanguageProvider = StateProvider<String>((ref) => 'en');
final targetLanguageProvider = StateProvider<String>((ref) => 'bo');

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceLang = ref.watch(sourceLanguageProvider);
    final targetLang = ref.watch(targetLanguageProvider);

    void handleSwapLanguages() {
      ref.read(sourceLanguageProvider.notifier).state = targetLang;
      ref.read(targetLanguageProvider.notifier).state = sourceLang;
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ButtonWrapper(
              value: languageSupported
                  .firstWhere(
                    (lang) => lang.code == sourceLang,
                    orElse: () => languageSupported.first,
                  )
                  .name,
              onChanged: (value) => {
                if (ref.read(targetLanguageProvider.notifier).state == value)
                  {handleSwapLanguages()}
                else
                  {ref.read(sourceLanguageProvider.notifier).state = value}
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz, size: 24),
            onPressed: handleSwapLanguages,
          ),
          Expanded(
            child: ButtonWrapper(
              value: languageSupported
                  .firstWhere(
                    (lang) => lang.code == targetLang,
                    orElse: () => languageSupported.first,
                  )
                  .name,
              onChanged: (value) => {
                if (ref.read(sourceLanguageProvider.notifier).state == value)
                  {handleSwapLanguages()}
                else
                  {ref.read(targetLanguageProvider.notifier).state = value}
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonWrapper extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const ButtonWrapper({Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
  State<ButtonWrapper> createState() => _ButtonWrapperState();
}

class _ButtonWrapperState extends State<ButtonWrapper> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MenuAnchor(
          alignmentOffset: Offset(0,
              -constraints.maxHeight * languageSupported.length.toDouble() - 5),
          controller: _menuController,
          menuChildren: languageSupported
              .map((lang) => SizedBox(
                    width: constraints.maxWidth,
                    child: MenuItemButton(
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(
                          Size(constraints.maxWidth, 48),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(fontSize: 16),
                        ),
                      ),
                      onPressed: () {
                        widget.onChanged(lang.code);
                        _menuController.close();
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(lang.name),
                      ),
                    ),
                  ))
              .toList(),
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
            return GestureDetector(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Container(
                width: constraints.maxWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.value,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Language {
  final String name;
  final String code;

  const Language({required this.name, required this.code});
}

const languageSupported = [
  Language(name: "English", code: "en"),
  Language(name: "Tibetan", code: "bo"),
];
