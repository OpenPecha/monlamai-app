import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:monlamai_app/widgets/speaker.dart';
import 'package:share_plus/share_plus.dart';

class OcrTools extends ConsumerWidget {
  const OcrTools(
      {super.key,
      required this.captureTexts,
      required this.translatedTexts,
      required this.isSelected});

  final String captureTexts;
  final List<String> translatedTexts;
  final List<bool> isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combineTranslateText = translatedTexts.join(' ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Theme.of(context)
                      .elevatedButtonTheme
                      .style
                      ?.backgroundColor
                      ?.resolve({WidgetState.pressed}) ??
                  Colors.transparent),
          child: Row(
            children: [
              SpeakerWidget(
                text: isSelected[1] ? combineTranslateText : captureTexts,
                language: isSelected[1]
                    ? ref.watch(targetLanguageProvider)
                    : ref.watch(sourceLanguageProvider),
              ),
              const Text('Listen'),
              const SizedBox(width: 10),
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.share),
          onPressed: () {
            final RenderBox box = context.findRenderObject() as RenderBox;
            Share.share(
              isSelected[1] ? combineTranslateText : captureTexts,
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
            );
          },
          label: const Text('Share'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: isSelected[1] ? combineTranslateText : captureTexts,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Text copied')),
            );
          },
          label: const Text('Copy'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
