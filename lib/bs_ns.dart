// lib/bs_ns.dart
// IMPORTANT: This file will require the google_generative_ai package or similar
// for interacting with the Gemini API. Add it to your pubspec.yaml
// e.g., `flutter pub add google_generative_ai`

import 'models/persona.dart';
// You would typically use the official Gemini SDK, e.g., package:google_generative_ai
// For this example, I'll mock the API calls conceptually.
// import 'package:google_generative_ai/google_generative_ai.dart'; // Example import

// Placeholder for actual Gemini API interaction.
// In a real app, this would use the `google_generative_ai` package.
class GeminiApiService {
  final String apiKey;
  final Function(String) logCallback;

  GeminiApiService({required this.apiKey, required this.logCallback});

  Future<String> generateContent(String prompt) async {
    logCallback("LLM PROMPT: $prompt");
    // --- 실제 Gemini API 호출 로직 ---
    // final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    // final content = [Content.text(prompt)];
    // final response = await model.generateContent(content);
    // logCallback("LLM RESPONSE: ${response.text}");
    // return response.text ?? "Error: No response from LLM.";
    // -----------------------------------

    // Mocked response for now:
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    String mockResponse;
    if (prompt.contains("simulated mediation jury")) {
      mockResponse = "Jury Report: The jury is composed of diverse individuals ready to listen.";
    } else if (prompt.contains("Your goal is to seek a peaceful resolution")) {
        mockResponse = "Understood. I am ready to mediate.";
    } else if (prompt.toLowerCase().contains("resolved")) {
        mockResponse = "I agree. RESOLVED";
    } else if (prompt.contains("generate a summary of the resolution")) {
        mockResponse = "Summary: A peaceful resolution was found through constructive dialogue.";
    }
     else {
      mockResponse = "This is a thoughtful point. I will consider it. What does my colleague think?";
    }
    logCallback("LLM RESPONSE (Mocked): $mockResponse");
    return mockResponse;
  }
}


class BsNs {
  final Function(String) logCallback;
  final Future<String?> Function() getApiKeyCallback;
  // late GeminiApiService _geminiService; // Uncomment when using actual API

  BsNs({required this.logCallback, required this.getApiKeyCallback});

