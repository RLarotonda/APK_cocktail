import 'package:flutter/material.dart';
import 'package:apk_cocktail/model/cocktail_model.dart';
import 'package:apk_cocktail/service/cocktail_service.dart';
import 'package:apk_cocktail/service/giphy_service.dart';

class CocktailPage extends StatefulWidget {
  final Cocktail cocktail;
  CocktailPage(this.cocktail);

  @override
  _CocktailPageState createState() => _CocktailPageState();
}

class _CocktailPageState extends State<CocktailPage> {
  final CocktailService _cocktailService = CocktailService();
  final GiphyService _giphyService = GiphyService();

  late Cocktail _cocktail;
  String? _gifUrl;
  bool _loadingGif = true;
  bool _loadingDetails = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _cocktail = widget.cocktail;
    // Vindo da busca por ingrediente, o drink ainda não tem os detalhes
    _loadingDetails = !_cocktail.isComplete;
    _loadGif();
    if (_loadingDetails) _loadDetails();
  }

  void _loadGif() async {
    final url = await _giphyService.getCocktailGif(_cocktail.name);
    if (!mounted) return;
    setState(() {
      _gifUrl = url;
      _loadingGif = false;
    });
  }

  void _loadDetails() async {
    try {
      final full = await _cocktailService.getById(_cocktail.id);
      if (!mounted) return;
      setState(() {
        if (full != null) {
          _cocktail = full;
        } else {
          _error = true;
        }
        _loadingDetails = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(_cocktail.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _gifArea(),
            const SizedBox(height: 16.0),
            Text(
              _cocktail.name,
              style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _chips(),
            const SizedBox(height: 16.0),
            if (_loadingDetails)
              const Center(child: CircularProgressIndicator())
            else if (_error)
              const Text("Could not load the details of this drink.")
            else
              ..._details(),
          ],
        ),
      ),
    );
  }

  // GIF do GIPHY (com carregamento e fallback para a foto da CocktailDB)
  Widget _gifArea() {
    Widget content;
    if (_loadingGif) {
      content = const CircularProgressIndicator();
    } else if (_gifUrl != null) {
      content = Image.network(
        _gifUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => _fallbackImage(),
      );
    } else {
      content = _fallbackImage();
    }
    return Column(
      children: <Widget>[
        Container(
          height: 260.0,
          width: double.infinity,
          alignment: Alignment.center,
          child: ClipRRect(borderRadius: BorderRadius.circular(12.0), child: content),
        ),
        const SizedBox(height: 4.0),
        const Text("Powered by GIPHY", style: TextStyle(fontSize: 11.0, color: Colors.grey)),
      ],
    );
  }

  Widget _fallbackImage() {
    if (_cocktail.thumb == null) return const Icon(Icons.local_bar, size: 80.0);
    return Image.network(_cocktail.thumb!, fit: BoxFit.contain);
  }

  Widget _chips() {
    return Wrap(
      spacing: 8.0,
      children: <Widget>[
        if (_cocktail.category != null) Chip(label: Text(_cocktail.category!)),
        if (_cocktail.alcoholic != null) Chip(label: Text(_cocktail.alcoholic!)),
      ],
    );
  }

  List<Widget> _details() {
    return <Widget>[
      _sectionTitle("Glass", Icons.wine_bar),
      Text(_cocktail.glass ?? "Not available", style: const TextStyle(fontSize: 18.0)),
      const SizedBox(height: 16.0),
      _sectionTitle("Ingredients", Icons.list_alt),
      ..._cocktail.ingredients.map(
        (item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text("• $item", style: const TextStyle(fontSize: 18.0)),
        ),
      ),
      const SizedBox(height: 16.0),
      _sectionTitle("Instructions", Icons.menu_book),
      Text(
        _cocktail.instructions ?? "Not available",
        style: const TextStyle(fontSize: 18.0, height: 1.4),
      ),
      const SizedBox(height: 24.0),
    ];
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
