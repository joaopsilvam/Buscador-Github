import 'package:buscador_github/modules/home/home_bloc.dart';
import 'package:buscador_github/services/github_service.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'modules/home/home_module.dart';
import 'modules/profile/profile_module.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton((i) => GitHubService()),
        Bind.singleton((i) => HomeBloc()),
      ];
  @override
  List<ModularRoute> get routes => [
        RedirectRoute('/', to: '/home'),
        ModuleRoute('/home', module: HomeModule()),
        ModuleRoute('/profile', module: ProfileModule()),
      ];
}
