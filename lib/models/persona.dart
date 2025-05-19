// lib/models/persona.dart
import 'package:uuid/uuid.dart';

class Persona {
  final String id;
  final String name;
  final String missionStatement;

  Persona({
    String? id,
    required this.name,
    required this.missionStatement,
  }) : id = id ?? Uuid().v4();

  Persona copyWith({
    String? id,
    String? name,
    String? missionStatement,
  }) {
    return Persona(
      id: id ?? this.id,
      name: name ?? this.name,
      missionStatement: missionStatement ?? this.missionStatement,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'missionStatement': missionStatement,
    };
  }

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: json['id'],
      name: json['name'],
      missionStatement: json['missionStatement'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Persona && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}