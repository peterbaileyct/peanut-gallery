// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/persona.dart'; // Assuming persona.dart is in lib/models/

class StorageService {
     static const String _apiKey = 'gemini_api_key';
static const String _userPersonaKey = 'user_persona';
static const String _otherPersonasKey = 'other_personas';

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKey, apiKey);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKey);
  }

  Future<void> saveUserPersona(Persona persona) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPersonaKey, jsonEncode(persona.toJson()));
  }

  Future<Persona?> getUserPersona() async {
    final prefs = await SharedPreferences.getInstance();
    final personaJson = prefs.getString(_userPersonaKey);
    if (personaJson != null) {
      return Persona.fromJson(jsonDecode(personaJson));
    }
    return null;
  }

  Future<void> saveOtherPersonas(List<Persona> personas) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> personasJsonList = personas.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_otherPersonasKey, personasJsonList);
  }

  Future<List<Persona>> getOtherPersonas() async {
    final prefs = await SharedPreferences.getInstance();
    final personasJsonList = prefs.getStringList(_otherPersonasKey);
    if (personasJsonList != null) {
      return personasJsonList.map((json) => Persona.fromJson(jsonDecode(json))).toList();
    }
    return [];
  }

  // Helper to save a single "other" persona (used for defaults)
  Future<void> savePersona(Persona persona) async {
      List<Persona> others = await getOtherPersonas();
      // Avoid duplicates by name, update if exists
      others.removeWhere((p) => p.name == persona.name);
      others.add(persona);
      await saveOtherPersonas(others);
  }
}