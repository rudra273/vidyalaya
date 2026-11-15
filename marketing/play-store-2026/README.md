# Vidyakalp Google Play assets

## Version 1.2.1

- [App icon](app-icon-512x512.png) — 512 × 512 sRGB RGBA PNG, exported from the current book-cover artwork.
- [Home](screenshots/01-home.png)
- [AI Learning](screenshots/02-ai-learning.png)
- [AI chat](screenshots/05-ai-qa.png)
- [Explore](screenshots/03-explore.png)
- [Profile](screenshots/10-profile.png)

The five phone screenshots are 1080 × 1920 RGB PNGs. They use current Flutter
screens rendered with demo data inside the existing campaign layout.

The other campaign screenshots and the [feature graphic](feature-graphic-1024x500.png)
remain available in this folder. The [contact sheet](screenshots-preview.jpg)
is for review. Google Play allows up to eight screenshots per device type, so
select up to three earlier images if uploading all five refreshed screenshots.

`build_assets.py` composes supplied raw captures into the campaign layout. Its
historical batch inputs refer to temporary attachment paths, so those files are
required to rebuild that batch. See [app artwork](../../assets/icon/README.md)
for the launcher and splash sources.
