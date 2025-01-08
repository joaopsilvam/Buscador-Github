import 'package:flutter_modular/flutter_modular.dart';
import 'modules/home/home_module.dart';
import 'modules/profile/profile_module.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        ModuleRoute('/home', module: HomeModule()),
        ModuleRoute('/profile', module: ProfileModule()),
      ];
}
