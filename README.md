# Build With AI

![Project Demo](./assets/pokemon.gif)

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
              SizedBox(
                height: 30,
                child:
                    (!kIsWeb)
                        ? Image.file(File(_lastImageTaken!.path))
                        : Image.network(_lastImageTaken!.path),
              ),
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

## 7 - Crie Pokemon Repository e Troque a APIKEY do AI STUDIO

```dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../models/pokemon_model.dart';

class PokemonRepository {
  final Dio _dio = Dio();

  Future<PokemonModel> whoIsThatPokemon({required XFile img}) async {
    final imageBytes = await img.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    const apiKey = 'API_KEY';
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    final List<Map<String, dynamic>> partsList = [
      {
        "text":
            'Você é um especialista Pokemon, te enviarei uma imagem e perguntar "Quem é esse Pokemon?:" '
            'e você precisa identificar o nome do pokemon e o numero dele em formato json, '
            'Se não identificar o pokemon, retorne um aleatorio. EX:'
            '{"name": "Ivysaur", "number": 2}'
            '{"name": "Charmander", "number": 4}'
            '{"name": "Pikachu", "number": 25}'
            '{"name": "Clefairy", "number": 35}'
            '{"name": "Machoke", "number": 67}',
      },

      {"text": 'Quem é esse Pokemon?: '},
    ];

    partsList.add({
      "inline_data": {"mime_type": 'image/jpeg', "data": base64Image},
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
  Future<void> _processImageAndIdentify(XFile img) async {

    final pokemonRepository = PokemonRepository();
    final result = await pokemonRepository.whoIsThatPokemon(img: img);

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
    final picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(
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
      _cameras.firstWhere((e) => e.lensDirection == CameraLensDirection.back),
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

## 13 - Adicionando ação de abrir camera

```dart
import 'package:flutter/material.dart';

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    (...)
    return Scaffold(
            (...)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _isLoading ? null : _openCameraAndIdentifyPokemon,
            ),
    );
  }
}

```

## 14 - Permissão

```xml
    <uses-permission android:name="android.permission.INTERNET" />
```

## 15 - Gerando APK

```bash
    flutter build apk --release
```
