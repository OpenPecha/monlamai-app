import 'package:flutter/material.dart';
import 'package:monlamai_app/screens/conversation.dart';
import 'package:monlamai_app/screens/favorites.dart';
import 'package:monlamai_app/screens/ocr_screen.dart';
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
                  "assets/images/monlam-logo.png",
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
                builder: (context) => FavoritesScreen(),
              ));
            },
            tooltip: 'Favorite',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TransaltionScreen(),
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
      ),
      bottomSheet: const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LanguageToggle(),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircularIconButton(
                  icon: Icons.chat_bubble,
                  padding: 4,
                  size: 28,
                  tooltip: "Chat",
                  route: ConversationScreen(),
                ),
                CircularIconButton(
                  icon: Icons.mic,
                  padding: 4,
                  size: 48,
                  tooltip: "Voice Input",
                  route: TranscribingScreen(),
                ),
                CircularIconButton(
                  icon: Icons.camera_alt,
                  padding: 4,
                  size: 28,
                  tooltip: "Camera",
                  route: OcrScreen(),
                ),
              ],
            ),
          ],
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
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
