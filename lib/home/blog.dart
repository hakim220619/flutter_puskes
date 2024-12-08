import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<dynamic> newsList = [];

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  Future<void> loadNews() async {
    final String response = await rootBundle.loadString('assets/news.json');
    final data = json.decode(response);
    setState(() {
      newsList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Berita'),
      ),
      body: newsList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final newsItem = newsList[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image.network(newsItem['imageUrl']),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          newsItem['title'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('${newsItem['description']}\n${newsItem['date']}'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
