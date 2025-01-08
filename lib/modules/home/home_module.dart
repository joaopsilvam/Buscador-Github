import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_bloc.dart';
import 'home_page.dart';

class HomeModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton((i) => HomeBloc()), // Vincula o Bloc ao módulo
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (_, __) => BlocProvider(
              create: (_) => Modular.get<HomeBloc>(), // Usa o Bloc para gerenciar estados
              child: HomePage(),
            )),
      ];
}
