import 'package:buscador_github/services/github_service.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'profile_page.dart';

class ProfileModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton((i) => GitHubService()), // Registra o GitHubService
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/:username', child: (_, args) => ProfilePage(username: args.params['username'])),
      ];
}
