import 'package:final4/ui/widget/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/post/GET_post.dart';
import '../../logic/post/Get_state.dart';

class PostListWidget extends StatelessWidget {
  const PostListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PostError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
        } else if (state is PostLoaded) {
          final posts = state.posts;
          return ListView.builder(
            shrinkWrap: true, // Add this line
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostWidget(post: posts[index]);
            },
          );
        }
        return const Center(child: Text('No posts yet', style: TextStyle(color: Colors.white)));
      },
    );
  }
}