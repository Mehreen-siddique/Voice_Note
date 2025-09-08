
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder(); // Use AudioRecorder instead of Record
  bool isRecording = false;
  Duration elapsed = Duration.zero;
  Timer? timer;
  String? recordedFilePath;

  Future<void> _toggleRecording() async {
    if (isRecording) {
      // Stop recording
      final path = await _recorder.stop();
      setState(() {
        isRecording = false;
        recordedFilePath = path;
      });
      timer?.cancel();
    } else {
      // Check for permission
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Start recording
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
          elapsed = Duration.zero;
          recordedFilePath = null;
        });

        timer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() {
            elapsed += const Duration(seconds: 1);
          });
        });
      } else {
        // Handle permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
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
    _recorder.dispose(); // Dispose AudioRecorder
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (isRecording)
            Container(
              height: 60,
              width: double.infinity,
              color: theme.cardColor.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fiber_manual_record,
                      color: theme.colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Recording... ${_formatTime(elapsed)}",
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: isRecording ? 150 : MediaQuery.of(context).size.height / 2 - 75,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
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
                    isRecording ? Icons.pause : Icons.mic,
                    size: 60,
                    color: isRecording
                        ? theme.floatingActionButtonTheme.foregroundColor
                        : theme.iconTheme.color,
                  ),
                ),
              ),
            ),
          ),

          if (recordedFilePath != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Text(
                "Saved: $recordedFilePath",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.iconTheme.color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}