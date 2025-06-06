import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:frase_do_dia/presentation/view_models/frase_view_model.dart';

class FraseView extends StatelessWidget {
  const FraseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FraseViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: viewModel.corFundo,
          appBar: AppBar(title: const Text('Frase do Dia')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: viewModel.carregando
                  ? const CircularProgressIndicator()
                  : Text(
                      viewModel.frase?.texto ?? 'Clique no botão para ver a frase do dia.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'copiar',
                tooltip: 'Copiar frase',
                onPressed: () async {
                  final texto = viewModel.frase?.texto;
                  if (texto != null && texto.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: texto));
                    await viewModel.salvarFraseNoHistorico(texto);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Frase copiada!')),
                      );
                    }
                  }
                },
                child: const Icon(Icons.copy),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'cor',
                tooltip: 'Mudar cor de fundo',
                onPressed: viewModel.alternarCorFundo,
                child: const Icon(Icons.color_lens),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'refresh',
                tooltip: 'Nova frase',
                onPressed: viewModel.carregarFrase,
                child: const Icon(Icons.refresh),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'historico',
                tooltip: 'Ver histórico',
                onPressed: () {
                  viewModel.carregarHistorico();
                  showDialog(
                    context: context,
                    builder: (context) {
                      final frases = viewModel.historico.reversed.toList();
                      return AlertDialog(
                        title: const Text('Histórico de Frases'),
                        content: frases.isEmpty
                            ? const Text('Nenhuma frase copiada ainda.')
                            : SizedBox(
                                height: 200,
                                width: 300,
                                child: ListView.builder(
                                  itemCount: frases.length,
                                  itemBuilder: (_, i) => ListTile(
                                    title: Text(frases[i]),
                                  ),
                                ),
                              ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Fechar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Icon(Icons.history),
              ),
            ],
          ),
        );
      },
    );
  }
}
