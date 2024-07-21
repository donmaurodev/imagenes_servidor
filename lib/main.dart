import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImagePickerPage(),
    );
  }
}

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});

  @override
  ImagePickerPageState createState() => ImagePickerPageState();
}

class ImagePickerPageState extends State<ImagePickerPage> {
  File? _image;
  final picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage(BuildContext context) async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.0.103/imagenes-flutter/subir_imagenes.php'), // Cambia la URL si es necesario
      );
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _image!.path,
        filename: basename(_image!.path),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Image uploaded successfully'),
        ));
      } else {
        print('Image upload failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Image upload failed with status: ${response.statusCode}'),
        ));
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading image: $e'),
      ));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subir imagen a servidor',
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? const Text('No ha seleccionado una imagen.')
                : Image.file(_image!),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Abrir Cámara'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Seleccionar de la Galeria'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _uploadImage(context),
                    child: const Text('Upload Image'),
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Limpiar imagen',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
