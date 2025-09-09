import 'package:flutter/material.dart';
import 'package:voicenote/screens/recordingScreen.dart';
import 'package:voicenote/screens/services.dart';
import 'package:voicenote/screens/transcript.dart';


class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme; // 👈 from main.dart

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transcript> transcripts = [];

  @override
  void initState() {
    super.initState();
    _loadTranscripts();
  }

  Future<void> _loadTranscripts() async {
    final data = await StorageService.getTranscripts();
    setState(() {
      transcripts = data.reversed.toList();
    });
  }

  Future<void> _goToRecording() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordingScreen()),
    );
    if (result == true) {
      _loadTranscripts(); // refresh on return
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text("Transcripts"),
        centerTitle: true,
      ),
      body:
      transcripts.isEmpty
          ? const Center(
        child: Text(
          "No transcripts yet",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: transcripts.length,
        itemBuilder: (context, index) {
          final transcript = transcripts[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(
                transcript.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                "${transcript.date}\n${transcript.content}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToRecording,
        child: const Icon(Icons.add),
      ),
    );
  }
}
