import 'package:flutter/material.dart';

import 'package:puskes/databayi/editdata.dart';
import 'package:puskes/home/HomePage.dart';
import 'package:puskes/keluhan/verifikasiadmin.dart';
import 'package:puskes/keluhan/addkeluhanPage.dart';
import 'package:puskes/keluhan/listKeluhanById.dart';
import 'package:puskes/konsultasi/konsultasiAdmin.dart';
import 'package:puskes/penimbangan/penimbangan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class DatabAyiPage extends StatefulWidget {
  const DatabAyiPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DatabAyiPage> createState() => _DatabAyiPageState();
}

List _listsData = [];

class _DatabAyiPageState extends State<DatabAyiPage> {
  Future<dynamic> listKeluhan() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/listUsers');
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
    listKeluhan();
  }

  Future refresh() async {
    setState(() {
      listKeluhan();
    });
  }

  _launchURL(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> cetakPdf() async {
    // print('PDf');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    var url = Uri.parse('${dotenv.env['url']}/exportPdf');
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    // print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _launchURL(data['file']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Data Bayi',
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
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    "Nama: ${_listsData[index]['name']}",
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "Email: ${_listsData[index]['email']} \nNik: ${_listsData[index]['nik']}",
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDataBayi(
                          id: _listsData[index]['id'].toString(),
                          nik: _listsData[index]['nik'].toString(),
                          nama: _listsData[index]['name'].toString(),
                          email: _listsData[index]['email'].toString(),
                          address: _listsData[index]['address'].toString(),
                          jenisKelamin:
                              _listsData[index]['jenis_kelamin'].toString(),
                          tanggalLahir:
                              _listsData[index]['tanggal_lahir'].toString(),
                          bbLahir: _listsData[index]['bb_lahir'].toString(),
                          tbLahir: _listsData[index]['tb_lahir'].toString(),
                          namaOrtu: _listsData[index]['nama_ortu'].toString(),
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
        onPressed: cetakPdf,
        tooltip: 'Increment',
        child: const Icon(Icons.picture_as_pdf),
      ), // Th
    );
  }
}
