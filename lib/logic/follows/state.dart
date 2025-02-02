import 'package:equatable/equatable.dart';

abstract class FollowState extends Equatable {
  @override
  List<Object> get props => [];
}

class FollowInitial extends FollowState {}

class FollowLoading extends FollowState {}

class FollowSuccess extends FollowState {}

class FollowFailure extends FollowState {
  final String error;
  FollowFailure(this.error);

  @override
  List<Object> get props => [error];
}

class FollowStatusChecked extends FollowState {
  final bool isFollowing;
  FollowStatusChecked(this.isFollowing);

  @override
  List<Object> get props => [isFollowing];
}
