import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_downloader/vidioplayerpage.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _controller = TextEditingController();
  bool _isDownloading = false;
  var downloadedPath = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Diaolog function

  Future _showMyDialog(String url) async {
    var rng = new Random();
    int randomNumber = rng.nextInt(90) + 10;
    var dir = await getExternalStorageDirectory();
    setState(() {
      downloadedPath = "${dir.path}/myFile_$randomNumber.mp4";
    });
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Downloading Location'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("The Video downloaded Location"),
                Text(
                  downloadedPath,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 15,
                  ),
                ),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                    fontSize: 20,
                  )),
              onPressed: () {
                Navigator.pop(context);
                downloadFile(url, downloadedPath).then((value) {});
              },
            ),
          ],
        );
      },
    );
  }

  // downdload function
  Future downloadFile(String url, String path) async {
    setState(() {
      _isDownloading = true;
    });
    Dio dio = Dio();

    // print(randomNumber);
    try {
      print(lookupMimeType(url).toString());
      // var dir = await getExternalStorageDirectory();
      if (lookupMimeType(url).toString() == "video/mp4") {
        showSnackBar("Downloading Started", 1000);

        await dio.download(
          url,
          path,
          options: Options(headers: {
            "accept": "*/*",
          }),
          onReceiveProgress: (rec, total) {
            print(total - rec);
            if (total - rec == 0) {
              setState(() {
                _isDownloading = false;
              });
              showSnackBar("Downloaded.. ", 1000);

              Scaffold.of(context).hideCurrentSnackBar();
              _showPlayConfirmation(path);
            } else {
              setState(() {
                _isDownloading = true;
              });
            }
            showSnackBar("Downloading.....", 0);
          },
        );

        print(downloadedPath);
      } else {
        print("incorrect");
        showSnackBar("Enter the Correct Url", 1000);
      }
    } catch (e) {
      showSnackBar(e.toString(), 1000);
      print(e);
    }
  }

  Future _showPlayConfirmation(String path) async {
    var rng = new Random();
    int randomNumber = rng.nextInt(90) + 10;
    var dir = await getExternalStorageDirectory();
    setState(() {
      downloadedPath = "${dir.path}/myFile_$randomNumber.mp4";
    });
    return showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Confirm'),
              content: Text("Play this video or not?"),
              actions: <Widget>[
                TextButton(
                  child: Text('OK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                        fontSize: 20,
                      )),
                  onPressed: () {
                    // Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return VideoPlayerPage(videoPath: path);
                        },
                      ),
                    );
                  },
                ),
                TextButton(
                  child: Text('Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                    _scaffoldKey.currentState.removeCurrentSnackBar();
                    // Scaffold.of(context).hideCurrentSnackBar();
                  },
                ),
              ]);
        });
  }

  showSnackBar(String message, var duration) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(microseconds: duration),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    // Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(gapPadding: 20),
                  labelText: "Enter Video Url"),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          !_isDownloading
              ? InkWell(
                  onTap: () async {
                    _showMyDialog(_controller.text.trim());
                  },
                  autofocus: true,
                  child: Card(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "Enter",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ),
                  ),
                )
              : CircularProgressIndicator(),
        ],
      ),
    );
  }
}
