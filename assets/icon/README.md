# Vidyakalp artwork

Editable design: https://www.figma.com/design/SnCH3jxuWR8EUDvjgvBdDq?node-id=2-2

`vidyalaya.svg` is the vector master exported from Figma with outlined lettering.
Its existing technical filename is intentional; the displayed brand is Vidyakalp.
No Figma account, connection, or network request is needed to build or run the app.

- `vidyalaya.png`: opaque 2048px square master for legacy Android, iPhone/iPad, desktop, and store icons.
- `adaptive_foreground.png`: transparent 1024px Android foreground. The full logo is scaled to 575px and centred so the artwork fits Android's 66dp safe circle within the 108dp layer.
- `monochrome.png`: transparent book outline and V for Android themed icons. Small lettering and shading are omitted for legibility when the system applies one colour.
- `maskable.png`: sage square with extra padding for web launcher masks.
- `vmark.png`: transparent book/V with Odia Medium + CBSE below it for the welcome screen.
- `splash_mark.png`: book with padding for the Android 12+ circular splash mask, also used on iOS and web.
- `branding.png`: transparent Odia Medium + CBSE caption for the Android 12+ splash branding strip.

The background is sage `#ECF1EC`, with emerald `#16855A`, dark green
`#0E6444`, and ink `#16201B`. Do not bake outer rounded corners into the master.
The device launcher applies its own mask. The larger caption uses two centred lines below the book in the
full logo; no app-name text is embedded in the icon. The caption can still be
small at launcher size. The system-tinted monochrome version uses the book/V only.

After replacing the source PNG assets, regenerate the platform resources:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

The settings are in `pubspec.yaml`. Keep the Android foreground inset at zero:
its source PNG already contains the required padding. Package names, bundle IDs,
repository names, and backend integrations are independent of this artwork.
