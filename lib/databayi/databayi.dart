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
  int? selectedYear;
  int? selectedMonth;
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
        print(data);

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

  Future<void> cetakPdf(String selectedMonth, String selectedYear) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    var url = Uri.parse(
        '${dotenv.env['url']}/exportPdf?month=$selectedMonth&year=$selectedYear'); // Menambahkan tahun ke query
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    print(selectedMonth);
    print(selectedYear);
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _launchURL(data['file']);
    }
  }

  // Show month selection dialog
  void _showYearAndMonthSelectionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Gunakan StatefulBuilder untuk memperbarui UI saat setState
          builder: (context, setState) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // responsive horizontal padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Year and Month',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20.0),

                  // Year selection
                  const Text('Select Year', style: TextStyle(fontSize: 16.0)),
                  Container(
                    width:
                        double.infinity, // Ensure full width for the dropdown
                    child: DropdownButton<int>(
                      hint: const Text('Select Year'),
                      value: selectedYear,
                      onChanged: (int? newYear) {
                        setState(() {
                          selectedYear = newYear;
                          selectedMonth =
                              null; // Reset the month when the year is changed
                        });
                      },
                      items: List.generate(5, (index) {
                        int year = DateTime.now().year - index;
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Month selection (only show if a year is selected)
                  if (selectedYear != null) ...[
                    const Text('Select Month',
                        style: TextStyle(fontSize: 16.0)),
                    Container(
                      width:
                          double.infinity, // Ensure full width for the dropdown
                      child: DropdownButton<int>(
                        hint: const Text('Select Month'),
                        value: selectedMonth,
                        onChanged: (int? newMonth) {
                          setState(() {
                            selectedMonth = newMonth;
                          });
                          Navigator.pop(context); // Close the dialog
                          if (selectedYear != null && selectedMonth != null) {
                            cetakPdf(
                                selectedMonth.toString(),
                                selectedYear
                                    .toString()); // Call cetakPdf with the selected year and month
                          }
                        },
                        items: List.generate(12, (index) {
                          String month = _getMonthName(index);
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text(month),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getMonthName(int index) {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
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
                await deleteUserData(
                    _listsData[index]['id']); // Pass the user ID
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
          _listsData.removeWhere(
              (user) => user['id'] == id); // Remove the user from the list
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Homepage()));
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
            onLongPress: () => _showDeleteConfirmationDialog(
                index), // Trigger long press dialog
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
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Detail"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Nama:",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_listsData[index]['name']}",
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Email:",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_listsData[index]['email']}",
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("NIK:",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_listsData[index]['nik']}",
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Alamat:",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_listsData[index]['address']}",
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Jenis Kelamin:",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_listsData[index]['jenis_kelamin']}",
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Tanggal Lahir:",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_listsData[index]['tanggal_lahir']}",
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Nama Orang Tua:",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_listsData[index]['nama_ortu']}",
                                      style: TextStyle(fontSize: 14)),
                                ],
                              )
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tutup"),
                            ),
                          ],
                        ),
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
        onPressed:
            _showYearAndMonthSelectionDialog, // Show year and month selection dialog
        tooltip: 'Select Year and Month for PDF',
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
