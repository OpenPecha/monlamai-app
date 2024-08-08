import 'package:flutter/material.dart';
import 'package:monlamai_app/screens/settings.dart';

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
              // do something
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
        child: Column(children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Enter text',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'English',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              const Icon(
                Icons.swap_horiz,
                size: 30,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'Tibetan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CircularIconButton(
                  icon: Icons.chat_bubble,
                  padding: 4,
                  size: 24,
                  tooltip: "Chat"),
              CircularIconButton(
                icon: Icons.mic,
                padding: 12,
                size: 34,
                tooltip: "Voice Input",
              ),
              CircularIconButton(
                  icon: Icons.camera_alt,
                  padding: 4,
                  size: 24,
                  tooltip: "Camera"),
            ],
          ),
        ]),
      ),
    );
  }
}

class LanguageButton extends StatelessWidget {
  final String language;
  final bool isSelected;

  const LanguageButton(
      {super.key, required this.language, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        primary: Colors.grey[700],
      ),
      child: Text(
        language,
        style: const TextStyle(
          color: Colors.white,
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

  const CircularIconButton(
      {super.key,
      required this.icon,
      required this.padding,
      required this.size,
      required this.tooltip});

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
        onPressed: () {},
        tooltip: tooltip,
      ),
    );
  }
}
