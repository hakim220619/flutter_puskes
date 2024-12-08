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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listsData = data['data'];
        });
      }
    } catch (e) {
      // Handle errors here
    }
  }

  Future refresh() async {
    setState(() {
      listKonsultasi();
    });
  }

  @override
  void initState() {
    super.initState();
    listKonsultasi();
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
          itemBuilder: (context, index) {
            return FutureBuilder<String?>(
              future: _getImageFromSharedPreferences(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                String imageUrl = snapshot.data ?? ''; // Default to empty string if no image found

                return Card(
                  margin: const EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: imageUrl.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(imageUrl),
                            radius: 30.0,
                          )
                        : const Icon(Icons.person, size: 30), // Fallback if no image
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
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Function to retrieve image URL from SharedPreferences
  Future<String?> _getImageFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_image'); // Replace 'user_image' with the correct key used to store the image URL
  }
}
