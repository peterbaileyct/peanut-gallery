import 'package:flutter/material.dart';
import 'package:peanut_gallery/models/persona.dart';

class PersonaSelector extends StatelessWidget {
  final List<Persona> availablePersonas;
  final List<Persona> advocatePersonas;
  final List<Persona> juryPersonas;
  final Function(List<Persona>) onAdvocatesChanged;
  final Function(List<Persona>) onJuryChanged;

  const PersonaSelector({
    Key? key,
    required this.availablePersonas,
    required this.advocatePersonas,
    required this.juryPersonas,
    required this.onAdvocatesChanged,
    required this.onJuryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Personas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Personas
            Expanded(
              child: _buildPersonaList(
                title: 'Available Personas',
                personas: availablePersonas,
                onTap: (persona) {
                  if (advocatePersonas.length < 2) {
                    final newAdvocates = List<Persona>.from(advocatePersonas)..add(persona);
                    onAdvocatesChanged(newAdvocates);
                  } else if (juryPersonas.length < 12) {
                    final newJury = List<Persona>.from(juryPersonas)..add(persona);
                    onJuryChanged(newJury);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            // Advocates
            Expanded(
              child: _buildPersonaList(
                title: 'Advocates (2)',
                personas: advocatePersonas,
                onTap: (persona) {
                  final newAdvocates = List<Persona>.from(advocatePersonas)
                    ..remove(persona);
                  onAdvocatesChanged(newAdvocates);
                },
                errorMessage: advocatePersonas.length < 2 
                  ? 'Select 2 advocates' 
                  : null,
              ),
            ),
            const SizedBox(width: 16),
            // Jury
            Expanded(
              child: _buildPersonaList(
                title: 'Jury (0-12)',
                personas: juryPersonas,
                onTap: (persona) {
                  final newJury = List<Persona>.from(juryPersonas)
                    ..remove(persona);
                  onJuryChanged(newJury);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonaList({
    required String title,
    required List<Persona> personas,
    required Function(Persona) onTap,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListView.builder(
            itemCount: personas.length,
            itemBuilder: (context, index) {
              final persona = personas[index];
              return ListTile(
                title: Text(persona.name, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  persona.missionStatement,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                dense: true,
                onTap: () => onTap(persona),
                trailing: const Icon(Icons.remove_circle_outline, size: 16),
              );
            },
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}