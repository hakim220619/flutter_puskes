import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:puskes/login/service/servicePage.dart';
import 'package:intl/intl.dart';
import 'package:puskes/penimbangan/servicePenimbangan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddPenimbanganPage extends StatefulWidget {
  const AddPenimbanganPage({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _AddPenimbanganPageState createState() => _AddPenimbanganPageState();
}

class _AddPenimbanganPageState extends State<AddPenimbanganPage> {
  String? bb_lahir;
  String? tb_lahir;
  String? TahunContr;
  String? bulan;
  List _listsData = [];

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<dynamic> GetMonth(tahun) async {
    try {
      print(tahun);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse("${dotenv.env['url']}/getMonth");
      final response = await http.post(url, body: {
        'id_user': widget.id.toString(),
        'tahun': tahun
      }, headers: {
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
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  TextEditingController tanggal_lahir = TextEditingController();

  Widget build(BuildContext context) {
    final List<String> tahun = <String>[
      "2023",
      "2024",
      "2025",
      "2026",
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Add Penimbangan'),
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.date_range),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Tahun'),
                      isExpanded: true,
                      items: tahun.map(
                        (item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        },
                      ).toList(),
                      validator: (value) {
                        if (value == null) return 'Silahkan Masukan Data';
                        return null;
                      },
                      value: TahunContr,
                      onChanged: (vale) {
                        setState(() {
                          bulan = null;
                          GetMonth(vale);
                          TahunContr = vale;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_month),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Bulan'),
                      isExpanded: true,
                      items: _listsData.map((item) {
                        return DropdownMenuItem(
                            value: item['id'].toString(),
                            child: Text(item['nama_bulan'].toString()));
                      }).toList(),
                      validator: (value) {
                        if (value == null) return 'Silahkan Masukan Data';
                        return null;
                      },
                      value: bulan,
                      onChanged: (vale) {
                        setState(() {
                          bulan = vale;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukan Berat Badan';
                        }
                        return null;
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.scale),
                          labelText: 'Masukan Berat badan',
                          hintText: 'Masukan Berat badan'),
                      onChanged: (value) {
                        setState(() {
                          bb_lahir = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukan Tinggi Badan';
                        }
                        return null;
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.person_3_outlined),
                          labelText: 'Masukan Tinggi badan',
                          hintText: 'Masukan Tinggi badan'),
                      onChanged: (value) {
                        setState(() {
                          tb_lahir = value;
                          print(tb_lahir);
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await HttpServicePenimbangan.Addpenimbangan(
                                widget.id.toString(),
                                TahunContr.toString(),
                                bulan.toString(),
                                bb_lahir.toString(),
                                tb_lahir.toString(),
                                context);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 10),
                          child: const Center(
                            child: Text(
                              "Simpan",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(9, 107, 199, 1),
                              borderRadius: BorderRadius.circular(10)),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
