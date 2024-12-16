// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:puskes/login/view/login.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpServiceChat {
  static final _client =http.Client() ;

  static final _loginUrl = Uri.parse('${dotenv.env['url']}/addMessage');
  static sendMessage(message, context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
     var token = preferences.getString('token');
     var id_ortu = preferences.getString('id');
     var role = preferences.getString('role');
     var id = preferences.getString('id');

    // print(id_ortu);
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client
        .post(_loginUrl, body: {"msg": message, "id_ortu": id_ortu, "id_admin": '2', "role": role});

    // print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      // var Users = jsonDecode(response.body);
      // print(Users);
     
    } else {
      EasyLoading.showError('Login Gagal');
      EasyLoading.dismiss();
    }
  }

  // static final _loginUrlAdmin = Uri.parse('${dotenv.env['url']}/addMessage');
  static sendMessageAdmin(message, id_ortu, context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
     var token = preferences.getString('token');
     var role = preferences.getString('role');
     var id = preferences.getString('id');
    // print(id_ortu);
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client
        .post(_loginUrl, body: {"msg": message, "id_ortu": id_ortu, "id_admin": id, "role": role});

    // print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      // var Users = jsonDecode(response.body);
      // print(Users);
     
    } else {
      EasyLoading.showError('Login Gagal');
      EasyLoading.dismiss();
    }
  }

  
}
