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
| `lib/core/ui/organic_blocks.dart` | The second handoff's blocks (`Blocks.dc.html`): heading, text, rows card, item row, toggle, buttons (primary, sage, outlined, danger, ghost), banner, message bubble, numbered step, stepper, photo, onboarding dots and illustration, chips, and `showBlockSheet` |
| `lib/core/ui/time_chips.dart` | Class time chips: common times, any other time, or none |
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

`Organic.dark` is the second handoff's dark palette (`[data-theme="dark"]`): a
deep warm ground, darkened 200–300 tints and lightened 800–900 text steps, with
the 600 accents unchanged.

## Second handoff: the remaining screens

The second handoff designed what the first left out. Where the app already did
more than the prototype (effective months on fee changes, waiving any month,
optional backup passwords, weekly summaries, custom member fees), the screens
take the design's layout and keep the app's features and wording.

- **Batches** have their own tab (six tabs in all): list, detail with this
  month's figures and members, and a form with day and time chips. "Delete
  batch" archives it (spec 5.2: soft delete).
- **Student form:** photo block, class chips, a due-day stepper, subject, day,
  time and batch chips. Batch chips join and leave batches on save.
- **Notes tab:** dated notes, newest first, stored in the existing notes field
  as `[YYYY-MM-DD] text` entries; older free text shows as an undated note.
- **Fee adjustments** page (`/students/:id/adjust`): change fee, pause or
  resume, one-time fee, waive or discount this month, and payments.
- **Receipt:** cream paper, brand badge, dashed rules and a "paid" stamp; PNG or
  PDF chosen with chips.
- **Home:** a dashed "Extra class" button under the day's classes opens a sheet
  with owner and time chips.
- **Mark class off:** one sheet with reasons; a public holiday is stored as a
  holiday, other reasons as a cancelled class with the reason as its note.
- **Messaging, reminders, backup, lock, onboarding, settings and reports**
  follow the handoff's blocks.

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
