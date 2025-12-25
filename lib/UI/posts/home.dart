// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/UI/Auth/login_screen.dart';
// import 'package:flutter_application_1/UI/forget_password.dart';
// import 'package:flutter_application_1/UI/posts/camera.dart';
// import 'package:flutter_application_1/UI/posts/recordings.dart';
// import 'package:flutter_application_1/UI/posts/user_details.dart';
// import 'package:flutter_application_1/UI/posts/video_list.dart';
// import 'package:flutter_application_1/utils/utils.dart';

// class Home extends StatelessWidget {
//   const Home({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Colors.blueAccent,
//         hintColor: Colors.redAccent,
//         scaffoldBackgroundColor: Colors.grey[200],
//         textTheme: const TextTheme(
//           bodyLarge: TextStyle(color: Colors.black54),
//           bodyMedium: TextStyle(color: Colors.black45),
//           displayLarge: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent),
//           displayMedium: TextStyle(
//               fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black54),
//         ),
//         buttonTheme: ButtonThemeData(
//           buttonColor: Colors.blueAccent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         floatingActionButtonTheme: const FloatingActionButtonThemeData(
//           backgroundColor: Colors.redAccent, // Red for SOS button
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//         bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
//       ),
//       home: LandingPage(),
//     );
//   }
// }

// class LandingPage extends StatelessWidget {
//   final auth = FirebaseAuth.instance;

//   LandingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(
//               Icons.menu, // Hamburger menu icon
//               color: Colors.black,
//             ),
//             onPressed: () {
//               Scaffold.of(context).openDrawer(); // Open the drawer
//             },
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.blueAccent,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircleAvatar(
//                     radius: 40,
//                     backgroundImage:
//                         AssetImage('logo.jpeg'), // Replace with your image
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     FirebaseAuth.instance.currentUser?.email ??
//                         'No email available',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   const Text(
//                     'ID: 12345678',
//                     // Replace with your 8-digit ID
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 8,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const ListTile(
//               title: Text('Core Features',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.home),
//               title: const Text('Home'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.video_library),
//               title: const Text('Recordings'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           const RecordingsPage()), // Navigate to RecordingsPage
//                 );
//               },
//             ),
//             const ListTile(
//               title: Text('Security Settings',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.fingerprint),
//               title: const Text('Biometric Settings'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.face),
//               title: const Text('Face ID'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.security),
//               title: const Text('Two-Factor Authentication'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             const ListTile(
//               title: Text('Storage Management',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.storage),
//               title: const Text('User Details'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const UserDetailsPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.storage),
//               title: const Text('MetaData'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const VideoList()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.cloud),
//               title: const Text('Cloud Sync'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             const ListTile(
//               title: Text('Account',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.password),
//               title: const Text('Change Password'),
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const ForgetPassword()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: () {
//                 auth.signOut().then((value) {
//                   Utils().toastmessage('Logged out');
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const LoginScreen()));
//                 }).onError((error, stackTrace) {
//                   Utils().toastmessage('Error: ${error.toString()}');
//                 });
//               },
//             ),
//             const ListTile(
//               title: Text('Help & Support',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.help),
//               title: const Text('Tutorial/Help'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.support_agent),
//               title: const Text('Support'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             const ListTile(
//               title: Text('Legal & About',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.privacy_tip),
//               title: const Text('Privacy Policy'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.info),
//               title: const Text('About'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Title
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Welcome to GuardianEye',
//                 style: Theme.of(context)
//                     .textTheme
//                     .displayLarge
//                     ?.copyWith(color: Colors.blueAccent),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Description text
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Text(
//                 'GuardianEye ensures the utmost security, privacy, and integrity in every recording. Empowering you to capture sensitive moments with unbreachable protection and reliability.',
//                 style: Theme.of(context).textTheme.displayMedium,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 textStyle: const TextStyle(fontSize: 20),
//               ),
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => const Camera()));
//               },
//               child: const Text("Start Recording"),
//             ),
//             const SizedBox(height: 30),

//             // Status text
//             const Text(
//               "Status: Ready to Record", // Modify based on actual status
//               style: TextStyle(fontSize: 18, color: Colors.black),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 6.0,
//         color: Colors.white,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.photo_album), // Gallery icon
//               onPressed: () {
//                 // Handle gallery option
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.search),
//               onPressed: () {
//                 // Handle search option
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.settings),
//               onPressed: () {
//                 // Handle settings option
//               },
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Add SOS functionality
//         },
//         backgroundColor: Colors.redAccent,
//         child: const Icon(
//           Icons.warning, // SOS Icon
//           size: 40.0,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }




import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/sos_service.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:flutter_application_1/UI/Auth/login_screen.dart';
import 'package:flutter_application_1/UI/posts/camera.dart';
import 'package:flutter_application_1/UI/posts/recordings.dart';
import 'package:flutter_application_1/UI/posts/user_details.dart';
import 'package:flutter_application_1/UI/posts/video_list.dart';
import 'package:flutter_application_1/utils/utils.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        hintColor: Colors.redAccent,
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black54),
          bodyMedium: TextStyle(color: Colors.black45),
          displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent),
          displayMedium: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black54),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.redAccent,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.white),

      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    listenForSOS();
  }

  void listenForSOS() {
    FirebaseFirestore.instance
        .collection('sos_alerts')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        NotificationService.showLocalNotification(
          "SOS Alert from ${data['username'] ?? 'User'}",
          'Location: ${data['latitude']}, ${data['longitude']}',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueAccent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('logo.jpeg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? 'No email available',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'ID: 12345678',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
            const ListTile(title: Text('Core Features', style: TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Recordings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecordingsPage()),
                );
              },
            ),
            const ListTile(title: Text('Security Settings', style: TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Biometric Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.face),
              title: const Text('Face ID'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Two-Factor Authentication'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const ListTile(title: Text('Storage Management', style: TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('User Details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserDetailsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('MetaData'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideoList()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Cloud Sync'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const ListTile(title: Text('Account', style: TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                auth.signOut().then((value) {
                  Utils().toastmessage('Logged out');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                }).onError((error, stackTrace) {
                  Utils().toastmessage('Error: ${error.toString()}');
                });
              },
            ),
            const ListTile(title: Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Tutorial/Help'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const ListTile(title: Text('Legal & About', style: TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Welcome to GuardianEye',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'GuardianEye ensures the utmost security, privacy, and integrity in every recording. Empowering you to capture sensitive moments with unbreachable protection and reliability.',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Camera()));
              },
              child: const Text("Start Recording"),
            ),
            const SizedBox(height: 30),
            const Text(
              "Status: Ready to Record",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.photo_album),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await SOSService.sendSOSAlert();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("SOS Alert Sent!")),
          );
        },
        child: const Icon(
          Icons.warning,
          size: 40.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
