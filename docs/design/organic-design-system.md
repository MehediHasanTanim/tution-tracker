# Organic design system in the app

The UI follows the **Organic** design system from the Claude Design handoff
(*Tuition Khata Mobile App*): warm and rounded, a cream-and-sand ground with a
terracotta accent and a sage second accent, Caprasimo headings over Figtree,
and pill-shaped controls.

## Where it lives

| File | What it holds |
|---|---|
| `lib/core/theme/organic_tokens.dart` | The palette (`OrganicPalette`: ground, surface, text and the 100–900 neutral, terracotta and sage ramps), the semantic roles screens use (`Organic`, a `ThemeExtension`, one set for light and one for dark), font family names and radii |
| `lib/core/theme/app_theme.dart` | The Material theme built from the tokens: colour scheme, type scale, and component themes (buttons, chips, segmented buttons, tabs, fields, nav bar, sheets, dialogs, snack bars, switches) |
| `lib/core/ui/organic_widgets.dart` | Small shared pieces: `StatusPill`, `SectionTitle`, `OrganicPanel`, `PillProgress`, `RoundIconButton` |
| `lib/features/fees/presentation/fee_status_style.dart` | Paid / Partial / Due / Overdue / Waived colours, used by the student list and ledger |

Screens read colours through `Organic.of(context)` (for example `o.accentSoft`
for the month card) or through the colour scheme, never as raw hex values.
The tokens are the only place colours are defined.

## Rules the screens follow

- **Colour roles.** `accent` (terracotta 600) fills primary buttons and
  selected chips; `accentStrong` (700) marks overdue and absent;
  `accentSoft` (200) tints the hero cards; `sage` (600) is WhatsApp, share and
  switches; `sageSoft` (200) is paid, present and done; `neutralSoft` (300) is
  due and late.
- **Type.** Caprasimo for display and headline sizes (40 hero figures, 28
  screen titles, 24 sheet titles, 20 section titles); Figtree for everything
  else. Both fall back to Hind Siliguri, because neither has Bangla glyphs, so
  Bangla headings render in Hind Siliguri, as the handoff's font stacks do.
- **Shape.** Cards 24, panels 28, sheets 32; every button, chip, tab and
  single-line input is a pill.
- **Layout.** Left-aligned, 20 px side margins, whitespace rather than
  dividers.
- **Icons.** Material *rounded* icons. The handoff specifies Lucide at a heavy
  stroke; the rounded Material set is the closest match without adding a
  dependency.

## Dark theme

The handoff ships light only. Dark mode (spec SE-4) reuses the same ramps from
the other end: a deep warm ground, the 400 steps for accents and the 800–900
steps for tinted fills (`Organic.dark`).

## Fonts

`assets/fonts/`: Caprasimo (400), Figtree (400/500/600/700, static instances
cut from the variable font) and Hind Siliguri (400/500/600/700), each with its
OFL licence. They replace the earlier Noto Sans Bengali.

## App icon

A cream notebook (খাতা) with a sage tick on terracotta.

- **Android:** `android/app/src/main/res/mipmap-*/`: legacy square and round
  launchers (48–192 px), adaptive layers (foreground, background and a
  monochrome layer for themed icons, 108–432 px) and
  `mipmap-anydpi-v26/ic_launcher.xml` / `ic_launcher_round.xml`. The 512 px
  Play Store icon is `branding/android/play-store-512.png`. The launch screen
  uses the page ground colour with the icon centred.
- **iOS:** the repository has no `ios/` project yet (iOS is later in the
  plan). The full set is ready in `branding/ios/AppIcon.appiconset/`: opaque
  PNGs from 20 to 1024 px plus dark and tinted 1024 px variants, with
  `Contents.json`. After `flutter create --platforms=ios .`, replace
  `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with that folder.
- `assets/brand/app_icon.png` (256 px) is the in-app copy shown on the welcome
  screen.
