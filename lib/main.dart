// lib/main.dart (Conceptual Outline)
import 'package:flutter/material.dart';
import 'models/persona.dart';
import 'services/storage_service.dart';
import 'bs_ns_controller.dart';
// Potentially: import 'ui/widgets/persona_editor.dart';
// Potentially: import 'ui/widgets/llm_output_display.dart';
// Potentially: import 'ui/widgets/question_input.dart';
// Potentially: import 'ui/widgets/advocate_jury_selector.dart';

void main() {
  runApp(PeanutGalleryApp());
}

class PeanutGalleryApp extends StatelessWidget {
  const PeanutGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peanut Gallery',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // User Persona state
  Persona userPersona = Persona(name: "Puddin' Tame", missionStatement: "I am a good dude and/or a strong lady and I have some questions.");
  TextEditingController userNameController = TextEditingController();
  TextEditingController userMissionController = TextEditingController();

  // API Key state
  String? geminiApiKey;

  // Advocates and Jury state
  List<Persona> availablePersonas = [];
  List<Persona?> selectedAdvocates = [null, null];
  List<Persona?> selectedJury = List.filled(12, null);

  // LLM Output log
  List<String> llmLog = [];

  // Question state
  TextEditingController questionController = TextEditingController();

  // Services and Controllers
  late StorageService storageService;
  late BsNsController bsNsController;

  @override
  void initState() {
    super.initState();
    storageService = StorageService();
    bsNsController = BsNsController(
      logCallback: (logEntry) {
        setState(() {
          llmLog.add(logEntry);
        });
      },
      getApiKeyCallback: () => Future.value(geminiApiKey),
    );
    _loadInitialData();
  }

  void _loadInitialData() async {
    // Load API Key
    geminiApiKey = await storageService.getApiKey();

    // Load User Persona
    Persona? storedUserPersona = await storageService.getUserPersona();
    if (storedUserPersona != null) {
      userPersona = storedUserPersona;
    }
    userNameController.text = userPersona.name;
    userMissionController.text = userPersona.missionStatement;

    // Load other Personas and defaults if needed
    List<Persona> otherPersonas = await storageService.getOtherPersonas();
    if (otherPersonas.isEmpty) {
      Persona stanley = Persona(name: "Stanley", missionStatement: "A comedic straight man or a taciturn defense attorney, as the situation demands.");
      Persona oliver = Persona(name: "Oliver", missionStatement: "A humorously exaggerated blowhard or a passionate fighter for justice, as the situation demands.");
      await storageService.savePersona(stanley);
      await storageService.savePersona(oliver);
      availablePersonas = [stanley, oliver];
    } else {
      availablePersonas = otherPersonas;
    }
    setState(() {});
  }

  void _saveUserPersona() {
    userPersona.name = userNameController.text;
    userPersona.missionStatement = userMissionController.text;
    storageService.saveUserPersona(userPersona);
    setState(() {});
  }

