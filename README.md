# 🍹 Choose your drink!

Aplicativo mobile desenvolvido em **Flutter/Dart** que permite pesquisar drinks (cocktails) por nome ou por ingrediente, ver os detalhes da receita e assistir a um **GIF animado** relacionado ao drink.

Trabalho prático da disciplina de desenvolvimento mobile — **Flutter + API + GIFs**.

---

## 📱 Funcionalidades

- **Tela inicial** com uma lista de drinks (começam com a letra "M": margarita, mojito...).
- **Pesquisa por nome** do drink (ex.: `margarita`).
- **Pesquisa por ingrediente** (ex.: `vodka`, `lime`), com busca parcial: digitar `sugar` também encontra drinks com `Sugar syrup`.
- **Tela de detalhes** com GIF animado, categoria, tipo (alcoólico ou não), copo, ingredientes com medidas e modo de preparo.
- **Drink aleatório** com um toque.
- **Fallback de imagem**: se o GIPHY não retornar nada, o app mostra a foto do drink.

## 🔘 Botões

| Botão | O que faz |
|---|---|
| **By name** | Ativa a pesquisa por nome do drink |
| **By ingredient** | Ativa a pesquisa por ingrediente |
| **🔍 (lupa)** | Executa a pesquisa com o termo digitado (ou tecla Enter) |
| **How about a random one?** | Abre um drink aleatório |
| **← (seta)** | Volta para a tela inicial / tela anterior |

## ✅ Validações

- Nenhum modo de busca escolhido antes de pesquisar.
- Campo vazio ou apenas com espaços.
- Texto sem nenhuma letra (ex.: `123`).
- Falha de conexão ou erro da API (mensagem na tela + `SnackBar`).
- Pesquisa sem resultados (mensagem com dica de nova busca).
- Botão de drink aleatório desabilitado durante o carregamento.

## 🌐 APIs utilizadas

| API | Uso |
|---|---|
| [TheCocktailDB](https://www.thecocktaildb.com/api.php) | Dados dos drinks (chave de teste gratuita) |
| [GIPHY](https://developers.giphy.com/) | GIF relacionado ao drink |

Endpoints da TheCocktailDB usados: `search.php?s=` (nome), `search.php?f=` (letra), `filter.php?i=` (ingrediente), `list.php?i=list` (lista de ingredientes), `lookup.php?i=` (detalhes por id) e `random.php` (aleatório).

## 🗂️ Estrutura do projeto

```
lib/
├── main.dart                       # Ponto de entrada e tema do app
├── model/
│   └── cocktail_model.dart         # Classe Cocktail (fromMap)
├── service/
│   ├── cocktail_service.dart       # Requisições à TheCocktailDB
│   └── giphy_service.dart          # Requisições ao GIPHY
└── view/
    ├── home_page.dart              # Tela inicial: busca, botões e grade de drinks
    └── cocktail_page.dart          # Tela de detalhes com GIF
```

O código segue a separação **model / service / view**: o *model* representa os dados, os *services* conversam com as APIs e as *views* cuidam só da interface.

## 🚀 Como executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (o `pubspec.yaml` exige Dart `^3.12.2`)
- Emulador Android/iOS ou um aparelho físico
- Uma chave de API gratuita do [GIPHY](https://developers.giphy.com/)

### Passo a passo

1. Clone o repositório:
   ```bash
   git clone <URL-DO-REPOSITORIO>
   cd apk_cocktail
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Coloque a sua chave do GIPHY em `lib/service/giphy_service.dart`:
   ```dart
   String _key = "SUA_CHAVE_AQUI";
   ```

4. Execute o app:
   ```bash
   flutter run
   ```

> A permissão de internet (`android.permission.INTERNET`) já está configurada no `AndroidManifest.xml`.

### Gerar o ícone do app (opcional)

```bash
dart run flutter_launcher_icons
```

## 🛠️ Tecnologias

- [Flutter](https://flutter.dev/) / [Dart](https://dart.dev/)
- Pacote [`http`](https://pub.dev/packages/http) para as requisições
- Material Design 3 (tema escuro)

## 👥 Autores

- **Rafael Larotonda** — [@RLarotonda](https://github.com/RLarotonda)
- **Luana Cosmo** — [@Luanacosmo](https://github.com/Luanacosmo)

## 📄 Licença

Projeto acadêmico, sem fins comerciais.

---

*Dados fornecidos por TheCocktailDB. GIFs fornecidos por GIPHY.*
