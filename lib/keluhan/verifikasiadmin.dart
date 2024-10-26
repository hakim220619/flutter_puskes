import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:puskes/keluhan/apiKeluhan.dart';
import 'package:puskes/login/service/servicePage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class VerifikasiAdmin extends StatefulWidget {
  const VerifikasiAdmin(
      {Key? key,
      required this.verifikasi,
      required this.pertanyaan,
      required this.nama_ortu,
      required this.name,
      required this.jenis_kelamin,
      required this.tanggal_lahir,
      required this.nik,
      required this.id_ortu,
      required this.id})
      : super(key: key);
  final String verifikasi;
  final String pertanyaan;
  final String nama_ortu;
  final String name;
  final String jenis_kelamin;
  final String tanggal_lahir;
  final String nik;
  final String id_ortu;
  final String id;

  @override
  _VerifikasiAdminState createState() => _VerifikasiAdminState();
}

class _VerifikasiAdminState extends State<VerifikasiAdmin> {
  late String jawaban;
  late SharedPreferences profileData;
  String? role;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initial();
  }

  void initial() async {
    profileData = await SharedPreferences.getInstance();
    setState(() {
      role = profileData.getString('role');
    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Keluhan',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            color: Colors.white,
            onPressed: () => Navigator.pop(context, false),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: widget.pertanyaan.toString()),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Deskripsi Keluhan'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      readOnly: true,
                      controller:
                          TextEditingController(text: widget.name.toString()),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Name'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      readOnly: true,
                      controller:
                          TextEditingController(text: widget.nik.toString()),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Nik'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: widget.jenis_kelamin.toString()),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Jenis Kelamin'),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: widget.nama_ortu.toString()),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Nama Ortu'),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: widget.tanggal_lahir.toString()),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Tanggal Lahir'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  role == '1'
                      ? widget.verifikasi == '0'
                          ? InkWell(
                              onTap: () async {
                                await HttpServiceKeluhan.verivikasi(
                                    widget.id, context);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 1, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Verifikasi",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(9, 107, 199, 1),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                          : Text('')
                      : InkWell(
                          onTap: () async {
                               final _client = http.Client() ;
                              final _cetak = Uri.parse('${dotenv.env['url']}/word');
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            var token = preferences.getString('token');
                            EasyLoading.show(status: 'loading...');
                            http.Response response =
                                await _client.post(_cetak, body: {
                              "id": widget.id.toString()
                            }, headers: {
                              "Accept": "application/json",
                              "Authorization": "Bearer $token",
                            });
                            print(response.body);
                            if (response.statusCode == 200) {
                              // ignore: non_constant_identifier_names
                              final data = jsonDecode(response.body);
                              EasyLoading.dismiss();
                              launchUrl(Uri.parse(data['file']));
                              // var Users = jsonDecode(response.body);
                              // print(Users);
                            } else {
                              EasyLoading.showError('Insert Gagal');
                              EasyLoading.dismiss();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 1, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Cetak",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(9, 107, 199, 1),
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
