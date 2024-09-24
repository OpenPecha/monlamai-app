import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/screens/split_screen.dart';
import 'package:monlamai_app/widgets/audio_recording.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:monlamai_app/widgets/loading_text.dart';
import 'package:monlamai_app/widgets/speaker.dart';

class Conversation {
  Conversation({
    required this.source,
    required this.target,
  });

  final String source;
  final String target;
}

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  bool _isSourceRecording = false;
  bool _isTargetRecording = false;
  bool _isLoading = false;
  bool _isLiked = false;
  // list of conversation messages
  final List<Map<String, String>> _conversations = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _conversations.clear();
    super.dispose();
  }

  void toggleLoading(bool loading) {
    // Handle loading state
    setState(() {
      _isLoading = loading;
    });
  }

  void setTexts(
    String sourceText,
    String targetText,
    String sourceLang,
    String targetLang,
  ) {
    // Handle transcribed text
    setState(() {
      _conversations.add({
        "sourceText": sourceText,
        "soucreLang": sourceLang,
        "targetText": targetText,
        "targetLang": targetLang,
      });
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
  Widget build(BuildContext context) {
    final sourceLang = ref.watch(sourceLanguageProvider);
    final targetLang = ref.watch(targetLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.horizontal_split),
            onPressed: () {
              // Handle star button press
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => SplitScreen(
                          conversationList: _conversations,
                          setTexts: setTexts,
                        )),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isSourceRecording || _isTargetRecording && !_isLoading
                ? const Text(
                    'Listening ....',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.grey,
                    ),
                  )
                : Container(),
            _conversations.isEmpty &&
                    !_isSourceRecording &&
                    !_isTargetRecording &&
                    !_isLoading
                ? Text(
                    'Speak',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.grey[600],
                    ),
                  )
                : Container(),
            _isLoading && !_isSourceRecording && !_isTargetRecording
                ? const LoadingText()
                : Container(),
            const SizedBox(height: 16),
            _conversations.isNotEmpty ? _sourceOutput() : Container(),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const LanguageToggle(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AudioRecordingWidget(
                isRecording: _isSourceRecording,
                toggleRecording: toggleSourceRecording,
                toggleLoading: toggleLoading,
                setTexts: setTexts,
                resetText: resetText,
                langFrom: sourceLang,
                langTo: targetLang,
              ),
              AudioRecordingWidget(
                isRecording: _isTargetRecording,
                toggleRecording: toggleTargetRecording,
                toggleLoading: toggleLoading,
                setTexts: setTexts,
                resetText: resetText,
                langFrom: targetLang,
                langTo: sourceLang,
              )
            ],
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _sourceOutput() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 150),
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          itemCount: _conversations.length,
          itemBuilder: (context, index) {
            return convoCard(
              _conversations[index]['sourceText']!,
              _conversations[index]['targetText']!,
              _conversations[index]['soucreLang']!,
              _conversations[index]['targetLang']!,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
    );
  }

// might need to refactor this widget to a separate file later
  Widget convoCard(String transcribedText, String translatedText,
      String sourceLang, String targetLang) {
    final from = sourceLang == 'en' ? 'English' : 'Tibetan';
    final to = targetLang == 'en' ? 'English' : 'Tibetan';
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  IconButton(
                    color: _isLiked ? Colors.green : Colors.black87,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // send feedback to the server
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Thanks for the feedback')),
                      );
                    },
                    icon: const Icon(Icons.thumb_up),
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
