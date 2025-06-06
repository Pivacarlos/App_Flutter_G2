import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import '../../domain/entities/frase.dart';
import '../../domain/use_cases/obter_frase_do_dia.dart';

class FraseViewModel extends ChangeNotifier {
  final ObterFraseDoDia obterFraseDoDia;

  Frase? _fraseOriginal;
  String _fraseTraduzida = '';
  bool _carregando = false;
  Color _corFundo = Colors.white;
  List<String> _historico = [];

  Frase? get fraseOriginal => _fraseOriginal;
  String get fraseTraduzida => _fraseTraduzida;
  bool get carregando => _carregando;
  Color get corFundo => _corFundo;
  List<String> get historico => _historico;

  FraseViewModel(this.obterFraseDoDia) {
    _carregarCorSalva();
    carregarHistorico();
  }

  Future<void> carregarFrase() async {
    _carregando = true;
    notifyListeners();

    try {
      final frase = await obterFraseDoDia();
      _fraseOriginal = frase;

      final traduzida = await traduzirTexto(frase.texto);
      _fraseTraduzida = traduzida;
    } catch (_) {
      _fraseOriginal = Frase(texto: 'Erro ao obter a frase.');
      _fraseTraduzida = '';
    }

    _carregando = false;
    notifyListeners();
  }

  Future<String> traduzirTexto(String texto) async {
    final translator = GoogleTranslator();
    final traducao = await translator.translate(texto, from: 'en', to: 'pt');
    return traducao.text;
  }

  Future<void> definirCorFundo(Color novaCor) async {
  _corFundo = novaCor;
  notifyListeners();
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('cor_fundo', novaCor.value);
  }

  Future<void> _salvarCor() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('cor_fundo', _corFundo.value);
  }

  Future<void> _carregarCorSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final corSalva = prefs.getInt('cor_fundo');
    if (corSalva != null) {
      _corFundo = Color(corSalva);
      notifyListeners();
    }
  }

  Future<void> salvarFraseNoHistorico(String frase) async {
    final prefs = await SharedPreferences.getInstance();
    _historico = prefs.getStringList('historico_frases') ?? [];

    if (!_historico.contains(frase)) {
      _historico.add(frase);
      await prefs.setStringList('historico_frases', _historico);
      notifyListeners();
    }
  }

  Future<void> carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    _historico = prefs.getStringList('historico_frases') ?? [];
    notifyListeners();
  }
}
