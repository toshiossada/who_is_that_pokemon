import 'dart:io';

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
  var err = '';

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

  Future<void> _processImageAndIdentify(XFile imageFile) async {
    try {
      err = '';
      final pokemonRepository = PokemonRepository();
      final result = await pokemonRepository.whoIsThatPokemon(img: imageFile);

      _pokemon = result;
    } catch (e) {
      err = e.toString();
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
