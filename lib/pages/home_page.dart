import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pokedex_who_are_pokemon/models/pokemon_model.dart';
import 'package:pokedex_who_are_pokemon/pages/camera_page.dart';
import 'package:pokedex_who_are_pokemon/repositories/pokemon_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PokemonModel? _pokemon;
  XFile? _lastImageTaken;
  var _isLoading = false;
  final _picker = ImagePicker();

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

  Future<void> _processImageAndIdentify(XFile img) async {
    try {
      final pokemonRepository = PokemonRepository();

      final result = await pokemonRepository.whoIsThatPokemon(img: img);

      _pokemon = result;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                height: 600,
                child:
                    (!kIsWeb)
                        ? Image.file(File(_lastImageTaken!.path))
                        : Image.network(_lastImageTaken!.path),
              ),
            const SizedBox(height: 20),
            if (_pokemon == null)
              Text(
                'Tire uma foto para começar!',
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
              onPressed: _isLoading ? null : _openCameraAndIdentifyPokemon,
            ),
            IconButton(
              icon: const Icon(Icons.file_copy_sharp),
              onPressed: _isLoading ? null : _pickImageAndIdentifyPokemon,
            ),
          ],
        ),
      ),
    );
  }
}
