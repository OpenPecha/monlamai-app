import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monlamai_app/db/database_helper.dart';
import 'package:monlamai_app/models/favorite.dart';
import 'package:monlamai_app/widgets/speaker.dart';

class TranslationCard extends StatefulWidget {
  const TranslationCard(
      {super.key,
      required this.id,
      required this.translatedText,
      required this.transcribedText,
      required this.sourceLang,
      required this.targetLang,
      this.onDeleted});

  final String id;
  final String translatedText;
  final String transcribedText;
  final String sourceLang;
  final String targetLang;
  final Function? onDeleted;

  @override
  State<TranslationCard> createState() => _TranslationCardState();
}

class _TranslationCardState extends State<TranslationCard> {
  final dbHelper = DatabaseHelper();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  _checkFavorite() async {
    final isFavorite = await dbHelper.isFavorite(widget.id);
    setState(() {
      this.isFavorite = isFavorite;
    });
  }

  // This method is called when the widget is updated
  @override
  void didUpdateWidget(covariant TranslationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _checkFavorite();
    }
  }

  void toggleFavorite() async {
    if (isFavorite) {
      await dbHelper.deleteFavorite(widget.id);
      widget.onDeleted?.call();
    } else {
      Favorite newFavorite = Favorite(
        id: widget.id,
        sourceText: widget.transcribedText,
        targetText: widget.translatedText,
        sourceLang: widget.sourceLang,
        targetLang: widget.targetLang,
        createdAt: DateTime.now(),
      );
      await dbHelper.insertFavorite(newFavorite);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final from = widget.sourceLang == 'en' ? 'English' : 'Tibetan';
    final to = widget.targetLang == 'en' ? 'English' : 'Tibetan';
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
              IconButton(
                onPressed: toggleFavorite,
                icon: Icon(
                  Icons.star,
                  color: isFavorite ? Colors.amber : Colors.grey[300],
                ),
              ),
            ],
          ),
          Text(
            widget.transcribedText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          Row(
            children: [
              SpeakerWidget(
                text: widget.transcribedText,
                language: widget.sourceLang,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: widget.transcribedText),
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
            widget.translatedText,
            softWrap: true,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          Row(
            children: [
              SpeakerWidget(
                text: widget.translatedText,
                language: widget.targetLang,
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: widget.translatedText),
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
