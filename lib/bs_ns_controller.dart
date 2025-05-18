// lib/bs_ns_controller.dart
import 'models/persona.dart';
import 'bs_ns.dart'; // Assuming bs_ns.dart is in lib/

class BsNsController {
  final Function(String) logCallback;
  final Future<String?> Function() getApiKeyCallback; // To fetch API key when needed
  late BsNs _bsNsInstance;

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
}