  void _updateApiKey() async {
    // Simple dialog to get API key
    String? newApiKey = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController apiKeyController = TextEditingController();
        return AlertDialog(
               title: const Text('Enter Gemini API Key'),
content: TextField(controller: apiKeyController, obscureText: true),
actions: <Widget>[
TextButton(
child: const Text('Cancel'),
onPressed: () => Navigator.of(context).pop(),
),
TextButton(
child: const Text('Save'),
onPressed: () => Navigator.of(context).pop(apiKeyController.text),
),
],
);
},
);
if (newApiKey != null && newApiKey.isNotEmpty) {
geminiApiKey = newApiKey;
await storageService.saveApiKey(newApiKey);
setState(() {});
}
}

  void _askQuestion() {
    if (geminiApiKey == null || geminiApiKey!.isEmpty) {
       // Show error: API Key needed
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please set your Gemini API Key.")));
       return;
    }
    if (userPersona.name.isEmpty || userPersona.missionStatement.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please set your Persona name and mission statement.")));
        return;
    }
    if (selectedAdvocates.any((p) => p == null)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select two Advocates.")));
        return;
    }

    final question = questionController.text;
    if (question.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a question.")));
        return;
    }

    setState(() {
      llmLog.clear(); // Clear previous logs
      llmLog.add("User: ${userPersona.name} asks: $question");
    });

    bsNsController.startMediation(
      userPersona: userPersona,
      advocates: selectedAdvocates.whereType<Persona>().toList(),
      jury: selectedJury.whereType<Persona>().toList(),
      question: question,
    );
  }


  @override
  Widget build(BuildContext context) {
    // This is a very basic layout.
    // You'll need to implement proper widgets for persona editing,
    // advocate/jury selection (drag and drop), LLM output display, etc.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peanut Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: _updateApiKey,
            tooltip: 'Set API Key',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel: User Persona
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Persona", style: Theme.of(context).textTheme.headlineSmall),
                  TextField(controller: userNameController, decoration: const InputDecoration(labelText: "Name")),
                  TextField(controller: userMissionController, decoration: const InputDecoration(labelText: "Mission Statement"), maxLines: 3),
                  ElevatedButton(onPressed: _saveUserPersona, child: const Text("Save Persona")),
                  const Divider(height: 30),
                  Text("Available Personas (Drag to Advocates/Jury)", style: Theme.of(context).textTheme.titleMedium),
                  // TODO: Implement Draggable list of availablePersonas
                  Expanded(
                    child: ListView.builder(
                      itemCount: availablePersonas.length,
                      itemBuilder: (context, index) => Draggable<Persona>(
                        data: availablePersonas[index],
                        feedback: Material(child: Text(availablePersonas[index].name, style: const TextStyle(fontSize: 16, color: Colors.blue))),
                        childWhenDragging: Container(padding: const EdgeInsets.all(8), child: Text(availablePersonas[index].name, style: const TextStyle(color: Colors.grey))),
                        child: Card(child: ListTile(title: Text(availablePersonas[index].name))),
                      )
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Panel: LLM Log, Advocates, Jury, Question
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Advocates & Jury Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [const Text("Advocate 1"), _buildDropTarget(0, true)]),
                      Column(children: [const Text("Advocate 2"), _buildDropTarget(1, true)]),
                    ],
                  ),
                  const Text("Jury (up to 12)"),
                  // TODO: Implement Jury drop targets (e.g., Wrap or GridView of DropTargets)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: List<Widget>.generate(12, (index) => _buildDropTarget(index, false)),
                  ),
                  const Divider(height: 30),
                  // LLM Output
                  Text("Conversation Log", style: Theme.of(context).textTheme.headlineSmall),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: ListView.builder(
                        itemCount: llmLog.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(llmLog[index]),
                        ),
                      ),
                    ),
                  ),
                  // Question Input
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: questionController,
                      decoration: const InputDecoration(hintText: "Enter your question here...", border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (selectedAdvocates.where((p) => p != null).length == 2 && userNameController.text.isNotEmpty && userMissionController.text.isNotEmpty)
                        ? _askQuestion
                        : null,
                    child: const Text("Ask"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropTarget(int index, bool isAdvocate) {
    return DragTarget<Persona>(
      builder: (context, candidateData, rejectedData) {
        Persona? currentPersona = isAdvocate ? selectedAdvocates[index] : (index < selectedJury.length ? selectedJury[index] : null);
        return Container(
          height: 50,
          width: 100,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey), color: candidateData.isNotEmpty ? Colors.lightBlue.withOpacity(0.3) : Colors.white),
          child: Center(child: Text(currentPersona?.name ?? (isAdvocate ? "Advocate" : "Juror"))),
        );
      },
      onAccept: (persona) {
        setState(() {
          if (isAdvocate) {
            // Prevent user persona from being an advocate, or same advocate twice
            if (persona.name != userPersona.name && !selectedAdvocates.any((p) => p?.name == persona.name)) {
               selectedAdvocates[index] = persona;
            }
          } else {
             // Prevent user persona from being a juror, or same juror multiple times
            if (persona.name != userPersona.name && !selectedJury.any((p) => p?.name == persona.name)) {
              if (index < selectedJury.length) selectedJury[index] = persona;
            }
          }
        });
      },
    );
  }
}