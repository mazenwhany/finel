import 'package:equatable/equatable.dart';
import 'package:final4/data/user_model.dart';


abstract class authState extends Equatable {
  const authState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends authState {}

class AuthLoading extends authState {}

class AuthSuccess extends authState {
  final UserModel user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends authState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}