// Modelo de dados que representa uma receita tanto da API TheMealDB quanto do Firestore
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

  /// Converte o texto corrido de instruções em uma lista de passos
  static List<String> _parseInstructions(String? rawInstructions) {
    if (rawInstructions == null || rawInstructions.trim().isEmpty) return [];
    return rawInstructions
        .split(RegExp(r'\r\n|\n|\r'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  /// Extrai a lista de ingredientes e medidas dos campos dinâmicos da API
  static List<Map<String, String>> _parseIngredientsFromApi(Map<String, dynamic> json) {
    final List<Map<String, String>> list = [];
    for (int i = 1; i <= 20; i++) {
      final String? name = json['strIngredient$i'];
      final String? measure = json['strMeasure$i'];
      if (name != null && name.trim().isNotEmpty) {
        list.add({
          'name': name.trim(),
          'measure': measure?.trim() ?? '',
        });
      }
    }
    return list;
  }

  /// Converte o JSON vindo da API TheMealDB
  factory RecipeModel.fromApiJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['idMeal']?.toString() ?? '',
      title: json['strMeal']?.toString() ?? '',
      category: json['strCategory']?.toString() ?? '',
      imageUrl: json['strMealThumb']?.toString() ?? '',
      instructions: _parseInstructions(json['strInstructions']),
      ingredients: _parseIngredientsFromApi(json),
    );
  }

  /// Converte a lista de ingredientes armazenada no Firestore
  static List<Map<String, String>> _parseFirestoreIngredients(dynamic raw) {
    if (raw is! List) return [];
    return raw.map<Map<String, String>>((item) {
      if (item is Map) {
        return {
          'name': item['name']?.toString() ?? '',
          'measure': item['measure']?.toString() ?? '',
        };
      }
      final str = item.toString();
      final parts = str.contains(': ') ? str.split(': ') : str.split(' - ');
      return {
        'name': parts.first.trim(),
        'measure': parts.length > 1 ? parts.sublist(1).join(' - ').trim() : '',
      };
    }).toList();
  }

  /// Converte as instruções armazenadas no Firestore (seja lista ou mapa)
  static List<String> _parseFirestoreInstructions(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is Map) {
      return raw.values.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Cria o modelo a partir do documento do Firestore
  factory RecipeModel.fromFirestore(Map<String, dynamic> doc) {
    return RecipeModel(
      id: doc['idMeal']?.toString() ?? '',
      title: doc['strMeal']?.toString() ?? '',
      category: doc['strCategory']?.toString() ?? '',
      imageUrl: doc['strMealThumb']?.toString() ?? '',
      instructions: _parseFirestoreInstructions(doc['instructions']),
      ingredients: _parseFirestoreIngredients(doc['ingredients']),
    );
  }

  /// Serializa a receita para armazenamento no Firestore
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