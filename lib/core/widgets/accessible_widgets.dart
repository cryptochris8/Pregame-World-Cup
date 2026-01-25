import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/accessibility_service.dart';

/// Minimum touch target size per WCAG 2.1 guidelines
const double kMinimumTouchTargetSize = 48.0;
const double kLargerTouchTargetSize = 56.0;

/// An accessible button that ensures minimum touch target size
/// and provides proper semantic labels for screen readers
class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget child;
  final String semanticLabel;
  final String? semanticHint;
  final bool isEnabled;
  final bool isSelected;
  final bool isToggle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final double? minWidth;
  final double? minHeight;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.onLongPress,
    this.semanticHint,
    this.isEnabled = true,
    this.isSelected = false,
    this.isToggle = false,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.minWidth,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityProvider.of(context);
    final minSize = accessibilityService.minimumTouchTargetSize;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      hint: semanticHint,
      selected: isSelected,
      toggled: isToggle ? isSelected : null,
      onTap: isEnabled ? onPressed : null,
      onLongPress: isEnabled ? onLongPress : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? minSize,
          minHeight: minHeight ?? minSize,
        ),
        child: Material(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            onLongPress: isEnabled ? onLongPress : null,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(12),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// An accessible icon button with proper semantics
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? semanticHint;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final bool isEnabled;
  final bool isSelected;
  final String? tooltip;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.semanticHint,
    this.iconSize = 24,
    this.color,
    this.backgroundColor,
    this.isEnabled = true,
    this.isSelected = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityProvider.of(context);
    final minSize = accessibilityService.minimumTouchTargetSize;

    Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: isEnabled ? color : color?.withValues(alpha: 0.5),
      semanticLabel: null, // We provide semantics at the button level
    );

    Widget button = Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      hint: semanticHint,
      selected: isSelected,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: Material(
          color: backgroundColor ?? Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all((minSize - iconSize) / 2),
              child: iconWidget,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// An accessible card that can be tapped
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String semanticLabel;
  final String? semanticHint;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;
  final BorderRadius? borderRadius;

  const AccessibleCard({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onTap,
    this.semanticHint,
    this.margin,
    this.padding,
    this.color,
    this.elevation = 1,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      hint: semanticHint,
      child: Card(
        margin: margin ?? const EdgeInsets.all(8),
        color: color,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// An accessible text widget that respects text scaling
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilitySettings = AccessibilityProvider.settingsOf(context);

    TextStyle effectiveStyle = style ?? DefaultTextStyle.of(context).style;

    // Apply bold text if accessibility setting is enabled
    if (accessibilitySettings.boldText) {
      effectiveStyle = effectiveStyle.copyWith(
        fontWeight: FontWeight.bold,
      );
    }

    Widget textWidget = Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: excludeFromSemantics ? null : (semanticLabel ?? text),
    );

    if (excludeFromSemantics) {
      return ExcludeSemantics(child: textWidget);
    }

    return textWidget;
  }
}

/// An accessible image with proper alt text
class AccessibleImage extends StatelessWidget {
  final ImageProvider image;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool excludeFromSemantics;

  const AccessibleImage({
    super.key,
    required this.image,
    required this.semanticLabel,
    this.width,
    this.height,
    this.fit,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: excludeFromSemantics ? null : semanticLabel,
    );

    if (excludeFromSemantics) {
      return ExcludeSemantics(child: imageWidget);
    }

    return Semantics(
      image: true,
      label: semanticLabel,
      child: imageWidget,
    );
  }
}

/// A wrapper that ensures minimum touch target size
class MinimumTouchTarget extends StatelessWidget {
  final Widget child;
  final double? minWidth;
  final double? minHeight;

  const MinimumTouchTarget({
    super.key,
    required this.child,
    this.minWidth,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityProvider.of(context);
    final minSize = accessibilityService.minimumTouchTargetSize;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? minSize,
        minHeight: minHeight ?? minSize,
      ),
      child: Center(child: child),
    );
  }
}

/// An accessible list item with proper semantics
class AccessibleListItem extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String semanticLabel;
  final String? semanticHint;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;

  const AccessibleListItem({
    super.key,
    required this.title,
    required this.semanticLabel,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticHint,
    this.isSelected = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityProvider.of(context);
    final minSize = accessibilityService.minimumTouchTargetSize;

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      hint: semanticHint,
      selected: isSelected,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minSize),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (leading != null) ...[
                  ExcludeSemantics(child: leading!),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ExcludeSemantics(child: title),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        ExcludeSemantics(child: subtitle!),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  ExcludeSemantics(child: trailing!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated container that respects reduce motion preference
class AccessibleAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final Clip clipBehavior;

  const AccessibleAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = !AccessibilityProvider.shouldReduceMotion(context);

    if (!shouldAnimate) {
      return Container(
        alignment: alignment,
        padding: padding,
        color: decoration == null ? color : null,
        decoration: decoration,
        width: width,
        height: height,
        constraints: constraints,
        margin: margin,
        transform: transform,
        clipBehavior: clipBehavior,
        child: child,
      );
    }

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      alignment: alignment,
      padding: padding,
      color: decoration == null ? color : null,
      decoration: decoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// A focus-aware wrapper that provides visual focus indicators
class FocusableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String semanticLabel;
  final bool autofocus;
  final FocusNode? focusNode;

  const FocusableWidget({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onTap,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<FocusableWidget> createState() => _FocusableWidgetState();
}

class _FocusableWidgetState extends State<FocusableWidget> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      focusable: true,
      focused: _isFocused,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: _isFocused
                ? BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Extension to add accessibility helpers to BuildContext
extension AccessibilityExtension on BuildContext {
  /// Get current accessibility settings
  AccessibilitySettings get accessibilitySettings => AccessibilityProvider.settingsOf(this);

  /// Check if high contrast mode is active
  bool get isHighContrast => AccessibilityProvider.isHighContrast(this);

  /// Check if motion should be reduced
  bool get shouldReduceMotion => AccessibilityProvider.shouldReduceMotion(this);

  /// Get minimum touch target size
  double get minimumTouchTarget => AccessibilityProvider.minimumTouchTarget(this);

  /// Announce a message to screen readers
  void announceForAccessibility(String message) {
    AccessibilityService.announce(message);
  }
}
