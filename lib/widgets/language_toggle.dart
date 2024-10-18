import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sourceLanguageProvider = StateProvider<String>((ref) => 'en');
final targetLanguageProvider = StateProvider<String>((ref) => 'bo');

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceLang = ref.watch(sourceLanguageProvider);
    final targetLang = ref.watch(targetLanguageProvider);

    void handleSwapLanguages() {
      ref.read(sourceLanguageProvider.notifier).state = targetLang;
      ref.read(targetLanguageProvider.notifier).state = sourceLang;
    }

    return SizedBox(
      height: 50,
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
  final String? type;

  const ButtonWrapper(
      {super.key, required this.value, required this.onChanged, this.type});

  @override
  State<ButtonWrapper> createState() => _ButtonWrapperState();
}

class _ButtonWrapperState extends State<ButtonWrapper> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double dy = widget.type == "source" || widget.type == "target"
            ? 0
            : -constraints.maxHeight * languageSupported.length.toDouble() - 65;
        return MenuAnchor(
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.grey[800]!),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          alignmentOffset: Offset(
            0,
            dy,
          ),
          controller: _menuController,
          menuChildren: languageSupported
              .map(
                (lang) => Transform.rotate(
                  angle: widget.type == "target" ? 3.14 : 0,
                  child: SizedBox(
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
                        child: Text(
                          lang.name,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
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
