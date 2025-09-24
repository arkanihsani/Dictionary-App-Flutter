import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _definitions = [];
  String? _error;

  Future<void> _searchWord(String word) async {
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _definitions = [];
      _error = null;
    });

    try {
      final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _definitions = data[0]["meanings"];
        });
      } else {
        setState(() {
          _error = "Word not found!";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dictionary App"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchWord,
                decoration: InputDecoration(
                  labelText: "Enter a word",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchWord(_controller.text),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: _definitions.isNotEmpty
                    ? ListView.builder(
                        itemCount: _definitions.length,
                        itemBuilder: (context, index) {
                          final meaning = _definitions[index];
                          final partOfSpeech = meaning["partOfSpeech"];
                          final defs = meaning["definitions"] as List<dynamic>;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    partOfSpeech.toString().toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...defs.map((d) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text("• ${d['definition']}"),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text("Type a word to search its meaning"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
