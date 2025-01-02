import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'listrecord_event.dart';
part 'listrecord_state.dart';

class ListrecordBloc extends Bloc<ListrecordEvent, ListrecordState> {
  ListrecordBloc() : super(ListrecordInitial()) {
    on<ListrecordEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
