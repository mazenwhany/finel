import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/stories/cubit.dart';
import '../../logic/stories/state.dart';
import '../screen/StoryScreen.dart';

class StoryListWidget extends StatelessWidget {
  const StoryListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final storyCubit = context.read<StoryCubit>();

    return BlocBuilder<StoryCubit, StoryState>(
      builder: (context, state) {
        if (state is StoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StoryFailure) {
          return Center(
            child: Text(state.error, style: const TextStyle(color: Colors.red)),
          );
        } else if (state is StorySuccess) {
          final stories = state.stories;

          if (stories.isEmpty) {
            return const Center(
              child: Text("No stories available", style: TextStyle(color: Colors.white)),
            );
          }

          final userStory = stories.firstWhere(
                (story) => story.userId == storyCubit.supabase.auth.currentUser?.id,
            orElse: () => stories.first, // Fallback to first story if no user story
          );

          return Column(
            children: [
              // Instagram Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.01,
                ),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Instagram',
                      style: GoogleFonts.dancingScript(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.message_sharp, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_box_rounded, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stories List
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = index == 0 ? userStory : stories[index];

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: screenWidth * 0.15,
                                height: screenWidth * 0.15,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Colors.purple, Colors.orange],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width: 2),
                                      image: DecorationImage(
                                        image: NetworkImage(story.avatarUrl ??
                                            'https://via.placeholder.com/150'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Show the "+" button only for the logged-in user
                              if (index == 0)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => StoryScreen()),
                                      );
                                    },
                                    child: Container(
                                      width: screenWidth * 0.05,
                                      height: screenWidth * 0.05,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            index == 0 ? 'Your Story' : story.username ?? "Story ${index + 1}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const Center(child: Text("Loading...", style: TextStyle(color: Colors.white)));
      },
    );
  }
}
