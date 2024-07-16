import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, String>> messages = [];
  TextEditingController queryController = TextEditingController();

  void _sendMessage() async {
    String query = queryController.text;
    if (query.isEmpty) return; // Ne pas envoyer de message vide

    queryController.clear();
    setState(() {
      messages.add({'message': query, 'type': 'user'});
    });

    try {
      var response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': query}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        setState(() {
          messages.add({
            'message': responseBody['choices'][0]['message']['content'],
            'type': 'assistant',
          });
        });
      }
    } catch (e) {
      // Gérer les exceptions (afficher une alerte ou log)
      print("Erreur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 2),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    bool isUser = messages[index]['type'] == 'user';
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.teal[50] : Colors.blue[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isUser ? Colors.teal : Colors.blue,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            messages[index]['message']!,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isUser ? Colors.teal[900] : Colors.blue[900],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: queryController,
                    onSubmitted: (value) => _sendMessage(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.teal),
                      ),
                      hintText: "Entrez votre message...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