  Future<void> mediate({
    required Persona userPersona,
    required List<Persona> advocates, // Should be exactly 2
    required List<Persona> jury,
    required String question,
  }) async {
    final apiKey = await getApiKeyCallback();
    if (apiKey == null || apiKey.isEmpty) {
      logCallback("BS-NS Error: Gemini API Key is not available.");
      return;
    }
    // _geminiService = GeminiApiService(apiKey: apiKey, logCallback: logCallback); // Uncomment

    // For mocking without the actual SDK for now:
    final mockGeminiService = GeminiApiService(apiKey: apiKey, logCallback: logCallback);

    logCallback("BS-NS: Mediation process started.");

    String juryReport = "";
    if (jury.isNotEmpty) {
      String juryPrompt = "Please generate a short summary of the members of a simulated mediation jury. They are:\n";
      for (var juror in jury) {
        juryPrompt += "- ${juror.name}: ${juror.missionStatement}\n";
      }
      // juryReport = await _geminiService.generateContent(juryPrompt); // Uncomment
      juryReport = await mockGeminiService.generateContent(juryPrompt); // Mock
      logCallback("BS-NS: Jury Report received.");
    }

    // Initialize Advocates
    List<String> advocateResponses = ["", ""];
    List<String> advocateLastMessage = ["", ""]; // To pass to the other advocate

    List<String> initialPrompts = List.generate(2, (i) {
      String advocatePrompt = "You are playing the role of a conflict mediator. Your name is ${advocates[i].name}. Your mission statement is: \"${advocates[i].missionStatement}\". Your goal is to seek a peaceful resolution. When you feel that a peaceful resolution has been identified, you will end your message with the word RESOLVED in a single line in all capitals.\n";
      if (jury.isNotEmpty) {
        advocatePrompt += "There is a jury for this dispute. You are encouraged to discuss the matter in terms that will be meaningful to them. They are:\n";
        for (var juror in jury) {
          advocatePrompt += "- ${juror.name}: ${juror.missionStatement}\n";
        }
         advocatePrompt += "\nJury Summary: $juryReport\n";
      }
      advocatePrompt += "${userPersona.name} (Mission: \"${userPersona.missionStatement}\") brings you a matter to resolve. They ask: \"$question\"";
      return advocatePrompt;
    });

    // Initial interaction with advocates
    for (int i = 0; i < 2; i++) {
      // advocateResponses[i] = await _geminiService.generateContent(initialPrompts[i]); // Uncomment
      advocateResponses[i] = await mockGeminiService.generateContent(initialPrompts[i]); // Mock
      advocateLastMessage[i] = "${advocates[i].name} says: ${advocateResponses[i]}";
      logCallback("${advocates[i].name}: ${advocateResponses[i]}");
    }


    int iterations = 0;
    bool advocate1Resolved = advocateResponses[0].trim().endsWith("RESOLVED");
    bool advocate2Resolved = advocateResponses[1].trim().endsWith("RESOLVED");

    while (!(advocate1Resolved && advocate2Resolved) && iterations < 10) {
      iterations++;
      logCallback("\nBS-NS: Iteration ${iterations + 1}");

      // Advocate 1 responds to Advocate 2's last message
      String promptForAdvocate1 = "${initialPrompts[0]}\n\nYour colleague, ${advocates[1].name}, previously said: \"${advocateResponses[1]}\"\nWhat is your response?";
      // advocateResponses[0] = await _geminiService.generateContent(promptForAdvocate1); // Uncomment
      advocateResponses[0] = await mockGeminiService.generateContent(promptForAdvocate1); // Mock
      advocateLastMessage[0] = "${advocates[0].name} says: ${advocateResponses[0]}";
      logCallback("${advocates[0].name}: ${advocates[0]}");
      advocate1Resolved = advocateResponses[0].trim().endsWith("RESOLVED");


      if (advocate1Resolved && advocate2Resolved) break; // Check early if both resolved

      // Advocate 2 responds to Advocate 1's last message
      String promptForAdvocate2 = "${initialPrompts[1]}\n\nYour colleague, ${advocates[0].name}, previously said: \"${advocateResponses[0]}\"\nWhat is your response?";
      // advocateResponses[1] = await _geminiService.generateContent(promptForAdvocate2); // Uncomment
      advocateResponses[1] = await mockGeminiService.generateContent(promptForAdvocate2); // Mock
      advocateLastMessage[1] = "${advocates[1].name} says: ${advocateResponses[1]}";
      logCallback("${advocates[1].name}: ${advocateResponses[1]}");
      advocate2Resolved = advocateResponses[1].trim().endsWith("RESOLVED");
    }

    if (advocate1Resolved && advocate2Resolved) {
      logCallback("\nBS-NS: Both advocates have indicated RESOLVED.");
      String summaryPrompt = "Based on the user's mission statement: \"${userPersona.missionStatement}\", and the preceding discussion where both advocates (${advocates[0].name} and ${advocates[1].name}) agreed on a resolution, please generate a summary of the resolution.\nAdvocate 1 (${advocates[0].name}) last said: ${advocateResponses[0]}\nAdvocate 2 (${advocates[1].name}) last said: ${advocateResponses[1]}";
      // String resolutionSummary = await _geminiService.generateContent(summaryPrompt); // Uncomment
      String resolutionSummary = await mockGeminiService.generateContent(summaryPrompt); // Mock
      logCallback("BS-NS: Resolution Summary: $resolutionSummary");
    } else {
      logCallback("\nBS-NS: No resolution could be found after ${iterations + 1} iterations. This matter should be brought to the attention of carbon-based life forms.");
    }
    logCallback("BS-NS: Mediation process ended.");
  }
}