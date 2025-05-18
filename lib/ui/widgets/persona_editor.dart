import 'package:flutter/material.dart';
import 'package:peanut_gallery/models/persona.dart';

class PersonaEditor extends StatefulWidget {
  final Persona persona;
  final Function(String, String) onPersonaChanged;

  const PersonaEditor({
    Key? key,
    required this.persona,
    required this.onPersonaChanged,
  }) : super(key: key);

  @override
  _PersonaEditorState createState() => _PersonaEditorState();
}

class _PersonaEditorState extends State<PersonaEditor> {
  late TextEditingController _nameController;
  late TextEditingController _missionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.persona.name);
    _missionController = TextEditingController(text: widget.persona.missionStatement);
  }

  @override
  void didUpdateWidget(PersonaEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.persona != widget.persona) {
      _nameController.text = widget.persona.name;
      _missionController.text = widget.persona.missionStatement;
    }
  }

  void _updatePersona() {
    widget.onPersonaChanged(
      _nameController.text,
      _missionController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Persona',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _updatePersona(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mission Statement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _missionController,
                decoration: const InputDecoration(
                  hintText: 'Describe your persona\'s mission...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => _updatePersona(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _missionController.dispose();
    super.dispose();
  }
}