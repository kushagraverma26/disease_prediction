import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disease Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Home'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  String _prediction;

  Future clickImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);

    setState(() {
      _image = File(image.path);
    });
  }

  Future pickImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(image.path);
    });
  }

  _asyncFileUpload(File file) async {
    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST",
        Uri.parse("https://6ac35ed06eee.ngrok.io/cropdisease/predict/"));
    //add text fields
    //  request.fields["t"] = text;
    //create multipart using filepath, string or bytes
    var pic = await http.MultipartFile.fromPath("image", file.path);
    //add multipart to request
    request.files.add(pic);
    var response = await request.send();

    //Get the response from the server
    var responseData = await response.stream.toBytes();
    print(responseData);
    var responseString = String.fromCharCodes(responseData);
    var decodedResponse = json.decode(responseString);
    var prediction = decodedResponse['prediction'];
    print(decodedResponse);
    print(decodedResponse['prediction']);
    setState(() {
      _prediction = prediction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disease Prediction'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              child: Center(
                child: _image == null
                    ? Text('No image selected.')
                    : Image.file(_image),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 100,
              child: Center(
                child: _image == null
                    ? Text('Upload image to get a prediction')
                    : _prediction == null
                        ? Text('Upload image to get a prediction')
                        : Text(_prediction),
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: new MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0)),
                    elevation: 5.0,
                    minWidth: 200.0,
                    height: 42.0,
                    color: Colors.blue,
                    child: new Text('Upload',
                        style:
                            new TextStyle(fontSize: 20.0, color: Colors.white)),
                    onPressed: () {
                      if (_image == null) {
                      } else {
                        setState(() {
                          _prediction = "Loading... Please wait...";
                        });
                        _asyncFileUpload(_image);
                      }
                    }))
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: clickImage,
            tooltip: 'Click Image',
            child: Icon(Icons.add_a_photo),
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            onPressed: pickImage,
            tooltip: 'Upload Image',
            child: Icon(Icons.image),
          ),
        ],
      ),
    );
  }
}
