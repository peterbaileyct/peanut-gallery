import 'package:flutter/material.dart';
import '../../models/persona.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';

class PersonaSelector extends StatefulWidget {
  final List<Persona> availablePersonas;
  final List<Persona> selectedAdvocates;
  final List<Persona> selectedJury;
  final Function(List<Persona>) onAdvocatesChanged;
  final Function(List<Persona>) onJuryChanged;

  const PersonaSelector({
    Key? key,
    required this.availablePersonas,
    required this.selectedAdvocates,
    required this.selectedJury,
    required this.onAdvocatesChanged,
    required this.onJuryChanged,
  }) : super(key: key);

  @override
  _PersonaSelectorState createState() => _PersonaSelectorState();
}

class _PersonaSelectorState extends State<PersonaSelector> {
  void _openPersonaManager() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonaManagerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter out personas already selected
    final availableForAdvocates = widget.availablePersonas
        .where((p) => !widget.selectedJury.contains(p))
        .toList();
        
    final availableForJury = widget.availablePersonas
        .where((p) => !widget.selectedAdvocates.contains(p))
        .toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: _openPersonaManager,
                  tooltip: 'Manage Personas',
                ),
              ],
            ),
            SizedBox(height: 16),
            
            Text(
              'Advocates:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('(Exactly 2 required)'),
            SizedBox(height: 8),
            
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _buildAdvocateDropArea(),
            ),
            
            SizedBox(height: 16),
            
            Text(
              'Jury:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('(Up to 12 optional)'),
            SizedBox(height: 8),
            
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _buildJuryDropArea(),
            ),
            
            SizedBox(height: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Personas:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.availablePersonas.length,
                      itemBuilder: (context, index) {
                        final persona = widget.availablePersonas[index];
                        return _buildDraggablePersona(
                          persona,
                          widget.selectedAdvocates.contains(persona) || 
                          widget.selectedJury.contains(persona)
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvocateDropArea() {
    return DragTarget<Persona>(
      onAccept: (persona) {
        final updatedList = List<Persona>.from(widget.selectedAdvocates);
        
        // Remove from jury if it's there
        if (widget.selectedJury.contains(persona)) {
          final updatedJury = List<Persona>.from(widget.selectedJury)
            ..remove(persona);
          widget.onJuryChanged(updatedJury);
        }
        
        // Add to advocates if not already there
        if (!updatedList.contains(persona)) {
          if (updatedList.length < 2) {
            updatedList.add(persona);
          } else {
            // Replace the first one if we already have 2
            updatedList.removeAt(0);
            updatedList.add(persona);
          }
          widget.onAdvocatesChanged(updatedList);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return widget.selectedAdvocates.isEmpty
            ? Center(child: Text('Drop advocates here'))
            : ListView.builder(
                itemCount: widget.selectedAdvocates.length,
                itemBuilder: (context, index) {
                  final persona = widget.selectedAdvocates[index];
                  return ListTile(
                    title: Text(persona.name),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () {
                        final updatedList = List<Persona>.from(widget.selectedAdvocates)
                          ..remove(persona);
                        widget.onAdvocatesChanged(updatedList);
                      },
                    ),
                  );
                },
              );
      },
    );
  }

  Widget _buildJuryDropArea() {
    return DragTarget<Persona>(
      onAccept: (persona) {
        final updatedList = List<Persona>.from(widget.selectedJury);
        
        // Remove from advocates if it's there
        if (widget.selectedAdvocates.contains(persona)) {
          final updatedAdvocates = List<Persona>.from(widget.selectedAdvocates)
            ..remove(persona);
          widget.onAdvocatesChanged(updatedAdvocates);
        }
        
        // Add to jury if not already there and we have less than 12
        if (!updatedList.contains(persona) && updatedList.length < 12) {
          updatedList.add(persona);
          widget.onJuryChanged(updatedList);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return widget.selectedJury.isEmpty
            ? Center(child: Text('Drop jury members here'))
            : ListView.builder(
                itemCount: widget.selectedJury.length,
                itemBuilder: (context, index) {
                  final persona = widget.selectedJury[index];
                  return ListTile(
                    title: Text(persona.name),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () {
                        final updatedList = List<Persona>.from(widget.selectedJury)
                          ..remove(persona);
                        widget.onJuryChanged(updatedList);
                      },
                    ),
                  );
                },
              );
      },
    );
  }

  Widget _buildDraggablePersona(Persona persona, bool isSelected) {
    return Opacity(
      opacity: isSelected ? 0.5 : 1.0,
      child: Draggable<Persona>(
        data: persona,
        feedback: Material(
          elevation: 4,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            width: 200,
            child: Text(persona.name),
          ),
        ),
        childWhenDragging: ListTile(
          title: Text(persona.name, style: TextStyle(color: Colors.grey)),
        ),
        child: ListTile(
          title: Text(persona.name),
          subtitle: Text(
            persona.missionStatement,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class PersonaManagerScreen extends StatelessWidget {
  void _showPersonaDialog(BuildContext context, {Persona? persona}) {
    final isEditing = persona != null;
    final nameController = TextEditingController(text: persona?.name ?? '');
    final missionController = TextEditingController(text: persona?.missionStatement ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Persona' : 'New Persona'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: missionController,
                decoration: InputDecoration(labelText: 'Mission Statement'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final mission = missionController.text.trim();
                if (name.isEmpty || mission.isEmpty) return;
                final storage = Provider.of<StorageService>(context, listen: false);
                if (isEditing) {
                  await storage.updatePersona(
                    persona!.copyWith(name: name, missionStatement: mission),
                  );
                } else {
                  await storage.addPersona(
                    Persona(name: name, missionStatement: mission),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storage, _) {
        final personas = storage.personas;
        return Scaffold(
          appBar: AppBar(
            title: Text('Manage Personas'),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                tooltip: 'Add Persona',
                onPressed: () => _showPersonaDialog(context),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: personas.length,
            itemBuilder: (context, index) {
              final persona = personas[index];
              return ListTile(
                title: Text(persona.name),
                subtitle: Text(persona.missionStatement, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () => _showPersonaDialog(context, persona: persona),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      tooltip: 'Delete',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Persona'),
                            content: Text('Are you sure you want to delete "${persona.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await storage.deletePersona(persona.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}