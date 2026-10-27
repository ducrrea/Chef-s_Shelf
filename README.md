# Chef's Shelf

Aplicativo mobile desenvolvido em **Flutter** integrado ao **Firebase** (Authentication e Cloud Firestore) e à API **TheMealDB**, permitindo que os usuários descubram receitas culinárias online e as salvem em seu caderno de receitas pessoal na nuvem.

---

## Sumário
1. [Visão Geral e Missão](#-visão-geral-e-missão)
2. [Recursos e Funcionalidades](#-recursos-e-funcionalidades)
3. [Modelagem de Dados no Firestore (Arrays e Maps)](#-modelagem-de-dados-no-firestore-arrays-e-maps)
4. [Operações CRUD](#-operações-crud)
5. [Autenticação e Regras de Segurança](#-autenticação-e-regras-de-segurança)
6. [Integração com TheMealDB API](#-integração-com-themealdb-api)
7. [Arquitetura e Princípios de Código Limpo (SOLID)](#-arquitetura-e-princípios-de-código-limpo-solid)
8. [Como Executar no BlueStacks / Emulador Android](#-como-executar-no-bluestacks--emulador-android)
9. [Solução de Problemas Comuns](#-solução-de-problemas-comuns)

---

## Visão Geral e Missão

- **Cliente**: Startup **GourmetGo**
- **Missão**: Construir o núcleo de uma aplicação móvel moderna onde usuários exploram receitas completas da web e organizam seu próprio caderno culinário na nuvem.
- **Desafio Central**: Uma receita vai muito além de um título simples — ela envolve metadados complexos, listas detalhadas de ingredientes associados a medidas e uma sequência cronológica de passos de preparo. Este projeto modela essas informações de forma estruturada, performática e isolada por usuário no Cloud Firestore.

---

##  Recursos e Funcionalidades

-  **Autenticação Segura**: Cadastro e Login por e-mail e senha com feedback de validação em português.
-  **Busca de Receitas em Tempo Real**: Consulta a receitas internacionais via TheMealDB API por nome ou ingrediente.
-  **Visualização Detalhada**: Imagem em alta definição, categoria, lista organizada de ingredientes com dosagens e passos numerados de preparo.
-  **Salvar no Caderno Pessoal**: Cópia instantânea dos dados da API para o banco Firestore do usuário com tipos complexos.
-  **Meu Caderno (Sincronização Reativa)**: Listagem dinâmica em tempo real (`StreamBuilder`) das receitas armazenadas.
-  **Remoção de Receitas**: Exclusão ágil no Firestore direto pelo card ou na tela de detalhes.

---

##  Modelagem de Dados no Firestore (Arrays e Maps)

O projeto cumpre com rigor os critérios de modelagem de dados complexos no NoSQL Cloud Firestore.

### Caminho da Coleção
Cada usuário possui sua própria subcoleção isolada:
```
users/
  └── {userId}/
        └── saved_recipes/
              └── {recipeId}
```

### Estrutura do Documento
Os ingredientes e instruções são armazenados utilizando **arrays** e **maps**:

```json
{
  "idMeal": "52772",
  "strMeal": "Teriyaki Chicken Casserole",
  "strCategory": "Chicken",
  "strMealThumb": "https://www.themealdb.com/images/media/meals/wvpsxx1468634969.jpg",
  "savedAt": "2026-10-27T14:10:00.000Z",
  "ingredients": [
    {
      "name": "soy sauce",
      "measure": "3/4 cup"
    },
    {
      "name": "water",
      "measure": "1/2 cup"
    },
    {
      "name": "brown sugar",
      "measure": "1/4 cup"
    }
  ],
  "instructions": [
    "Preheat oven to 350° F. Spray a 9x13-inch baking dish with cooking spray.",
    "Combine soy sauce, water, and brown sugar in a saucepan and bring to a boil.",
    "Place chicken in prepared dish and pour sauce over chicken.",
    "Bake uncovered for 45 to 50 minutes until chicken is cooked through."
  ]
}
```

- **`ingredients` (`Array<Map<String, String>>`)**: Cada elemento é um Map contendo `name` (nome do ingrediente) e `measure` (quantidade/medida). O modelo também suporta de forma resiliente listas de strings formatadas (`"Ingrediente: Medida"`).
- **`instructions` (`Array<String>`)**: Vetor com cada etapa do modo de preparo dividida e higienizada, permitindo renderização passo a passo enumerada na interface.

---

##  Operações CRUD

As operações de banco de dados são centralizadas na classe `FirestoreService`:

| Operação | Método no `FirestoreService` | Descrição |
|---|---|---|
| **Create** | `saveRecipe(RecipeModel recipe)` | Grava o documento completo com arrays e maps em `users/{uid}/saved_recipes/{id}`. |
| **Read** | `getSavedRecipesStream()` | Retorna um `Stream<List<RecipeModel>>` com atualizações em tempo real do caderno. |
| **Read (Item)** | `isRecipeSaved(String recipeId)` | Checa a existência da receita no caderno do usuário para alternar o botão de ação. |
| **Delete** | `deleteRecipe(String recipeId)` | Remove a receita do caderno do usuário autenticado no Firestore. |

---

##  Autenticação e Regras de Segurança

Para garantir a privacidade e segurança exigidas no briefing, as regras do Cloud Firestore asseguram que nenhum usuário consiga visualizar, gravar ou deletar as receitas de outro usuário.

O arquivo `firestore.rules` contém:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Cada usuário só pode ler, criar, atualizar e deletar receitas do seu próprio caderno
    match /users/{userId}/saved_recipes/{recipeId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Como aplicar no Firebase Console:
1. Acesse o [Firebase Console](https://console.firebase.google.com/).
2. Selecione o projeto `chefs-shelf-37519`.
3. Navegue até **Build > Firestore Database > Regras (Rules)**.
4. Cole o conteúdo acima e clique em **Publicar (Publish)**.

---

##  Integração com TheMealDB API

A comunicação HTTP com a API TheMealDB é gerenciada pelo `ApiService`:
- **Endpoint**: `https://www.themealdb.com/api/json/v1/1/search.php?s={query}`
- **Parsing Automático**: Converte as chaves dinâmicas da API (`strIngredient1` a `strIngredient20` e `strMeasure1` a `strMeasure20`) para a estrutura limpa de `ingredients` e fatia o texto de `strInstructions` em passos individuais.

---

##  Arquitetura e Princípios de Código Limpo (SOLID)

O código foi estruturado seguindo boas práticas de engenharia de software:

- **Separação de Camadas**:
  - `lib/models/`: Modelos de dados e lógica de serialização/deserialização (`RecipeModel`).
  - `lib/services/`: Camada de serviços externos (`AuthService`, `FirestoreService`, `ApiService`).
  - `lib/views/`: Telas da aplicação (`LoginView`, `HomeView`, `RecipeDetailView`).
  - `lib/widgets/`: Componentes visuais reutilizáveis (`RecipeCard`, `EmptyStateWidget`).
- **Princípio da Responsabilidade Única (SRP)**: Cada classe e função tem uma única responsabilidade.
- **Funções Curtas**: Todas as funções possuem menos de 20 linhas, garantindo fácil leitura e manutenção.
- **Idioma dos Comentários**: Todos os comentários do código estão em português do Brasil (`pt-BR`).

---

##  Como Executar no BlueStacks / Emulador Android

### 1. Conectar o BlueStacks via ADB
Certifique-se de que o BlueStacks está aberto com a opção "Depuração Android (ADB)" ativada nas configurações do BlueStacks (Configurações > Avançado > Ativar Depuração Android).

No terminal (PowerShell ou Prompt de Comando), conecte o ADB:
```bash
adb connect 127.0.0.1:5555
```

### 2. Verificar os Dispositivos Detectados
```bash
flutter devices
```
Você verá o dispositivo `127.0.0.1:5555` listado como conectado.

### 3. Navegar até a Pasta do Projeto Flutter (Crucial!)
>  **Atenção**: O comando `flutter run` deve ser executado **obrigatoriamente dentro da pasta `chefs_shelf`** (onde está o arquivo `pubspec.yaml`). Se executado na pasta raiz superior, ocorrerá o erro `Error: No pubspec.yaml file found`.

```bash
cd chefs_shelf
```

### 4. Instalar Dependências e Executar
```bash
flutter pub get
flutter run -d 127.0.0.1:5555
```
*(Caso queira rodar sem especificar o id do dispositivo, apenas digite `flutter run` e selecione o número correspondente ao BlueStacks).*

---

##  Solução de Problemas Comuns

###  Erro: `Error: No pubspec.yaml file found`
- **Causa**: O comando foi executado fora da pasta do projeto Flutter.
- **Solução**:
  ```bash
  cd c:\Users\2DevSesi\Documents\Duda\mobile\Chef's_Shelf\chefs_shelf
  flutter run
  ```

###  Erro: `Your app is using an unsupported Gradle project`
- **Causa**: O arquivo `android/app/build.gradle.kts` estava incorreto ou sem a declaração dos plugins e do namespace.
- **Solução Realizada**: O arquivo foi devidamente configurado com os plugins do Android, Kotlin, Flutter e Google Services, com `minSdk = flutter.minSdkVersion` e suporte a rede.

###  Erro: Falha de conexão com a API ou Firebase
- **Causa**: Falta da permissão de Internet no Android.
- **Solução Realizada**: As permissões `android.permission.INTERNET` e `android.permission.ACCESS_NETWORK_STATE` foram adicionadas ao `AndroidManifest.xml`.
