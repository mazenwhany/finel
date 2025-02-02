import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../../data/user_model.dart";
import "../../logic/GET_User_data/Stateofowener post.dart";
import "../../logic/GET_User_data/getownerpost_cubit.dart";
import "../../logic/follows/cubit.dart";
import "../../logic/follows/state.dart";
import "Chat_screen.dart";

final supabase = Supabase.instance.client;

class ProfilePage extends StatelessWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FollowCubit(supabase)
            ..checkFollowStatus(currentUser!.id, user.id),
        ),
        BlocProvider(
          create: (context) => PostsCubit()..fetchUserPosts(user.id),
        ),
      ],
      child: _ProfileContent(user: user),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel user;
  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          user.username,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(user: user),
            ProfileBio(user: user),
            ProfileButtons(user: user),
            const SizedBox(height: 16),
            PostsGrid(userId: user.id),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.purple, width: 2),
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                user.avatarUrl ??
                    "https://i2.wp.com/vdostavka.ru/wp-content/uploads/2019/05/no-avatar.png?ssl=1",
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BlocBuilder<FollowCubit, FollowState>(
                  builder: (context, state) {
                    int followersCount = user.followersCount;
                    if (state is FollowStatusChecked) {
                      followersCount += state.isFollowing ? 1 : 0;
                    }
                    return _buildStatColumn(followersCount.toString(), 'Followers');
                  },
                ),
                _buildStatColumn(user.followingCount.toString(), 'Following'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class ProfileBio extends StatelessWidget {
  final UserModel user;
  const ProfileBio({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (user.fullName != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                user.fullName!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          if (user.bio != null)
            Text(
              user.bio!,
              style: const TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

class ProfileButtons extends StatelessWidget {
  final UserModel user;
  const ProfileButtons({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<FollowCubit, FollowState>(
        builder: (context, state) {
          bool isFollowing = false;
          if (state is FollowStatusChecked) {
            isFollowing = state.isFollowing;
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final followCubit = context.read<FollowCubit>();

                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User not logged in!')),
                          );
                          return;
                        }

                        if (isFollowing) {
                          followCubit.unfollowUser(currentUser.id, user.id);
                        } else {
                          followCubit.followUser(
                            currentUser.id,
                            user.id,
                            currentUser.email ?? 'Unknown',
                            user.username,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing ? Colors.grey[700] : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isFollowing ? 'Unfollow' : 'Follow',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Share Profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isFollowing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  ChatScreen(
                            currentUserId: currentUser!.id,
                            chatPartnerId: user.id,
                            chatPartnerName: user.username,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Chat', style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}



class PostsGrid extends StatelessWidget {
  final String userId;
  const PostsGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, PostsState>(
      builder: (context, state) {
        if (state is PostsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PostsError) {
          return Center(
              child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)));
        } else if (state is PostsLoaded) {
          if (state.posts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No posts yet!', style: TextStyle(color: Colors.white)),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return Image.network(
                post.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error_outline, color: Colors.white),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}