import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/stat_card.dart';
import '../widgets/topbar.dart';
import '../widgets/animated_entry.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SideBar(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              const AnimatedEntry(
                delay: 0,
                child: TopBar(title: "Dashboard"),
              ),

              const SizedBox(height: 40),

              // Stat Cards (Staggered)
              Row(
                children: const [
                  AnimatedEntry(
                    delay: 100,
                    child: StatCard(
                      title: "Total Officers",
                      value: "12",
                    ),
                  ),
                  SizedBox(width: 24),
                  AnimatedEntry(
                    delay: 200,
                    child: StatCard(
                      title: "Total Cases",
                      value: "47",
                    ),
                  ),
                  SizedBox(width: 24),
                  AnimatedEntry(
                    delay: 300,
                    child: StatCard(
                      title: "Total Interviews",
                      value: "15",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
