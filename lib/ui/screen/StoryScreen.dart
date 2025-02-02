import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../logic/stories/cubit.dart';
import '../../logic/stories/state.dart';
import 'home_screen.dart';

class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Upload the story
  void _uploadStory() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first!")),
      );
      return;
    }

    final storyCubit = context.read<StoryCubit>();
    storyCubit.postStory(
      imageFile: _selectedImage!,
      avatarUrl: 'https://example.com/avatar.png', // Replace with actual avatar URL
      username: 'John Doe', // Replace with actual username
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<StoryCubit>().fetchStories(); // Fetch stories on screen load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      appBar: AppBar(
        title: const Text("Stories", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Image Picker and Upload Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_selectedImage != null)
                  Image.file(_selectedImage!, height: 200, width: 200, fit: BoxFit.cover),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Pick Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _uploadStory; // Call your upload function first
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: const Text("Upload Story"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Story List
          Expanded(
            child: BlocBuilder<StoryCubit, StoryState>(
              builder: (context, state) {
                if (state is StoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StorySuccess) {
                  return ListView.builder(
                    itemCount: state.stories.length,
                    itemBuilder: (context, index) {
                      final story = state.stories[index];
                      return ListTile(
                        leading: story.avatarUrl != null && story.avatarUrl!.isNotEmpty
                            ? CircleAvatar(backgroundImage: NetworkImage(story.avatarUrl!))
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(story.username ?? "Unknown", style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          story.createdAt.toLocal().toString(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Image.network(story.imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                      );
                    },
                  );
                } else if (state is StoryFailure) {
                  return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                }
                return const Center(child: Text("No stories yet", style: TextStyle(color: Colors.white)));
              },
            ),
          ),
        ],
      ),
    );
  }
}
