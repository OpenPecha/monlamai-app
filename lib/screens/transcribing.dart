import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/db/database_helper.dart';
import 'package:monlamai_app/models/favorite.dart';
import 'package:monlamai_app/widgets/audio_recording.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:monlamai_app/widgets/loading_text.dart';
import 'package:monlamai_app/widgets/speaker.dart';

class TranscribingScreen extends ConsumerStatefulWidget {
  const TranscribingScreen({super.key});

  @override
  ConsumerState<TranscribingScreen> createState() => _TranscribingScreenState();
}

class _TranscribingScreenState extends ConsumerState<TranscribingScreen> {
  bool _isRecording = false;
  bool _isLoading = false;
  String _id = '';
  String _transcribedText = '';
  String _translatedText = '';
  bool _isLiked = false;
  bool _isFavorite = false;
  final dbHelper = DatabaseHelper();

  void toggleRecording() {
    // Handle recording toggle
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  void toggleLoading(bool loading) {
    // Handle loading state
    setState(() {
      _isLoading = loading;
    });
  }

  void setTexts(String id, String transcribedText, String translated,
      String sourceLang, String targetLang) {
    // Handle transcribed text
    setState(() {
      _id = id;
      _transcribedText = transcribedText;
      _translatedText = translated;
    });
  }

  // reset both text
  void resetText() {
    setState(() {
      _id = '';
      _transcribedText = '';
      _translatedText = '';
    });
  }

  void toggleFavorite(String sourceLang, String targetLang) async {
    if (_isFavorite) {
      await dbHelper.deleteFavorite(_id);
    } else {
      Favorite newFavorite = Favorite(
        id: _id,
        sourceText: _transcribedText,
        targetText: _translatedText,
        sourceLang: sourceLang,
        targetLang: targetLang,
        createdAt: DateTime.now(),
      );
      await dbHelper.insertFavorite(newFavorite);
    }
    setState(() {
      _isFavorite = !_isFavorite;
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isRecording && !_isLoading & _transcribedText.isEmpty
                    ? const Text(
                        'Listening ....',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
                !_isRecording && !_isLoading & _transcribedText.isEmpty
                    ? const Text(
                        'Tap the mic button to start',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
                !_isRecording && _isLoading && _transcribedText.isEmpty
                    ? const LoadingText()
                    : Container(),
                _transcribedText.isNotEmpty &&
                        _translatedText.isNotEmpty &&
                        !_isLoading &&
                        !_isRecording
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  _transcribedText,
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  toggleFavorite(sourceLang, targetLang);
                                },
                                child: Icon(
                                  Icons.star,
                                  color: _isFavorite
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SpeakerWidget(
                                text: _transcribedText,
                                language: sourceLang,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _transcribedText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Text copied')),
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
                                  _translatedText,
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
                                    text: _translatedText,
                                    language: targetLang,
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: _translatedText),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Text copied')),
                                      );
                                    },
                                    icon: const Icon(Icons.copy_outlined),
                                  ),
                                  IconButton(
                                    color: _isLiked
                                        ? Colors.green
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      // send feedback to the server
                                      setState(() {
                                        _isLiked = !_isLiked;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Thanks for the feedback')),
                                      );
                                    },
                                    icon: const Icon(Icons.thumb_up),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 20,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const LanguageToggle(),
          const SizedBox(height: 16.0),
          AudioRecordingWidget(
            isRecording: _isRecording,
            toggleRecording: toggleRecording,
            toggleLoading: toggleLoading,
            setTexts: setTexts,
            resetText: resetText,
            langFrom: sourceLang,
            langTo: targetLang,
          ),
        ]),
      ),
    );
  }
}
