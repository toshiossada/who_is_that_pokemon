# Build With AI

## Adicionando depedencias

```bash
flutter pub add camera
flutter pub add image_picker
flutter pub add dio
```

## 1 - Inicie o projeto

```dart
import 'app_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AppWidget());
}
```

## 2 - Adicione o widget Principal

```dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}
```

## 3 - Crie a HomePage

```dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quem é Esse Pokémon?'),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
```

## 4 - Criar classe Pokemon

```dart
import 'dart:convert';

class PokemonModel {
  final String name;
  final int number;

  PokemonModel({required this.name, required this.number});

  factory PokemonModel.fromMap(Map<String, dynamic> map) {
    return PokemonModel(name: map['name'] as String, number: map['number'] as int);
  }

  factory PokemonModel.fromJson(String source) =>
      PokemonModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

```

## 5 - Adicione as Variaveis de controle

```dart
class _HomePageState extends State<HomePage> {
  PokemonModel? _pokemon;
  bool _isLoading = false;
  XFile? _lastImageTaken;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    (...)
  }
}
```

## 6 - Começando a construir a tela

```dart
@override
import 'package:flutter/material.dart';

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Quem é Esse Pokémon?')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_lastImageTaken != null)
              Image.file(File(_lastImageTaken!.path)),
            const SizedBox(height: 20),
            if (_pokemon == null)
              Text(
                _pokemon?.name ?? 'Tire uma foto para começar!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              )
            else
              Text(
                'Este é o: #${_pokemon?.number} ${_pokemon?.name}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _isLoading ? null : (){},
            ),
            IconButton(
              icon: const Icon(Icons.file_copy_sharp),
              onPressed: _isLoading ? null : (){},
            ),
          ],
        ),
      ),
    );
  }
}

```

## 7 - Crie Pokemon Repository

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pokemon_model.dart';

class PokemonRepository {
  final Dio _dio = Dio();

  Future<PokemonModel> whoIsThatPokemon({required XFile img}) async {
    final Uint8List imageBytes = await File(img.path).readAsBytes();

    String mimeType = 'image/jpeg';
    final String fileName = img.name.toLowerCase();
    if (fileName.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      mimeType = 'image/jpeg';
    } else if (fileName.endsWith('.webp')) {
      mimeType = 'image/webp';
    }
    const apiKey = 'AIzaSyBFwE6ZdMiq887B-Q0BAbECNndLXoZwbS0';
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    final List<Map<String, dynamic>> partsList = [
      {
        "text":
            'Você é um especialista Pokemon, te enviarei uma imagem e você precisa identificar o nome do pokemon e o numero dele em formato json.',
      },
      {"text": 'Quem é esse Pokemon?: {"name": "Ivysaur", "number": 2}'},
      {"text": 'Quem é esse Pokemon?: {"name": "Charmander", "number": 4}'},
      {"text": 'Quem é esse Pokemon?: {"name": "Pikachu", "number": 25}'},
      {"text": 'Quem é esse Pokemon?: {"name": "Clefairy", "number": 35}'},
      {"text": 'Quem é esse Pokemon?: {"name": "Machoke", "number": 67}'},
      {"text": 'Quem é esse Pokemon?: '},
    ];

    final String base64Image = base64Encode(imageBytes);
    partsList.add({
      "inline_data": {"mime_type": mimeType, "data": base64Image},
    });

    final data = {
      "contents": [
        {"parts": partsList},
      ],
    };

    final response = await _dio.post(
      url,
      queryParameters: {'key': apiKey},
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return PokemonModel.fromJson(
      response.data["candidates"][0]["content"]["parts"][0]['text'],
    );
  }
}
```

## 8 - Crie metodo para processar imagem

```dart
class _HomePageState extends State<HomePage> {
  Future<void> _processImageAndIdentify(XFile imageFile) async {

    final pokemonRepository = PokemonRepository();
    final result = await pokemonRepository.whoIsThatPokemon(img: imageFile);

    _pokemon = result;
    setState(() {
        _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    (...)
  }
}
```

## 9 - Crie metodo para selecionar imagem

```dart
import 'package:flutter/material.dart';

class _HomePageState extends State<HomePage> {
  Future<void> _pickImageAndIdentifyPokemon() async {
    final XFile? imageFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (imageFile != null) {
      setState(() {
        _isLoading = true;
        _pokemon = null;
        _lastImageTaken = imageFile;
      });
      await _processImageAndIdentify(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    (...)
  }
}

```

## 10 - Adicionando ação de selecionar imagem

```dart
import 'package:flutter/material.dart';

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    (...)
    return Scaffold(
            (...)
            IconButton(
              icon: const Icon(Icons.file_copy_sharp),
              onPressed: _isLoading ? null : _pickImageAndIdentifyPokemon,
            ),
    );
  }
}

```

## 11 - Criar Camera Page

```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  var loading = true;
  late List<CameraDescription> _cameras;
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  init() async {
    _cameras = await availableCameras();

    controller = CameraController(
      _cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );
    await controller.initialize();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Column(children: [Expanded(child: CameraPreview(controller))]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile image = await controller.takePicture();

          close(image);
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  void close(XFile image) {
    if (!mounted) return;
    Navigator.pop(context, image);
  }
}
```

## 12 - Crie metodo para abrir camera

```dart
class _HomePageState extends State<HomePage> {
  Future<void> _openCameraAndIdentifyPokemon() async {
    final XFile? imageFile = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage()),
    );

    if (imageFile != null) {
      setState(() {
        _isLoading = true;
        _pokemon = null;
        _lastImageTaken = imageFile;
      });

      await _processImageAndIdentify(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    (...)
  }
}

```

## 13 - Gerando APK

```bash
    flutter build apk --release
```
