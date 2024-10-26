import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:puskes/login/service/servicePage.dart';
import 'package:intl/intl.dart';
import 'package:puskes/penimbangan/servicePenimbangan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImunisasiUsersById extends StatefulWidget {
  const ImunisasiUsersById({Key? key}) : super(key: key);

  @override
  _ImunisasiUsersByIdState createState() => _ImunisasiUsersByIdState();
}

class _ImunisasiUsersByIdState extends State<ImunisasiUsersById> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List _listsData = [];
  String? jenis_vaksin;
  String? tanggal_vaksin;
  String? anak_ke;
  String? jadwal_mendatang;
  Future<dynamic> ListUsersById() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/liestImunisasiById');
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
          jenis_vaksin = _listsData[0]['jenis_vaksin'];
          tanggal_vaksin = _listsData[0]['tanggal_vaksin'];
          anak_ke = _listsData[0]['anak_ke'];
          jadwal_mendatang = _listsData[0]['jadwal_mendatang'];
          // print(tanggal_vaksin);
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ListUsersById();
  }

  Future refresh() async {
    setState(() {
      ListUsersById();
    });
  }

  TextEditingController tanggal_lahir = TextEditingController();

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Imunisasi'),
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              itemCount: _listsData.length,
              itemBuilder: (context, index) => Column(
                children: [
                  TextFormField(
                    readOnly: true,
                    obscureText: false,
                    initialValue: _listsData[index]['jenis_vaksin'],
                    maxLines: 1,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.scale),
                        labelText: 'Jenis Vaksin',
                        hintText: 'Jenis Vaksin'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    readOnly: true,
                    initialValue: tanggal_vaksin,
                    obscureText: false,
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.person_3_outlined),
                        labelText: 'Tanggal Vaksin',
                        hintText: 'Tanggal Vaksin'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    readOnly: true,
                    initialValue: anak_ke,
                    obscureText: false,
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.person_3_outlined),
                        labelText: 'Anak Ke',
                        hintText: 'Anak Ke'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    readOnly: true,
                    initialValue: jadwal_mendatang,
                    obscureText: false,
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.person_3_outlined),
                        labelText: 'Jadwal Mendatang',
                        hintText: 'Jadwal Mendatang'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
