import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          "Favorites",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
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
      body: ListView.builder(
        itemCount: 3, // Replace with actual number of history items
        itemBuilder: (context, index) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ENGLISH → TIBETAN',
                        style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          fontSize: 10,
                        ),
                      ),
                      Icon(Icons.star, color: Color(0xFFC4AC69)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'I am fine , Thank you',
                    style: TextStyle(fontSize: 18),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.grey),
                        onPressed: () {/* Handle audio playback */},
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: () {/* Handle copy */},
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_up, color: Colors.grey),
                        onPressed: () {/* Handle like */},
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'ང་བདེ་པོ་ཡིན། ཐུགས་རྗེ་ཆེ།',
                    style: TextStyle(fontSize: 18),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.grey),
                        onPressed: () {/* Handle audio playback */},
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: () {/* Handle copy */},
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_up, color: Colors.grey),
                        onPressed: () {/* Handle like */},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
