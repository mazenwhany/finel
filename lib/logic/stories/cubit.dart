import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/Stories_data.dart';
import 'state.dart';

class StoryCubit extends Cubit<StoryState> {
  final SupabaseClient supabase;

  StoryCubit(this.supabase) : super(StoryInitial());

  /// Fetch all stories from the `stories` table
  Future<void> fetchStories() async {
    emit(StoryLoading());
    try {
      final response = await supabase
          .from('stories')
          .select('*')
          .order('created_at', ascending: false);

      final stories = response.map((data) => Story.fromJson(data)).toList();
      emit(StorySuccess(stories));
    } catch (e) {
      emit(StoryFailure('Failed to fetch stories: $e'));
    }
  }

  /// Upload an image to Supabase storage and return the URL
  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'stories/$fileName';

      final response = await supabase.storage.from('stories').upload(
        storagePath,
        image,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );


      return supabase.storage.from('stories').getPublicUrl(storagePath);
    } catch (e) {
      emit(StoryFailure('Image upload failed: $e'));
      return null;
    }
  }

  /// Post a new story
  Future<void> postStory({
    required File imageFile,
    String? avatarUrl,
    String? username,
  }) async {
    emit(StoryLoading());

    try {
      // Get the authenticated user ID (UUID)
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      // Upload image
      final imageUrl = await _uploadImage(imageFile);
      if (imageUrl == null) throw Exception('Failed to upload image');

      // Insert into database
      final response = await supabase.from('stories').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'avatar_url': avatarUrl,
        'username': username ?? 'Anonymous',
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      if (response.isEmpty) throw Exception("Failed to insert story");

      // Refresh stories
      await fetchStories();
    } catch (e) {
      emit(StoryFailure('Failed to post story: $e'));
    }
  }
}
