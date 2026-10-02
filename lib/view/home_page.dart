import 'package:flutter/material.dart';
import 'package:apk_cocktail/model/cocktail_model.dart';
import 'package:apk_cocktail/service/cocktail_service.dart';
import 'package:apk_cocktail/view/cocktail_page.dart';

enum SearchMode { name, ingredient }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CocktailService _service = CocktailService();
  final TextEditingController _controller = TextEditingController();

  SearchMode? _mode; // null = nenhum botão de busca escolhido ainda
  List<Cocktail> _cocktails = []; // Lista de drinks exibidos na grade
  bool _loading = false; // Carregando a grade
  bool _randomLoading = false; // Carregando o drink aleatório
  String _message = ''; // Mensagem de erro ou "nenhum drink encontrado"
  bool _searched = false; // true depois que o usuário apertou "search" (para mostrar a seta de voltar)

  @override
  void initState() {
    super.initState();
    _loadStart();
  }

  // Carrega a tela inicial com drinks que começam com a letra "m"
  void _loadStart() {
    _runSearch(
      () => _service.searchByLetter('m'),
      'No drinks found.',
    );
  }

  // Volta para a tela inicial (botão de voltar ou título)
  void _goHome() {
    FocusScope.of(context).unfocus();
    setState(() {
      _mode = null;
      _searched = false;
      _controller.clear();
    });
    _loadStart();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Executa uma requisição e atualiza a grade (com tratamento de erro)
  Future<void> _runSearch(
    Future<List<Cocktail>> Function() request,
    String emptyMessage,
  ) async {
    setState(() {
      _loading = true;
      _message = '';
    });
    try {
      final result = await request();
      if (!mounted) return;
      setState(() {
        _cocktails = result;
        _message = result.isEmpty ? emptyMessage : '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cocktails = [];
        _message = 'Connection error. Check your internet.';
      });
      _showSnack('Error fetching drinks. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Botões "By name" / "By ingredient": escolhem o modo e mostram o campo
  void _selectMode(SearchMode mode) {
    setState(() {
      _mode = mode;
      _controller.clear();
    });
  }

  // Botão de buscar (ou "enter" no teclado) com as validações
  void _search() {
    final text = _controller.text.trim();

    if (_mode == null) {
      _showSnack('First choose: search by name or by ingredient.');
      return;
    }
    if (text.isEmpty) {
      _showSnack('Type something to search!');
      return;
    }
    if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(text)) {
      _showSnack('Type at least one letter.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _searched = true;
    });

    if (_mode == SearchMode.name) {
      _runSearch(
        () => _service.searchByName(text),
        'No drinks named "$text".\nTip: try another spelling (e.g. margarita).',
      );
    } else {
      _runSearch(
        () => _service.filterByIngredient(text),
        'No drinks with the ingredient "$text".\nTip: try another ingredient (e.g. lime, vodka).',
      );
    }
  }

  // Botão "How about a random one?"
  Future<void> _openRandom() async {
    setState(() {
      _randomLoading = true;
    });
    try {
      final cocktail = await _service.getRandom();
      if (!mounted) return;
      if (cocktail == null) {
        _showSnack('Could not pick a random drink.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CocktailPage(cocktail)),
        );
      }
    } catch (e) {
      if (mounted) _showSnack('Error picking a drink. Check your internet.');
    } finally {
      if (mounted) {
        setState(() {
          _randomLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Seta de voltar só depois que o usuário apertou "search"
        leading: _searched
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: "Back to start",
                onPressed: _goHome,
              )
            : null,
        // Title clicável para voltar à tela inicial
        title: GestureDetector(
          onTap: _goHome,
          child: const Text(
            "Choose your drink!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _searchButtons(),
            if (_mode != null) _searchField(),
            Expanded(child: _content()),
            _randomButton(),
          ],
        ),
      ),
    );
  }

  // Dois botões de escolha do tipo de busca
  Widget _searchButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(child: _modeButton("By name", Icons.local_bar, SearchMode.name)),
          const SizedBox(width: 10.0),
          Expanded(
            child: _modeButton("By ingredient", Icons.set_meal, SearchMode.ingredient),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String label, IconData icon, SearchMode mode) {
    final selected = _mode == mode;
    return selected
        ? FilledButton.icon(
            onPressed: () => _selectMode(mode),
            icon: Icon(icon),
            label: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: () => _selectMode(mode),
            icon: Icon(icon),
            label: Text(label),
          );
  }

  // Campo de pesquisa: só aparece depois de escolher o tipo de busca
  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: _mode == SearchMode.name
              ? "Cocktail name (e.g. margarita)"
              : "Ingredient (e.g. vodka)",
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ),
        style: const TextStyle(fontSize: 18.0),
        onSubmitted: (value) => _search(),
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 5.0));
    }
    if (_cocktails.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
    return _createCocktailTable();
  }

  // Grade com 2 drinks por linha: foto + nome embaixo
  Widget _createCocktailTable() {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.85,
      ),
      itemCount: _cocktails.length,
      itemBuilder: (context, index) {
        final cocktail = _cocktails[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CocktailPage(cocktail)),
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: cocktail.thumb == null
                      ? const Icon(Icons.local_bar, size: 60.0)
                      : Image.network(
                          cocktail.thumb!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.local_bar, size: 60.0),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    cocktail.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Botão fixo embaixo da tela
  Widget _randomButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _randomLoading ? null : _openRandom,
          icon: _randomLoading
              ? const SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )
              : const Icon(Icons.casino),
          label: const Text("How about a random one?", style: TextStyle(fontSize: 18.0)),
        ),
      ),
    );
  }
}
