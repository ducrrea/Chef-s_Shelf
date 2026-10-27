import 'package:flutter/material.dart';

import 'package:chefs_shelf/models/recipe_model.dart';
import 'package:chefs_shelf/services/api_service.dart';
import 'package:chefs_shelf/services/auth_service.dart';
import 'package:chefs_shelf/services/firestore_service.dart';
import 'package:chefs_shelf/views/recipe_detail_view.dart';
import 'package:chefs_shelf/widgets/empty_state.dart';
import 'package:chefs_shelf/widgets/recipe_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Controladores e serviços
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // Variáveis de estado para controle da interface
  List<RecipeModel> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';

  /// Função responsável por buscar receitas na API externa
  void _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final results = await ApiService.searchRecipes(query);

      // Garante que a tela ainda está ativa antes de atualizar o estado
      if (!mounted) return;

      setState(() {
        _searchResults = results;
        if (results.isEmpty) {
          _errorMessage = 'Nenhuma receita encontrada com "$query".';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao buscar receitas: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  void dispose() {
    // Libera a memória ocupada pelo controlador de texto ao fechar a tela
    _searchController.dispose();
    super.dispose();
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
            // ==========================================
            // ABA 1: BUSCA DE RECEITAS DA API
            // ==========================================
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
                            hintText: 'Digite um ingrediente ou prato (ex: chicken)...',
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
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Expanded(
                      child: EmptyStateWidget(
                        icon: Icons.search_off,
                        message: _errorMessage,
                      ),
                    )
                  else if (_searchResults.isEmpty)
                    const Expanded(
                      child: EmptyStateWidget(
                        icon: Icons.soup_kitchen,
                        message: 'Pesquise por um ingrediente acima para descobrir receitas deliciosas!',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final recipe = _searchResults[index];
                          // Uso do Widget Reutilizável RecipeCard
                          return RecipeCard(
                            recipe: recipe,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailView(recipe: recipe),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ==========================================
            // ABA 2: MINHAS RECEITAS SALVAS NO FIRESTORE
            // ==========================================
            StreamBuilder<List<RecipeModel>>(
              stream: _firestoreService.getSavedRecipesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    message: 'Erro ao carregar caderno: ${snapshot.error}',
                  );
                }

                final savedRecipes = snapshot.data ?? [];

                if (savedRecipes.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.menu_book,
                    message: 'Seu caderno está vazio.\nBusque e salve receitas na primeira aba!',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = savedRecipes[index];
                    // Uso do Widget Reutilizável RecipeCard com botão de exclusão
                    return RecipeCard(
                      recipe: recipe,
                      trailingIcon: IconButton(
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