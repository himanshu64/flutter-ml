import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetect extends StatefulWidget {
  @override
  _FaceDetectState createState() => _FaceDetectState();
}

class _FaceDetectState extends State<FaceDetect> {
  File _imageFile;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;

  Future getImage(bool isCamera) async {
    File image;
    if (isCamera) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    setState(() {
      _imageFile = image;
      isLoading=true;
    });
    if(_imageFile != null){
      detectFaces(_imageFile);
    }else{
      isLoading = false;
    }
    
  }
  detectFaces(File imageFile) async {
    try{
      final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);
    print(faces);
    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
        _loadImage(imageFile);
      });
    }
    }catch (Exception) {
         print('Error on File handling');
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        _image = value;
        isLoading = false;
      }),
    );
      
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Face Detector"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (_imageFile == null)
              ? Center(child: Text('No image selected'))
              : Center(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: FittedBox(
                        child: SizedBox(
                          width: _image.width.toDouble(),
                          height: _image.height.toDouble(),
                          child: CustomPaint(
                            painter: FacePainter(_image, _faces),
                          ),
                        ),
                      )
                      ),
                      Expanded(
                      flex: 1,
                      child: ListView(
                        children: _faces.map<Widget>((f) => FaceCoordinates(f)).toList(),
                      ),
                    ),
                    ],
                  ),
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            onPressed:(){
                getImage(true);
            },
            tooltip: 'Camera',
            child: Icon(Icons.add_a_photo),
          ),
          SizedBox(
            height: 22.0,
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed:(){
                getImage(false);
            },
            tooltip: 'Gallery',
            child: Icon(Icons.folder),
          ),
        ],
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..color = Colors.green[300];

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}
 class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this._face);

  final Face _face;
  
  @override
  Widget build(BuildContext context) {
    final pos = _face.boundingBox;
    return ListTile(
      title: Text(
          '(T:${pos.top}, L:${pos.left}), (B:${pos.bottom}, R:${pos.right})'),
     
    );
  }
}