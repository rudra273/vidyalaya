# Vidyakalp artwork

The [editable Figma artwork](https://www.figma.com/design/Z97YlwQ1m33sNbfQaVnS5K?node-id=2-2)
contains the book cover, round and monochrome marks, and wordmark. The app
bundles the approved artwork locally.

- `vmark.svg` and `vmark.png` carry the rounded cover for the in-app logo,
  legacy Android, macOS, and Windows. `wordmark.svg` contains the outlined
  lettering, which the app recolors for dark mode.
- `vidyalaya.svg` and `vidyalaya.png` are the full-bleed artwork for the
  standard iOS and store icons. The system applies the outer mask.
- `ios_dark.png` uses the two pages and spark on a transparent background.
  `ios_tinted.png` preserves the page contrast in grayscale.
- `adaptive_background.png` supplies Android's full-bleed gradient.
  `adaptive_foreground.png` and `monochrome.png` keep their visible artwork
  within the adaptive icon safe area. The monochrome layer has a transparent
  cutout for the spark so it stays visible when Android applies a system tint.
- `maskable.png` fills the web icon canvas and keeps its artwork within the
  maskable safe area.
- `splash_mark.png` uses the round cover with transparent padding for Android's
  circular splash mask. The same artwork is used for iOS and web launch screens.

After updating the source PNGs, regenerate the configured platform assets:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Keep the Android foreground inset at zero in `pubspec.yaml`. The foreground
and monochrome source images already include the padding.
