import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideBar extends StatelessWidget {
  final Widget child;

  const SideBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 240,
          height: double.infinity,
          color: const Color(0xFF0D0D0D),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "GuardianEye Admin",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              _menuItem(context, Icons.dashboard, "Dashboard", "/dashboard"),
              const SizedBox(height: 20),
              _menuItem(context, Icons.people, "Officers", "/officers"),
              const SizedBox(height: 20),
              _menuItem(context, Icons.person_search, "Suspects", "/suspects"),
              const SizedBox(height: 20),
              _menuItem(context, Icons.video_camera_back, "Interviews", "/interviews"),

              const Spacer(),

              // Logout
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go('/login'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text("Logout", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // MAIN CONTENT
        Expanded(child: child),
      ],
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, String route) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
