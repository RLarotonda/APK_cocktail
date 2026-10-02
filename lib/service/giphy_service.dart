import 'package:http/http.dart' as http;
import 'dart:convert';

String _key = "7lui0xpvgr8Y6fBBlf7qynJQ6kcPGYuW";

class GiphyService {
  // Busca um GIF relacionado ao nome do drink.
  // Se não achar, tenta um GIF genérico de cocktail. Retorna null em caso de erro.
  Future<String?> getCocktailGif(String name) async {
    try {
      String? url = await _search('$name cocktail');
      url ??= await _search('cocktail drink');
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _search(String query) async {
    final response = await http.get(
      Uri.parse(
        "https://api.giphy.com/v1/gifs/search?api_key=$_key"
        "&q=${Uri.encodeQueryComponent(query)}&limit=1&rating=g&lang=en",
      ),
    );
    if (response.statusCode != 200) return null;
    final data = json.decode(response.body);
    final list = data['data'];
    if (list is List && list.isNotEmpty) {
      return list[0]['images']['fixed_height']['url'];
    }
    return null;
  }
}
