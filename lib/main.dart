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
        Uri.parse('http://10.0.2.2:5002/chat'),
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.purpleAccent),
            ),
            SizedBox(width: 10),
            Text(
              'Lily',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
             
            },
          ),
          IconButton(
            icon: Icon(Icons.brightness_6, color: Colors.white),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Chat(
          messages: _messages,
          onSendPressed: (partialText) => _sendMessage(partialText.text),
          user: _user,
          theme: DefaultChatTheme(
            inputBackgroundColor: Colors.purpleAccent,
            inputTextColor: Colors.white,
            primaryColor: Colors.deepPurpleAccent,
            secondaryColor: Colors.purple.shade100,
            backgroundColor: Colors.transparent,
            sentMessageBodyTextStyle: TextStyle(color: Colors.white),
            receivedMessageBodyTextStyle: TextStyle(color: Colors.black87),
            messageInsetsVertical: 10,
            messageBorderRadius: 20, 
          ),
        ),
      ),
    );
  }
}
