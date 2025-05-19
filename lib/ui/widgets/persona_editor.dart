import 'package:flutter/material.dart';
import '../../models/persona.dart';

class PersonaEditor extends StatefulWidget {
  final Persona? persona;
  final Function(Persona) onSave;

  const PersonaEditor({
    Key? key,
    required this.persona,
    required this.onSave,
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
    _nameController = TextEditingController(text: widget.persona?.name ?? '');
    _missionController = TextEditingController(text: widget.persona?.missionStatement ?? '');
  }

  @override
  void didUpdateWidget(PersonaEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.persona != oldWidget.persona) {
      _nameController.text = widget.persona?.name ?? '';
      _missionController.text = widget.persona?.missionStatement ?? '';
    }
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _missionController.text.trim().isNotEmpty;

  void _saveChanges() {
    if (!_isValid) return;

    final updatedPersona = (widget.persona ??
        Persona(
          id: 'user',
          name: _nameController.text.trim(),
          missionStatement: _missionController.text.trim(),
        )).copyWith(
      name: _nameController.text.trim(),
      missionStatement: _missionController.text.trim(),
    );

    widget.onSave(updatedPersona);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Persona',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _missionController,
                decoration: InputDecoration(
                  labelText: 'Mission Statement',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isValid ? _saveChanges : null,
                child: Text('Save'),
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