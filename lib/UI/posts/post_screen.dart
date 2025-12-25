import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/Auth/login_screen.dart';
import 'package:flutter_application_1/UI/posts/home.dart';

import 'package:flutter_application_1/utils/utils.dart';

class PostScreen extends StatefulWidget {
  // final String userEmail;
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Screen'),
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Utils().toastmessage('Logged out');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()));
              }).onError((error, stackTrace) {
                Utils().toastmessage('Error: ${error.toString()}');
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Home()));
        },
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
      ),
    );
  }
}
