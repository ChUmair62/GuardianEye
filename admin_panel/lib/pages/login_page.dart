import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final email = TextEditingController();
  final password = TextEditingController();
  String error = '';

  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (mounted) context.go('/splash');

    } catch (e) {
      setState(() => error = cleanFirebaseError(e.toString()));
    }
  }

  String cleanFirebaseError(String raw) {
    if (raw.contains("invalid-credential")) {
      return "Invalid email or password.";
    }
    if (raw.contains("user-not-found")) {
      return "No admin found with this email.";
    }
    if (raw.contains("wrong-password")) {
      return "Incorrect password.";
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌌 Animated Background
          const _AnimatedBackground(),

          // 🧊 Glass Login Card
          Center(
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(color: Colors.white12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 30,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "GuardianEye",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Admin Panel",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 32),

                    _GlowField(
                      controller: email,
                      label: "Email",
                      icon: Icons.email,
                    ),

                    const SizedBox(height: 18),

                    _GlowField(
                      controller: password,
                      label: "Password",
                      icon: Icons.lock,
                      obscure: true,
                    ),

                    const SizedBox(height: 28),

                    _AnimatedLoginButton(onPressed: login),

                    if (error.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌌 BACKGROUND GRADIENT
class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F0C29),
            Color(0xFF302B63),
            Color(0xFF24243E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

/// ✨ INPUT WITH GLOW
class _GlowField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  const _GlowField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  @override
  State<_GlowField> createState() => _GlowFieldState();
}

class _GlowFieldState extends State<_GlowField> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.6),
                    blurRadius: 16,
                  )
                ]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            labelText: widget.label,
            labelStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🚀 LOGIN BUTTON
class _AnimatedLoginButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedLoginButton({required this.onPressed});

  @override
  State<_AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<_AnimatedLoginButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? 1.04 : 1,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: Colors.deepPurpleAccent,
            elevation: hover ? 14 : 6,
          ),
          child: const Text(
            "LOGIN",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
