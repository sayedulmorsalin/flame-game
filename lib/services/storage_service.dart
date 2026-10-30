import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class StorageService {
  static const String _keyGameState = 'btminer_save_state_v1';

  static Future<void> saveGame(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_keyGameState, jsonString);
    } catch (e) {
      // Error handling
    }
  }

  static Future<DateTime?> loadGame(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyGameState);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonString);
        state.loadFromJson(data);
        return state.lastActiveTime;
      }
    } catch (e) {
      // Load error
    }
    return null;
  }
}
