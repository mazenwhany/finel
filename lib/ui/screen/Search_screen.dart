import 'package:final4/ui/screen/UserProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/user_model.dart';
import '../../logic/seacrh/Cubit.dart';
import '../../logic/seacrh/State.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<SearchCubit>().searchUsers(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users by username', // Updated hint
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchCubit>().searchUsers(''); // Trigger empty search
                  },
                ),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchSuccess) {
                  return _buildSearchResults(state.users);
                } else if (state is SearchError) {
                  return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)));
                } else {
                  return const Center(child: Text('Start searching for users', style: TextStyle(color: Colors.white)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found', style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : const AssetImage('assets/default_avatar.png') as ImageProvider,
            child: user.avatarUrl == null
                ? Text(user.username[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                : null,
          ),
          title: Text(user.username, style: const TextStyle(color: Colors.white)),
          subtitle: Text(user.fullName ?? '', style: TextStyle(color: Colors.grey[400])),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProfilePage(user: user),
            ));
          },
        );
      },
    );
  }
}