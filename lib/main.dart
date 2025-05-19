import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'models/persona.dart';
import 'ui/widgets/persona_editor.dart';
import 'ui/widgets/conversation_display.dart';
import 'ui/widgets/persona_selector.dart';
import 'ui/widgets/api_key_dialog.dart';
import 'bs_ns_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => storageService),
      ],
      child: PeanutGalleryApp(),
    ),
  );
}

class PeanutGalleryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peanut Gallery',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<Persona> _selectedAdvocates = [];
  final List<Persona> _selectedJury = [];
  final BSNSController _bsNsController = BSNSController();
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }
  
  void _checkApiKey() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final apiKey = await storageService.getGeminiApiKey();
    
    if (apiKey == null || apiKey.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showApiKeyDialog();
      });
    }
  }
  
  void _showApiKeyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApiKeyDialog(
        onSaved: () {
          // Dialog will handle saving the API key
          setState(() {});
        },
      ),
    );
  }
  
  bool get _canAsk => 
    _selectedAdvocates.length == 2 && 
    !_isProcessing &&
    _questionController.text.trim().isNotEmpty &&
    Provider.of<StorageService>(context, listen: false).userPersona != null &&
    Provider.of<StorageService>(context, listen: false).userPersona!.name.isNotEmpty &&
    Provider.of<StorageService>(context, listen: false).userPersona!.missionStatement.isNotEmpty;
  
  void _askQuestion() async {
    if (!_canAsk) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final storageService = Provider.of<StorageService>(context, listen: false);
      final userPersona = storageService.userPersona!;
      final apiKey = await storageService.getGeminiApiKey();
      
      await _bsNsController.processQuestion(
        question: _questionController.text,
        userPersona: userPersona,
        advocates: _selectedAdvocates,
        jury: _selectedJury,
        apiKey: apiKey!,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final storageService = Provider.of<StorageService>(context);
    final availablePersonas = storageService.personas
        .where((p) => p.id != storageService.userPersona?.id)
        .toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Peanut Gallery'),
        actions: [
          IconButton(
            icon: Icon(Icons.vpn_key),
            onPressed: _showApiKeyDialog,
            tooltip: 'Set API Key',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - User Persona editor
                SizedBox(
                  width: 300,
                  child: PersonaEditor(
                    persona: storageService.userPersona,
                    onSave: (persona) {
                      storageService.updateUserPersona(persona);
                    },
                  ),
                ),
                
                // Middle - Conversation display
                Expanded(
                  child: ConversationDisplay(
                    controller: _bsNsController,
                  ),
                ),
                
                // Right side - Persona selector
                SizedBox(
                  width: 250,
                  child: PersonaSelector(
                    availablePersonas: availablePersonas,
                    selectedAdvocates: _selectedAdvocates,
                    selectedJury: _selectedJury,
                    onAdvocatesChanged: (advocates) {
                      setState(() {
                        _selectedAdvocates.clear();
                        _selectedAdvocates.addAll(advocates);
                      });
                    },
                    onJuryChanged: (jury) {
                      setState(() {
                        _selectedJury.clear();
                        _selectedJury.addAll(jury);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Question input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Enter your question here...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (_canAsk) _askQuestion();
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _canAsk ? _askQuestion : null,
                  child: Text('Ask'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 64),
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