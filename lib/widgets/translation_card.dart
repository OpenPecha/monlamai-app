import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monlamai_app/widgets/speaker.dart';

class TranslationCard extends StatelessWidget {
  const TranslationCard(
      {super.key,
      required this.translatedText,
      required this.transcribedText,
      required this.sourceLang,
      required this.targetLang});

  final String translatedText;
  final String transcribedText;
  final String sourceLang;
  final String targetLang;

  @override
  Widget build(BuildContext context) {
    final from = sourceLang == 'en' ? 'English' : 'Tibetan';
    final to = targetLang == 'en' ? 'English' : 'Tibetan';
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$from  ->  $to",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.star)),
            ],
          ),
          Text(
            transcribedText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          Row(
            children: [
              SpeakerWidget(
                text: transcribedText,
                language: sourceLang,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: transcribedText),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Text copied')),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
              ),
            ],
          ),
          const Divider(
            thickness: 1,
            height: 1,
            color: Color(0xFF0C53C5),
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 16.0),
          Text(
            translatedText,
            softWrap: true,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
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
            ],
          ),
        ],
      ),
    );
  }
}
