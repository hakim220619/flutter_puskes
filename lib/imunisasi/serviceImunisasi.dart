// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:puskes/imunisasi/imunisasiPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpServiceImunisasi {
  static final _client = http.Client();

  static final _keluhanUrl = Uri.parse('${dotenv.env['url']}/addImunisasi');
  static addimunisasi(getIdOrtu, tanggalVaksin, anakke, jenisVaksin,
      jadwalMendatang, tahun, bulan, context) async {
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client.post(_keluhanUrl, body: {
      "id_user": getIdOrtu.toString(),
      "tanggal_vaksin": tanggalVaksin,
      "anak_ke": anakke.toString(),
      "jenis_vaksin": jenisVaksin,
      "jadwal_mendatang": jadwalMendatang,
      "tahun": tahun.toString(),
      "id_bulan": bulan.toString(),
    });
    print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const ListImunisasi(),
        ),
      );
      // var Users = jsonDecode(response.body);
      // print(Users);
    } else {
      EasyLoading.showError('Insert Gagal');
      EasyLoading.dismiss();
    }
  }

  static final _imunisasiUpdateUrl =
      Uri.parse('${dotenv.env['url']}/updateImunisasi');

  static updateImunisasi(id, tanggalVaksin,anakke, jenisVaksin,  jadwalMendatang, context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client.post(_imunisasiUpdateUrl, body: {
      "id": id,
      "tanggal_vaksin": tanggalVaksin,
      "anak_ke": anakke.toString(),
      "jenis_vaksin": jenisVaksin,
      "jadwal_mendatang": jadwalMendatang
    }, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    // print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const ListImunisasi(),
        ),
      );
      // var Users = jsonDecode(response.body);
      // print(Users);
    } else {
      EasyLoading.showError('Insert Gagal');
      EasyLoading.dismiss();
    }
  }

  static final _imunisasideleteUrl =
      Uri.parse('${dotenv.env['url']}/deleteImunisasi');
  static delete(id, context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client.post(_imunisasideleteUrl, body: {
      "id": id
    }, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const ListImunisasi(),
        ),
      );
      // var Users = jsonDecode(response.body);
      // print(Users);
    } else {
      EasyLoading.showError('Insert Gagal');
      EasyLoading.dismiss();
    }
  }
}
