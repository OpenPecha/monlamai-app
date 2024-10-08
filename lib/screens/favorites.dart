import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/db/database_helper.dart';
import 'package:monlamai_app/models/favorite.dart';
import 'package:monlamai_app/widgets/speaker.dart';
import 'package:monlamai_app/widgets/translation_card.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});
  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final dbHelper = DatabaseHelper();
  List<Favorite> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  _loadFavorites() async {
    List<Favorite> loadedFavorites = await dbHelper.getFavorites();
    setState(() {
      favorites = loadedFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final favorites = ref.watch(favoriteProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: "Back",
        ),
        title: Text(
          "Saved",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              favorites.isEmpty
                  ? const Center(
                      child: Text(
                        "No saved translations",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : _favoriteList(favorites),
            ],
          )),
    );
  }

  Widget _favoriteList(favorites) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 150),
        child: ListView.separated(
          scrollDirection: Axis.vertical,
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            return TranslationCard(
              id: favorite.id,
              transcribedText: favorite.sourceText,
              translatedText: favorite.targetText,
              sourceLang: favorite.sourceLang,
              targetLang: favorite.targetLang,
              onDeleted: _loadFavorites,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
    );
  }

  Widget convoCard(BuildContext context, String transcribedText,
      String translatedText, String sourceLang, String targetLang) {
    final from = sourceLang == 'en' ? 'English' : 'Tibetan';
    final to = targetLang == 'en' ? 'English' : 'Tibetan';
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 4,
                ),
                child: Text(
                  "$from  ->  $to",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ),
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
          const SizedBox(height: 16.0),
          const Divider(
            thickness: 1,
            height: 1,
            color: Color(0xFF0C53C5),
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
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
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
