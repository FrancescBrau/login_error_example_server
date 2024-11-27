import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

// Klasse zur Darstellung eines Benutzers
class User {
  final String username;
  final String password;

  /// Konstruktor mit Validierung
  User({required this.username, required this.password})
      : assert(username.isNotEmpty, 'Username cannot be empty');

  /// Benannter Konstruktor: Erstellt einen Benutzer aus einer Map (z. B. aus JSON)
  User.fromMap(Map<String, dynamic> map)
      : username = map['username'] ?? '',
        password = map['password'] ?? '' {
    if (username.isEmpty) {
      throw ArgumentError('Username cannot be empty');
    }
  }

  /// Konvertiert einen Benutzer in eine Map (z. B. für JSON)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }
}

// Benutzer-Repository für die Verwaltung der Benutzerdaten
class UserRepository {
  final String dataFilePath;
  late List<User> _users;

  UserRepository({required this.dataFilePath});

  /// Initialisiert die JSON-Datei und lädt die Benutzer in den Speicher
  Future<void> initialize() async {
    final file = File(dataFilePath);
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
    final file = File(dataFilePath);
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

late final UserRepository userRepository;

// Handler für die Login-Route
Future<Response> loginHandler(Request request) async {
  final body = await request.readAsString();
  final Map<String, dynamic> data = jsonDecode(body);

  final String? username = data['username'];
  final String? password = data['password'];

  // 400 Bad Request: Username ist erforderlich
  if (username == null || username.isEmpty) {
    return Response(400, body: jsonEncode({'message': 'Username is required'}));
  }

  // Überprüfung auf Benutzerexistenz
  if (userRepository.userExists(username, password)) {
    // 200 OK: Login erfolgreich
    return Response.ok(jsonEncode({'message': 'Login successful'}));
  } else {
    // 401 Unauthorized: Ungültige Anmeldedaten
    return Response(401, body: jsonEncode({'message': 'Invalid credentials'}));
  }
}

// Handler für die Registrierung
Future<Response> registerHandler(Request request) async {
  final body = await request.readAsString();
  final Map<String, dynamic> data = jsonDecode(body);

  final String? username = data['username'];
  final String? password = data['password'];

  // 400 Bad Request: Username ist erforderlich
  if (username == null || username.isEmpty) {
    return Response(400, body: jsonEncode({'message': 'Username is required'}));
  }

  // Überprüfung, ob der Benutzername bereits existiert
  if (userRepository.usernameExists(username)) {
    // 409 Conflict: Benutzername bereits vergeben
    return Response(409, body: jsonEncode({'message': 'User already exists'}));
  }

  // Benutzer hinzufügen
  try {
    await userRepository.addUser(username, password);
  } catch (e) {
    // 500 Internal Server Error: Unerwarteter Fehler beim Hinzufügen des Benutzers
    return Response(500,
        body: jsonEncode({'message': 'Internal Server Error'}));
  }

  // 200 OK: Benutzer erfolgreich registriert
  return Response.ok(jsonEncode({'message': 'User registered successfully'}));
}

void main() async {
  // Repository initialisieren
  userRepository = UserRepository(
    dataFilePath: p.join(Directory.current.path, 'users.json'),
  );
  await userRepository.initialize();

  final app = Router();

  // Routen definieren
  app.post('/login', loginHandler);
  app.post('/register', registerHandler);

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app.call);

  // Server starten
  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Server listening on http://${server.address.host}:${server.port}');
}
