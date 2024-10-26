import 'package:flutter/material.dart';
import 'package:puskes/home/HomePage.dart';
import 'package:puskes/keluhan/verifikasiadmin.dart';
import 'package:puskes/keluhan/addkeluhanPage.dart';
import 'package:puskes/keluhan/listKeluhanById.dart';
import 'package:puskes/konsultasi/konsultasiAdmin.dart';
import 'package:puskes/penimbangan/addPenimbanganPage.dart';
import 'package:puskes/penimbangan/penimbangan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../listusers/listusers.dart';

class ListPenimbanganById extends StatefulWidget {
  const ListPenimbanganById({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  State<ListPenimbanganById> createState() => _ListPenimbanganByIdState();
}

List _listsData = [];

class _ListPenimbanganByIdState extends State<ListPenimbanganById> {
  Future<dynamic> ListPenimbangan() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url =
          Uri.parse("${dotenv.env['url']}/getPenimbanganByMonth/${widget.id}");
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(data);
        setState(() {
          _listsData = data['data'];
          print(_listsData);
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
    ListPenimbangan();
  }

  Future refresh() async {
    setState(() {
      ListPenimbangan();
    });
  }

  void addPenimbangan() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AddPenimbanganPage(
                id: widget.id.toString(),
              )),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Penimbangan By Month',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ListUsers()));
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
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    "${_listsData[index]['nama_bulan']} - ${_listsData[index]['tahun']}",
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "BB ${_listsData[index]['bb_lahir']} TB ${_listsData[index]['tb_lahir']}",
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PenimbanganPage(
                          id: _listsData[index]['id'].toString(),
                          id_user: _listsData[index]['id_user'].toString(),
                          bblahir: _listsData[index]['bb_lahir'].toString(),
                          tblahir: _listsData[index]['tb_lahir'].toString(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPenimbangan,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
