import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'home_bloc.dart';

class HomePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Profile Finder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de busca
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar Usuário do GitHub',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    final username = _controller.text.trim();
                    if (username.isNotEmpty) {
                      // Salva a pesquisa no estado
                      Modular.get<HomeBloc>().add(SaveSearchEvent(username));

                      // Navega para a página de perfil
                      Modular.to.pushNamed('/profile/$username');
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            // Exibição de sugestões
            BlocBuilder<HomeBloc, HomeState>(
  builder: (context, state) {
    print("BlocBuilder reconstruído com sugestões: ${state.suggestions}");

    if (state.suggestions.isEmpty) {
      return Text(
        'Sem sugestões no momento',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sugestões:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: state.suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = state.suggestions[index];
            return ListTile(
              title: Text(suggestion),
              onTap: () {
                _controller.text = suggestion;
                Modular.to.pushNamed('/profile/$suggestion');
              },
            );
          },
        ),
      ],
    );
  },
),

          ],
        ),
      ),
    );
  }
}
