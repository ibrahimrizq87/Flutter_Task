import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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
  final String description;
  final String url;

  RedditPost({required this.title, required this.description, required this.url,});
}
class RedditPostWidget extends StatelessWidget {
  final RedditPost post;
  final int postIndex;

  RedditPostWidget({required this.post,required this.postIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        child: InkWell(
          onTap: () {
            _launchURL(post.url);
          },
          child: ListTile(
            title: RichText(
              text: TextSpan(
                text: "${post.title} #${postIndex}" ,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            subtitle: Text(
              post.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
  /*void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
*/}


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
    fetchRedditData('hot');
  }

  Future<void> fetchRedditData(String sortType) async {
    final response = await http.get(
      Uri.parse('https://www.reddit.com/r/FlutterDev/$sortType.json?limit=10&after=$after'),
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
            description: postData['selftext'] ?? 'null content',
            url: postData['url'],
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
            fetchRedditData('hot');
          }
          return false;
        },
        child: ListView.builder(
          itemCount: redditPosts.length,
          itemBuilder: (context, index) {
            return RedditPostWidget(post: redditPosts[index],postIndex: index);
          },
        ),
      ),
    );
  }
}