import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/widgets/audio_recording.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:monlamai_app/widgets/loading_text.dart';
import 'package:monlamai_app/widgets/speaker.dart';

class SplitScreen extends ConsumerStatefulWidget {
  const SplitScreen(
      {super.key, required this.conversationList, required this.setTexts});
  final List<Map<String, String>> conversationList;
  final Function setTexts;

  @override
  ConsumerState<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends ConsumerState<SplitScreen> {
  bool _isSourceRecording = false;
  bool _isTargetRecording = false;
  bool _isLoading = false;

  void toggleLoading(bool loading) {
    // Handle loading state
    setState(() {
      _isLoading = loading;
    });
  }

  // reset both text
  void resetText() {
    setState(() {});
  }

  void toggleSourceRecording() {
    setState(() {
      if (_isTargetRecording) {
        // If target is recording, stop it and start source
        _isTargetRecording = false;
        _isSourceRecording = true;
      } else {
        // Otherwise, just toggle source
        _isSourceRecording = !_isSourceRecording;
      }
    });
  }

  void toggleTargetRecording() {
    setState(() {
      if (_isSourceRecording) {
        // If source is recording, stop it and start target
        _isSourceRecording = false;
        _isTargetRecording = true;
      } else {
        // Otherwise, just toggle target
        _isTargetRecording = !_isTargetRecording;
      }
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final sourceLang = ref.watch(sourceLanguageProvider);
    final targetLang = ref.watch(targetLanguageProvider);
    log("list of conversation messages: ${widget.conversationList}");

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
                          conversationList: widget.conversationList,
                          isRecording: _isTargetRecording,
                          isloading: _isLoading,
                          toggleRecording: toggleTargetRecording,
                          toggleLoading: toggleLoading,
                          setTexts: widget.setTexts,
                          resetText: resetText,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const BackButton(),
                        Divider(
                          thickness: 1,
                          height: 1,
                          color: Theme.of(context).colorScheme.secondary,
                          indent: 20,
                        ),
                      ],
                    ),
                    Container(width: 2, color: Colors.pink[300]),
                    Expanded(
                      child: _ConversationSide(
                        type: 'source',
                        language: sourceLang,
                        instruction: 'Tap on the Mic to Start',
                        conversationList: widget.conversationList,
                        isRecording: _isSourceRecording,
                        isloading: _isLoading,
                        toggleRecording: toggleSourceRecording,
                        toggleLoading: toggleLoading,
                        setTexts: widget.setTexts,
                        resetText: resetText,
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
  final bool isRecording;
  final bool isloading;
  final Function toggleRecording;
  final Function toggleLoading;
  final Function setTexts;
  final Function resetText;

  _ConversationSide({
    required this.type,
    required this.language,
    required this.instruction,
    required this.conversationList,
    required this.isRecording,
    required this.isloading,
    required this.toggleRecording,
    required this.toggleLoading,
    required this.setTexts,
    required this.resetText,
  }) : filteredList = conversationList
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
            .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceLang = ref.watch(sourceLanguageProvider);
    final targetLang = ref.watch(targetLanguageProvider);

    void handleSwapLanguages() {
      ref.read(sourceLanguageProvider.notifier).state = targetLang;
      ref.read(targetLanguageProvider.notifier).state = sourceLang;
    }

    String langTo = language == "en" ? "bo" : "en";

    return Column(
      children: [
        isloading ? const LoadingText() : const SizedBox(),
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          maxLines: null,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
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
            AudioRecordingWidget(
              isRecording: isRecording,
              toggleRecording: toggleRecording,
              toggleLoading: toggleLoading,
              setTexts: setTexts,
              resetText: resetText,
              langFrom: language,
              langTo: langTo,
            ),
            const Spacer(),
            Expanded(
              child: ButtonWrapper(
                type: type,
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
