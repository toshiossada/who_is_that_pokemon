// ignore_for_file: public_member_api_docs, sort_constructors_first
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
