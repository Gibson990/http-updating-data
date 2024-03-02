import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(const Myapp());
}

class Album {
  final int id;

  final String title;

  const Album({
    required this.title,
    required this.id,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(id: json['id'], title: json['title']);
  }
}

Future<Album> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('album not found');
  }
}
// update album fuction

Future<Album> updateAlbum(String title) async {
  final response =
      await http.put(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'),
          headers: <String, String>{
            'Content-Type': 'application/json;charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'title': title,
          }));
  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('update failed');
  }
}

class Myapp extends StatefulWidget {
  const Myapp({super.key});

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  final TextEditingController _controller = TextEditingController();
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrangeAccent,
          title: const Text('Update album'),
          centerTitle: true,
        ),
        body: Center(
          child: FutureBuilder<Album>(
              future: futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Text(snapshot.data!.title),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                              hintText: 'update album',
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black87))),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final updatedAlbum =
                                  await updateAlbum(_controller.text);
                              setState(() {
                                futureAlbum = Future.value(updatedAlbum);
                              });
                            } catch (error) {
                              print('Error updating album: $error');
                            }
                          },
                          child: const Text('update album'),
                        )
                      ],
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              }),
        ),
      ),
    );
  }
}
