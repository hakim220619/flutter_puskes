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
  const ListImunisasi({Key? key}) : super(key: key);

  @override
  State<ListImunisasi> createState() => _ListImunisasiState();
}

List _listsData = [];

class _ListImunisasiState extends State<ListImunisasi> {
  String? _role; // Variable to store the role of the user

  @override
  void initState() {
    super.initState();
    fetchRole(); // Fetch role from SharedPreferences
    listKeluhan();
  }

  Future<void> fetchRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _role = preferences.getString('role'); // Get role from SharedPreferences
    });
  }

  Future<dynamic> listKeluhan() async {
    try {
      // Mengambil data dari SharedPreferences
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var idUsers = preferences.getString('id');
      var role = preferences.getString('role');
      var url = Uri.parse('${dotenv.env['url']}/listImunisasiAll');

      // Melakukan permintaan GET ke server
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Jika response sukses (200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Inisialisasi data yang akan disimpan
        List<dynamic> filteredData;

        // Jika role adalah 1, data tidak difilter
        if (role == '1') {
          filteredData = data['data'];
        } else {
          // Jika role bukan 1, data difilter berdasarkan id_user
          filteredData = (data['data'] as List).where((item) {
            return item['id_user'] == idUsers.toString();
          }).toList();
        }

        // Update state dengan data yang sesuai
        setState(() {
          _listsData = filteredData;
        });
      } else {
        // Menangani jika ada error dari server
        print("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      // Menangani jika ada exception saat eksekusi
      print("Error: $e");
    }
  }

  Future refresh() async {
    setState(() {
      listKeluhan();
    });
  }

  void addImunisasi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddImunisasi()),
    );
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
                          jenis_vaksin:
                              _listsData[index]['jenis_vaksin'].toString(),
                          tanggal_vaksin:
                              _listsData[index]['tanggal_vaksin'].toString(),
                          anak_ke: _listsData[index]['anak_ke'].toString(),
                          jadwal_mendatang:
                              _listsData[index]['jadwal_mendatang'].toString(),
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
      floatingActionButton: _role == '1'
          ? FloatingActionButton(
              onPressed: addImunisasi,
              tooltip: 'Add Imunisasi',
              child: const Icon(Icons.add),
            )
          : null, // Hide button for other roles
    );
  }
}
