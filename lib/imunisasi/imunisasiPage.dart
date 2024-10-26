import 'package:flutter/material.dart';
import 'package:puskes/home/HomePage.dart';
import 'package:puskes/imunisasi/addimunisasi.dart';
import 'package:puskes/imunisasi/updateImunisasi.dart';
import 'package:puskes/keluhan/addkeluhanPage.dart';
import 'package:puskes/konsultasi/konsultasiAdmin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ListImunisasi extends StatefulWidget {
  const ListImunisasi({
    Key? key,
  }) : super(key: key);

  @override
  State<ListImunisasi> createState() => _ListImunisasiState();
}

List _listsData = [];

class _ListImunisasiState extends State<ListImunisasi> {
  Future<dynamic> listKeluhan() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/listImunisasiAll');
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

  void addImunisasi() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddImunisasi()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Imunisasi',
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
                    "Jenis Vaksin: ${_listsData[index]['jenis_vaksin']} \nVaksin Berikutnya: ${_listsData[index]['jadwal_mendatang']}\nTahun: ${_listsData[index]['tahun']}\nBulan: ${_listsData[index]['nama_bulan']}",
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImunisasiUsersAdminById(
                            id: _listsData[index]['id'].toString(),
                            name: _listsData[index]['name'].toString(),
                            jenis_vaksin: _listsData[index]['jenis_vaksin'].toString(),
                            tanggal_vaksin: _listsData[index]['tanggal_vaksin'].toString(),
                            anak_ke: _listsData[index]['anak_ke'].toString(),
                            jadwal_mendatang: _listsData[index]['jadwal_mendatang'].toString(),
                            tahun: _listsData[index]['tahun'].toString(),
                            namaBulan: _listsData[index]['nama_bulan'].toString(),
                            ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addImunisasi,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), //
    );
  }
}
