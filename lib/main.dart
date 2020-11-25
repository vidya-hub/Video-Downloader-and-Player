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
  String helperText = "";

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
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20,
                  )),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MyApp();
                }));
                _scaffoldKey.currentState.removeCurrentSnackBar();
                // Scaffold.of(context).hideCurrentSnackBar();
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
              _scaffoldKey.currentState.removeCurrentSnackBar();
              // Scaffold.of(context).hideCurrentSnackBar();
              _showPlayConfirmation(path);
            } else {
              setState(() {
                _isDownloading = true;
              });
              // double percentage = ((total - rec) / total) * 100;
              showSnackBar("Downloading.....", 0);
            }
          },
        );

        print(downloadedPath);
      } else {
        print("incorrect");
        showSnackBar("Enter the Correct Url", 1000);
        setState(() {
          _isDownloading = false;
        });
      }
    } catch (e) {
      showSnackBar(e.toString(), 1000);
      print(e);
      setState(() {
        _isDownloading = false;
      });
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
                        color: Colors.blue,
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MyApp();
                    }));
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
      // appBar: ,
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            Text("Video\nDownloader",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 50,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.arrow_circle_down),
                      border: OutlineInputBorder(gapPadding: 20),
                      labelText: "Enter Video Url",
                      // helperText: _controller.text.isEmpty ? "" : "Enter Url",
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                !_isDownloading
                    ? InkWell(
                        splashColor: Colors.blue,
                        onTap: () async {
                          if (_controller.text.isNotEmpty) {
                            _showMyDialog(_controller.text.trim());
                          }
                        },
                        autofocus: true,
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: Text(
                              "Download",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                        ),
                      )
                    : CircularProgressIndicator(),
                _isDownloading
                    ? InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MyApp();
                          }));
                        },
                        autofocus: true,
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        );
      }),
    );
  }
}
