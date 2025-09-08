import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isRecording = false;
  bool isPaused = false;
  Duration elapsed = Duration.zero;
  Timer? timer;
  String? recordedFilePath;

  Future<void> _toggleRecording() async {
    if (isRecording) {
      if (isPaused) {
        // Resume recording
        await _recorder.resume();
        setState(() {
          isPaused = false;
        });
        timer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() {
            elapsed += const Duration(seconds: 1);
          });
        });
      } else {
        // Pause recording
        await _recorder.pause();
        setState(() {
          isPaused = true;
        });
        timer?.cancel();
      }
    } else {
      // Start recording
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        setState(() {
          isRecording = true;
          isPaused = false;
          elapsed = Duration.zero;
          recordedFilePath = null;
        });

        timer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() {
            elapsed += const Duration(seconds: 1);
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (isRecording) {
      final path = await _recorder.stop();
      setState(() {
        isRecording = false;
        isPaused = false;
        recordedFilePath = path;
      });
      timer?.cancel();
    }
  }

  Future<void> _playRecording() async {
    if (recordedFilePath != null) {
      try {
        await _audioPlayer.play(DeviceFileSource(recordedFilePath!));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    timer?.cancel();
    _recorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Recording status text above the button
          if (isRecording)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPaused
                          ? "Paused ${_formatTime(elapsed)}"
                          : "Recording... ${_formatTime(elapsed)}",
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Recording button (persistent)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 75,
            child: GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: isRecording
                      ? theme.floatingActionButtonTheme.backgroundColor
                      : theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isRecording
                        ? (isPaused ? Icons.play_arrow : Icons.pause)
                        : Icons.mic,
                    size: 60,
                    color: isRecording
                        ? theme.floatingActionButtonTheme.foregroundColor
                        : theme.iconTheme.color,
                  ),
                ),
              ),
            ),
          ),

          // Stop button (visible when recording)
          if (isRecording)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 + 100,
              child: GestureDetector(
                onTap: _stopRecording,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.stop,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // Playback button and file path (visible when recording is stopped)
          if (recordedFilePath != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    "Saved: $recordedFilePath",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.iconTheme.color,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _playRecording,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Play Recording"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor : theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}