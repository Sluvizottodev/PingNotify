import 'package:flutter/material.dart';
import '../../Service/ntfyService.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final NtfyService _ntfyService = NtfyService();
  bool _isSending = false;
  String _priority = 'normal'; // Valor padrão para prioridade

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enviar Mensagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Digite sua mensagem',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: InputDecoration(
                labelText: 'Prioridade',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'low', child: Text('Baixa')),
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                DropdownMenuItem(value: 'high', child: Text('Alta')),
              ],
              onChanged: (value) {
                setState(() {
                  _priority = value ?? 'normal';
                });
              },
            ),
            SizedBox(height: 16),
            _isSending
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Enviar Mensagem'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    setState(() {
      _isSending = true;
    });

    try {
      await _ntfyService.sendMessage(
        title: _titleController.text,
        message: _messageController.text,
        priority: _priority,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mensagem enviada com sucesso')),
      );
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _priority = 'normal';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao enviar mensagem')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
}
