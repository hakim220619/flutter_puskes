import 'package:flutter/material.dart';
import 'package:puskes/home/HomePage.dart';
import 'package:puskes/keluhan/addkeluhanPage.dart';
import 'package:puskes/konsultasi/konsultasiAdmin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ListKonsultasi extends StatefulWidget {
  const ListKonsultasi({
    Key? key,
  }) : super(key: key);

  @override
  State<ListKonsultasi> createState() => _ListKonsultasiState();
}

List _listsData = [];

class _ListKonsultasiState extends State<ListKonsultasi> {
  Future<dynamic> listKonsultasi() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/listKonsultasi');
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      // print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(data);
        setState(() {
          _listsData = data['data'];
          // print(_listsData);
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  // Sample data for three lists
  @override
  void initState() {
    super.initState();
    listKonsultasi();
  }

  Future refresh() async {
    setState(() {
      listKonsultasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Konsultasi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Homepage()));
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(253, 255, 252, 252),
          ),
        ),
        backgroundColor: Colors.blue[300],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          itemCount: _listsData.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.all(10.0),
            child: ListTile(
              title: Text(
                "${_listsData[index]['name']}",
                style: const TextStyle(
                    fontSize: 15.0, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "${_listsData[index]['nik']}",
                maxLines: 2,
                style: const TextStyle(fontSize: 14.0),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KonsultasiAdmin(
                      id_ortu: _listsData[index]['id_ortu'].toString(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
