import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  final String baseUrl = "https://api.github.com";
  final String token = "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";

  Future<Map<String, dynamic>> fetchUser(String username) async {
    print('Buscando dados do usuário: $username');
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    print('Resposta: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Erro ao carregar dados do usuário.');
      throw Exception('Erro ao carregar os dados do usuário.');
    }
  }

  Future<List<dynamic>> fetchRepositories(String username,
      {int page = 1, String sort = 'created', String direction = 'asc'}) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/users/$username/repos?per_page=10&page=$page&sort=$sort&direction=$direction'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    print('Buscando repositórios para $username na página $page');
    print('Resposta: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Repositórios não encontrados');
    }
  }
}
