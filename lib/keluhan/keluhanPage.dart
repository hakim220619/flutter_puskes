import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:puskes/home/HomePage.dart';
import 'package:puskes/keluhan/addkeluhanPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KeluhanPage extends StatefulWidget {
  const KeluhanPage({
    Key? key,
  }) : super(key: key);

  @override
  State<KeluhanPage> createState() => _KeluhanPageState();
}

List _listsData = [];

class _KeluhanPageState extends State<KeluhanPage> {
  Future<dynamic> listKeluhan() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var id = preferences.getString('id');
      var url = Uri.parse('${dotenv.env['url']}/keluhan/$id');
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
  Future Logout(id) async {
    try {
      EasyLoading.show(status: 'loading...');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url_deleteKeluhan = Uri.parse('${dotenv.env['url']}/delete-keluhan/$id');
      http.Response response = await http.get(url_deleteKeluhan, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      print(response.body);
      if (response.statusCode == 200) {
        listKeluhan();
        EasyLoading.dismiss();
        // ignore: use_build_context_synchronously
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showMyDialog(String id, String title, String text, String nobutton,
      String yesbutton, Function onTap, bool isValue) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: isValue,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(nobutton),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(yesbutton),
              onPressed: () async {
                Logout(id);
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
          ],
        );
      },
    );
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
  void addKeluhan(){
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const AddKeluhanPage(),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rujukan',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: InkWell(
              onTap: () {
                Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Homepage()));
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
          itemBuilder: (context, index) => InkWell(
            onLongPress: (){
   _showMyDialog('${_listsData[index]["id"]}' , 'Delete', 'Are you sure you want to Delete?', 'No',
                  'Yes', () async {}, false);
            },
            child: Card(
              margin: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                 
                  const ListTile(
                    leading: Icon(Icons.wysiwyg),
                    title: Text(
                        'Rujukan'),
                  ),
                  const Divider(),
                  ListView.builder(
                    itemCount: 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                           
                            title: Text('${_listsData[index]["pertanyaan"]}'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addKeluhan,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // Th
    );
  }
}
