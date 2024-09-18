import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';

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
                          language: targetLang,
                          instruction: 'Tap on the Mic to Start',
                          isReversed: true,
                        ),
                      ),
                    ),
                    const BackButton(),
                    Container(width: 2, color: Colors.pink[300]),
                    Expanded(
                      child: _ConversationSide(
                        language: sourceLang,
                        instruction: 'Tap on the Mic to Start',
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
  final String language;
  final String instruction;
  final bool isReversed;

  const _ConversationSide({
    required this.language,
    required this.instruction,
    this.isReversed = false,
    Key? key,
  }) : super(key: key);

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
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  instruction,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
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
