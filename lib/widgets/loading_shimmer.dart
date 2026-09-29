import 'package:flutter/material.dart';

class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({super.key});

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    double radius = 8,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF22222C) : const Color(0xFFE5E7EB);
    final highlight = isDark ? const Color(0xFF2F2F3D) : const Color(0xFFF3F4F6);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlight, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_animation.value * 3.14159),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2A2A35)
                  : const Color(0xFFE5E7EB),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(height: 200, width: double.infinity, radius: 0),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(height: 12, width: 100, radius: 6),
                    const SizedBox(height: 12),
                    _shimmerBox(height: 16, width: double.infinity),
                    const SizedBox(height: 8),
                    _shimmerBox(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                    const SizedBox(height: 12),
                    _shimmerBox(height: 14, width: double.infinity, radius: 7),
                    const SizedBox(height: 6),
                    _shimmerBox(
                      height: 14,
                      width: MediaQuery.of(context).size.width * 0.5,
                      radius: 7,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}