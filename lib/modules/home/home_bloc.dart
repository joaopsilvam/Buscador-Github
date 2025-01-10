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
    on<SaveSearchEvent>(_handleSaveSearchEvent);
  }

  void _handleSaveSearchEvent(SaveSearchEvent event, Emitter<HomeState> emit) {
  final updatedSuggestions = List<String>.from(state.suggestions);

  updatedSuggestions.remove(event.username);
  updatedSuggestions.insert(0, event.username);

  if (updatedSuggestions.length > 5) {
    updatedSuggestions.removeRange(5, updatedSuggestions.length);
  }

  emit(state.copyWith(suggestions: updatedSuggestions));
  print("Sugestões atualizadas: ${updatedSuggestions}"); // Log para depuração
}


  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    try {
      return HomeState.fromJson(json);
    } catch (e) {
      print("Erro ao carregar estado do JSON: $e");
      return HomeState();
    }
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    try {
      return state.toJson();
    } catch (e) {
      print("Erro ao salvar estado no JSON: $e");
      return null;
    }
  }
}
