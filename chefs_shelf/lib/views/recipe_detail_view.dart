import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/firestore_service.dart';


// aqui é onde vamos criar a tela de detalhes da receita, que vai exibir as informações da receita e permitir que o usuário salve ou remova a receita do caderno
class RecipeDetailView extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

//aqui é onde vamos criar o estado da tela de detalhes da receita, que vai gerenciar o estado de salvamento da receita e exibir as informações da receita
class _RecipeDetailViewState extends State<RecipeDetailView> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaved = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
  }

  void _checkSavedStatus() async {
    bool saved = await _firestoreService.isRecipeSaved(widget.recipe.id);
    if (mounted) {
      setState(() {
        _isSaved = saved;
        _isLoading = false;
      });
    }
  }

  void _toggleSaveRecipe() async {
    setState(() => _isLoading = true);
    if (_isSaved) {
      await _firestoreService.deleteRecipe(widget.recipe.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita removida do caderno!')),
        );
      }
    } else {
      await _firestoreService.saveRecipe(widget.recipe);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita salva com sucesso no caderno!')),
        );
      }
    }
    _checkSavedStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _toggleSaveRecipe,
              backgroundColor: _isSaved ? Colors.red : Colors.deepOrange,
              icon: Icon(_isSaved ? Icons.bookmark_remove : Icons.bookmark_add, color: Colors.white),
              label: Text(_isSaved ? 'Remover' : 'Salvar no Caderno', style: const TextStyle(color: Colors.white)),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.recipe.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Chip(
              label: Text(widget.recipe.category),
              backgroundColor: Colors.deepOrange.shade100,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ingredientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...widget.recipe.ingredients.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, size: 10, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(
                      '${item['name']}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(item['measure'] ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Modo de Preparo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...widget.recipe.instructions.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.deepOrange,
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(entry.value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80), // Espaço extra para o FloatingActionButton não cobrir o texto
          ],
        ),
      ),
    );
  }
}