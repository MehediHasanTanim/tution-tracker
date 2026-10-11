import 'package:flutter/material.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';

/// The building blocks of the second design handoff (`Blocks.dc.html`): the
/// screens it adds (batches, forms, adjustments, backup, reminders, lock,
/// onboarding) are stacks of these. Each mirrors one block type there.

/// `h`: a Caprasimo page heading (26 px).
class BlockHeading extends StatelessWidget {
  const BlockHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium
          ?.copyWith(fontSize: 26, height: 1.3),
    ),
  );
}

/// `h2`: a Caprasimo section heading (19 px).
class BlockSubheading extends StatelessWidget {
  const BlockSubheading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontSize: 19, height: 1.3),
    ),
  );
}

/// `p`: a short explanatory paragraph.
class BlockText extends StatelessWidget {
  const BlockText(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 14,
      height: 1.5,
      color: color ?? Organic.of(context).subtle,
    ),
  );
}

/// `rows`: label–value pairs on a surface card.
class BlockRows extends StatelessWidget {
  const BlockRows(this.rows, {super.key});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: o.surface,
        borderRadius: BorderRadius.circular(OrganicRadius.card),
      ),
      child: Column(
        children: [
          for (final (k, v) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      k,
                      style: TextStyle(fontSize: 15, color: o.muted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      v,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The round leading mark of an [BlockItem]: an icon on a tint.
class BlockIcon extends StatelessWidget {
  const BlockIcon(this.icon, {this.sage = false, super.key});

  final IconData icon;

  /// Sage tint instead of terracotta.
  final bool sage;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: sage ? o.sageSoft : o.accentSoft,
      ),
      child: Icon(icon, size: 22, color: sage ? o.onSageSoft : o.onAccentSoft),
    );
  }
}

/// `item`: a tappable surface row with a leading mark, title, subtitle, and
/// an optional tag pill and chevron.
class BlockItem extends StatelessWidget {
  const BlockItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.tag,
    this.tagBackground,
    this.tagForeground,
    this.chevron = false,
    this.trailing,
    this.onTap,
    super.key,
  });

  /// Anything else at the end of the row, such as a menu.
  final Widget? trailing;

  final String title;
  final String? subtitle;
  final Widget? leading;
  final String? tag;
  final Color? tagBackground;
  final Color? tagForeground;
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(OrganicRadius.card),
    );
    return Material(
      color: o.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: o.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (tag != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: ShapeDecoration(
                      color: tagBackground ?? o.sageSoft,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      tag!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: tagForeground ?? o.onSageSoft,
                      ),
                    ),
                  ),
                ],
                ?trailing,
                if (chevron) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 22, color: o.muted),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `tog`: a labelled switch on a surface card.
class BlockToggle extends StatelessWidget {
  const BlockToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    return Material(
      color: o.surface,
      borderRadius: BorderRadius.circular(OrganicRadius.card),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: TextStyle(fontSize: 13, color: o.muted)),
      ),
    );
  }
}

/// The button kinds of the design: primary terracotta, sage, outlined,
/// danger (deep terracotta), and ghost (text only).
enum BlockButtonKind { primary, sage, outlined, danger, ghost }

/// `btn`: a full-width pill button. A null [onPressed] greys it out, the
/// design's disabled state.
class BlockButton extends StatelessWidget {
  const BlockButton(
    this.label, {
    required this.onPressed,
    this.kind = BlockButtonKind.primary,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final BlockButtonKind kind;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    const size = Size.fromHeight(56);
    final text = Text(label);
    final iconW = icon == null ? null : Icon(icon, size: 20);
    switch (kind) {
      case BlockButtonKind.outlined:
        final style = OutlinedButton.styleFrom(minimumSize: size);
        return iconW == null
            ? OutlinedButton(onPressed: onPressed, style: style, child: text)
            : OutlinedButton.icon(
                onPressed: onPressed,
                style: style,
                icon: iconW,
                label: text,
              );
      case BlockButtonKind.ghost:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(minimumSize: size),
          child: text,
        );
      case BlockButtonKind.primary:
      case BlockButtonKind.sage:
      case BlockButtonKind.danger:
        final bg = switch (kind) {
          BlockButtonKind.sage => o.sage,
          BlockButtonKind.danger => o.accentStrong,
          _ => o.accent,
        };
        final style = FilledButton.styleFrom(
          minimumSize: size,
          backgroundColor: bg,
          foregroundColor: Colors.white,
        );
        return iconW == null
            ? FilledButton(onPressed: onPressed, style: style, child: text)
            : FilledButton.icon(
                onPressed: onPressed,
                style: style,
                icon: iconW,
                label: text,
              );
    }
  }
}

