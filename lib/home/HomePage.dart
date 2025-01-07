import 'dart:convert';
import 'dart:ffi';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:profile/profile.dart';
import 'package:puskes/blog/blogPage.dart';
import 'package:puskes/blog/blogdetail.dart';
import 'package:puskes/databayi/databayi.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'package:puskes/login/view/login.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  static const appTitle = 'Puskes';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String counter2 = '265';
  late SharedPreferences profileData;
  List _listsData = [];
  String nameU = '';
  String? name;
  String? nik;
  String? role;
  String? email;
  String? jenis_kelamin;
  String emailU = '';
  String tglLahir = '';
  String addressU = '';
  File? _image;
  String imgshared = '';
  List<dynamic> newsList = [];

  bool _isImageChanged = false;

  Future<dynamic> ListUsersById() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/me');
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      // print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(data);
        setState(() {
          nameU = data['data'][0]['name'];
          tglLahir = data['data'][0]['tanggal_lahir'];
          addressU = data['data'][0]['address'];
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initial();
    ListUsersById();
    loadBlogList();
    _loadImageFromPreferences();
  }

  void initial() async {
    profileData = await SharedPreferences.getInstance();
    setState(() {
      name = profileData.getString('name');
      nik = profileData.getString('nik');
      role = profileData.getString('role');
      email = profileData.getString('email');
      jenis_kelamin = profileData.getString('jenis_kelamin');
    });
  }

  static final _client = http.Client();
  static final _logoutUrl = Uri.parse('${dotenv.env['url']}/logout');

  // ignore: non_constant_identifier_names
  Future Logout() async {
    try {
      EasyLoading.show(status: 'loading...');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      http.Response response = await _client.get(_logoutUrl, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      print(response.body);
      if (response.statusCode == 200) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        setState(() {
          preferences.remove("id");
          preferences.remove("name");
          preferences.remove("nik");
          preferences.remove("email");
          preferences.remove("role");
          preferences.remove("address");
          preferences.remove("jenis_kelamin");
          preferences.remove("bb_lahir");
          preferences.remove("tb_lahir");
          preferences.remove("nama_ortu");
          preferences.remove("token");
          preferences.remove("image");
          preferences.remove("is_login");
        });
        EasyLoading.dismiss();
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const LoginPage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadImageFromPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? imagePath = preferences.getString('image');
    if (imagePath != null) {
      setState(() {
        imgshared = imagePath.toString();
        // print(imgshared);
      });
    }
  }

  Future<void> _showMyDialog(String title, String text, String nobutton,
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
                Logout();
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
          ],
        );
      },
    );
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

  Future refresh() async {
    setState(() {
      ListUsersById();
    });
  }

  Future loadBlogList() async {
    try {
      var url = Uri.parse(
          '${dotenv.env['url']}/blog'); // Replace with your API endpoint
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(data);
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
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: () {
              _showMyDialog('Log Out', 'Are you sure you want to logout?', 'No',
                  'Yes', () async {}, false);

              // ignore: unused_label
              child:
              Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              );
            },
          )
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
                  Container(
                    height: 200,
                    color: Colors.grey, // Warna latar belakang biru
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap:
                                _pickImage, // GestureDetector untuk memilih gambar
                            child: CircleAvatar(
                              radius: 50, // Ukuran lingkaran profil
                              backgroundColor: Colors.white,
                              child: _image != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _image!,
                                        width:
                                            100, // Ukuran sesuai dengan lingkaran profil
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : (imgshared.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            imgshared, // Default gambar dari jaringan
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons
                                              .person, // Placeholder ikon jika tidak ada gambar
                                          size: 50,
                                          color: Colors.grey,
                                        )),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 10,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 15, // Ukuran lingkaran ikon edit
                                backgroundColor: Colors.blueAccent,
                                child: Icon(
                                  Icons.edit,
                                  size: 15,
                                  color: Colors.white, // Ikon edit
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ProfileInfoRow(icon: Icons.person, label: nameU),
                        Divider(),
                        ProfileInfoRow(icon: Icons.date_range, label: tglLahir),
                        Divider(),
                        ProfileInfoRow(
                            icon: Icons.assist_walker, label: addressU),
                        Divider(),
                        if (_isImageChanged)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: _saveChanges,
                                icon:
                                    const Icon(Icons.save, color: Colors.white),
                                label: const Text("Save Changes",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white)),
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
                    height: 660, // Set a height for the GridView
                    child: newsList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Number of boxes per row
                              crossAxisSpacing:
                                  8.0, // Horizontal spacing between boxes
                              mainAxisSpacing:
                                  8.0, // Vertical spacing between boxes
                              childAspectRatio:
                                  0.75, // Box size ratio (width:height)
                            ),
                            itemCount: newsList.length,
                            itemBuilder: (context, index) {
                              final blogItem = newsList[index];
                              return GestureDetector(
                                onTap: () {
                                  // Handle the tap action here
                                  // You can navigate to another screen or show more details
                                  print('Tapped on: ${blogItem['title']}');
                                  // For example, navigate to a detail page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BlogDetailPage(blogItem: blogItem),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        blogItem['imageUrl']
                                            .toString(), // URL for the image
                                        width: double.infinity,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          blogItem['title'],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          blogItem['description'],
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          blogItem['date'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('$name')),
            role == '1'
                ? Column(children: [
                    ListTile(
                      title: const Text('Profile'),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(0);
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    // ListTile(
                    //   title: const Text('Konsultasi'),
                    //   selected: _selectedIndex == 1,
                    //   onTap: () {
                    //     // Update the state of the app
                    //     // _onItemTapped(1);
                    //     // Then close the drawer
                    //     // if (roleid == '3') {
                    //     //   Navigator.push(
                    //     //       context,
                    //     //       MaterialPageRoute(
                    //     //           builder: (context) => const KelasPage(keyword: 'nilaisiswa')));
                    //     // } else if (roleid == '2') {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => ListKonsultasi()));
                    //     // }
                    //   },
                    // ),
                    // ListTile(
                    //   title: const Text('Rujukan'),
                    //   selected: _selectedIndex == 1,
                    //   onTap: () {
                    //     // Update the state of the app
                    //     // _onItemTapped(1);
                    //     // Then close the drawer
                    //     // if (roleid == '3') {
                    //     //   Navigator.push(
                    //     //       context,
                    //     //       MaterialPageRoute(
                    //     //           builder: (context) => const KelasPage(keyword: 'nilaisiswa')));
                    //     // } else if (roleid == '2') {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) =>
                    //                 const ListKeluhanUsers()));
                    //     // }
                    //   },
                    // ),
                    ListTile(
                      title: const Text('Penimbangan'),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(1);
                        // Then close the drawer
                        // if (roleid == '3') {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => const KelasPage(keyword: 'nilaisiswa')));
                        // } else if (roleid == '2') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListUsers()));
                        // }
                      },
                    ),
                    ListTile(
                      title: const Text('Imunisasi'),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(1);
                        // Then close the drawer
                        // if (roleid == '3') {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => const KelasPage(keyword: 'nilaisiswa')));
                        // } else if (roleid == '2') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListImunisasi()));
                        // }
                      },
                    ),
                    ListTile(
                      title: const Text('Data Bayi'),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DatabAyiPage()));
                      },
                    ),
                    ListTile(
                      title: const Text('Blog'),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BlogPage()));
                      },
                    ),
                  ])
                : const Text(''),
            role == '2'
                ? Column(children: [
                    ListTile(
                      title: const Text('Profile'),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(0);
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Kms'),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(1);
                        // Then close the drawer
                        // if (roleid == '3') {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => const KelasPage(keyword: 'nilaisiswa')));
                        // } else if (roleid == '2') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChartPageKms()));
                        // }
                      },
                    ),
                    ListTile(
                      title: const Text('Penimbangan'),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListUsers()));
                        // }
                      },
                    ),
                    ListTile(
                      title: const Text('Imunisasi'),
                      selected: _selectedIndex == 2,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(2);
                        // Then close the drawer

                        // if (roleid == '3') {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => const KelasPage(keyword: 'jadwalpelajaranSiswa')));
                        // } else if (roleid == '2') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListImunisasi()));
                        // }
                      },
                    ),
                    ListTile(
                      title: const Text('Konsultasi'),
                      selected: _selectedIndex == 3,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(3);
                        // Then close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => KonsultasiOrtu()));
                      },
                    ),
                    ListTile(
                      title: const Text('Rujukan'),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(0);
                        // Then close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const KeluhanPage()));
                      },
                    )
                  ])
                : const Text(''),
            role == '3'
                ? Column(children: [
                    ListTile(
                      title: const Text('Home'),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(0);
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Rujukan'),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(0);
                        // Then close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ListKeluhanUsers()));
                      },
                    ),
                    ListTile(
                      title: const Text('Konsultasi'),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        // Update the state of the app
                        // _onItemTapped(1);
                        // Then close the drawer
                        // if (roleid == '3') {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => const KelasPage(keyword: 'nilaisiswa')));
                        // } else if (roleid == '2') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListKonsultasi()));
                        // }
                      },
                    ),
                  ])
                : const Text('')
          ],
        ),
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

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  ProfileInfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
