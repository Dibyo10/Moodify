import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:modify1/Home.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MoodifyApp());
}

class AIChatApp extends StatefulWidget {
  @override
  _AIChatAppState createState() => _AIChatAppState();
}

class _AIChatAppState extends State<AIChatApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: ChatScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  ChatScreen({required this.isDarkMode, required this.onThemeToggle});

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
        elevation: 10,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDarkMode
                  ? [Colors.deepPurple.shade900, Colors.black87] 
                  : [Colors.deepPurple, Colors.purpleAccent], 
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(Icons.person, color: Colors.purpleAccent),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lily',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "AI Chat Assistant",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.white),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [Colors.black87, Colors.black54]
                : [Colors.purple.shade50, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Chat(
          messages: _messages,
          onSendPressed: (partialText) => _sendMessage(partialText.text),
          user: _user,
          theme: DefaultChatTheme(
            inputBackgroundColor: widget.isDarkMode ? Colors.grey[850]! : Colors.purpleAccent,
            inputTextColor: Colors.white,
            primaryColor: widget.isDarkMode
                ? Colors.deepPurpleAccent.shade700 // Sent messages in dark mode (Purple like Instagram)
                : Colors.deepPurpleAccent, // Light mode sent messages
            secondaryColor: widget.isDarkMode
                ? Colors.white 
                : Colors.purple.shade100, 
            backgroundColor: Colors.transparent,
            sentMessageBodyTextStyle: TextStyle(color: Colors.white),
            receivedMessageBodyTextStyle: TextStyle(color: Colors.black),
            messageInsetsVertical: 10,
            messageBorderRadius: 20,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(AIChatApp());
}

class AIChatApp extends StatefulWidget {
  @override
  _AIChatAppState createState() => _AIChatAppState();
}

class _AIChatAppState extends State<AIChatApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: ChatScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  ChatScreen({required this.isDarkMode, required this.onThemeToggle});

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
        elevation: 10,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDarkMode
                  ? [Colors.deepPurple.shade900, Colors.black87] 
                  : [Colors.deepPurple, Colors.purpleAccent], 
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(Icons.person, color: Colors.purpleAccent),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lily',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "AI Chat Assistant",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.white),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [Colors.black87, Colors.black54]
                : [Colors.purple.shade50, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Chat(
          messages: _messages,
          onSendPressed: (partialText) => _sendMessage(partialText.text),
          user: _user,
          theme: DefaultChatTheme(
            inputBackgroundColor: widget.isDarkMode ? Colors.grey[850]! : Colors.purpleAccent,
            inputTextColor: Colors.white,
            primaryColor: widget.isDarkMode
                ? Colors.deepPurpleAccent.shade700 
                : Colors.deepPurpleAccent,
            secondaryColor: widget.isDarkMode
                ? Colors.white 
                : Colors.purple.shade100, 
            backgroundColor: Colors.transparent,
            sentMessageBodyTextStyle: TextStyle(color: Colors.white),
            receivedMessageBodyTextStyle: TextStyle(color: Colors.black),
            messageInsetsVertical: 10,
            messageBorderRadius: 20,
          ),
        ),
      ),
    );
  }
}
