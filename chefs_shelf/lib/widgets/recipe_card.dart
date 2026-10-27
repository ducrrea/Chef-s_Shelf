

import 'package:chefs_shelf/models/recipe_model.dart';
import 'package:flutter/material.dart';

//aqui vai ser onde vamos criar o widget que vai exibir a receita em um card, que vai ser usado na tela de busca e na tela de caderno
class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;
  final Widget? trailingIcon;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            recipe.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            // Tratamento de erro caso a imagem da API falhe no carregamento
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
        ),
        title: Text(
          recipe.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(recipe.category),
        trailing: trailingIcon ?? const Icon(Icons.chevron_right, color: Color.fromARGB(255, 196, 89, 56)),
        onTap: onTap,
      ),
    );
  }
}