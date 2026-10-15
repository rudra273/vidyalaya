# ─── Vidya AI release keep rules ────────────────────────────────────────────
# R8 (isMinifyEnabled + isShrinkResources) runs on release builds. Flutter,
# Firebase and Play services ship their own consumer rules, so only libraries
# that do not are listed here. Avoid broad keeps: they block obfuscation.

# ─── flutter_pdfview (com.github.barteksc PdfiumAndroid) ───
-keep class com.shockwave.** { *; }
-dontwarn com.shockwave.**

# Keep annotations and generic signatures (needed for reflection-based JSON
# and Play services internals).
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
