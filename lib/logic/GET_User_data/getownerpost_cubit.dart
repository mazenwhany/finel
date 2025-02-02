import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/post_model.dart';
import 'Stateofowener post.dart';

class PostsCubit extends Cubit<PostsState> {
  PostsCubit() : super(PostsInitial());

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> fetchUserPosts(String userId) async {
    emit(PostsLoading());
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final posts = (response as List)
          .map((json) => Post.fromJson(json))
          .toList();

      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }
}