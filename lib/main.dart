import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
class RedditPost {
  final String title;
  final String author;

  RedditPost({required this.title, required this.author});
}

class RedditPostWidget extends StatelessWidget {
  final RedditPost post;

  RedditPostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        child: ListTile(
          title: Text(post.title),
          subtitle: Text("Author: ${post.author}"),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<RedditPost> redditPosts = [];
  String after = '';

  @override
  void initState() {
    super.initState();
    fetchRedditData();
  }

  Future<void> fetchRedditData() async {
    final response = await http.get(
      Uri.parse('https://www.reddit.com/r/FlutterDev.json?limit=10&after=$after'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> newPosts = data['data']['children'];

      after = data['data']['after'];

      setState(() {
        redditPosts.addAll(newPosts.map((post) {
          final postData = post['data'];
          return RedditPost(
            title: postData['title'],
            author: postData['author'],
          );
        }).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Reddit Posts"),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            fetchRedditData();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: redditPosts.length,
          itemBuilder: (context, index) {
            return RedditPostWidget(post: redditPosts[index]);
          },
        ),
      ),
    );
  }
}