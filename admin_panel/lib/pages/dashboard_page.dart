import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/stat_card.dart';
import '../widgets/topbar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SideBar(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(title: "Dashboard"),
              const SizedBox(height: 40),

              Row(
                children: const [
                  StatCard(title: "Total Officers", value: "12"),
                  SizedBox(width: 24),
                  StatCard(title: "Total Cases", value: "47"),
                  SizedBox(width: 24),
                  StatCard(title: "Total Interviews", value: "15"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
