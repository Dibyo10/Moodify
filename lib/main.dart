import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(AIChatApp());
}

class AIChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  final types.User _user = types.User(id: '1');
  final types.User _ai = types.User(id: '2', firstName: 'Lily');

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = types.TextMessage(
      id: const Uuid().v4(),
      author: _user,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() => _messages.insert(0, userMessage));

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5002/chat'), // ✅ Updated port
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botMessage = types.TextMessage(
          id: const Uuid().v4(),
          author: _ai,
          text: data['response'],
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        setState(() => _messages.insert(0, botMessage));
      } else {
        _showErrorMessage('Failed to get a response from AI.');
      }
    } catch (e) {
      _showErrorMessage('Error: Unable to connect to the server.');
    }
  }

  void _showErrorMessage(String errorMsg) {
    final errorMessage = types.TextMessage(
      id: const Uuid().v4(),
      author: _ai,
      text: errorMsg,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() => _messages.insert(0, errorMessage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lily', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: (partialText) => _sendMessage(partialText.text),
        user: _user,
        theme: DefaultChatTheme(
          inputBackgroundColor: Colors.purple,
          inputTextColor: Colors.white,
          primaryColor: Colors.purpleAccent,
          secondaryColor: Colors.grey.shade300,
          backgroundColor: Colors.white,
          sentMessageBodyTextStyle: TextStyle(color: Colors.white),
          receivedMessageBodyTextStyle: TextStyle(color: Colors.black87),
          messageInsetsVertical: 10,
        ),
      ),
    );
  }
}
