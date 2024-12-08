import 'package:flutter/material.dart';
import 'package:puskes/home/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class DatabAyiPage extends StatefulWidget {
  const DatabAyiPage({Key? key}) : super(key: key);

  @override
  State<DatabAyiPage> createState() => _DatabAyiPageState();
}

List _listsData = [];

class _DatabAyiPageState extends State<DatabAyiPage> {
  Future<void> listKeluhan() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/listUsers');
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
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

  _launchURL(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> cetakPdf(String selectedMonth) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    var url = Uri.parse('${dotenv.env['url']}/exportPdf?month=$selectedMonth'); // Add the selected month in the query
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    print(selectedMonth);
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _launchURL(data['file']);
    }
  }

  // Show month selection dialog
  void _showMonthSelectionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          height: 300.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Month',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    String month = _getMonthName(index);
                    return ListTile(
                      title: Text(month),
                      onTap: () {
                        Navigator.pop(context); // Close the dialog
                        cetakPdf(month); // Call cetakPdf with the selected month
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int index) {
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[index];
  }

  // Show the confirmation dialog for deleting a user's data
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await deleteUserData(_listsData[index]['id']); // Pass the user ID
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete user data by ID
  Future<void> deleteUserData(String id) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/deleteUser/$id');
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _listsData.removeWhere((user) => user['id'] == id); // Remove the user from the list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete data')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Data Bayi'),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Homepage()));
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.blue[300],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          itemCount: _listsData.length,
          itemBuilder: (context, index) => GestureDetector(
            onLongPress: () => _showDeleteConfirmationDialog(index), // Trigger long press dialog
            child: Card(
              margin: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Nama: ${_listsData[index]['name']}",
                      style: const TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Email: ${_listsData[index]['email']} \nNik: ${_listsData[index]['nik']}",
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    onTap: () {
                      // Handle navigation to another screen
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMonthSelectionDialog, // Show month selection dialog
        tooltip: 'Select Month for PDF',
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
