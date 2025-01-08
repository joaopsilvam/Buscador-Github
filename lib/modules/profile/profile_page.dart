import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../services/github_service.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  ProfilePage({required this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> userFuture;

  @override
  void initState() {
    super.initState();
    final service = Modular.get<GitHubService>();
    userFuture = service.fetchUser(widget.username);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Perfil de ${widget.username}'),
    ),
    body: FutureBuilder<Map<String, dynamic>>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar os dados do usuário.'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Usuário não encontrado.'));
        }

        final user = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dados do Usuário
              CircleAvatar(
                backgroundImage: NetworkImage(user['avatar_url']),
                radius: 50,
              ),
              SizedBox(height: 16),
              Text(user['name'] ?? 'Sem nome', style: TextStyle(fontSize: 20)),
              if (user['bio'] != null) ...[
                SizedBox(height: 8),
                Text(user['bio'], style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
              if (user['blog'] != null && user['blog']!.isNotEmpty)
                ElevatedButton(
                  onPressed: () => Modular.to.pushNamed('/webview', arguments: user['blog']),
                  child: Text('Visitar Site'),
                ),
              if (user['twitter_username'] != null && user['twitter_username']!.isNotEmpty)
                ElevatedButton(
                  onPressed: () => Modular.to.pushNamed(
                    '/webview',
                    arguments: 'https://twitter.com/${user['twitter_username']}',
                  ),
                  child: Text('Twitter'),
                ),
              SizedBox(height: 20),

              // Repositórios
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: Modular.get<GitHubService>().fetchRepositories(widget.username),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erro ao carregar repositórios.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Nenhum repositório encontrado.'));
                    }

                    final repos = snapshot.data!;
                    return ListView.builder(
                      itemCount: repos.length,
                      itemBuilder: (context, index) {
                        final repo = repos[index];
                        return ListTile(
                          title: Text(repo['name']),
                          subtitle: Text(repo['description'] ?? 'Sem descrição'),
                          onTap: () => Modular.to.pushNamed('/webview', arguments: repo['html_url']),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

}
