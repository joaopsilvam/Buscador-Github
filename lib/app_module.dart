import 'package:flutter_modular/flutter_modular.dart';
import 'modules/home/home_module.dart';
import 'modules/profile/profile_module.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => []; // Vincula dependências globais, se necessário

  @override
  List<ModularRoute> get routes => [
        RedirectRoute('/', to: '/home'), // Redireciona '/' para '/home'
        ModuleRoute('/home', module: HomeModule()),
        ModuleRoute('/profile', module: ProfileModule()),
      ];
}
