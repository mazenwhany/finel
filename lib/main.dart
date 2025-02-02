import 'package:final4/logic/auth/cubit.dart';
import 'package:final4/logic/seacrh/Cubit.dart';

import 'package:final4/ui/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:supabase_flutter/supabase_flutter.dart';

import 'logic/GET_User_data/Cubit.dart';
import 'logic/follows/cubit.dart';
import 'logic/messages/cubit.dart';
import 'logic/post/GET_post.dart';
import 'logic/post/cubit.dart';
import 'logic/stories/cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fbbldyqsqlwsovtlrsau.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZiYmxkeXFzcWx3c292dGxyc2F1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgwNDg2MzMsImV4cCI6MjA1MzYyNDYzM30.zNMu9w-8Ne2-oe9_fB4N4p77pabJS2QtUCTiIVQ8R-M',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SupabaseClient>(
          create: (_) => Supabase.instance.client,
        ),
        BlocProvider(
          create: (context) => AuthCubit(
            supabase: context.read<SupabaseClient>(),
          ),
        ),
        BlocProvider(
          create: (context) => SearchCubit(
            supabase: context.read<SupabaseClient>(),
          ),
        ),
        BlocProvider(
          create: (context) => PostUploadCubit(),
        ),
        BlocProvider(
          create: (context) => PostCubit()..getPosts(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            supabase: context.read<SupabaseClient>(), // Access via Provider
          )..loadUserProfile(),
        ),
        BlocProvider(
          create: (context) => FollowCubit(Supabase.instance.client),
          ),
        BlocProvider(
          create: (context) => MessageCubit(Supabase.instance.client),
        ),
        BlocProvider(
          create: (context) => StoryCubit(Supabase.instance.client)),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
      ),
    );
  }
}