import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  final String baseUrl = "https://api.github.com";

  Future<Map<String, dynamic>> fetchUser(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$username'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Usuário não encontrado');
    }
  }

  Future<List<dynamic>> fetchRepositories(String username, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username/repos?per_page=10&page=$page'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Repositórios não encontrados');
    }
  }
}
