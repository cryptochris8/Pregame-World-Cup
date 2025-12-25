import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swipe gesture detector with customizable actions and animations
class SwipeableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final double swipeThreshold;
  final Duration animationDuration;
  final bool enableHaptics;
  final Color? leftActionColor;
  final Color? rightActionColor;
  final IconData? leftActionIcon;
  final IconData? rightActionIcon;
  final String? leftActionLabel;
  final String? rightActionLabel;

  const SwipeableWidget({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.swipeThreshold = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableHaptics = true,
    this.leftActionColor,
    this.rightActionColor,
    this.leftActionIcon,
    this.rightActionIcon,
    this.leftActionLabel,
    this.rightActionLabel,
  });

  @override
  State<SwipeableWidget> createState() => _SwipeableWidgetState();
}

class _SwipeableWidgetState extends State<SwipeableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _controller.stop();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });

    // Provide haptic feedback at certain thresholds
    if (widget.enableHaptics) {
      final distance = _dragOffset.distance;
      if (distance > widget.swipeThreshold * 0.5 && distance < widget.swipeThreshold * 0.6) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    // Check if swipe threshold is met or velocity is high enough
    final isSwipeLeft = dx < -widget.swipeThreshold || velocity.dx < -500;
    final isSwipeRight = dx > widget.swipeThreshold || velocity.dx > 500;
    final isSwipeUp = dy < -widget.swipeThreshold || velocity.dy < -500;
    final isSwipeDown = dy > widget.swipeThreshold || velocity.dy > 500;

    if (isSwipeLeft && widget.onSwipeLeft != null) {
      _executeSwipe(widget.onSwipeLeft!, const Offset(-1.0, 0.0));
    } else if (isSwipeRight && widget.onSwipeRight != null) {
      _executeSwipe(widget.onSwipeRight!, const Offset(1.0, 0.0));
    } else if (isSwipeUp && widget.onSwipeUp != null) {
      _executeSwipe(widget.onSwipeUp!, const Offset(0.0, -1.0));
    } else if (isSwipeDown && widget.onSwipeDown != null) {
      _executeSwipe(widget.onSwipeDown!, const Offset(0.0, 1.0));
    } else {
      _resetPosition();
    }

    setState(() {
      _isDragging = false;
    });
  }

  void _executeSwipe(VoidCallback action, Offset direction) {
    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }

    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: direction * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward().then((_) {
      action();
      _resetPosition();
    });
  }

  void _resetPosition() {
    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.reset();
    _controller.forward().then((_) {
      setState(() {
        _dragOffset = Offset.zero;
      });
    });
  }

  Widget _buildActionIndicator(bool isLeft) {
    final color = isLeft ? widget.leftActionColor : widget.rightActionColor;
    final icon = isLeft ? widget.leftActionIcon : widget.rightActionIcon;
    final label = isLeft ? widget.leftActionLabel : widget.rightActionLabel;
    
    if (color == null || icon == null) return const SizedBox();

    final progress = isLeft 
        ? (-_dragOffset.dx / widget.swipeThreshold).clamp(0.0, 1.0)
        : (_dragOffset.dx / widget.swipeThreshold).clamp(0.0, 1.0);

    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      top: 0,
      bottom: 0,
      child: AnimatedOpacity(
        opacity: progress,
        duration: const Duration(milliseconds: 50),
        child: Container(
          width: 80,
          color: color.withOpacity(0.8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = _isDragging ? _dragOffset : _slideAnimation.value;
          
          return Stack(
            children: [
              // Action indicators
              _buildActionIndicator(true),  // Left action
              _buildActionIndicator(false), // Right action
              
              // Main content
              Transform.translate(
                offset: offset,
                child: Transform.scale(
                  scale: _isDragging ? 0.98 : _scaleAnimation.value,
                  child: widget.child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Page swipe navigation for bottom navigation tabs
class SwipeablePageView extends StatefulWidget {
  final List<Widget> children;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final PageController? controller;
  final bool enableSwipe;

  const SwipeablePageView({
    super.key,
    required this.children,
    this.initialPage = 0,
    this.onPageChanged,
    this.controller,
    this.enableSwipe = true,
  });

  @override
  State<SwipeablePageView> createState() => _SwipeablePageViewState();
}

class _SwipeablePageViewState extends State<SwipeablePageView> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = widget.controller ?? PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    widget.onPageChanged?.call(page);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      physics: widget.enableSwipe 
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return widget.children[index];
      },
    );
  }
}

/// Dismissible card with swipe-to-dismiss functionality
class SwipeToDismiss extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDismissed;
  final Color dismissColor;
  final IconData dismissIcon;
  final String dismissLabel;
  final DismissDirection direction;

  const SwipeToDismiss({
    super.key,
    required this.child,
    this.onDismissed,
    this.dismissColor = Colors.red,
    this.dismissIcon = Icons.delete,
    this.dismissLabel = 'Delete',
    this.direction = DismissDirection.endToStart,
  });

  @override
  State<SwipeToDismiss> createState() => _SwipeToDismissState();
}

class _SwipeToDismissState extends State<SwipeToDismiss>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: widget.direction,
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        widget.onDismissed?.call();
      },
      background: Container(
        color: widget.dismissColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.dismissIcon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              widget.dismissLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: widget.child,
    );
  }
}

/// Pull-to-refresh with custom animations
class SwipeRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final String refreshText;

  const SwipeRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.refreshText = 'Pull to refresh',
  });

  @override
  State<SwipeRefresh> createState() => _SwipeRefreshState();
}

class _SwipeRefreshState extends State<SwipeRefresh> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: widget.color ?? Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      displacement: 60,
      child: widget.child,
    );
  }
}

/// Swipeable card stack (like Tinder cards)
class SwipeableCardStack extends StatefulWidget {
  final List<Widget> cards;
  final ValueChanged<int>? onSwipeLeft;
  final ValueChanged<int>? onSwipeRight;
  final VoidCallback? onStackEmpty;

  const SwipeableCardStack({
    super.key,
    required this.cards,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onStackEmpty,
  });

  @override
  State<SwipeableCardStack> createState() => _SwipeableCardStackState();
}

class _SwipeableCardStackState extends State<SwipeableCardStack>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.cards.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _swipeCard(bool isLeft) {
    if (_currentIndex >= widget.cards.length) return;

    final controller = _controllers[_currentIndex];
    controller.forward().then((_) {
      if (isLeft) {
        widget.onSwipeLeft?.call(_currentIndex);
      } else {
        widget.onSwipeRight?.call(_currentIndex);
      }

      setState(() {
        _currentIndex++;
      });

      if (_currentIndex >= widget.cards.length) {
        widget.onStackEmpty?.call();
      }
    });

    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;

        if (index < _currentIndex) return const SizedBox();

        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            final animation = _controllers[index];
            final offset = Offset(
              animation.value * (index == _currentIndex ? 300 : 0),
              0,
            );

            return Transform.translate(
              offset: offset,
              child: Transform.scale(
                scale: 1.0 - (animation.value * 0.1),
                child: Opacity(
                  opacity: 1.0 - animation.value,
                  child: index == _currentIndex
                      ? SwipeableWidget(
                          onSwipeLeft: () => _swipeCard(true),
                          onSwipeRight: () => _swipeCard(false),
                          leftActionColor: Colors.red,
                          rightActionColor: Colors.green,
                          leftActionIcon: Icons.close,
                          rightActionIcon: Icons.favorite,
                          child: card,
                        )
                      : card,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
} 