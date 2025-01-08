import 'package:hydrated_bloc/hydrated_bloc.dart';

// Estado do HomeBloc
class HomeState {
  final List<String> suggestions;

  HomeState({this.suggestions = const []});

  HomeState copyWith({List<String>? suggestions}) {
    return HomeState(
      suggestions: suggestions ?? this.suggestions,
    );
  }

  Map<String, dynamic> toJson() => {'suggestions': suggestions};

  factory HomeState.fromJson(Map<String, dynamic> json) {
    return HomeState(
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

// Eventos do HomeBloc
abstract class HomeEvent {}

class SaveSearchEvent extends HomeEvent {
  final String username;
  SaveSearchEvent(this.username);
}

// Implementação do HomeBloc
class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState()) {
    // Registra o handler para SaveSearchEvent
    on<SaveSearchEvent>((event, emit) {
      final updatedSuggestions = List<String>.from(state.suggestions);

      // Adiciona o novo nome, evitando duplicatas
      if (!updatedSuggestions.contains(event.username)) {
        updatedSuggestions.add(event.username);

        // Mantém apenas as últimas 5 sugestões
        if (updatedSuggestions.length > 5) updatedSuggestions.removeAt(0);
      }

      emit(state.copyWith(suggestions: updatedSuggestions));

      // Log para depuração
      print("Sugestões atualizadas: ${updatedSuggestions}");
    });
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) => HomeState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(HomeState state) => state.toJson();
}
