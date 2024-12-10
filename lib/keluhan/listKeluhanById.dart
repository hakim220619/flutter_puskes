import 'package:flutter/material.dart';
import 'package:puskes/keluhan/verifikasiadmin.dart';
import 'package:puskes/keluhan/addkeluhanPage.dart';
import 'package:puskes/konsultasi/konsultasiAdmin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ListKeluhanAdminById extends StatefulWidget {
  const ListKeluhanAdminById({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<ListKeluhanAdminById> createState() => _ListKeluhanAdminByIdState();
}

List _listsData = [];

class _ListKeluhanAdminByIdState extends State<ListKeluhanAdminById> {
  Future<dynamic> listKeluhan() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/listKeluhanById/${widget.id}');
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
    listKeluhan();
  }

  late SharedPreferences profileData;
  String? role;
  void initial() async {
    profileData = await SharedPreferences.getInstance();
    setState(() {
      role = profileData.getString('role');
    });
  }

  Future refresh() async {
    setState(() {
      listKeluhan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Rujukan',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          itemCount: _listsData.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    "Pertanyaan: ${_listsData[index]['pertanyaan']}",
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "Dibuat: ${_listsData[index]['created_at']}",
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerifikasiAdmin(
                            verifikasi:
                                _listsData[index]['verifikasi'].toString(),
                            pertanyaan:
                                _listsData[index]['pertanyaan'].toString(),
                            nama_ortu:
                                _listsData[index]['nama_ortu'].toString(),
                            name: _listsData[index]['name'].toString(),
                            jenis_kelamin:
                                _listsData[index]['jenis_kelamin'].toString(),
                            tanggal_lahir:
                                _listsData[index]['tanggal_lahir'].toString(),
                            nik: _listsData[index]['nik'].toString(),
                            id_ortu: _listsData[index]['id_ortu'].toString(),
                            id: _listsData[index]['id'].toString()),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
