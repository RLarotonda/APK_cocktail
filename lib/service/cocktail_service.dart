import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:apk_cocktail/model/cocktail_model.dart';

// Chave de teste gratuita da TheCocktailDB
const String _base = 'https://www.thecocktaildb.com/api/json/v1/1';

class CocktailService {
  // Busca por nome (search.php?s=)
  Future<List<Cocktail>> searchByName(String name) {
    return _getList('$_base/search.php?s=${Uri.encodeQueryComponent(name.trim())}');
  }

  // Lista de drinks que começam com uma letra (usada na tela inicial)
  Future<List<Cocktail>> searchByLetter(String letter) {
    return _getList('$_base/search.php?f=$letter');
  }

  // Lista com o nome de todos os ingredientes (list.php?i=list).
  // Fica em cache: só é buscada na primeira pesquisa por ingrediente.
  List<String>? _ingredientNames;

  Future<List<String>> _getIngredientNames() async {
    if (_ingredientNames != null) return _ingredientNames!;
    final response = await http.get(Uri.parse('$_base/list.php?i=list'));
    if (response.statusCode != 200) throw Exception('Erro ${response.statusCode}');
    final data = json.decode(response.body);
    final drinks = data['drinks'];
    if (drinks is! List) return [];
    _ingredientNames = drinks
        .map<String>((d) => (d['strIngredient1'] ?? '').toString())
        .where((name) => name.isNotEmpty)
        .toList();
    return _ingredientNames!;
  }

  // Busca por ingrediente (filter.php?i=).
  Future<List<Cocktail>> filterByIngredient(String ingredient) async {
    final query = ingredient.trim().toLowerCase();
    final names = await _getIngredientNames();

    List<String> matches =
        names.where((n) => n.toLowerCase().contains(query)).take(8).toList();
    if (matches.isEmpty) matches = [ingredient.trim()]; // tentativa direta

    final lists = await Future.wait(matches.map((name) {
      final formatted = name.replaceAll(' ', '_');
      return _getList('$_base/filter.php?i=${Uri.encodeQueryComponent(formatted)}');
    }));

    // Junta tudo e remove drinks repetidos (mesmo id)
    final Map<String, Cocktail> unique = {};
    for (final list in lists) {
      for (final cocktail in list) {
        unique[cocktail.id] = cocktail;
      }
    }
    final result = unique.values.toList();
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  // Detalhes completos de um drink (lookup.php?i=)
  Future<Cocktail?> getById(String id) async {
    final list = await _getList('$_base/lookup.php?i=$id');
    return list.isEmpty ? null : list.first;
  }

  // Drink aleatório (random.php)
  Future<Cocktail?> getRandom() async {
    final list = await _getList('$_base/random.php');
    return list.isEmpty ? null : list.first;
  }

  Future<List<Cocktail>> _getList(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Erro ${response.statusCode}');
    }
    // Quando não acha nada a API pode devolver corpo vazio
    if (response.body.trim().isEmpty) return [];
    final data = json.decode(response.body);
    final drinks = data['drinks'];
    if (drinks is! List) return [];
    return drinks
        .map<Cocktail>((d) => Cocktail.fromMap(Map<String, dynamic>.from(d)))
        .toList();
  }
}
