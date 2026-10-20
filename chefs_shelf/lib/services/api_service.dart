import 'dart:convert';

import 'package:http/http.dart' as http;

class Recipe {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final List<String> instructions;
  final List<Map<String, String>> ingredients;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.instructions,
    required this.ingredients,
  });

  //aqui é onde vamos processar os dados recebidos da API para criar uma instância de Recipe
  factory Recipe.fromJson(Map<String, dynamic> json) {
    String rawInstructions = json['strInstructions'] ?? '';
    List<String> instructionsList = rawInstructions
        .split(RegExp(r'\r\n|\n|\r'))
        .where((step) => step.trim().isNotEmpty)
        .toList();
    List<Map<String, String>> ingredientsList = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredientsList.add({
          'name': ingredient.trim(),
          'measure': measure?.trim() ?? '',
        });
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      instructions: instructionsList,
      ingredients: ingredientsList,
    );
  }

  // Converte o objeto para salvar no Cloud Firestore no formato exato da avaliação
  Map<String, dynamic> toFirestore() {
    return {
      'idMeal': id,
      'strMeal': title,
      'strCategory': category,
      'strMealThumb': imageUrl,
      'instructions': instructions,
      'ingredients': ingredients,
      'savedAt': DateTime.now().toIso8601String(),
    };
  }
}

// aqui é onde vamos criar a classe ApiService para lidar com as requisições HTTP à API de receitas
class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Realiza a busca de receitas pelo termo informado pelo usuário
  static Future<List<Recipe>> searchRecipes(String query) async {
    final Uri url = Uri.parse('$_baseUrl/search.php?s=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['meals'] == null) {
          return []; // Nenhuma receita foi encontrada
        }

        final List<dynamic> mealsList = data['meals'];
        return mealsList.map((meal) => Recipe.fromJson(meal)).toList();
      } else {
        throw Exception('Erro ao conectar ao servidor HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha no processamento da busca: $e');
    }
  }
  
}