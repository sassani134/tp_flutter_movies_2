import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tv_show.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies & TV Shows',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPage = 1;
  int _pageSize = 20;
  int _totalPages = 1;

  Future<List<TvShow>> fetchTvShows(int currentPage) async {
    final response = await http.get(Uri.parse('https://www.episodate.com/api/most-popular?page=$currentPage&limit=$_pageSize'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      _totalPages = jsonResponse['pages'];
      List<dynamic> tvShowsJson = jsonResponse['tv_shows'];
      return tvShowsJson.map((json) => TvShow.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load TV shows');
    }
  }

  void _increment() {
    setState(() {
      if (_currentPage < _totalPages) {
        _currentPage++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('TV Shows', style: TextStyle(color: Colors.white)),
        elevation: 4.0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentPage = 1;
              });
            },
            icon: const Icon(Icons.update, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<List<TvShow>>(
        future: fetchTvShows(_currentPage),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No TV shows found'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final tvShow = snapshot.data![index];
                  return Card(
                    color: Color(0xFF202238),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            tvShow.imageThumbnailPath,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              tvShow.name,
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      backgroundColor: Color(0xFF01031C),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        backgroundColor: Colors.deepOrange,
        tooltip: 'Increment',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
