import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'user_repository.dart';

void main() async {
  // Repository initialisieren
  final userRepository = UserRepository(dataFilePath: 'users.json');
  await userRepository.initialize();

  final app = Router();

  app.get('/', (Request request) async {
    String info = '''
    Welcome to the User Management Server!

    Available endpoints:
    - POST /register : Register a new user with a username and password.
    - POST /login    : Login with your username and password.

    Example usage:
    - Register: curl -X POST http://0.0.0.0:8080/register -H "Content-Type: application/json" -d '{"username": "testuser", "password": "mypassword"}'
    - Login:    curl -X POST http://0.0.0.0:8080/login -H "Content-Type: application/json" -d '{"username": "testuser", "password": "mypassword"}'
    ''';
    return Response.ok(info, headers: {'Content-Type': 'text/plain'});
  });

  // Routen definieren
  app.post('/login', (Request request) async {
    final body = await request.readAsString();
    final Map<String, dynamic> data = jsonDecode(body);

    final String? username = data['username'];
    final String? password = data['password'];

    // 400 Bad Request: Username ist erforderlich
    if (username == null || username.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'message': 'Username is required'}),
      );
    }

    // Überprüfung auf Benutzerexistenz
    if (userRepository.userExists(username, password)) {
      // 200 OK: Login erfolgreich
      return Response.ok(jsonEncode({'message': 'Login successful'}));
    } else {
      // 401 Unauthorized: Ungültige Anmeldedaten
      return Response(
        401,
        body: jsonEncode({'message': 'Invalid credentials'}),
      );
    }
  });

  app.post('/register', (Request request) async {
    final body = await request.readAsString();
    final Map<String, dynamic> data = jsonDecode(body);

    if (body.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'message': 'Data to register is required'}),
      );
    }

    final String? username = data['username'];
    final String? password = data['password'];

    // 400 Bad Request: Username ist erforderlich
    if (username == null || username.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'message': 'Username is required'}),
      );
    }

    // Überprüfung, ob der Benutzername bereits existiert
    if (userRepository.usernameExists(username)) {
      // 409 Conflict: Benutzername bereits vergeben
      return Response(
        409,
        body: jsonEncode({'message': 'User already exists'}),
      );
    }

    // Benutzer hinzufügen
    try {
      await userRepository.addUser(username, password);
    } catch (e) {
      // 500 Internal Server Error: Unerwarteter Fehler beim Hinzufügen des Benutzers
      return Response(
        500,
        body: jsonEncode({'message': 'Internal Server Error'}),
      );
    }

    // 200 OK: Benutzer erfolgreich registriert
    return Response.ok(jsonEncode({'message': 'User registered successfully'}));
  });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app.call);

  // Server starten
  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Server listening on http://${server.address.host}:${server.port}');
}
