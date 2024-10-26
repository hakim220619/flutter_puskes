import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:puskes/databayi/databayi.dart';
import 'package:puskes/home/blog.dart';
import 'package:puskes/imunisasi/imunisasiPage.dart';
import 'package:puskes/imunisasi/imunisasiusers.dart';
import 'package:puskes/keluhan/listKeluhanUsers.dart';
import 'package:puskes/kms/kms.dart';
import 'package:puskes/konsultasi/konsultasiAdmin.dart';
import 'package:puskes/konsultasi/listKonsultasi.dart';
import 'package:puskes/konsultasi/view.dart';
import 'package:puskes/keluhan/keluhanPage.dart';
import 'package:puskes/listusers/listusers.dart';
import 'package:puskes/penimbangan/penimbanganusers.dart';
import 'package:puskes/login/view/login.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);
  static const appTitle = 'Puskes';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: MyHomePage(title: appTitle),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SharedPreferences profileData;
  String nameU = '';
  String emailU = '';
  String addressU = '';
  String imgshared = '';
  File? _image;
  bool _isImageChanged = false;
  List<dynamic> newsList = [];

  @override
  void initState() {
    super.initState();
    _initialize();
    _loadImageFromPreferences();
    loadBlogList(); 
  }

  Future<void> _initialize() async {
    profileData = await SharedPreferences.getInstance();
    await _listUsersById();
  }

  Future<void> _listUsersById() async {
    try {
      var token = profileData.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/me');
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nameU = data['data'][0]['name'];
          emailU = data['data'][0]['email'];
          addressU = data['data'][0]['address'];
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _logout() async {
    try {
      EasyLoading.show(status: 'Logging out...');
      var token = profileData.getString('token');
      var logoutUrl = Uri.parse('${dotenv.env['url']}/logout');
      var response = await http.get(logoutUrl, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        await _clearPreferences();
        EasyLoading.dismiss();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      print("Error during logout: $e");
    }
  }

  Future<void> _clearPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isImageChanged = true;
      });
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('image', pickedFile.path);
    }
  }

  Future<void> _loadImageFromPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? imagePath = preferences.getString('image');
    if (imagePath != null) {
      setState(() {
        imgshared = imagePath.toString();
        print(imgshared);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_image != null) {
      try {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        var token = preferences.getString('token');
        var idUser = preferences.getString('id');
        var uri = Uri.parse('${dotenv.env['url']}/change-image');

        var request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['Accept'] = 'application/json'
          ..fields['id_user'] = idUser ?? '';

        request.files
            .add(await http.MultipartFile.fromPath('image', _image!.path));

        var response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded successfully')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _logout();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future loadBlogList() async {
    try {
    
      var url = Uri.parse(
          'https://apipuskesmas.sppapp.com/api/blog'); // Replace with your API endpoint
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          newsList =
              data['data']; // Adjust based on your API response structure
        });
      } else {
        print('Failed to load blog list: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching blog list: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 8,
            shadowColor: Colors.black45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: _image != null
                            ? Image.file(
                                _image!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                imgshared, // Default network image
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: FloatingActionButton(
                          onPressed: _pickImage,
                          mini: true,
                          backgroundColor: Colors.blueAccent,
                          child:
                              const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "Profile",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('Name', nameU),
                        if (_isImageChanged)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: _saveChanges,
                                icon:
                                    const Icon(Icons.save, color: Colors.white),
                                label: const Text("Save Changes",
                                    style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 660, // Set a height for the ListView
                    child: newsList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: newsList.length,
                            itemBuilder: (context, index) {
                              final blogItem = newsList[index];
                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      blogItem['imageUrl'].toString()
                                          , // Use network image if URL is provided
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        blogItem['title'],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        '${blogItem['description']}\n${blogItem['date']}',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text('Welcome, $nameU',
                style: const TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: const Text('Konsultasi'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ListKonsultasi()));
            },
          ),
          // Add other ListTile for different sections here
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}