/// `ban`: a tinted card with a Caprasimo title, for status and warnings.
class BlockBanner extends StatelessWidget {
  const BlockBanner({
    required this.title,
    required this.text,
    required this.background,
    required this.foreground,
    super.key,
  });

  final String title;
  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(OrganicRadius.panel),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(color: foreground),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(fontSize: 14, height: 1.5, color: foreground),
          ),
        ],
      ),
    );
  }
}

/// `msg`: a message as the guardian will see it, as a chat bubble.
class BlockMessage extends StatelessWidget {
  const BlockMessage(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: o.sageSoft.withValues(alpha: 0.6),
        border: Border.all(color: o.sageSoft, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(6),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, height: 1.55)),
    );
  }
}

/// `step`: a numbered instruction on a surface card.
class BlockStep extends StatelessWidget {
  const BlockStep({required this.number, required this.text, super.key});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: o.surface,
        borderRadius: BorderRadius.circular(OrganicRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: o.accentSoft,
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: o.onAccentSoft,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `stp`: a pill stepper with − and + buttons.
class BlockStepper extends StatelessWidget {
  const BlockStepper({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.minusTooltip,
    this.plusTooltip,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final String? minusTooltip;
  final String? plusTooltip;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsetsDirectional.fromSTEB(22, 6, 8, 6),
      decoration: ShapeDecoration(
        color: o.surface,
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: minusTooltip,
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded),
            style: IconButton.styleFrom(
              backgroundColor: o.bg,
              foregroundColor: o.text,
              fixedSize: const Size(48, 48),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          IconButton(
            tooltip: plusTooltip,
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(
              backgroundColor: o.accent,
              foregroundColor: Colors.white,
              fixedSize: const Size(48, 48),
            ),
          ),
        ],
      ),
    );
  }
}

/// `photo`: a large avatar with a dashed "add photo" pill beside it.
class BlockPhoto extends StatelessWidget {
  const BlockPhoto({
    required this.avatar,
    required this.label,
    required this.onTap,
    super.key,
  });

  final Widget avatar;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    return Row(
      children: [
        avatar,
        const SizedBox(width: 16),
        Flexible(
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.photo_camera_rounded, size: 20),
            label: Text(label),
            // The design's dashed outline reads as "optional"; Flutter has no
            // dashed border, so a lighter accent stands in for it.
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 48),
              side: BorderSide(
                color: o.accent.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// `dots`: the onboarding progress, the current step a wider pill.
class BlockDots extends StatelessWidget {
  const BlockDots({required this.count, required this.current, super.key});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == current ? 28 : 10,
              height: 10,
              margin: const EdgeInsetsDirectional.only(end: 8),
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                color: i == current ? o.accent : o.neutralSoft,
              ),
            ),
        ],
      ),
    );
  }
}

/// `ill`: the onboarding illustration, overlapping soft circles around an
/// icon. [sage] swaps which accent leads.
class BlockIllustration extends StatelessWidget {
  const BlockIllustration({required this.icon, this.sage = true, super.key});

  final IconData icon;
  final bool sage;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    final big = sage ? o.sageSoft : o.accentSoft;
    final small = sage ? o.accentSoft : o.sageSoft;
    final centre = sage ? o.sage : o.accent;
    return SizedBox(
      height: 230,
      child: Stack(
        children: [
          PositionedDirectional(start: 0, top: 10, child: _circle(210, big)),
          PositionedDirectional(end: 24, bottom: 4, child: _circle(84, small)),
          Align(
            alignment: const Alignment(-0.25, 0),
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(shape: BoxShape.circle, color: centre),
              child: Icon(icon, size: 52, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

/// Single- or multi-select pill chips, the design's `chips` block: the
/// chosen ones fill with the accent.
class BlockChips<T> extends StatelessWidget {
  const BlockChips({
    required this.options,
    required this.isSelected,
    required this.onTap,
    this.multi = false,
    super.key,
  });

  final List<(T, String)> options;
  final bool Function(T) isSelected;
  final ValueChanged<T> onTap;

  /// Multi-select chips are [FilterChip]s, single-select [ChoiceChip]s.
  final bool multi;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (value, label) in options)
          multi
              ? FilterChip(
                  label: Text(label),
                  selected: isSelected(value),
                  onSelected: (_) => onTap(value),
                )
              : ChoiceChip(
                  label: Text(label),
                  selected: isSelected(value),
                  onSelected: (_) => onTap(value),
                ),
      ],
    );
  }
}

/// A modal sheet holding a stack of blocks, the design's second-level
/// sheet. Scrolls when the keyboard or a long list needs it.
Future<T?> showBlockSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: builder(context),
      ),
    ),
  );
}

/// Children with the design's 12 px gap between blocks.
class BlockStack extends StatelessWidget {
  const BlockStack({required this.children, this.gap = 12, super.key});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) SizedBox(height: gap),
        children[i],
      ],
    ],
  );
}
