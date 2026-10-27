
import 'package:chefs_shelf/models/recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


//aqui é onde vamos criar o serviço que vai lidar com o Firestore, que é onde vamos salvar as receitas no caderno do usuário
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //aqui é onde vamos criar a função que vai retornar a referência da coleção de receitas salvas do usuário logado
  CollectionReference<Map<String, dynamic>> _getUserRecipesRef() {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Utilizador não autenticado no Firebase.');
    }
    return _db.collection('users').doc(userId).collection('saved_recipes');
  }

  //aqui é onde vamos criar a função que vai salvar a receita no caderno do usuário
  Future<void> saveRecipe(RecipeModel recipe) async {
    final ref = _getUserRecipesRef();
    // Chamada corrigida de toFirestoreMap() para toFirestore()
    await ref.doc(recipe.id).set(recipe.toFirestore());
  }

  //aqui é onde vamos criar a função que vai retornar um Stream de receitas salvas no caderno do usuário
  Stream<List<RecipeModel>> getSavedRecipesStream() {
    final ref = _getUserRecipesRef();
    return ref.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc.data()))
          .toList();
    });
  }

  //aqui é onde vamos criar a função que vai deletar a receita do caderno do usuário
  Future<void> deleteRecipe(String recipeId) async {
    final ref = _getUserRecipesRef();
    await ref.doc(recipeId).delete();
  }

  //aqui é onde vamos criar a função que vai verificar se a receita já está salva no caderno do usuário
  Future<bool> isRecipeSaved(String recipeId) async {
    final ref = _getUserRecipesRef();
    final doc = await ref.doc(recipeId).get();
    return doc.exists;
  }
}