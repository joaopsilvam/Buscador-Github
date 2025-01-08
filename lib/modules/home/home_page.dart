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
                Modular.to.pushNamed('/profile/$username');
                Modular.get<HomeBloc>().add(SaveSearchEvent(username));
              }
            },
          ),
        ),
        onChanged: (value) {
          Modular.get<HomeBloc>().add(SearchChangedEvent(value));
        },
      ),
      SizedBox(height: 10),
      // Lista de sugestões
      Expanded(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.suggestions.isEmpty) {
              return Center(
                child: Text(
                  'Nenhuma sugestão disponível',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
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
            );
          },
        ),
      ),
    ],
  ),
),


    );
  }
}
