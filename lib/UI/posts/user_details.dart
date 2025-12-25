import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserDetailsPage extends StatefulWidget {
  final String? initialEmail;
  const UserDetailsPage({super.key, this.initialEmail});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController emailController = TextEditingController();
  Map<String, dynamic>? userDetails;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      emailController.text = widget.initialEmail!;
      searchUserByEmail();
    }
  }

  Future<void> searchUserByEmail() async {
    final email = emailController.text.trim().toLowerCase();
    if (email.isEmpty) return;

    setState(() {
      loading = true;
      userDetails = null;
    });

    try {
      DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users');
      final snapshot = await databaseRef.once();
      final users = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (users != null) {
        for (var entry in users.entries) {
          final user = Map<String, dynamic>.from(entry.value);
          final userEmail = (user['email'] ?? '').toString().toLowerCase();

          if (userEmail == email) {
            setState(() {
              userDetails = {
                'first_name': user['first_name'],
                'last_name': user['last_name'],
                'username': user['username'],
                'phone': user['phone'],
                'email': user['email'],
              };
              loading = false;
            });
            return;
          }
        }
      }

      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user found with that email.')),
      );
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Enter Email',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchUserByEmail,
                ),
              ),
              onSubmitted: (_) => searchUserByEmail(),
            ),
            const SizedBox(height: 20),
            if (loading)
              const CircularProgressIndicator()
            else if (userDetails != null)
              UserDetailsDisplay(userDetails: userDetails!)
            else
              const Text('No user details to display.'),
          ],
        ),
      ),
    );
  }
}

class UserDetailsDisplay extends StatelessWidget {
  final Map<String, dynamic> userDetails;

  const UserDetailsDisplay({super.key, required this.userDetails});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: ${userDetails['first_name'] ?? 'N/A'}'),
            Text('Last Name: ${userDetails['last_name'] ?? 'N/A'}'),
            Text('Username: ${userDetails['username'] ?? 'N/A'}'),
            Text('Phone: ${userDetails['phone'] ?? 'N/A'}'),
            Text('Email: ${userDetails['email'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
