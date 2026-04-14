class Player {
  final int id;
  final String name;
  final String imageUrl;
  final String difficulty;
  final String country;
  final List<String> aliases; 
  // Constructor — creates a Player object
  Player({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.difficulty,
    required this.country,
    this.aliases = const [], 
  });

  // Factory constructor — converts a JSON map into a Player object
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      difficulty: json['difficulty'],
      country: json['country'],
    );
  }
}