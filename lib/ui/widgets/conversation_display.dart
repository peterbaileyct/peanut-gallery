import 'package:flutter/material.dart';
import '../../bs_ns_controller.dart';

class ConversationDisplay extends StatelessWidget {
  final BSNSController controller;

  const ConversationDisplay({
    Key? key, 
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Conversation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Divider(),
            Expanded(
              child: StreamBuilder<List<ConversationEntry>>(
                stream: controller.conversationStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Ask a question to start a conversation.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final entry = snapshot.data![index];
                      return _buildConversationEntry(context, entry);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConversationEntry(BuildContext context, ConversationEntry entry) {
    Color backgroundColor;
    String prefix;
    
    switch (entry.type) {
      case EntryType.prompt:
        backgroundColor = Colors.grey[200]!;
        prefix = "PROMPT:";
        break;
      case EntryType.response:
        backgroundColor = Colors.blue[50]!;
        prefix = "RESPONSE:";
        break;
      case EntryType.metadata:
        backgroundColor = Colors.amber[50]!;
        prefix = "META:";
        break;
      case EntryType.system:
        backgroundColor = Colors.green[50]!;
        prefix = "SYSTEM:";
        break;
    }
    
    return Card(
      color: backgroundColor,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.speaker.isNotEmpty)
              Text(
                "${entry.speaker} ($prefix)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (entry.speaker.isEmpty)
              Text(
                prefix,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 4),
            SelectableText(entry.content),
          ],
        ),
      ),
    );
  }
}