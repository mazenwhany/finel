import 'package:flutter/material.dart';
import '../../data/post_model.dart';
import '../screen/UserProfileScreen.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: screenWidth * 0.05,
            backgroundImage: post.avatar_url != null
                ? NetworkImage(post.avatar_url!)
                : null,
            child: post.avatar_url == null
                ? Text(
              post.username[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )
                : null,
          ),
          title: InkWell(
            onTap: () {

            },
            child: Text(
              post.username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(
            post.createdAt.toLocal().toString().split('.')[0],
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.more_horiz, color: Colors.white),
        ),

        // Post Image
        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            post.photoUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error, color: Colors.red),
              );
            },
          ),
        ),

        // Post Actions
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.comment_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined, color: Colors.white),
                onPressed: () {},
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Caption
        if (post.caption != null && post.caption!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            child: Text(
              post.caption!,
              style: const TextStyle(color: Colors.white),
            ),
          ),

        const SizedBox(height: 8),
      ],
    );
  }
}

