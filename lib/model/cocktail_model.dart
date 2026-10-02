class Cocktail {
  Cocktail({
    required this.id,
    required this.name,
    this.thumb,
    this.category,
    this.alcoholic,
    this.glass,
    this.instructions,
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final String? thumb;
  final String? category;
  final String? alcoholic;
  final String? glass;
  final String? instructions;
  final List<String> ingredients;

  // A busca por ingrediente (filter.php) só devolve id, nome e foto.
  bool get isComplete => instructions != null;

  factory Cocktail.fromMap(Map<String, dynamic> map) {
    // A API devolve strIngredient1..15 e strMeasure1..15 (muitos nulos)
    final List<String> items = [];
    for (int i = 1; i <= 15; i++) {
      final ingredient = map['strIngredient$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        final measure = map['strMeasure$i'];
        final m = measure == null ? '' : measure.toString().trim();
        final ing = ingredient.toString().trim();
        items.add(m.isEmpty ? ing : '$m $ing');
      }
    }

    return Cocktail(
      id: map['idDrink'].toString(),
      name: map['strDrink'] ?? '',
      thumb: map['strDrinkThumb'],
      category: map['strCategory'],
      alcoholic: map['strAlcoholic'],
      glass: map['strGlass'],
      instructions: map['strInstructions'],
      ingredients: items,
    );
  }

  @override
  String toString() => 'Cocktail(id: $id, name: $name)';
}
