import 'package:flutter/material.dart';
import '../../data/Stories_data.dart';

class StoryShowScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryShowScreen({
    Key? key,
    required this.stories,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _StoryShowScreenState createState() => _StoryShowScreenState();
}

class _StoryShowScreenState extends State<StoryShowScreen> {
  late PageController _pageController;
  late int _currentIndex;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _startProgress();
  }

  void _startProgress() {
    _progress = 0.0;
    Future.doWhile(() {
      if (_progress >= 1.0) {
        _nextStory();
        return false;
      }
      return Future.delayed(const Duration(milliseconds: 50), () {
        setState(() => _progress += 0.01);
        return true;
      });
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _startProgress();
                });
              },
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                return Image.network(
                  story.imageUrl,
                  fit: BoxFit.cover,
                );
              },
            ),
            _buildTopBar(),
            _buildProgressIndicator(),
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final story = widget.stories[_currentIndex];
    return Positioned(
      top: 40,
      left: 10,
      right: 10,
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(story.avatarUrl!),
          ),
          const SizedBox(width: 10),
          Text(
            story.username ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      top: 30,
      left: 0,
      right: 0,
      child: Row(
        children: widget.stories.map((story) {
          final index = widget.stories.indexOf(story);
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index < _currentIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: index == _currentIndex
                  ? LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.transparent,
                valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}