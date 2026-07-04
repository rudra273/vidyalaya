# ─── Vidyālaya release keep rules ───────────────────────────────────────────
# R8 (isMinifyEnabled + isShrinkResources) runs on release builds. The Flutter
# Gradle plugin contributes the core Flutter/embedding keep rules; the entries
# below cover the native-facing plugins this app depends on.

# ─── Flutter embedding ───
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ─── Firebase / Google Play services (firebase_core, firebase_auth) ───
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ─── Google Sign-In (google_sign_in) ───
-keep class com.google.android.gms.auth.** { *; }

# ─── flutter_pdfview (com.github.barteksc PdfiumAndroid) ───
-keep class com.shockwave.** { *; }
-dontwarn com.shockwave.**

# ─── webview_flutter ───
-keep class android.webkit.** { *; }

# Keep annotations and generic signatures (needed for reflection-based JSON
# and Play services internals).
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
