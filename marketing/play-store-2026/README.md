# Vidyakalp — Google Play assets

Upload-ready files:

- `app-icon-512x512.png` — 512 × 512 RGBA PNG
- `feature-graphic-1024x500.png` — 1024 × 500 RGB PNG
- `screenshots/*.png` — nine 1080 × 1920 RGB PNG phone screenshots

The screenshots preserve the supplied app UI and add a branded phone frame,
educational background, and short student-focused headline. The launcher icon is
exported directly from the current iOS/Android app artwork rather than redrawn.

`screenshots-preview.jpg` is a contact sheet for review and should not be uploaded
as a store screenshot.

The generated background sources and composition script are included. The script
expects original phone screenshots at its configured temporary attachment paths;
those source screenshots are not bundled and must be supplied before rebuilding.

The saved campaign images were rebranded using built-in ImageGen with this brief:
replace the brand lettering with “Vidyakalp”, preserving the existing style,
layout, phone UI, and other text.

The launcher icon uses these exact lines:

- Vidyakalp
- Odia Medium • CBSE
- AI Answer Guide

Its built-in ImageGen edit brief replaces the two tagline lines with the wording
above while preserving the book illustration, palette, wordmark, corner badge,
divider, and ribbon. Splash artwork keeps the brand wordmark alone.

Platform icons are regenerated from `assets/icon/vidyalaya.png` with
`dart run flutter_launcher_icons`, and splash branding with
`dart run flutter_native_splash:create`. Asset filenames stay unchanged.
