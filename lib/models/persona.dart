// lib/models/persona.dart
class Persona {
  final String name;
  final String missionStatement;

  Persona({
    required this.name,
    required this.missionStatement,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'missionStatement': missionStatement,
    };
  }

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      name: json['name'] as String,
      missionStatement: json['missionStatement'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Persona && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}