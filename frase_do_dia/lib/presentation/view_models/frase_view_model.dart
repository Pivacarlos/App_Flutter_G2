import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/frase.dart';
import '../../domain/use_cases/obter_frase_do_dia.dart';

class FraseViewModel extends ChangeNotifier {
  final ObterFraseDoDia obterFraseDoDia;

  Frase? _frase;
  bool _carregando = false;
  Color _corFundo = Colors.white;
  List<String> _historico = [];

  Frase? get frase => _frase;
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

    _frase = await obterFraseDoDia();

    _carregando = false;
    notifyListeners();
  }

  Future<void> alternarCorFundo() async {
    _corFundo = _corFundo == Colors.white ? Colors.blue.shade50 : Colors.white;
    notifyListeners();
    await _salvarCor();
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
