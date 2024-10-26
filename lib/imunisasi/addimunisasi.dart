import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:puskes/imunisasi/serviceImunisasi.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddImunisasi extends StatefulWidget {
  const AddImunisasi({Key? key}) : super(key: key);

  @override
  _AddImunisasiState createState() => _AddImunisasiState();
}

String? TahunContr;
String? bulan;
List _listsData = [];

class _AddImunisasiState extends State<AddImunisasi> {
  late String anakke;
  var jenisVaksin;
  // late String selected = '';
  var getIdOrtu;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  // ignore: override_on_non_overriding_member
  List getuserOrtuTerima = [];
  Future getuserOrtu() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    var baseUrl = '${dotenv.env['url']}/listUsers';
    http.Response response = await http.get(Uri.parse(baseUrl), headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    // print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      // print(jsonData);
      setState(() {
        getuserOrtuTerima = jsonData['data'];
        // print(getuserOrtuTerima);
      });
    }
  }

  Future<dynamic> GetMonth(id_user, tahun) async {
    try {
      print(tahun);
      print(id_user);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse("${dotenv.env['url']}/getMonthImunisasi");
      final response = await http.post(url, body: {
        'id_user': id_user.toString(),
        'tahun': tahun.toString()
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

  void initState() {
    super.initState();
    getuserOrtu();
    
    
    // getagentTo();
  }

  final surveyDateController = TextEditingController(text: '');

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();

  }

  TextEditingController jadwalMendatang = TextEditingController();
  TextEditingController tanggalVaksin = TextEditingController();

  final List<String> nameList = <String>[
    "imunisasi Bcg Polio",
    "imunisasi DPT-HB-Hib 1 polio 2",
    "imunisasi DPT-HB-Hib 2 polio 3",
    "imunisasi DPT-HB-Hib 3 polio 4",
    "imunisasi Campak",
    "imunisasi DPT-HB-Hib 1 dosis",
    "imunisasi Campak Rubella 1 dosis",
    "imunisasi Campak Rubella dan DT",
    "imunisasi Tethanus Diphteria TD",
    "imunisasi Pneumococcal Conjugate Vaccine(PCV)",
    "imunisasi Rotavirus",
    "imunisasi Human Papilloma Virus(HPV)",
  ];
  final List<String> tahun = <String>[
    "2023",
    "2024",
    "2025",
    "2026",
  ];

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Imunisasi'),
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
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: 'User'),
                      isExpanded: true,
                      items: getuserOrtuTerima.map((item) {
                        return DropdownMenuItem(
                            value: item['id'], child: Text('${item['name']}'));
                      }).toList(),
                      validator: (value) {
                        if (value == null) return 'Silahkan Masukan Data';
                        return null;
                      },
                      value: getIdOrtu,
                      onChanged: (value) => setState(
                        () {
                          if (value != null) getIdOrtu = value;

                          // print(selected);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
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
                          GetMonth(getIdOrtu, vale);
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
                      readOnly: true,
                      controller: tanggalVaksin,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.date_range),
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: 'Tanggal Vaksin Anak'),
                      validator: (value) {
                        if (value == false) return 'Silahkan Pilih Tanggal';
                        return null;
                      },
                      onTap: () async {
                        DateFormat('dd/mm/yyyy').format(DateTime.now());
                        var date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1999),
                            lastDate: DateTime.now());
                        if (date == null) {
                          tanggalVaksin.text = "";
                        } else {
                          tanggalVaksin.text = date.toString().substring(0, 10);
                        }
                      },
                    ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    // // TextFormField(
                    //   initialValue: getIdOrtu.toString(),
                    //   readOnly: true,
                    //   obscureText: false,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Masukan Nama Ortu';
                    //     }
                    //     return null;
                    //   },
                    //   maxLines: 1,
                    //   decoration: InputDecoration(
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(10.0),
                    //       ),
                    //       prefixIcon: const Icon(Icons.person_2_sharp),
                    //       labelText: 'Masukan Nama Orang Tua',
                    //       hintText: 'Masukan Nama Orang Tua'),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       var nama_ortu = value;
                    //     });
                    //   },
                    // ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Anak Ke';
                        }
                        return null;
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.child_care_outlined),
                          labelText: 'Masukan Anak Ke',
                          hintText: 'Masukan Anak Ke'),
                      onChanged: (value) {
                        setState(() {
                          anakke = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.man_2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Jenis Vaksin'),
                      isExpanded: true,
                      items: nameList.map(
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
                      value: jenisVaksin,
                      onChanged: (vale) {
                        setState(() {
                          jenisVaksin = vale;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: jadwalMendatang,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.date_range),
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: 'Jadwal Mendatang'),
                      validator: (value) {
                        if (value == false) return 'Silahkan Pilih Tanggal';
                        return null;
                      },
                      onTap: () async {
                        DateFormat('dd/mm/yyyy').format(DateTime.now());
                        var date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100));
                        if (date == null) {
                          jadwalMendatang.text = "";
                        } else {
                          jadwalMendatang.text =
                              date.toString().substring(0, 10);
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await HttpServiceImunisasi.addimunisasi(
                                getIdOrtu,
                                tanggalVaksin.text,
                                anakke,
                                jenisVaksin,
                                jadwalMendatang.text,
                                TahunContr,
                                bulan,
                                context);
                                TahunContr = null;
                                bulan = null;
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
