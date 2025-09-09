import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  bool isClicked = false;
  int seconds = 0;
  Timer? timer;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeechInitialized = false;
  String _transcript = '';
  String _speechStatus = 'Not initialized';
  late AnimationController _waveController;
  List<double> _waveHeights = List.generate(20, (_) => 10.0);

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
      if (isClicked) {
        setState(() {
          _waveHeights = List.generate(20, (_) => 10 + Random().nextDouble() * 30);
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _waveController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _initSpeech() async {
    _isSpeechInitialized = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        setState(() {
          _speechStatus = status;
          // Restart listening if it stops unexpectedly while isClicked is true
          if (isClicked && status == 'done' || status == 'notListening') {
            _restartListening();
          }
        });
      },
      onError: (error) {
        print('Speech error: $error');
        setState(() {
          _speechStatus = 'Error: ${error.errorMsg}';
        });
      },
      debugLogging: true, // Enable detailed logging
    );
    if (!_isSpeechInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initialize speech recognition')),
      );
    }
    setState(() {});
  }

  void _restartListening() async {
    if (!_isSpeechInitialized || !isClicked) return;
    await _speech.stop();
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcript = result.recognizedWords;
          if (result.finalResult) {
            print('Final result: $_transcript');
          }
        });
      },
      listenFor: const Duration(minutes: 10),
      pauseFor: const Duration(seconds: 10),
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
    );
  }

  void startRecording() async {
    if (!_isSpeechInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not initialized')),
      );
      return;
    }
    setState(() {
      isClicked = true;
      seconds = 0;
      _transcript = '';
      _speechStatus = 'Starting...';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcript = result.recognizedWords;
          if (result.finalResult) {
            print('Final result: $_transcript');
          }
        });
      },
      listenFor: const Duration(minutes: 10),
      pauseFor: const Duration(seconds: 10),
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
    );

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        seconds++;
      });
    });
    _waveController.repeat();
  }

  void stopRecording() async {
    await _speech.stop();
    timer?.cancel();
    _waveController.stop();
    setState(() {
      isClicked = false;
      seconds = 0;
      _waveHeights = List.generate(20, (_) => 10.0);
    });
  }

  void saveRecording() {
    print('Saved transcript: $_transcript');
    stopRecording();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recording saved: ${_transcript.isEmpty ? "No transcript" : _transcript}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text("Recording"),
        actions: isClicked
            ? [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveRecording,
          ),
        ]
            : [],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isClicked)
              Container(
                color: Colors.redAccent,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fiber_manual_record, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Recording... $seconds s",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            if (isClicked)
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_waveHeights.length, (index) {
                    return Container(
                      width: 4,
                      height: _waveHeights[index],
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: Colors.redAccent,
                    );
                  }),
                ),
              ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: isClicked ? 50 : 0),
              child: GestureDetector(
                onTap: isClicked ? stopRecording : startRecording,
                child: Container(
                  height: 120,
                  width: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    isClicked ? Icons.stop : Icons.mic,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    size: 35,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isClicked ? "Tap to stop" : "Tap to record",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (isClicked)
              Container(
                height: 200,
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _transcript.isEmpty ? "Listening for speech..." : _transcript,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (isClicked)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Status: $_speechStatus',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}