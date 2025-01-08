import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String username;

  ProfilePage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de $username'),
      ),
      body: Center(
        child: Text('Dados do usuário $username'),
      ),
    );
  }
}
