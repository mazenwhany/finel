import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/post_model.dart';
import 'Get_state.dart';

class PostCubit extends Cubit<PostState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  PostCubit() : super(PostInitial());

  Future<void> getPosts() async {
    emit(PostLoading());
    try {
      final List<dynamic> response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      final posts = response.map((json) => Post.fromJson(json)).toList();
      emit(PostLoaded(posts));

    } on PostgrestException catch (e) {
      emit(PostError('Database error: ${e.message}'));
    } catch (e) {
      emit(PostError('Failed to fetch posts: ${e.toString()}'));
    }
  }

  late final StreamSubscription<List<Map<String, dynamic>>> _postsSubscription;

  void subscribeToPosts() {
    _postsSubscription = _supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
      final posts = data.map((json) => Post.fromJson(json)).toList();
      emit(PostLoaded(posts));
    });
  }

  @override
  Future<void> close() {
    _postsSubscription.cancel();
    return super.close();
  }
}
