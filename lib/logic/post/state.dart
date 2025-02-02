import 'package:equatable/equatable.dart';
import '../../data/post_model.dart';


abstract class PostUploadState extends Equatable {
  const PostUploadState();

  @override
  List<Object> get props => [];
}

class PostUploadInitial extends PostUploadState {}

class PostUploadLoading extends PostUploadState {}

class PostUploadSuccess extends PostUploadState {}

class PostUploadError extends PostUploadState {
  final String message;

  const PostUploadError(this.message);

  @override
  List<Object> get props => [message];
}