// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:puskes/databayi/databayi.dart';
import 'package:puskes/imunisasi/imunisasiPage.dart';

class HttpServiceDataBayi {
  static final _client = http.Client();

  static final _userUrl = Uri.parse('${dotenv.env['url']}/editUsersOrtu');
  static editData(id, _nik, name, email, password, address, jenisKelamin, tanggalLahir, namaOrtu, bbLahir, tbLahir, context) async {
    EasyLoading.show(status: 'loading...');
    // print(_nik);
    var data = {
      "id": id,
      "nik": _nik,
      "name": name,
      "email": email,
      "password": password,
      "address": address,
      "jenis_kelamin": jenisKelamin,
      "tanggal_lahir": tanggalLahir.text,
      "nama_ortu": namaOrtu,
      "bb_lahir": bbLahir,
      "tb_lahir": tbLahir,
    };
    // print(data);
    http.Response response = await _client.post(_userUrl, body: data);
    print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const DatabAyiPage(),
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
