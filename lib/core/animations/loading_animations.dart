import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Smooth pulsing loading indicator
class PulsingLoader extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const PulsingLoader({
    super.key,
    this.color = Colors.blue,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<PulsingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha:_animation.value),
          ),
        );
      },
    );
  }
}

/// Three dots loading animation
class DotsLoader extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const DotsLoader({
    super.key,
    this.color = Colors.blue,
    this.size = 8.0,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = (animationValue <= 0.5)
                ? (animationValue * 2)
                : ((1 - animationValue) * 2);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
              child: Transform.scale(
                scale: 0.5 + (scale * 0.5),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Skeleton loader for content placeholders
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ],
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Enhanced loading state widget
class EnhancedLoadingState extends StatelessWidget {
  final String message;
  final Color? color;
  final bool showPulse;

  const EnhancedLoadingState({
    super.key,
    this.message = 'Loading...',
    this.color,
    this.showPulse = true,
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppTheme.primaryDeepBlue;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showPulse)
            PulsingLoader(
              color: loadingColor,
              size: 60,
            )
          else
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
              strokeWidth: 3,
            ),
          
          const SizedBox(height: 24),
          
          DotsLoader(
            color: loadingColor,
            size: 6,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// List item skeleton placeholder
class ListItemSkeleton extends StatelessWidget {
  final bool hasAvatar;
  final bool hasSubtitle;

  const ListItemSkeleton({
    super.key,
    this.hasAvatar = true,
    this.hasSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (hasAvatar) ...[
            const SkeletonLoader(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            const SizedBox(width: 16),
          ],
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                ),
                
                if (hasSubtitle) ...[
                  const SizedBox(height: 8),
                  SkeletonLoader(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 14,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card skeleton placeholder
class CardSkeleton extends StatelessWidget {
  final double? height;

  const CardSkeleton({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          
          const SizedBox(height: 16),
          
          const SkeletonLoader(
            width: double.infinity,
            height: 20,
          ),
          
          const SizedBox(height: 8),
          
          SkeletonLoader(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 16,
          ),
          
          const SizedBox(height: 12),
          
          const Row(
            children: [
              SkeletonLoader(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              SizedBox(width: 8),
              SkeletonLoader(
                width: 60,
                height: 16,
              ),
              Spacer(),
              SkeletonLoader(
                width: 80,
                height: 32,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 