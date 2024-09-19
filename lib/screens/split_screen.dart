import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:monlamai_app/widgets/speaker.dart';

class SplitScreenConversation extends ConsumerWidget {
  const SplitScreenConversation({
    Key? key,
    required this.conversationList,
  }) : super(key: key);

  final List<Map<String, String>> conversationList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceLang = ref.watch(sourceLanguageProvider);
    final targetLang = ref.watch(targetLanguageProvider);
    log("list of conversation messages: $conversationList");

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Transform.rotate(
                        angle: 3.14,
                        child: _ConversationSide(
                          type: 'target',
                          language: targetLang,
                          instruction: 'Tap on the Mic to Start',
                          conversationList: conversationList,
                        ),
                      ),
                    ),
                    const BackButton(),
                    Container(width: 2, color: Colors.pink[300]),
                    Expanded(
                      child: _ConversationSide(
                        type: 'source',
                        language: sourceLang,
                        instruction: 'Tap on the Mic to Start',
                        conversationList: conversationList,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationSide extends ConsumerWidget {
  final String type;
  final String language;
  final String instruction;
  final List<Map<String, String>> conversationList;
  final List<String> filteredList;

  _ConversationSide({
    required this.type,
    required this.language,
    required this.instruction,
    required this.conversationList,
    Key? key,
  })  : filteredList = conversationList
            .map((conversation) {
              if (conversation['soucreLang'] == language) {
                return conversation['sourceText']!;
              } else if (conversation['targetLang'] == language) {
                return conversation['targetText']!;
              }
              return null;
            })
            .where((text) => text != null)
            .cast<String>()
            .toList(),
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceLang = ref.watch(sourceLanguageProvider);
    final targetLang = ref.watch(targetLanguageProvider);

    void handleSwapLanguages() {
      ref.read(sourceLanguageProvider.notifier).state = targetLang;
      ref.read(targetLanguageProvider.notifier).state = sourceLang;
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final text = filteredList[index];
                final lang = language;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SpeakerWidget(text: text, language: lang),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 16),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.mic,
                  size: 42,
                ),
                color: const Color(0xFF202020),
                onPressed: () {},
                tooltip: "Tap to type",
              ),
            ),
            const Spacer(),
            Expanded(
              child: ButtonWrapper(
                value: languageSupported
                    .firstWhere(
                      (lang) => lang.code == language,
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
          ],
        ),
      ],
    );
  }
}
