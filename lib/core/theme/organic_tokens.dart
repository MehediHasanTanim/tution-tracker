import 'package:flutter/material.dart';

/// The Organic design system's tokens (design handoff `styles.css`): a
/// cream-and-sand ground, a terracotta accent and a sage second accent, each
/// with a 100–900 tonal ramp on one shared lightness scale. Widgets read the
/// tokens through [Organic.of], never through hard-coded colours.
abstract final class OrganicPalette {
  static const bg = Color(0xFFF5EAD8);
  static const surface = Color(0xFFEBDDC5);
  static const text = Color(0xFF201E1D);

  static const neutral100 = Color(0xFFF9F4ED);
  static const neutral200 = Color(0xFFEEE7DB);
  static const neutral300 = Color(0xFFDCD3C4);
  static const neutral400 = Color(0xFFC0B6A5);
  static const neutral500 = Color(0xFFA19786);
  static const neutral600 = Color(0xFF82796A);
  static const neutral700 = Color(0xFF645C50);
  static const neutral800 = Color(0xFF474238);
  static const neutral900 = Color(0xFF2E2B25);

  static const accent100 = Color(0xFFFFF2EB);
  static const accent200 = Color(0xFFFFE1D0);
  static const accent300 = Color(0xFFFFC6A5);
  static const accent400 = Color(0xFFF6A06B);
  static const accent500 = Color(0xFFD67F48);
  static const accent600 = Color(0xFFB2622D);
  static const accent700 = Color(0xFF8C491A);
  static const accent800 = Color(0xFF643312);
  static const accent900 = Color(0xFF402310);

  static const sage100 = Color(0xFFF0FAE1);
  static const sage200 = Color(0xFFE1EECC);
  static const sage300 = Color(0xFFCCDBB2);
  static const sage400 = Color(0xFFAEBF92);
  static const sage500 = Color(0xFF8FA073);
  static const sage600 = Color(0xFF728157);
  static const sage700 = Color(0xFF56633F);
  static const sage800 = Color(0xFF3D472B);
  static const sage900 = Color(0xFF272E1B);
}

/// Semantic roles over the palette, one set per brightness. Screens use these
/// names (for example [hero] for the month card) so light and dark stay in step.
@immutable
class Organic extends ThemeExtension<Organic> {
  const Organic({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.text,
    required this.muted,
    required this.subtle,
    required this.divider,
    required this.accent,
    required this.onAccent,
    required this.accentStrong,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.accentDecor,
    required this.track,
    required this.sage,
    required this.sageSoft,
    required this.onSageSoft,
    required this.sageStrong,
    required this.neutralSoft,
    required this.onNeutralSoft,
    required this.avatars,
  });

  /// Page ground.
  final Color bg;

  /// Cards and list rows.
  final Color surface;

  /// Bars and inputs that sit above the ground (nav bar, text fields).
  final Color raised;
  final Color text;

  /// Secondary text (neutral-700).
  final Color muted;

  /// Tertiary text and hints (neutral-800 on light; reads as body-adjacent).
  final Color subtle;
  final Color divider;

  /// Solid accent fill: primary buttons, selected chips (accent-600).
  final Color accent;
  final Color onAccent;

  /// Deep accent: overdue and absent states, accent text (accent-700).
  final Color accentStrong;

  /// Tinted accent fill: the hero card, partial status (accent-200).
  final Color accentSoft;
  final Color onAccentSoft;

  /// Decorative circle on the hero card, inactive chart bars (accent-300).
  final Color accentDecor;

  /// Progress track on an accent card (accent-100).
  final Color track;

  /// Solid sage: WhatsApp, share, switches on (accent-2-600).
  final Color sage;

  /// Tinted sage: paid, present, done (accent-2-200).
  final Color sageSoft;
  final Color onSageSoft;

  /// Sage text on the ground: paid amounts (accent-2-800).
  final Color sageStrong;

  /// Neutral pill: due, late (neutral-300).
  final Color neutralSoft;
  final Color onNeutralSoft;

  /// Avatar fills, picked by the student's name so each keeps its colour.
  final List<Color> avatars;

