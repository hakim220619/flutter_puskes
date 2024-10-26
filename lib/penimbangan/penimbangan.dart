import 'package:flutter/material.dart';
import 'package:puskes/login/service/servicePage.dart';
import 'package:intl/intl.dart';
import 'package:puskes/penimbangan/servicePenimbangan.dart';

class PenimbanganPage extends StatefulWidget {
  const PenimbanganPage({Key? key, required this.id, required this.id_user, required this.bblahir, required this.tblahir}) : super(key: key);
  final String id;
  final String id_user;
  final String bblahir;
  final String tblahir;

  @override
  _PenimbanganPageState createState() => _PenimbanganPageState();
}

class _PenimbanganPageState extends State<PenimbanganPage> {
  
  String? bb_lahir;
  String? tb_lahir;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
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
                      obscureText: false,
                      initialValue: widget.bblahir.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukan Berat Badan';
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
                          labelText: 'Masukan Berat badan',
                          hintText: 'Masukan Berat badan'),
                      onChanged: (value) {
                        setState(() {
                          bb_lahir = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue: widget.tblahir.toString(),
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
                      onChanged: (value) {
                        setState(() {
                          tb_lahir = value;
                        });
                      },
                    ),
                    
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await HttpServicePenimbangan.penimbangan(
                              widget.id_user,
                                bb_lahir == null ?  widget.bblahir : bb_lahir.toString(),
                                tb_lahir == null ?  widget.tblahir : tb_lahir.toString(),
                                widget.id,
                                context);
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
