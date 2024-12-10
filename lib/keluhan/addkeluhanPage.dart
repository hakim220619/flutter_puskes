import 'package:flutter/material.dart';
import 'package:puskes/keluhan/apiKeluhan.dart';
import 'package:puskes/login/service/servicePage.dart';
import 'package:intl/intl.dart';

class AddKeluhanPage extends StatefulWidget {
  const AddKeluhanPage({Key? key}) : super(key: key);

  @override
  _AddKeluhanPageState createState() => _AddKeluhanPageState();
}

class _AddKeluhanPageState extends State<AddKeluhanPage> {
  late String keluhan;
 
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  // ignore: override_on_non_overriding_member


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
          title: const Text('Rujukan'),
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
                    
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                     
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukan Keluhan';
                        }
                        return null;
                      },
                      maxLines: 3,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.question_answer_outlined),
                          labelText: 'Masukan Keluhan',
                          hintText: 'Masukan Keluhan'),
                      onChanged: (value) {
                        setState(() {
                          keluhan = value;
                        });
                      },
                    ),
                   
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await HttpServiceKeluhan.addKeluhan(
                                keluhan,
                                context);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 10),
                          child: const Center(
                            child: Text(
                              "Simpan",
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
