import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/player.dart';

class PlayerData {
  static Future<List<Player>> loadByDifficulty(String difficulty) async {
    try {
      // load JSON file
      final String response =
          await rootBundle.loadString('lib/data/players.json');

      final Map<String, dynamic> jsonData = json.decode(response); // ✅ decode as Map
      final List data = jsonData['players'];                        // ✅ extract the list

      // convert to Player objects
      List<Player> allPlayers =
          data.map((e) => Player.fromJson(e)).toList();

      // filter by difficulty
      List<Player> filteredPlayers = allPlayers
          .where((player) =>
              player.difficulty.toLowerCase() ==
              difficulty.toLowerCase())
          .toList();

      return filteredPlayers;
    } catch (e) {
      print("ERROR in PlayerData: $e");
      return [];
    }
  }
}