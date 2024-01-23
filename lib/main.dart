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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String stringResponse = "";
  List<dynamic> redditPosts = [];
  String after="";

  @override
  void initState() {
    super.initState();
    fetchRedditData();
  }
/*
  Future<void> apicall() async {
    http.Response response;
    response = await http.get(Uri.parse('https://www.reddit.com/r/FlutterDev.json'));
    print("here   ");
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        print("here   ");
        print(response.body);
        stringResponse = response.body;
      });
    }
  }
*/
  Future<void> fetchRedditData() async {
    final response = await http.get(
      Uri.parse('https://www.reddit.com/r/FlutterDev.json?limit=10&after=$after'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> newPosts = data['data']['children'];
      after = data['data']['after'];

      setState(() {
        redditPosts.addAll(newPosts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My First Application with Flutter"),
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
              final post = redditPosts[index]['data'];
              return ListTile(
                title: Text(post['title']),
                subtitle: Text("Author: ${post['author']}"),

              );
            },),)
      /*body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                //apicall();
              },
              child: const Text("Click me"),
            ),
            const SizedBox(height: 20),
            Text(
              "API Response:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              stringResponse,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Setting",
            icon: Icon(Icons.settings),
          ),
        ],
      ),*/


    );
  }
}