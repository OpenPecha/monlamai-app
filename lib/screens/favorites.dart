import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/providers/favorite_provider.dart';
import 'package:monlamai_app/widgets/speaker.dart';
import 'package:monlamai_app/widgets/translation_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProvider);
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
                    child: Text("Star a translation to see it here"),
                  )
                : const SizedBox(),
            favorites.isNotEmpty ? _favoriteList(favorites) : const SizedBox(),
          ],
        ),
      ),
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
            return TranslationCard(
              transcribedText: favorites[index]['text']!,
              translatedText: favorites[index]['translatedText']!,
              sourceLang: favorites[index]['sourceLang']!,
              targetLang: favorites[index]['targetLang']!,
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




// ListView.builder(
//         itemCount: 1, // Replace with actual number of history items
//         itemBuilder: (context, index) {
//           return Card(
//             elevation: 1,
//             margin: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 8,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'ENGLISH → TIBETAN',
//                         style: TextStyle(
//                           color: Color.fromRGBO(0, 0, 0, 0.5),
//                           fontSize: 10,
//                         ),
//                       ),
//                       Icon(Icons.star, color: Color(0xFFC4AC69)),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     'I am fine , Thank you',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.volume_up, color: Colors.grey),
//                         onPressed: () {/* Handle audio playback */},
//                       ),
//                       const Spacer(),
//                       IconButton(
//                         icon: const Icon(Icons.copy, color: Colors.grey),
//                         onPressed: () {/* Handle copy */},
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.thumb_up, color: Colors.grey),
//                         onPressed: () {/* Handle like */},
//                       ),
//                     ],
//                   ),
//                   const Divider(),
//                   const Text(
//                     'ང་བདེ་པོ་ཡིན། ཐུགས་རྗེ་ཆེ།',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.volume_up, color: Colors.grey),
//                         onPressed: () {/* Handle audio playback */},
//                       ),
//                       const Spacer(),
//                       IconButton(
//                         icon: const Icon(Icons.copy, color: Colors.grey),
//                         onPressed: () {/* Handle copy */},
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.thumb_up, color: Colors.grey),
//                         onPressed: () {/* Handle like */},
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),