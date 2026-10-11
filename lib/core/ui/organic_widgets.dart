import 'package:flutter/material.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';

/// A small rounded label for a state: Paid, Partial, Due, Overdue, Present.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    required this.background,
    required this.foreground,
    this.height = 32,
    super.key,
  });

  final String label;
  final Color background;
  final Color foreground;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      // Shrink-wraps the label's width; centres it in the fixed height.
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: foreground,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

/// A Caprasimo section heading (20 px), flush left.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final title = Text(text, style: Theme.of(context).textTheme.titleLarge);
    if (trailing == null) return title;
    return Row(
      children: [
        Expanded(child: title),
        trailing!,
      ],
    );
  }
}

/// A rounded surface container: the handoff's 24–28 px cards.
class OrganicPanel extends StatelessWidget {
  const OrganicPanel({
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.radius = OrganicRadius.card,
    this.onTap,
    super.key,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    return Material(
      color: color ?? Organic.of(context).surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              customBorder: shape,
              child: Padding(padding: padding, child: child),
            ),
    );
  }
}

/// A rounded progress bar on a tinted track.
class PillProgress extends StatelessWidget {
  const PillProgress({
    required this.value,
    required this.color,
    required this.track,
    this.height = 10,
    super.key,
  });

  /// 0 to 1.
  final double value;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(OrganicRadius.pill),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value.clamp(0, 1).toDouble(),
          minHeight: height,
          color: color,
          backgroundColor: track,
          borderRadius: BorderRadius.circular(OrganicRadius.pill),
        ),
      ),
    );
  }
}

/// A round, tinted icon button (48 px), like the reminder button on a due row.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.background,
    this.foreground,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: background ?? o.sageSoft,
        foregroundColor: foreground ?? o.sageStrong,
        disabledBackgroundColor: o.surface,
        fixedSize: const Size(48, 48),
        shape: const CircleBorder(),
      ),
    );
  }
}
