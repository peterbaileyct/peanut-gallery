import 'package:flutter/material.dart';
import 'package:peanut_gallery/services/storage_service.dart';
import 'package:peanut_gallery/bs_ns_controller.dart';
import 'package:peanut_gallery/models/persona.dart';
import 'package:peanut_gallery/ui/widgets/persona_editor.dart';
import 'package:peanut_gallery/ui/widgets/conversation_display.dart';
import 'package:peanut_gallery/ui/widgets/persona_selector.dart';
import 'package:peanut_gallery/ui/widgets/api_key_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();
  runApp(PeanutGalleryApp(storageService: storageService));
}

class PeanutGalleryApp extends StatelessWidget {
  final StorageService storageService;

  const PeanutGalleryApp({Key? key, required this.storageService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peanut Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(storageService: storageService),
    );
  }
}

class MainScreen extends StatefulWidget {
  final StorageService storageService;

  const MainScreen({Key? key, required this.storageService}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late BsNsController _bsNsController;
  late TextEditingController _questionController;
  Persona _userPersona = Persona(
    name: "Puddin' Tame",
    missionStatement: "I am a good dude and/or a strong lady and I have some questions."
  );
  final List<Persona> _availablePersonas = [];
  List<Persona> _advocatePersonas = [];
  List<Persona> _juryPersonas = [];
  String? _apiKey;
  String _conversationText = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _bsNsController = BsNsController(
      logCallback: (String logMessage) {
        setState(() {
          _conversationText += '$logMessage\n';
        });
      },
      getApiKeyCallback: () async {
        if (_apiKey == null) {
          _showApiKeyDialog();
        }
        return _apiKey ?? '';
      },
    );

    _loadData();
  }

  Future<void> _loadData() async {
    _apiKey = await widget.storageService.getApiKey();
    if (_apiKey == null) {
      _showApiKeyDialog();
    }

    // Load user persona
    var userPersona = await widget.storageService.getUserPersona();
    if (userPersona != null) {
      setState(() {
        _userPersona = userPersona;
      });
    } else {
      // Save the default persona we already created
      await widget.storageService.saveUserPersona(_userPersona);
    }
    
    // Load available personas
    var personas = await widget.storageService.getPersonas();
    if (personas.isEmpty) {
      personas = [
        Persona(
          name: "Stanley",
          missionStatement: "A comedic straight man or a taciturn defense attorney, as the situation demands."
        ),
        Persona(
          name: "Oliver",
          missionStatement: "A humorously exaggerated blowhard or a passionate fighter for justice, as the situation demands."
        )
      ];
      await widget.storageService.savePersonas(personas);
    }
    
    // Update the available personas in state
    setState(() {
      _availablePersonas.clear();
      _availablePersonas.addAll(personas);
    });
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApiKeyDialog(
        onSubmit: (apiKey) async {
          await widget.storageService.saveApiKey(apiKey);
          setState(() {
            _apiKey = apiKey;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _updateUserPersona(String name, String missionStatement) {
    final updatedPersona = Persona(
      name: name,
      missionStatement: missionStatement
    );
    widget.storageService.saveUserPersona(updatedPersona);
    setState(() {
      _userPersona = updatedPersona;
    });
  }

  bool get _canAsk {
    return _userPersona.name.isNotEmpty && 
           _userPersona.missionStatement.isNotEmpty && 
           _advocatePersonas.length == 2 &&
           !_isProcessing;
  }

  void _askQuestion() async {
    if (!_canAsk) return;
    
    final question = _questionController.text;
    if (question.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _conversationText = 'Processing question: $question\n\n';
    });

    final result = await _bsNsController.process(
      question: question,
      userPersona: _userPersona,
      advocates: _advocatePersonas,
      jury: _juryPersonas,
      apiKey: _apiKey!,
      onUpdate: (text) {
        setState(() {
          _conversationText += text;
        });
      }
    );

    setState(() {
      _conversationText += '\n\nFinal result: $result';
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peanut Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: _showApiKeyDialog,
            tooltip: 'Change API Key',
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side - User Persona Editor
          Expanded(
            flex: 3,
            child: PersonaEditor(
              persona: _userPersona,
              onPersonaChanged: _updateUserPersona,
            ),
          ),
          
          // Right side - Conversation display and Persona selection
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // Conversation display
                Expanded(
                  flex: 3,
                  child: ConversationDisplay(text: _conversationText),
                ),
                
                // Question input and Persona selection
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      PersonaSelector(
                        availablePersonas: _availablePersonas,
                        advocatePersonas: _advocatePersonas,
                        juryPersonas: _juryPersonas,
                        onAdvocatesChanged: (advocates) {
                          setState(() {
                            _advocatePersonas = advocates;
                          });
                        },
                        onJuryChanged: (jury) {
                          setState(() {
                            _juryPersonas = jury;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _questionController,
                              decoration: const InputDecoration(
                                hintText: 'Type your question...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              onSubmitted: (_) {
                                if (_canAsk) _askQuestion();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _canAsk ? _askQuestion : null,
                            child: const Text('Ask'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}