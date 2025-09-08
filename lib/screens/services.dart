import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voicenote/screens/transcript.dart';


class StorageService {
  static const String transcriptsKey = "transcripts";

  /// Save new transcript
  static Future<void> saveTranscript(Transcript transcript) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList =
        prefs.getStringList(transcriptsKey) ?? [];

    savedList.add(jsonEncode(transcript.toJson()));
    await prefs.setStringList(transcriptsKey, savedList);
  }

  /// Get all transcripts
  static Future<List<Transcript>> getTranscripts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList =
        prefs.getStringList(transcriptsKey) ?? [];

    return savedList
        .map((jsonStr) => Transcript.fromJson(jsonDecode(jsonStr)))
        .toList();
  }
}
