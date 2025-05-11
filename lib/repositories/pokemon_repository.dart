import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../models/pokemon_model.dart';

class PokemonRepository {
  final Dio _dio = Dio();

  Future<PokemonModel> whoIsThatPokemon({required XFile img}) async {
    final imageBytes = await img.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    const apiKey = 'AIzaSyBFwE6ZdMiq887B-Q0BAbECNndLXoZwbS0';
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
