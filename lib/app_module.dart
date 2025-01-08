import 'package:buscador_github/services/github_service.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'modules/home/home_module.dart';
import 'modules/profile/profile_module.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton((i) => GitHubService()), // Registra o GitHubService
      ];
  @override
  List<ModularRoute> get routes => [
        RedirectRoute('/', to: '/home'), // Redireciona '/' para '/home'
        ModuleRoute('/home', module: HomeModule()),
        ModuleRoute('/profile', module: ProfileModule()),
      ];
}
