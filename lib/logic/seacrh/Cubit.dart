import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/user_model.dart';
import 'State.dart';

class SearchCubit extends Cubit<SearchState> {
  final SupabaseClient supabase;

  SearchCubit({required this.supabase}) : super(SearchInitial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(const SearchSuccess([]));
      return;
    }

    try {
      emit(SearchLoading());

      final currentUserId = supabase.auth.currentUser?.id;

      final response = await supabase
          .from('profiles')
          .select()
          .ilike('username', '%$query%')  // Changed from 'name' to 'username'
          .not('id', 'eq', currentUserId)
          .order('username')  // Changed from 'name' to 'username'
          .limit(20);

      final users = (response as List).map((user) => UserModel.fromJson(user)).toList();
      emit(SearchSuccess(users));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}