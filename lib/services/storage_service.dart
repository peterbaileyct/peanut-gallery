// lib/services/storage_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/persona.dart';

class StorageService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String _apiKeyKey = 'gemini_api_key';
  final String _personasKey = 'personas';
  final String _userPersonaKey = 'user_persona';
  
  List<Persona> _personas = [];
  Persona? _userPersona;
  
  List<Persona> get personas => _personas;
  Persona? get userPersona => _userPersona;
  
  Future<void> initialize() async {
    await _loadPersonas();
    await _loadUserPersona();
    
    // Create default personas if none exist
    if (_personas.isEmpty) {
      _personas = [
        Persona(
          id: 'stanley',
          name: 'Stanley',
          missionStatement: 'A comedic straight man or a taciturn defense attorney, as the situation demands.'
        ),
        Persona(
          id: 'oliver',
          name: 'Oliver',
          missionStatement: 'A humorously exaggerated blowhard or a passionate fighter for justice, as the situation demands.'
        ),
      ];
      _savePersonas();
    }
    
    // Create default user persona if none exists
    if (_userPersona == null) {
      _userPersona = Persona(
        id: 'user',
        name: 'Puddin\' Tame',
        missionStatement: 'I am a good dude and/or a strong lady and I have some questions.'
      );
      _saveUserPersona();
    }
  }
  
  // API Key methods
  Future<String?> getGeminiApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey);
  }
  
  Future<void> saveGeminiApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeyKey, value: apiKey);
    notifyListeners();
  }
  
  // Persona methods
  Future<void> _loadPersonas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dynamic personasData = prefs.get(_personasKey);
      
      if (personasData != null) {
        List<dynamic> decodedList;
        
        if (personasData is String) {
          // Handle string (expected JSON format)
          decodedList = jsonDecode(personasData);
        } else if (personasData is List) {
          // Handle case where it's already a List
          decodedList = personasData;
        } else {
          // Unexpected format, reset to empty
          decodedList = [];
        }
        
        _personas = decodedList.map((item) => Persona.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading personas: $e');
      // Reset to empty list on error
      _personas = [];
    }
  }
  
  Future<void> _savePersonas() async {
    final prefs = await SharedPreferences.getInstance();
    final String personasJson = jsonEncode(_personas.map((p) => p.toJson()).toList());
    await prefs.setString(_personasKey, personasJson);
    notifyListeners();
  }
  
  Future<void> addPersona(Persona persona) async {
    _personas.add(persona);
    await _savePersonas();
  }
  
  Future<void> updatePersona(Persona persona) async {
    final index = _personas.indexWhere((p) => p.id == persona.id);
    if (index >= 0) {
      _personas[index] = persona;
      await _savePersonas();
    }
  }
  
  Future<void> deletePersona(String id) async {
    _personas.removeWhere((p) => p.id == id);
    await _savePersonas();
  }
  
  // User Persona methods
  Future<void> _loadUserPersona() async {
    final prefs = await SharedPreferences.getInstance();
    final String? personaJson = prefs.getString(_userPersonaKey);
    
    if (personaJson != null) {
      _userPersona = Persona.fromJson(jsonDecode(personaJson));
    }
  }
  
  Future<void> _saveUserPersona() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userPersona != null) {
      final String personaJson = jsonEncode(_userPersona!.toJson());
      await prefs.setString(_userPersonaKey, personaJson);
    }
    notifyListeners();
  }
  
  Future<void> updateUserPersona(Persona persona) async {
    _userPersona = persona.copyWith(id: 'user');
    await _saveUserPersona();
  }
}