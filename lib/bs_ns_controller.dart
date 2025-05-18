// lib/bs_ns_controller.dart
import 'models/persona.dart';
import 'bs_ns.dart'; // Assuming bs_ns.dart is in lib/
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:peanut_gallery/models/persona.dart';

class BsNsController {
  final Function(String) logCallback;
  final Future<String?> Function() getApiKeyCallback; // To fetch API key when needed
  late BsNs _bsNsInstance;

  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  BsNsController({required this.logCallback, required this.getApiKeyCallback}) {
    _bsNsInstance = BsNs(logCallback: logCallback, getApiKeyCallback: getApiKeyCallback);
  }

  Future<void> startMediation({
    required Persona userPersona,
    required List<Persona> advocates,
    required List<Persona> jury,
    required String question,
  }) async {
    // Ensure advocates are exactly two as per spec, though bs_ns.dart might also validate
    if (advocates.length != 2) {
      logCallback("Error: Exactly two advocates are required.");
      return;
    }
    await _bsNsInstance.mediate(
      userPersona: userPersona,
      advocates: advocates,
      jury: jury,
      question: question,
    );
  }

  /// Processes a question using the BS-NS methodology
  /// 
  /// Takes a question and runs it through the BS-NS process using the provided personas
  /// Returns the final answer and provides updates through the onUpdate callback
  Future<String> process({
    required String question,
    required Persona userPersona,
    required List<Persona> advocates,
    required List<Persona> jury,
    required String apiKey,
    required Function(String) onUpdate,
  }) async {
    if (advocates.length != 2) {
      throw ArgumentError('Exactly 2 advocate personas are required');
    }
    
    // Step 1: Initial analysis by advocates
    onUpdate('Step 1: Advocates analyzing the question...\n');
    
    final advocate1Response = await _getPersonaResponse(
      persona: advocates[0],
      question: question,
      role: 'Advocate',
      apiKey: apiKey,
    );
    
    onUpdate('\n${advocates[0].name} (Advocate 1):\n$advocate1Response\n');
    
    final advocate2Response = await _getPersonaResponse(
      persona: advocates[1],
      question: question,
      role: 'Advocate',
      apiKey: apiKey,
    );
    
    onUpdate('\n${advocates[1].name} (Advocate 2):\n$advocate2Response\n');
    
    // Step 2: Jury deliberation
    String juryResponse = '';
    if (jury.isNotEmpty) {
      onUpdate('\nStep 2: Jury deliberation...\n');
      
      final juryDeliberation = await _conductJuryDeliberation(
        question: question,
        advocate1: advocates[0],
        advocate1Response: advocate1Response,
        advocate2: advocates[1],
        advocate2Response: advocate2Response,
        jury: jury,
        apiKey: apiKey,
      );
      
      juryResponse = juryDeliberation;
      onUpdate('\nJury Deliberation:\n$juryResponse\n');
    }
    
    // Step 3: Final synthesis
    onUpdate('\nStep 3: Final synthesis...\n');
    
    final finalResponse = await _synthesizeFinalResponse(
      question: question,
      userPersona: userPersona,
      advocate1: advocates[0],
      advocate1Response: advocate1Response,
      advocate2: advocates[1],
      advocate2Response: advocate2Response,
      juryResponse: juryResponse,
      apiKey: apiKey,
    );
    
    onUpdate('\nFinal Response:\n$finalResponse\n');
    
    return finalResponse;
  }
  
  Future<String> _getPersonaResponse({
    required Persona persona,
    required String question,
    required String role,
    required String apiKey,
  }) async {
    final prompt = '''
    You are ${persona.name}, with the following mission: "${persona.missionStatement}"
    
    As a $role, your task is to analyze and respond to this question:
    
    "$question"
    
    Provide your perspective based on your mission statement. Be thorough but concise.
    ''';
    
    return await _callGeminiApi(prompt: prompt, apiKey: apiKey);
  }
  
  Future<String> _conductJuryDeliberation({
    required String question,
    required Persona advocate1,
    required String advocate1Response,
    required Persona advocate2,
    required String advocate2Response,
    required List<Persona> jury,
    required String apiKey,
  }) async {
    final juryNames = jury.map((p) => p.name).join(', ');
    final juryMissions = jury.map((p) => '${p.name}: "${p.missionStatement}"').join('\n');
    
    final prompt = '''
    You are acting as a jury consisting of: $juryNames
    
    Each jury member has the following mission statement:
    $juryMissions
    
    You are deliberating on the following question:
    "$question"
    
    Two advocates have presented their perspectives:
    
    ${advocate1.name} said:
    "$advocate1Response"
    
    ${advocate2.name} said:
    "$advocate2Response"
    
    As the jury, deliberate on these perspectives and provide a consensus view. If consensus isn't possible, note areas of agreement and disagreement.
    Respond in a single voice representing the jury's collective judgment.
    ''';
    
    return await _callGeminiApi(prompt: prompt, apiKey: apiKey);
  }
  
  Future<String> _synthesizeFinalResponse({
    required String question,
    required Persona userPersona,
    required Persona advocate1,
    required String advocate1Response,
    required Persona advocate2,
    required String advocate2Response,
    required String juryResponse,
    required String apiKey,
  }) async {
    final hasJuryInput = juryResponse.isNotEmpty;
    
    final prompt = '''
    You are helping ${userPersona.name}, whose mission is "${userPersona.missionStatement}",
    to synthesize perspectives on the question:
    
    "$question"
    
    The following perspectives were provided:
    
    ${advocate1.name} (Advocate 1) said:
    "$advocate1Response"
    
    ${advocate2.name} (Advocate 2) said:
    "$advocate2Response"
    
    ${hasJuryInput ? 'The jury deliberation resulted in:\n"$juryResponse"\n\n' : ''}
    
    Synthesize a final, balanced answer to the question that takes into account all perspectives.
    Focus on providing practical, actionable insights if applicable.
    ''';
    
    return await _callGeminiApi(prompt: prompt, apiKey: apiKey);
  }
  
  Future<String> _callGeminiApi({
    required String prompt,
    required String apiKey,
  }) async {
    final url = '$_geminiBaseUrl?key=$apiKey';
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text': prompt
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      }
    };
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to get response from Gemini API: ${response.body}');
    }
  }
}