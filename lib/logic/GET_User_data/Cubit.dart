import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './State.dart';
import '../../data/user_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final SupabaseClient supabase;

  ProfileCubit({required this.supabase}) : super(ProfileInitial());

  Future<void> loadUserProfile() async {
    try {
      emit(ProfileLoading());

      final user = supabase.auth.currentUser;
      if (user == null) {
        emit(const ProfileError('No user logged in'));
        return;
      }

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final userModel = UserModel.fromJson(response as Map<String, dynamic>);
      emit(ProfileLoaded(userModel));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}

