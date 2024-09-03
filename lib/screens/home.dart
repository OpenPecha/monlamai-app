import 'package:flutter/material.dart';
import 'package:monlamai_app/screens/favorites.dart';
import 'package:monlamai_app/screens/settings.dart';
import 'package:monlamai_app/screens/transcribing.dart';
import 'package:monlamai_app/screens/translation.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        leading: IconButton(
          icon: const Icon(Icons.list),
          onPressed: () {
            // navigate to settings screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          tooltip: "Menu",
        ),
        title: SizedBox(
          width: double.infinity,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/icon-circular.png",
                  width: 37,
                  height: 34,
                ),
                const SizedBox(width: 8),
                Text(
                  "Monlam AI",
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              // navigate to favorites screen
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const FavoritesScreen(),
              ));
            },
            tooltip: 'Favorite',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransaltionScreen(),
              ),
            ),
            child: const Text(
              "Enter text",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const Spacer(),
          const LanguageToggle(),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CircularIconButton(
                icon: Icons.chat_bubble,
                padding: 4,
                size: 24,
                tooltip: "Chat",
                route: TransaltionScreen(),
              ),
              CircularIconButton(
                icon: Icons.mic,
                padding: 12,
                size: 34,
                tooltip: "Voice Input",
                route: TranscribingScreen(),
              ),
              CircularIconButton(
                icon: Icons.camera_alt,
                padding: 4,
                size: 24,
                tooltip: "Camera",
                route: TransaltionScreen(),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class LanguageButton extends StatelessWidget {
  final String language;

  const LanguageButton({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
        child: Text(
          language,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final double padding;
  final double size;
  final String tooltip;
  final Widget route;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.padding,
    required this.size,
    required this.tooltip,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(padding),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE0E0E0),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: size,
        ),
        color: const Color(0xFF202020),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => route,
            ),
          );
        },
        tooltip: tooltip,
      ),
    );
  }
}
