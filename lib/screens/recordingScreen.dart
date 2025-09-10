import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  final AudioRecorder audioRecorder = AudioRecorder();
  late AnimationController _waveController;
  List<double> _waveHeights = List.generate(20, (_) => 10.0);

  String? recordingPath;
  bool isRecording = false;
  int seconds = 0;
  Timer? timer;

  void startRecording() async {
    if (await audioRecorder.hasPermission()) {
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final String filePath = p.join(appDocumentsDir.path, "recording.wav");
      await audioRecorder.start(const RecordConfig(), path: filePath);
      setState(() {
        isRecording = true;
        seconds = 0;
        recordingPath = null;
      });
      _waveController.repeat(); // Moved inside: Start animation only if permission granted and recording starts
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (mounted) {
          setState(() {
            seconds++;
          });
        }
      });
    }
  }

  void stopRecording() async {
    String? filePath = await audioRecorder.stop(); // Capture the returned file path from stop()
    timer?.cancel();
    _waveController.stop();
    if (mounted) { // Always update UI if mounted
      setState(() {
        isRecording = false;
        seconds = 0; // Reset seconds
        recordingPath = filePath; // Set the path (even if null, but handle errors if needed)
      });
    }
    // Optional: If filePath is null, show an error message or log it
    if (filePath == null) {
      // Handle error, e.g., show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recording failed to save')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
      if (isRecording && mounted) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text("Recording"),
        actions: isRecording
            ? [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: stopRecording, // Updated: Call stopRecording() when "Save" is pressed (or rename button to "Stop" if preferred)
              child: Row(
                children: [
                  Icon(
                    Icons.save,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  const SizedBox(width: 5),
                  const Text("Save"),
                ],
              ),
            ),
          )
        ]
            : [],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecording)
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_waveHeights.length, (index) {
                          return Expanded(
                            child: Container(
                              height: _waveHeights[index],
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              color: Colors.black,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Recording... $seconds s",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: isRecording ? 50 : 0),
              child: GestureDetector(
                onTap: () {
                  if (isRecording) {
                    stopRecording();
                  } else {
                    startRecording();
                  }
                },
                child: Container(
                  height: 120,
                  width: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    isRecording ? Icons.mic_off : Icons.mic,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    size: 35,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap to record",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (recordingPath != null) // New: Show the saved path after stopping (replace with navigation if needed)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Saved at: $recordingPath",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 20),
            if (isRecording)
              Container(
                height: 200,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  "Live Transcript",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}