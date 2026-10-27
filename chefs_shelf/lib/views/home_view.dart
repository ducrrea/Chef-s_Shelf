import 'package:chefs_shelf/models/recipe_model.dart';
import 'package:chefs_shelf/services/api_service.dart' hide RecipeModel;
import 'package:chefs_shelf/services/auth_service.dart';
import 'package:chefs_shelf/services/firestore_service.dart';
import 'package:chefs_shelf/views/recipe_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chefs_shelf/models/recipe_model.dart';
import 'package:chefs_shelf/services/api_service.dart';
import 'package:chefs_shelf/services/auth_service.dart';
import 'package:chefs_shelf/services/firestore_service.dart';
import 'package:chefs_shelf/widgets/recipe_card.dart';
import 'package:chefs_shelf/widgets/empty_state.dart';



class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<RecipeModel> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';

  void _onSearch() async {
    final query = _searchController.text;
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final results = await ApiService.searchRecipes(query);
      setState(() {
        _searchResults = results;
        if (results.isEmpty) {
          _errorMessage = 'Nenhuma receita encontrada com "$query".';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao buscar receitas: $e';
      });
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chef\'s Shelf'),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => _authService.signOut(),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.search), text: 'Buscar Receitas'),
              Tab(icon: Icon(Icons.book), text: 'Meu Caderno'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ABA 1: BUSCA DE RECEITAS DA API
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Digite um ingrediente ou prato (ex: chicken, pasta)...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _onSearch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _onSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.search),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isSearching)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage.isNotEmpty)
                    Text(_errorMessage, style: const TextStyle(color: Colors.grey))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final recipe = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  recipe.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(recipe.title),
                              subtitle: Text(recipe.category),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecipeDetailView(recipe: recipe),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ABA 2: MINHAS RECEITAS SALVAS NO FIRESTORE
            StreamBuilder<List<RecipeModel>>(
              stream: _firestoreService.getSavedRecipesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar caderno: ${snapshot.error}'));
                }

                final savedRecipes = snapshot.data ?? [];

                if (savedRecipes.isEmpty) {
                  return const Center(
                    child: Text(
                      'Seu caderno está vazio.\nBusque e salve receitas na primeira aba!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = savedRecipes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recipe.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(recipe.title),
                        subtitle: Text(recipe.category),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _firestoreService.deleteRecipe(recipe.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Receita removida!')),
                              );
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailView(recipe: recipe),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}