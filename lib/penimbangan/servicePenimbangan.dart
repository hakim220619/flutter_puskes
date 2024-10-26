// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:puskes/listusers/listusers.dart';
import 'package:puskes/login/view/login.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'listPenimbanganbyId.dart';

class HttpServicePenimbangan {
  static final _client = http.Client();

  static final _updatePenimbangan =
      Uri.parse('${dotenv.env['url']}/updatepenimbangan');

  static penimbangan(id_user, bbLahir, tbLahir, id, context) async {

    EasyLoading.show(status: 'loading...');
    http.Response response = await _client.post(_updatePenimbangan,
        body: {"bb_lahir": bbLahir, "tb_lahir": tbLahir, "id": id});

    print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      // print(Users);

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>  ListPenimbanganById(id: id_user.toString()),
          ));
    } else {
      // print(response);
      EasyLoading.showError('Gagal');
      EasyLoading.dismiss();
    }
  }
  static final _addPenimbangan =
  Uri.parse('${dotenv.env['url']}/addPenimbangan');
  static Addpenimbangan(id, tahun, bulan, bbLahir, tbLahir, context) async {
    print(id);
    print(bbLahir);
    print(tbLahir);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client.post(_addPenimbangan,
        body: {"bb_lahir": bbLahir, "tb_lahir": tbLahir, "id_user": id, "tahun" : tahun, "id_bulan": bulan}, headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        });

    print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      // print(Users);

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>  ListPenimbanganById(id: id.toString()),
          ));
    } else {
      print(response);
      EasyLoading.showError('Gagal');
      EasyLoading.dismiss();
    }
  }
}
