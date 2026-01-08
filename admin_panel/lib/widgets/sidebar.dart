import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_background.dart';

class SideBar extends StatelessWidget {
  final Widget child;

  const SideBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return AppBackground(
      child: Row(
        children: [
          // ================= SIDEBAR =================
          Container(
            width: 240,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D0D),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(4, 0),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "GuardianEye Admin",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                _AnimatedMenuItem(
                  icon: Icons.dashboard,
                  label: "Dashboard",
                  route: "/dashboard",
                  active: currentRoute == "/dashboard",
                ),
                const SizedBox(height: 12),

                _AnimatedMenuItem(
                  icon: Icons.people,
                  label: "Officers",
                  route: "/officers",
                  active: currentRoute == "/officers",
                ),
                const SizedBox(height: 12),

                _AnimatedMenuItem(
                  icon: Icons.person_search,
                  label: "Suspects",
                  route: "/suspects",
                  active: currentRoute == "/suspects",
                ),
                const SizedBox(height: 12),

                _AnimatedMenuItem(
                  icon: Icons.video_camera_back,
                  label: "Interviews",
                  route: "/interviews",
                  active: currentRoute == "/interviews",
                ),

                const Spacer(),

                _LogoutButton(),
              ],
            ),
          ),

          // ================= MAIN CONTENT =================
          Expanded(child: child),
        ],
      ),
    );
  }
}

// =====================================================
// Animated Menu Item (UI ONLY)
// =====================================================

class _AnimatedMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool active;

  const _AnimatedMenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.active,
  });

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.active
                ? Colors.deepPurple.withOpacity(0.18)
                : hover
                    ? Colors.white.withOpacity(0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.active
                ? const Border(
                    left: BorderSide(
                      color: Colors.deepPurple,
                      width: 4,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color:
                    widget.active ? Colors.deepPurple : Colors.white70,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      widget.active ? FontWeight.w600 : FontWeight.normal,
                  color:
                      widget.active ? Colors.deepPurple : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// Logout Button (UI ONLY)
// =====================================================

class _LogoutButton extends StatefulWidget {
  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                hover ? Colors.deepPurpleAccent : Colors.deepPurple,
            borderRadius: BorderRadius.circular(14),
            boxShadow: hover
                ? [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.6),
                      blurRadius: 18,
                    )
                  ]
                : [],
          ),
          child: const Center(
            child: Text(
              "Logout",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
