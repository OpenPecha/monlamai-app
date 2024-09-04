import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:aws_s3_upload/aws_s3_upload.dart';

class AudioRecordingS3Widget extends StatefulWidget {
  const AudioRecordingS3Widget(
      {Key? key, required this.isRecording, required this.toggleRecording})
      : super(key: key);

  final bool isRecording;
  final Function toggleRecording;

  @override
  State<AudioRecordingS3Widget> createState() => _AudioRecordingS3WidgetState();
}

class _AudioRecordingS3WidgetState extends State<AudioRecordingS3Widget> {
  final _audioRecorder = Record();
  String _audioPath = '';
  String _s3Url = '';

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // final directory = await getApplicationDocumentsDirectory();
        // _audioPath = '${directory.path}/${Uuid().v4()}.m4a';
        // await _audioRecorder.start(path: _audioPath);
        // log("Audio path: $_audioPath");
        // await _audioRecorder.start(path: _audioPath);
        // // Ensure the directory exists
        // await Directory(path.dirname(_audioPath)).create(recursive: true);
        widget.toggleRecording();
      }
    } catch (e) {
      log('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      // await _audioRecorder.stop();
      widget.toggleRecording();
      // await _uploadToS3();
    } catch (e) {
      log('Error stopping recording: $e');
    }
  }

  Future<void> _uploadToS3() async {
    try {
      final file = File(_audioPath);
      final result = await AwsS3.uploadFile(
        region: dotenv.env['AWS_REGION'].toString(),
        bucket: dotenv.env['AWS_BUCKET_NAME'].toString(),
        accessKey: dotenv.env['AWS_ACCESS_KEY_ID'].toString(),
        secretKey: dotenv.env['AWS_SECRET_ACCESS_KEY'].toString(),
        file: file,
        key: 'audio/${file.path.split('/').last}',
        contentType: 'audio/m4a',
        destDir: "transcriptions",
      );
      if (result != null) {
        setState(() => _s3Url = result);
        log('File uploaded successfully. URL: $_s3Url');
        log('Local file path: $_audioPath');
      } else {
        log('Failed to upload file to S3');
      }
    } catch (e) {
      log('Error uploading to S3: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Center(
            child: FloatingActionButton(
              onPressed: widget.isRecording ? _stopRecording : _startRecording,
              child: Icon(
                widget.isRecording ? Icons.square_rounded : Icons.mic,
                size: 35,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}
