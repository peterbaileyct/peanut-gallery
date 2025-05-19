// lib/bs_ns_controller.dart
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/persona.dart';

enum EntryType {
  prompt,    // Prompts sent to LLM
  response,  // Responses from LLM
  metadata,  // Information about the process
  system,    // System messages
}

class ConversationEntry {
  final EntryType type;
  final String speaker;
  final String content;
  final DateTime timestamp;
  
  ConversationEntry({
    required this.type,
    this.speaker = '',
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class BSNSController {
  final StreamController<List<ConversationEntry>> _conversationController = 
      StreamController<List<ConversationEntry>>.broadcast();
  
  final List<ConversationEntry> _entries = [];
  
  Stream<List<ConversationEntry>> get conversationStream => _conversationController.stream;
  List<ConversationEntry> get entries => List.unmodifiable(_entries);
  
  void _addEntry(ConversationEntry entry) {
    _entries.add(entry);
    _conversationController.add(_entries);
  }
  
  void clearConversation() {
    _entries.clear();
    _conversationController.add(_entries);
  }
  
  Future<void> processQuestion({
    required String question,
    required Persona userPersona,
    required List<Persona> advocates,
    required List<Persona> jury,
    required String apiKey,
  }) async {
    if (advocates.length != 2) {
      _addEntry(ConversationEntry(
        type: EntryType.system,
        content: 'Error: Exactly 2 advocate personas are required',
      ));
      return;
    }
    
    // Clear previous conversation
    clearConversation();
    
    // Add question to conversation
    _addEntry(ConversationEntry(
      type: EntryType.system,
      speaker: userPersona.name,
      content: question,
    ));
    
    // Log that we're starting BS-NS process
    _addEntry(ConversationEntry(
      type: EntryType.metadata,
      content: 'Starting BS-NS process with advocates: ${advocates.map((a) => a.name).join(", ")}',
    ));
    
    try {
      // This would integrate with the actual BS-NS process defined in bs-ns.few.md
      // For now, we'll simulate the process with a simple implementation
      
      // Advocate 1 response
      await _simulateAdvocateResponse(advocates[0], question, apiKey);
      
      // Advocate 2 response
      await _simulateAdvocateResponse(advocates[1], question, apiKey);
      
      // If jury members are present, get their feedback
      if (jury.isNotEmpty) {
        _addEntry(ConversationEntry(
          type: EntryType.metadata,
          content: 'Getting feedback from jury with ${jury.length} members',
        ));
        
        for (var juror in jury) {
          await _simulateJurorFeedback(juror, question, apiKey);
        }
      }
      
      // Final summary
      _addEntry(ConversationEntry(
        type: EntryType.metadata,
        content: 'BS-NS process completed',
      ));
      
    } catch (e) {
      _addEntry(ConversationEntry(
        type: EntryType.system,
        content: 'Error during BS-NS process: ${e.toString()}',
      ));
    }
  }
  
  // This is a simplified simulation - would be replaced with actual calls to Gemini API
  Future<void> _simulateAdvocateResponse(Persona advocate, String question, String apiKey) async {
    _addEntry(ConversationEntry(
      type: EntryType.prompt,
      speaker: advocate.name,
      content: 'Considering question as ${advocate.name}: "${advocate.missionStatement}"',
    ));
    
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    _addEntry(ConversationEntry(
      type: EntryType.response,
      speaker: advocate.name,
      content: 'This is a simulated response from ${advocate.name} about "$question".\n\n'
          'My perspective as ${advocate.name} (${advocate.missionStatement}) is that...',
    ));
  }
  
  // Simulated jury feedback
  Future<void> _simulateJurorFeedback(Persona juror, String question, String apiKey) async {
    _addEntry(ConversationEntry(
      type: EntryType.prompt,
      speaker: juror.name,
      content: 'Asking for feedback from ${juror.name} (${juror.missionStatement})',
    ));
    
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    _addEntry(ConversationEntry(
      type: EntryType.response,
      speaker: juror.name,
      content: 'As ${juror.name}, I evaluate the arguments as follows...',
    ));
  }
  
  // In a real implementation, this would make actual API calls to Google Gemini
  Future<String> _callGeminiAPI(String prompt, String apiKey) async {
    // This is just a placeholder - actual implementation would use the Gemini API
    throw UnimplementedError('Gemini API integration not implemented');
  }
}