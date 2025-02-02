import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:final4/logic/post/state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PostUploadCubit extends Cubit<PostUploadState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  PostUploadCubit() : super(PostUploadInitial());

  Future<void> uploadPost(XFile imageFile, {String? caption}) async {
    emit(PostUploadLoading());
    try {

      final File file = File(imageFile.path);

      // Upload image to Supabase Storage
      final String filePath = 'posts/${DateTime.now().millisecondsSinceEpoch}_${_supabase.auth.currentUser!.id}';

      await _supabase.storage
          .from('posts')
          .upload(filePath, file); // Pass the File object directly

      // Get public URL of the uploaded image
      final String imageUrl = _supabase.storage
          .from('posts')
          .getPublicUrl(filePath);

      // Insert post data into posts table
      await _supabase.from('posts').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'photo_url': imageUrl,
        'caption': caption,
      });

      emit(PostUploadSuccess());
    } on PostgrestException catch (e) {
      emit(PostUploadError('Database error: ${e.message}'));
    } on StorageException catch (e) {
      emit(PostUploadError('Storage error: ${e.message}'));
    } catch (e) {
      emit(PostUploadError('Failed to upload post: $e'));
    }
  }

  Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      emit(PostUploadError('Failed to pick image: $e'));
      return null;
    }
  }
}

