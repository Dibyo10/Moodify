import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = "http://10.0.2.2:5002"; 

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["response"];
      } else {
        return "Error: Unable to connect to server";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
