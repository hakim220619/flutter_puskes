import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:puskes/login/service/servicePage.dart';
import 'package:intl/intl.dart';
import 'package:puskes/penimbangan/servicePenimbangan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PenimbanganPageUsers extends StatefulWidget {
  const PenimbanganPageUsers({Key? key}) : super(key: key);

  @override
  _PenimbanganPageUsersState createState() => _PenimbanganPageUsersState();
}

class _PenimbanganPageUsersState extends State<PenimbanganPageUsers> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List _listsData = [];

  // Future<dynamic> ListUsersById() async {
  //   try {
  //     SharedPreferences preferences = await SharedPreferences.getInstance();
  //     var token = preferences.getString('token');
  //     var url = Uri.parse('${dotenv.env['url']}/liestUserById');
  //     final response = await http.get(url, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token",
  //     });
  //     // print(response.body);
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       // print(data);
  //       setState(() {
  //         _listsData = data['data'];
  //         bb_lahir = _listsData[0]['bb_lahir'];
  //         tb_lahir = _listsData[0]['tb_lahir'];
  //         print(_listsData[0]['tb_lahir']);
  //       });
  //     }
  //   } catch (e) {
  //     // print(e);
  //   }
  // }

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
    initial();
  }
  String? bb_lahir;
  var tb_lahir;
  void initial() async {
    profileData = await SharedPreferences.getInstance();
    setState(() {
      
      bb_lahir = profileData.getString('bb_lahir');
      tb_lahir = profileData.getString('tb_lahir');
    });
  }

  TextEditingController tanggal_lahir = TextEditingController();

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Penimbangan'),
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
                    
                    TextFormField(
                      readOnly: true,
                      obscureText: false,
                      initialValue: profileData.getString('bb_lahir'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukan Berat Badan';
                        }
                        return null;
                      },
                      maxLines: 1,
                 
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.scale),
                          labelText: 'Masukan Berat badan',
                          hintText: 'Masukan Berat badan'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      readOnly: true,
                      initialValue: profileData.getString('tb_lahir'),
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
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
