import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<String> fetchFraseDoDia() async {
    final response = await http.get(
      Uri.parse('https://api.adviceslip.com/advice'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['slip']['advice'];
    } else {
      throw Exception('Falha ao carregar a frase');
    }
  }
}
