// lib/services/storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/persona.dart';

class StorageService {
  static const String _apiKeyKey = 'gemini_api_key';
  static const String _userPersonaKey = 'user_persona';
  static const String _personasKey = 'personas';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // API Key Management
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey);
  }
  
  Future<void> saveApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeyKey, value: apiKey);
  }
  
  // User Persona Management
  Future<Persona?> getUserPersona() async {
    final personaJson = _prefs.getString(_userPersonaKey);
    if (personaJson == null) return null;
    
    final Map<String, dynamic> data = json.decode(personaJson);
    return Persona.fromJson(data);
  }
  
  Future<void> saveUserPersona(Persona persona) async {
    await _prefs.setString(_userPersonaKey, json.encode(persona.toJson()));
  }
  
  // Other Personas Management
  Future<List<Persona>> getPersonas() async {
    final personasJson = _prefs.getStringList(_personasKey);
    if (personasJson == null) return [];
    
    return personasJson
        .map((personaJson) => Persona.fromJson(json.decode(personaJson)))
        .toList();
  }
  
  Future<void> savePersonas(List<Persona> personas) async {
    final personasJson = personas
        .map((persona) => json.encode(persona.toJson()))
        .toList();
    
    await _prefs.setStringList(_personasKey, personasJson);
  }
  
  Future<void> addPersona(Persona persona) async {
    final personas = await getPersonas();
    personas.add(persona);
    await savePersonas(personas);
  }
  
  Future<void> updatePersona(Persona updatedPersona) async {
    final personas = await getPersonas();
    final index = personas.indexWhere((p) => p.name == updatedPersona.name);
    
    if (index != -1) {
      personas[index] = updatedPersona;
      await savePersonas(personas);
    }
  }
  
  Future<void> deletePersona(String name) async {
    final personas = await getPersonas();
    personas.removeWhere((p) => p.name == name);
    await savePersonas(personas);
  }
}