  static const light = Organic(
    bg: OrganicPalette.bg,
    surface: OrganicPalette.surface,
    raised: OrganicPalette.neutral100,
    text: OrganicPalette.text,
    muted: OrganicPalette.neutral700,
    subtle: OrganicPalette.neutral800,
    divider: Color(0x29201E1D),
    accent: OrganicPalette.accent600,
    onAccent: Colors.white,
    accentStrong: OrganicPalette.accent700,
    accentSoft: OrganicPalette.accent200,
    onAccentSoft: OrganicPalette.accent900,
    accentDecor: OrganicPalette.accent300,
    track: OrganicPalette.accent100,
    sage: OrganicPalette.sage600,
    sageSoft: OrganicPalette.sage200,
    onSageSoft: OrganicPalette.sage900,
    sageStrong: OrganicPalette.sage800,
    neutralSoft: OrganicPalette.neutral300,
    onNeutralSoft: OrganicPalette.neutral900,
    avatars: [
      OrganicPalette.accent300,
      OrganicPalette.sage300,
      OrganicPalette.accent200,
      OrganicPalette.sage200,
    ],
  );

  /// The handoff's dark palette (`[data-theme="dark"]`): a deep warm ground,
  /// the 200–300 tints darkened and the 800–900 text steps lightened, with
  /// the 600 accents unchanged.
  static const dark = Organic(
    bg: Color(0xFF1B1917),
    surface: Color(0xFF26231F),
    raised: Color(0xFF2A2623),
    text: Color(0xFFF3EADB),
    muted: Color(0xFFB5ADA3),
    subtle: Color(0xFFCDC6BC),
    divider: Color(0xFF3A3530),
    accent: OrganicPalette.accent600,
    onAccent: Colors.white,
    accentStrong: Color(0xFFB25A28),
    accentSoft: Color(0xFF4D2F1C),
    onAccentSoft: Color(0xFFF3CFB4),
    accentDecor: Color(0xFF6B3D22),
    track: Color(0xFF33201A),
    sage: OrganicPalette.sage600,
    sageSoft: Color(0xFF333B27),
    onSageSoft: Color(0xFFDFE7CC),
    sageStrong: Color(0xFFC3CFA9),
    neutralSoft: Color(0xFF443E39),
    onNeutralSoft: Color(0xFFE6DFD3),
    avatars: [
      Color(0xFF6B3D22),
      Color(0xFF4A5638),
      Color(0xFF4D2F1C),
      Color(0xFF333B27),
    ],
  );

  /// The tokens for the current theme; light if none is installed (tests that
  /// pump a bare MaterialApp).
  static Organic of(BuildContext context) =>
      Theme.of(context).extension<Organic>() ?? light;

  /// A stable avatar fill for [name].
  Color avatarFor(String name) {
    var h = 0;
    for (final c in name.runes) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return avatars[h % avatars.length];
  }

  @override
  Organic copyWith() => this;

  @override
  Organic lerp(Organic? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Organic(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      raised: l(raised, other.raised),
      text: l(text, other.text),
      muted: l(muted, other.muted),
      subtle: l(subtle, other.subtle),
      divider: l(divider, other.divider),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentStrong: l(accentStrong, other.accentStrong),
      accentSoft: l(accentSoft, other.accentSoft),
      onAccentSoft: l(onAccentSoft, other.onAccentSoft),
      accentDecor: l(accentDecor, other.accentDecor),
      track: l(track, other.track),
      sage: l(sage, other.sage),
      sageSoft: l(sageSoft, other.sageSoft),
      onSageSoft: l(onSageSoft, other.onSageSoft),
      sageStrong: l(sageStrong, other.sageStrong),
      neutralSoft: l(neutralSoft, other.neutralSoft),
      onNeutralSoft: l(onNeutralSoft, other.onNeutralSoft),
      avatars: [
        for (var i = 0; i < avatars.length; i++)
          l(avatars[i], other.avatars[i]),
      ],
    );
  }
}

/// Type families. Caprasimo and Figtree carry no Bangla glyphs, so every
/// style falls back to Hind Siliguri, as the handoff's font stacks do.
abstract final class OrganicFonts {
  static const heading = 'Caprasimo';
  static const body = 'Figtree';
  static const bangla = 'HindSiliguri';
  static const fallback = [bangla];
}

/// Corner radii. The system over-rounds: containers 24–28, sheets 32, and
/// every button, chip and input is a pill.
abstract final class OrganicRadius {
  static const card = 24.0;
  static const panel = 28.0;
  static const sheet = 32.0;
  static const pill = 999.0;
}
