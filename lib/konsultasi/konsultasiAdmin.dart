import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:audioplayers/audioplayers.dart';
import "package:cached_network_image/cached_network_image.dart";
import 'package:puskes/konsultasi/httpserviceChat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KonsultasiAdmin extends StatefulWidget {
  const KonsultasiAdmin({
    Key? key,
    required this.id_ortu,
   
    
  }) : super(key: key);
  final String id_ortu;
  

  @override
  _KonsultasiAdminState createState() => _KonsultasiAdminState();
}

List _listsData = [];

class _KonsultasiAdminState extends State<KonsultasiAdmin> {
  AudioPlayer audioPlayer = new AudioPlayer();
  Duration duration = new Duration();
  Duration position = new Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  Future<dynamic> KonsultasiChat() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      // print(widget.id_ortu);
      var url =
          Uri.parse('${dotenv.env['url']}/messages?id_admin=1&id_ortu=${widget.id_ortu.toString()}');
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
          // print(_listsData);
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    KonsultasiChat();
  }

  late SharedPreferences profileData;
  String? id_siswa;
  void initial() async {
    profileData = await SharedPreferences.getInstance();
    setState(() {
      id_siswa = profileData.getString('id');
      print(id_siswa);
    });
  }
  static final _client = http.Client();
  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Konsultasi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _listsData.length,
            itemBuilder: (context, index) => Column(
                children: <Widget>[
                  //         ListView.builder(
                  // itemCount: _listsData.length,
                  // itemBuilder: (context, index) =>
                  // DateChip(
                  //   date: new DateTime(now.year, now.month, now.day - 2),
                  // ),
                  _listsData[index]['flag'] == '1'
                      ? BubbleNormal(
                          text: _listsData[index]['msg'],
                          isSender: false,
                          color: Color(0xFF1B97F3),
                          tail: false,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        )
                      : const Text(''),
                  _listsData[index]['flag'] == '2'
                      ? BubbleSpecialTwo(
                          text: _listsData[index]['msg'],
                          isSender: true,
                          color: Color(0xFFE8E8EE),
                          sent: true,
                        )
                      : const Text('')
                  // DateChip(
                  //   date: now,
                  // ),
                  // const BubbleSpecialTwo(
                  //   text: 'bubble special tow with tail',
                  //   isSender: true,
                  //   color: Color(0xFFE8E8EE),
                  //   sent: true,
                  // ),
                  // const BubbleSpecialTwo(
                  //   text: 'bubble special tow without tail',
                  //   isSender: false,
                  //   tail: false,
                  //   color: Color(0xFF1B97F3),
                  //   textStyle: TextStyle(
                  //     fontSize: 20,
                  //     color: Colors.black,
                  //   ),
                  // ),
              
                  // const SizedBox(
                  //   height: 100,
                  // )
                  // )
                ],
              ),
            ),
          
         
          MessageBar(
            onSend: (message) async => {HttpServiceChat.sendMessageAdmin(message, widget.id_ortu, context),KonsultasiChat()},
            // actions: [
            //   InkWell(
            //     child: Icon(
            //       Icons.add,
            //       color: Colors.black,
            //       size: 24,
            //     ),
            //     onTap: () {},
            //   ),
            //   Padding(
            //     padding: EdgeInsets.only(left: 8, right: 8),
            //     child: InkWell(
            //       child: Icon(
            //         Icons.camera_alt,
            //         color: Colors.green,
            //         size: 24,
            //       ),
            //       onTap: () {},
            //     ),
            //   ),
            // ],
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _image() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 20.0,
        minWidth: 20.0,
      ),
      child: CachedNetworkImage(
        imageUrl: 'https://i.ibb.co/JCyT1kT/Asset-1.png',
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  void _changeSeek(double value) {
    setState(() {
      audioPlayer.seek(new Duration(seconds: value.toInt()));
    });
  }

  void _playAudio() async {
    final url =
        'https://file-examples.com/storage/fef1706276640fa2f99a5a4/2017/11/file_example_MP3_700KB.mp3';
    if (isPause) {
      await audioPlayer.resume();
      setState(() {
        isPlaying = true;
        isPause = false;
      });
    } else if (isPlaying) {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
        isPause = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
      await audioPlayer.play(UrlSource(url));
      setState(() {
        isPlaying = true;
      });
    }

    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        duration = d;
        isLoading = false;
      });
    });
    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        position = p;
      });
    });
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        duration = new Duration();
        position = new Duration();
      });
    });
  }
}
