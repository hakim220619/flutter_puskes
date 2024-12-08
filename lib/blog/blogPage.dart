import 'package:flutter/material.dart';
import 'package:puskes/blog/addBlog.dart';
import 'package:puskes/home/HomePage.dart';
import 'package:puskes/keluhan/verifikasiadmin.dart';
import 'package:puskes/keluhan/addkeluhanPage.dart';
import 'package:puskes/keluhan/listKeluhanById.dart';
import 'package:puskes/konsultasi/konsultasiAdmin.dart';
import 'package:puskes/penimbangan/addPenimbanganPage.dart';
import 'package:puskes/penimbangan/penimbangan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../listusers/listusers.dart';

class BlogPage extends StatefulWidget {
  @override
  State<BlogPage> createState() => _BlogPageState();
}

List _listsData = [];

class _BlogPageState extends State<BlogPage> {
  String? userRole;

  Future<dynamic> ListPenimbangan() async {
    try {
      var url = Uri.parse("${dotenv.env['url']}/blog");
      final response = await http.get(url, headers: {
        "Accept": "application/json",
      });
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listsData = data['data'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getUserRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userRole = preferences.getString('role');
    });
  }

  @override
  void initState() {
    super.initState();
    ListPenimbangan();
    getUserRole();
  }

  Future refresh() async {
    setState(() {
      ListPenimbangan();
    });
  }

  bool isLoading = false;

  void addPenimbangan() {
    if (userRole == '1') {
      File? _selectedImage; // Variabel untuk menyimpan gambar terpilih
      final ImagePicker _picker = ImagePicker();
      final TextEditingController titleController = TextEditingController();
      final TextEditingController descriptionController =
          TextEditingController();

      Future<void> saveBlogBerita() async {
        if (titleController.text.isEmpty ||
            descriptionController.text.isEmpty ||
            _selectedImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Semua data harus diisi')),
          );
          return;
        }

        setState(() {
          isLoading = true; // Tampilkan indikator loading
        });

        try {
          final uri = Uri.parse("${dotenv.env['url']}/saveBlogBerita");
          final request = http.MultipartRequest('POST', uri);

          // Tambahkan field ke request
          request.fields['title'] = titleController.text;
          request.fields['description'] = descriptionController.text;

          // Tambahkan gambar ke request
          request.files.add(
            await http.MultipartFile.fromPath('image', _selectedImage!.path),
          );

          // Kirim request
          final response = await request.send();

          setState(() {
            isLoading = false; // Hentikan indikator loading
          });
          print(response.statusCode);
          if (response.statusCode == 200) {
            final responseData = await response.stream.bytesToString();
            final decodedResponse = jsonDecode(responseData);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      decodedResponse['message'] ?? 'Blog berhasil disimpan')),
            );

            await ListPenimbangan();

            // Tutup modal
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal menyimpan blog')),
            );
          }
        } catch (e) {
          setState(() {
            isLoading = false; // Hentikan indikator loading
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: $e')),
          );
        }
      }

      // Fungsi untuk memilih gambar
      Future<void> _pickImage() async {
        final XFile? pickedFile =
            await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          _selectedImage = File(pickedFile.path);
        }
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tambah Blog Baru',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Blog',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Blog',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _selectedImage == null
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              final XFile? pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  _selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Pilih Gambar'),
                          )
                        : Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  _selectedImage!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () async {
                                  final XFile? pickedFile =
                                      await _picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (pickedFile != null) {
                                    setState(() {
                                      _selectedImage = File(pickedFile.path);
                                    });
                                  }
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Ubah Gambar'),
                              ),
                            ],
                          ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: saveBlogBerita,
                            child: const Text('Simpan'),
                          ),
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Anda tidak memiliki akses untuk menambah blog')),
      );
    }
  }

  Future<void> savePenimbangan(
      String id, String title, String description, File? image) async {
    try {
      final uri = Uri.parse("${dotenv.env['url']}/updateBlogBerita/$id");
      final request = http.MultipartRequest('POST', uri);

      // Tambahkan field ke request
      request.fields['title'] = title;
      request.fields['description'] = description;

      // Tambahkan gambar ke request (jika ada)
      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      // Kirim request
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedResponse = jsonDecode(responseData);

        // Berikan feedback ke pengguna
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(decodedResponse['message'] ?? 'Blog berhasil disimpan')),
        );

        // Lakukan tindakan tambahan jika diperlukan
        await ListPenimbangan(); // Pastikan metode ini didefinisikan
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Gagal menyimpan data. Kode: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Tangani kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void navigateToPenimbanganPage(
      BuildContext context, Map<String, dynamic> data, String userRole) {
    if (userRole == '1') {
      final ImagePicker _picker = ImagePicker();
      final TextEditingController titleController =
          TextEditingController(text: data['title']?.toString() ?? '');
      final TextEditingController descriptionController =
          TextEditingController(text: data['description']?.toString() ?? '');
      File? _selectedImage;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Edit Blog Berita',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Blog',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Blog',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _selectedImage == null
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              final XFile? pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  _selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Pilih Gambar'),
                          )
                        : Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  _selectedImage!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () async {
                                  final XFile? pickedFile =
                                      await _picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (pickedFile != null) {
                                    setState(() {
                                      _selectedImage = File(pickedFile.path);
                                    });
                                  }
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Ubah Gambar'),
                              ),
                            ],
                          ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Pastikan untuk memanggil fungsi `savePenimbangan` dengan benar
                        await savePenimbangan(
                          data['id']?.toString() ?? '',
                          titleController.text,
                          descriptionController.text,
                          _selectedImage,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Anda tidak memiliki akses untuk melihat atau mengedit data ini'),
        ),
      );
    }
  }

  Future<void> deleteBlog(String id) async {
    try {
      final uri = Uri.parse("${dotenv.env['url']}/deleteBlog/$id");
      final response = await http.delete(uri);
print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData['message'] ?? 'Blog berhasil dihapus')),
        );

        // Refresh data setelah menghapus
        await ListPenimbangan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Gagal menghapus data. Kode: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userRole = '1'; // Atur sesuai dengan logika aplikasi
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blog Berita',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Homepage()));
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[300],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          itemCount: _listsData.length,
          itemBuilder: (context, index) => GestureDetector(
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Konfirmasi Penghapusan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Apakah Anda yakin ingin menghapus blog ini? Data tidak dapat dikembalikan.',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                Navigator.pop(context); // Tutup modal
                                await deleteBlog(
                                    _listsData[index]['id'].toString());
                              },
                              child: const Text('Hapus'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Tutup modal
                              },
                              child: const Text('Batal'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Card(
              margin: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "${_listsData[index]['title']}",
                      style: const TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "${_listsData[index]['date']} \n${_listsData[index]['description']}",
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => navigateToPenimbanganPage(
                      context,
                      _listsData[index],
                      userRole,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: userRole == '1'
          ? FloatingActionButton(
              onPressed: addPenimbangan,
              tooltip: 'Tambah Penimbangan',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
