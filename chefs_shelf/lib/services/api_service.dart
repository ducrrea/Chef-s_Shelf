import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart'; // Importação do modelo oficial

/// Serviço responsável por realizar as buscas na API TheMealDB
class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Busca receitas pelo termo informado e retorna uma lista de RecipeModel
  static Future<List<RecipeModel>> searchRecipes(String query) async {
    final String cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final Uri url = Uri.parse('$_baseUrl/search.php?s=$cleanQuery');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['meals'] == null) {
          return [];
        }

        final List<dynamic> mealsList = data['meals'];
        return mealsList
            .map((meal) => RecipeModel.fromApiJson(meal))
            .toList();
      } else {
        throw Exception('Erro ao conectar ao servidor HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha no processamento da busca: $e');
    }
  }
}