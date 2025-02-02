import 'package:bloc/bloc.dart';
import 'package:final4/logic/follows/state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class FollowCubit extends Cubit<FollowState> {
  final SupabaseClient supabase;

  FollowCubit(this.supabase) : super(FollowInitial());

  Future<void> followUser(String followerId, String followingId, String followerUsername, String followingUsername) async {
    emit(FollowLoading());
    try {
      await supabase.from('follows').insert({
        'follower_id': followerId,
        'following_id': followingId,
        'follower_username': followerUsername,
        'following_username': followingUsername,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update follower count
      await supabase.rpc('increment_followers_count', params: {'user_id': followingId});

      emit(FollowStatusChecked(true));
    } catch (e) {
      emit(FollowFailure(e.toString()));
    }
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    emit(FollowLoading());
    try {
      await supabase.from('follows').delete().match({
        'follower_id': followerId,
        'following_id': followingId,
      });

      // Update follower count
      await supabase.rpc('decrement_followers_count', params: {'user_id': followingId});

      emit(FollowStatusChecked(false));
    } catch (e) {
      emit(FollowFailure(e.toString()));
    }
  }

  Future<void> checkFollowStatus(String followerId, String followingId) async {
    try {
      final response = await supabase
          .from('follows')
          .select()
          .match({'follower_id': followerId, 'following_id': followingId});

      emit(FollowStatusChecked(response.isNotEmpty));
    } catch (e) {
      emit(FollowFailure(e.toString()));
    }
  }
}
