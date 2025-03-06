// import 'package:flutter/material.dart';
// import '../../Service/ntfyService.dart';
//
// class MessageScreen extends StatefulWidget {
//   @override
//   _MessageScreenState createState() => _MessageScreenState();
// }
//
// class _MessageScreenState extends State<MessageScreen> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _messageController = TextEditingController();
//   final NtfyService _ntfyService = NtfyService();
//   bool _isSending = false;
//   String _priority = 'normal'; // Valor padrão para prioridade
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Enviar Mensagem'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(
//                 labelText: 'Título',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _messageController,
//               decoration: InputDecoration(
//                 labelText: 'Mensagem',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _priority,
//               onChanged: (newValue) {
//                 setState(() {
//                   _priority = newValue!;
//                 });
//               },
//               decoration: InputDecoration(
//                 labelText: 'Prioridade',
//                 border: OutlineInputBorder(),
//               ),
//               items: [
//                 DropdownMenuItem(
//                   value: 'normal',
//                   child: Text('Normal'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'high',
//                   child: Text('Alta'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'low',
//                   child: Text('Baixa'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _isSending ? null : _sendMessage,
//               child: _isSending
//                   ? CircularProgressIndicator()
//                   : Text('Enviar Mensagem'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _sendMessage() async {
//     setState(() {
//       _isSending = true;
//     });
//
//     try {
//       await _ntfyService.sendMessage(
//         title: _titleController.text,
//         message: _messageController.text,
//         priority: _priority,
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Mensagem enviada com sucesso')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Falha ao enviar mensagem')),
//       );
//     } finally {
//       setState(() {
//         _isSending = false;
//       });
//     }
//   }
// }
