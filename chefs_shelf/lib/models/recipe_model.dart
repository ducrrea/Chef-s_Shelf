import 'dart:convert';

//aqui é onde vamos criar a parte que vai lidar com a API TheMealDB, que é onde vamos buscar as receitas
class RecipeModel {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final List<String> instructions;
  final List<Map<String, String>> ingredients;

  RecipeModel({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.instructions,
    required this.ingredients,
  });

  /// Converte o JSON vindo da API TheMealDB
  factory RecipeModel.fromApiJson(Map<String, dynamic> json) {
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

    return RecipeModel(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      instructions: instructionsList,
      ingredients: ingredientsList,
    );
  }

  //aqui é onde vamos criar a função que vai converter o modelo de receita para um mapa que pode ser salvo no Firestore
  factory RecipeModel.fromFirestore(Map<String, dynamic> doc) {
    List<dynamic> rawIngredients = doc['ingredients'] ?? [];
    List<Map<String, String>> parsedIngredients = rawIngredients.map((item) {
      return {
        'name': item['name']?.toString() ?? '',
        'measure': item['measure']?.toString() ?? '',
      };
    }).toList();

    return RecipeModel(
      id: doc['idMeal'] ?? '',
      title: doc['strMeal'] ?? '',
      category: doc['strCategory'] ?? '',
      imageUrl: doc['strMealThumb'] ?? '',
      instructions: List<String>.from(doc['instructions'] ?? []),
      ingredients: parsedIngredients,
    );
  }

  //aqui é onde vamos criar a função que vai converter o modelo de receita para um mapa que pode ser salvo no Firestore
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