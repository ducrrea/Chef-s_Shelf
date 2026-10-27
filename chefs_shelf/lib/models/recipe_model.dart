
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

  //aqui converte a lista de instruções em uma string para armazenar no Firestore
  static List<String> _parseInstructions(String? rawInstructions) {
    if (rawInstructions == null || rawInstructions.trim().isEmpty) return [];
    return rawInstructions
        .split(RegExp(r'\r\n|\n|\r'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  //aqui converte a lista de ingredientes em uma lista de mapas para armazenar no Firestore
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

  //aqui cria o modelo a partir do JSON da API TheMealDB
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

  //aqui cria o modelo a partir do documento do Firestore, lidando com diferentes formatos de dados
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

  //aqui cria o modelo a partir do documento do Firestore, lidando com diferentes formatos de dados
  static List<String> _parseFirestoreInstructions(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is Map) {
      return raw.values.map((e) => e.toString()).toList();
    }
    return [];
  }

  //aqui cria o modelo a partir do documento do Firestore, lidando com diferentes formatos de dados
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

  //aqui converte o modelo em um mapa para armazenar no Firestore
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