import 'dart:io';
import 'package:final4/logic/auth/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/user_model.dart';

class AuthCubit extends Cubit<authState> {

  final SupabaseClient supabase;
  AuthCubit({required this.supabase}) : super(AuthInitial());

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    String? fullName,
    File? avatar,
    String? bio,
  }) async {
    try {
      emit(AuthLoading());


      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        emit(const AuthError('Signup failed'));
        return;
      }


      String? avatarUrl;
      if (avatar != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('user_photos').upload(
          fileName,
          avatar,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        avatarUrl = supabase.storage.from('user_photos').getPublicUrl(fileName);
      }


      final userData = {
        'id': authResponse.user!.id,
        'username': username,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'bio': bio,
      };

      final response = await supabase
          .from('profiles')
          .insert(userData)
          .select()
          .single();

      // 4. Create UserModel with complete data
      final user = UserModel.fromJson(response);
      emit(AuthSuccess(user));

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        emit(const AuthError('Login failed'));
        return;
      }

      // Get profile from profiles table
      final userData = await supabase
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      final user = UserModel.fromJson(userData);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}