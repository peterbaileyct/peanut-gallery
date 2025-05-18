import 'package:flutter/material.dart';

class ApiKeyDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const ApiKeyDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _ApiKeyDialogState createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isValid = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Google Gemini API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Please enter your Google Gemini API key to continue. '
            'You can get one from the Google AI Studio.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(),
              hintText: 'Enter your Gemini API key',
            ),
            obscureText: true,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isValid
              ? () => widget.onSubmit(_controller.text.trim())
              : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}