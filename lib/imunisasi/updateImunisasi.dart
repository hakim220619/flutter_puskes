import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:puskes/imunisasi/serviceImunisasi.dart';
import 'package:puskes/login/service/servicePage.dart';
import 'package:intl/intl.dart';
import 'package:puskes/penimbangan/servicePenimbangan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImunisasiUsersAdminById extends StatefulWidget {
  const ImunisasiUsersAdminById(
      {Key? key,
      required this.id,
      required this.name,
      required this.jenis_vaksin,
      required this.tanggal_vaksin,
      required this.anak_ke,
      required this.jadwal_mendatang,
      required this.tahun,
      required this.namaBulan})
      : super(key: key);

  final String id;
  final String name;
  final String jenis_vaksin;
  final String tanggal_vaksin;
  final String anak_ke;
  final String jadwal_mendatang;
  final String tahun;
  final String namaBulan;

  @override
  _ImunisasiUsersAdminByIdState createState() =>
      _ImunisasiUsersAdminByIdState();
}

class _ImunisasiUsersAdminByIdState extends State<ImunisasiUsersAdminById> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? anakke = '';
  String? selectedJenisVaksin = '';
  var jenisVaksin;
  String? userRole;
  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  late SharedPreferences profileData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserRole();
  }

  TextEditingController jadwalMendatang = TextEditingController();
  TextEditingController tanggalVaksin = TextEditingController();
  Future<void> _getUserRole() async {
    profileData = await SharedPreferences.getInstance();
    setState(() {
      userRole =
          profileData.getString('role'); // Ambil role dari SharedPreferences
    });
  }

  Widget build(BuildContext context) {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Imunisasi'),
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child: Form(
            key: _formKey,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      obscureText: false,
                      initialValue: widget.tahun.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jenis Vaksin';
                        }
                        return null;
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.date_range),
                          labelText: 'Tahun',
                          hintText: 'Tahun'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      readOnly: true,
                      obscureText: false,
                      initialValue: widget.namaBulan.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jenis Vaksin';
                        }
                        return null;
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.date_range_sharp),
                          labelText: 'Nama Bulan',
                          hintText: 'Nama Bulan'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      readOnly: true,
                      obscureText: false,
                      initialValue: widget.name.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jenis Vaksin';
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
                          labelText: 'Nama',
                          hintText: 'Nama'),
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
                      value: widget.jenis_vaksin,
                      onChanged: (vale) {
                        setState(() {
                          selectedJenisVaksin = vale;
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
                        hintText: 'Tanggal Vaksin Anak',
                        labelText: 'Tanggal Vaksin Anak',
                      ),
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
                          tanggalVaksin.text = widget.tanggal_vaksin;
                        } else {
                          tanggalVaksin.text = date.toString().substring(0, 10);
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue: widget.anak_ke,
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
                    TextFormField(
                      readOnly: true,
                      controller: jadwalMendatang,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.date_range),
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: 'Jadwal Mendatang',
                          labelText: 'Jadwal Mendatang'),
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
                          jadwalMendatang.text = widget.jadwal_mendatang;
                        } else {
                          jadwalMendatang.text =
                              date.toString().substring(0, 10);
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (userRole == '1') // Hanya tampilkan jika role = 1
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await HttpServiceImunisasi.updateImunisasi(
                                      widget.id.toString(),
                                      tanggalVaksin.text.isEmpty
                                          ? widget.tanggal_vaksin
                                          : tanggalVaksin.text,
                                      anakke!.isEmpty
                                          ? widget.anak_ke
                                          : anakke.toString(),
                                      selectedJenisVaksin!.isEmpty
                                          ? widget.jenis_vaksin
                                          : selectedJenisVaksin,
                                      jadwalMendatang.text.isEmpty
                                          ? widget.jadwal_mendatang
                                          : jadwalMendatang.text,
                                      context,
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 10),
                                  child: const Center(
                                    child: Text(
                                      "Update",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await HttpServiceImunisasi.delete(
                                        widget.id.toString(), context);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 10),
                                  child: const Center(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          )
                      ],
                    )
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
