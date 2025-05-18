// lib/models/persona.dart
class Persona {
  String name;
  String missionStatement;

  Persona({required this.name, required this.missionStatement});

  // Optional: Add methods for JSON serialization/deserialization if needed for storage
  Map<String, dynamic> toJson() => {
    'name': name,
    'missionStatement': missionStatement,
  };

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
    name: json['name'] as String,
    missionStatement: json['missionStatement'] as String,
  );
}