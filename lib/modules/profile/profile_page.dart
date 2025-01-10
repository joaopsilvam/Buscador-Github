import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir links externos
import '../../services/github_service.dart';
import '../home/home_bloc.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  ProfilePage({required this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> userFuture;
  final List<dynamic> _repositories = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _currentSort = 'created';
  String _currentDirection = 'asc';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final service = Modular.get<GitHubService>();
    userFuture = service.fetchUser(widget.username);
    _loadRepositories();

    // Salva a pesquisa inicial no HomeBloc
    BlocProvider.of<HomeBloc>(context).add(SaveSearchEvent(widget.username));
  }

  Future<void> _loadRepositories() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newRepos = await Modular.get<GitHubService>().fetchRepositories(
        widget.username,
        page: _currentPage,
        sort: _currentSort,
        direction: _currentDirection,
      );

      setState(() {
        if (_currentPage == 1) _repositories.clear();
        _repositories.addAll(newRepos);
        _hasMore = newRepos.length == 10;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMore() {
    setState(() {
      _currentPage++;
      _loadRepositories();
    });
  }

  void _changeSorting(String sort, String direction) {
    setState(() {
      _currentSort = sort;
      _currentDirection = direction;
      _repositories.clear(); // Limpa os repositórios para carregar novamente
      _currentPage = 1; // Reinicia a paginação
      _hasMore = true; // Permite carregar mais repositórios
      _loadRepositories(); // Recarrega os repositórios com os novos parâmetros
    });
  }

  String formatTimeAgo(DateTime updatedAt) {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 0) {
      return 'Atualizado há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    } else if (difference.inHours > 0) {
      return 'Atualizado há ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'Atualizado há ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Atualizado há poucos segundos';
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o link: $url')),
      );
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Color.fromARGB(100, 0, 0, 92),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Color.fromARGB(50, 0, 0, 92),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            BlocProvider.of<HomeBloc>(context).add(SaveSearchEvent(value));
            Modular.to.pushReplacementNamed('/profile/$value');
          }
        },
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Color.fromARGB(100, 0, 0, 92),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String imagePath, String? value, {String? url}) {
    if (value == null || value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: url != null ? () => _launchUrl(url) : null,
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14, // Diminuído para 14
                  color: Color(0xFF4A5568), // Cor #4A5568
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding geral
              child: isDesktop
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              right: 60, left: 16), // Espaço entre logo e barra
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 150, // Largura fixa da logo
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.5, // Largura fixa da barra
                          child: _buildSearchBar(),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16.0), // Espaço entre logo e barra
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 250, // Largura fixa da logo
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.8, // Largura fixa da barra
                          child: _buildSearchBar(),
                        ),
                      ],
                    ),
            ),
          ),
        ),
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
          final userInfoWidget = Container(
            margin: const EdgeInsets.all(16.0), // Margem ao redor
            color: Colors.white, // Fundo branco
            width: MediaQuery.of(context).size.width *
                0.25, // 25% da largura da tela
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user['avatar_url']),
                            radius: 35, // Tamanho reduzido da foto
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name'] ?? 'Sem nome',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '@${user['login']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (user['bio'] != null)
                        Text(
                          user['bio']!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Color(0xFF4A5568), // Cor #4A5568
                          ),
                        ),
                      SizedBox(height: 16),
                      _buildInfoRow('assets/icons/seguidores.png',
                          user['followers'].toString() + ' seguidores'),
                      _buildInfoRow('assets/icons/coracao.png',
                          user['following'].toString() + ' seguindo'),
                      _buildInfoRow(
                          'assets/icons/empresa.png', user['company']),
                      _buildInfoRow(
                          'assets/icons/cidade.png', user['location']),
                      _buildInfoRow('assets/icons/email.png', user['email']),
                      _buildInfoRow('assets/icons/site.png', user['blog'],
                          url: user['blog']),
                      _buildInfoRow(
                        'assets/icons/twitter.png',
                        user['twitter_username'],
                        url: user['twitter_username'] != null
                            ? 'https://twitter.com/${user['twitter_username']}'
                            : null,
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Modular.to.pushNamed('/contact'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8C19D2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              minimumSize: Size(0, 54),
                            ),
                            child: Text(
                              'Contato',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          final repoListWidget = Center(
            // Centraliza o container na tela
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.7, // Define 70% da largura da tela
              color: Colors.white, // Fundo branco
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              margin: const EdgeInsets.symmetric(
                  vertical: 20.0), // Margin aumentado
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ), // Padding interno
                    margin: EdgeInsets.symmetric(
                        vertical: 5), // Espaçamento externo
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFE2E8F0), // Cor da borda
                        width: 1.5,
                      ),
                      borderRadius:
                          BorderRadius.circular(5), // Arredondamento das bordas
                      color: Colors.white, // Fundo branco
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Ordenar por:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color.fromARGB(100, 0, 0,
                                92), // Cor consistente com barra de busca
                          ),
                        ),
                        SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _currentSort,
                          underline:
                              SizedBox(), // Remove a linha inferior padrão do DropdownButton
                          onChanged: (value) {
                            if (value != null)
                              _changeSorting(value, _currentDirection);
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'created',
                              child: Text(
                                'Data de criação',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color.fromARGB(100, 0, 0, 92),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'updated',
                              child: Text(
                                'Última atualização',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color.fromARGB(100, 0, 0, 92),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'full_name',
                              child: Text(
                                'Nome',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color.fromARGB(100, 0, 0, 92),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Direção:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color.fromARGB(
                                100, 0, 0, 92), // Cor consistente
                          ),
                        ),
                        SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _currentDirection,
                          underline:
                              SizedBox(), // Remove a linha inferior padrão do DropdownButton
                          onChanged: (value) {
                            if (value != null)
                              _changeSorting(_currentSort, value);
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'asc',
                              child: Text(
                                'Crescente',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color.fromARGB(100, 0, 0, 92),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'desc',
                              child: Text(
                                'Decrescente',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color.fromARGB(100, 0, 0, 92),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _repositories.length,
                      itemBuilder: (context, index) {
                        final repo = _repositories[index];
                        return ListTile(
                          title: InkWell(
                            onTap: () => _launchUrl(repo['html_url']),
                            child: Text(
                              repo['name'] ?? 'Sem nome',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                repo['description'] ?? 'Sem descrição',
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.star_outline, // Estrela outline
                                    size: 20, // Tamanho da estrela
                                    color: Color(0xFF4A5568), // Cinza escuro
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Espaçamento entre estrela e número
                                  Text(
                                    '${repo['stargazers_count']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Color(
                                          0xFF4A5568), // Mesma cor da estrela
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Espaçamento entre número e bolinha
                                  Icon(
                                    Icons.circle,
                                    size: 5, // Tamanho pequeno para a bolinha
                                    color: Color(0xFF4A5568), // Cinza escuro
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Espaçamento entre bolinha e "Atualizado"
                                  Text(
                                    formatTimeAgo(
                                        DateTime.parse(repo['updated_at'])),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Color(0xFF4A5568), // Cinza escuro
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Colors.grey[300], // Cor cinza para a divisória
                          thickness: 1.0, // Espessura da divisória
                          height:
                              16.0, // Espaçamento acima e abaixo da divisória
                        );
                      },
                    ),
                  ),
                  if (_hasMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: _loadMore,
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Carregar Mais',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          );

          return isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(flex: 1, child: userInfoWidget),
                    Flexible(flex: 2, child: repoListWidget),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userInfoWidget,
                    repoListWidget,
                  ],
                );
        },
      ),
    );
  }
}
