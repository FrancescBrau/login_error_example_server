import 'dart:convert';
import 'dart:io';

import 'user.dart';

class UserRepository {
  final String _dataFilePath;
  late List<User> _users;

  UserRepository({required String dataFilePath}) : _dataFilePath = dataFilePath;

  /// Initialisiert die JSON-Datei und lädt die Benutzer in den Speicher
  Future<void> initialize() async {
    final file = File(_dataFilePath);
    if (!await file.exists()) {
      await file.writeAsString(jsonEncode([]));
    }
    final content = await file.readAsString();
    final List<dynamic> userData = jsonDecode(content);
    _users = [];
    for (final userMap in userData) {
      try {
        final user = User.fromMap(userMap);
        _users.add(user);
      } catch (e) {
        // Benutzer mit leerem Namen werden ignoriert
        print('Skipping invalid user: $userMap');
      }
    }
  }

  /// Speichert die Benutzerliste zurück in die Datei
  Future<void> _persist() async {
    final file = File(_dataFilePath);
    final List<Map<String, dynamic>> userMaps = [];
    for (final user in _users) {
      userMaps.add(user.toMap());
    }
    await file.writeAsString(jsonEncode(userMaps));
  }

  /// Gibt alle Benutzer zurück (nur für Debugging, nicht in der API verwendet)
  List<User> getAllUsers() {
    final List<User> usersCopy = [];
    for (final user in _users) {
      usersCopy.add(user);
    }
    return usersCopy;
  }

  /// Prüft, ob ein Benutzer mit gegebenen Zugangsdaten existiert
  bool userExists(String username, String? password) {
    for (final user in _users) {
      if (user.username == username && user.password == password) {
        return true;
      }
    }
    return false;
  }

  /// Prüft, ob ein Benutzername bereits existiert
  bool usernameExists(String username) {
    for (final user in _users) {
      if (user.username == username) {
        return true;
      }
    }
    return false;
  }

  /// Fügt einen neuen Benutzer hinzu
  Future<void> addUser(String username, String? password) async {
    if (username.isEmpty) {
      throw ArgumentError('Username cannot be empty');
    }
    _users.add(User(username: username, password: password ?? ''));
    await _persist();
  }
}
