import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool hover = false;

  double _parseValue() {
    return double.tryParse(widget.value.replaceAll(',', '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final targetValue = _parseValue();

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? 1.03 : 1,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: 220,
          height: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(18),
            boxShadow: hover
                ? [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
            border: Border.all(
              color: hover
                  ? Colors.deepPurple.withOpacity(0.6)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),

              const Spacer(),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: targetValue),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
