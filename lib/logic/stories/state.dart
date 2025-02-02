import 'package:equatable/equatable.dart';

import '../../data/Stories_data.dart';


abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StorySuccess extends StoryState {
  final List<Story> stories;

  const StorySuccess(this.stories);

  @override
  List<Object?> get props => [stories];
}

class StoryFailure extends StoryState {
  final String error;

  const StoryFailure(this.error);

  @override
  List<Object?> get props => [error];
}
