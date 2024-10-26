import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puskes/keluhan/keluhanPage.dart';
import 'package:puskes/keluhan/listKeluhanUsers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class HttpServiceKeluhan {
  static final _client = http.Client() ;

  static final _keluhanUrl = Uri.parse('${dotenv.env['url']}/addKeluhan');
  static addKeluhan(pertanyaan, context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
     var id_ortu = preferences.getString('id');
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client
        .post(_keluhanUrl, body: {"pertanyaan": pertanyaan, "id_ortu": id_ortu, "id_admin": '1'});
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const KeluhanPage(),
        ),
       
      );
      // var Users = jsonDecode(response.body);
      // print(Users);
     
    } else {
      EasyLoading.showError('Insert Gagal');
      EasyLoading.dismiss();
    }
  }
    static final _jawabanUrl = Uri.parse('${dotenv.env['url']}/addJawaban');
  static addJawaban(jawaban, id_ortu, id, context) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    //  var id_ortu = preferences.getString('id');
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client
        .post(_jawabanUrl, body: {"jawaban": jawaban, "id_ortu": id_ortu, "id_admin": '1', "id": id});

        print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names

      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const ListKeluhanUsers(),
        ),
      );
      // var Users = jsonDecode(response.body);
      // print(Users);
     
    } else {
      EasyLoading.showError('Insert Gagal');
      EasyLoading.dismiss();
    }
  }
  static final _verifikasi = Uri.parse('${dotenv.env['url']}/verifikasiKeluhan');
  static verivikasi(id, context) async {
    print(id);
    SharedPreferences preferences = await SharedPreferences.getInstance();
     var token = preferences.getString('token');
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client
        .post(_verifikasi, body: {"id": id}, headers: {
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
          builder: (BuildContext context) => const ListKeluhanUsers(),
        ),
      );
      // var Users = jsonDecode(response.body);
      // print(Users);
     
    } else {
      EasyLoading.showError('Insert Gagal');
      EasyLoading.dismiss();
    }
  }  
  _launchURL(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }


  static final _cetak = Uri.parse('${dotenv.env['url']}/word');
  static cetak(id, context) async {
    print(id);
    SharedPreferences preferences = await SharedPreferences.getInstance();
     var token = preferences.getString('token');
    EasyLoading.show(status: 'loading...');
    http.Response response = await _client
        .post(_cetak, body: {"id": id}, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
        print(response.body);
    if (response.statusCode == 200) {
      // ignore: non_constant_identifier_names
 final data = jsonDecode(response.body);
      EasyLoading.dismiss();
      launchUrl(Uri.parse(data['file']));
      // var Users = jsonDecode(response.body);
      // print(Users);
     
    } else {
      EasyLoading.showError('Insert Gagal');
      EasyLoading.dismiss();
    }
  }  
}
