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
