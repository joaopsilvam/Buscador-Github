import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

// Events
abstract class HomeEvent {}

class SearchChangedEvent extends HomeEvent {
  final String query;
  SearchChangedEvent(this.query);
}

class SaveSearchEvent extends HomeEvent {
  final String username;
  SaveSearchEvent(this.username);
}

// States
class HomeState {
  final List<String> suggestions;
  HomeState({this.suggestions = const []});
}

// Bloc
class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is SearchChangedEvent) {
      yield HomeState(
        suggestions: state.suggestions
            .where((s) => s.toLowerCase().contains(event.query.toLowerCase()))
            .toList(),
      );
    } else if (event is SaveSearchEvent) {
      final updated = List<String>.from(state.suggestions);
      if (!updated.contains(event.username)) {
        updated.add(event.username);
        if (updated.length > 5) updated.removeAt(0);
      }
      yield HomeState(suggestions: updated);
    }
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    return HomeState(suggestions: List<String>.from(json['suggestions']));
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    return {'suggestions': state.suggestions};
  }
}
