"""
Remove watermarks from Odisha Board PDF textbooks.

Watermarks to remove:
  1. Text: "https://odishaboardsolutions.com/..." (top & bottom of pages)
  2. Square annotation: full-page teal rectangle at 10% opacity

Strategy:
  - Delete Square annotations (no rasterisation needed)
  - Redact watermark text only (tiny area, minimal size impact)
  - Use deflate + garbage collection + linearize to keep output small
"""

import fitz  # PyMuPDF
from pathlib import Path
import time
import sys
import os

# Fix Windows console encoding for emoji/unicode
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    os.environ.setdefault("PYTHONIOENCODING", "utf-8")

# ── Config ────────────────────────────────────────────────
INPUT_DIR  = Path("Odisha_Books_2026_27/Class_8")
OUTPUT_DIR = Path("Odisha_Books_2026_27/Class_8_Clean")

# Substrings that identify watermark text (case-insensitive)
WATERMARK_MARKERS = [
    "odishaboardsolutions.com",
]
# ──────────────────────────────────────────────────────────

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def is_watermark_text(text: str) -> bool:
    """Return True if the text span is a watermark."""
    t = text.strip().lower()
    return any(marker in t for marker in WATERMARK_MARKERS)


def clean_pdf(src: Path, dst: Path) -> dict:
    """Remove watermarks from *src* and save to *dst*. Returns stats."""
    doc = fitz.open(src)
    stats = {"annotations_removed": 0, "text_removed": 0}

    for page in doc:
        # ── 1. Remove Square annotations (the teal overlay) ──────────
        annots_to_delete = []
        for annot in page.annots():
            # Type 4 = Square (Rectangle)
            if annot.type[0] == 4:
                annots_to_delete.append(annot)

        for annot in annots_to_delete:
            page.delete_annot(annot)
            stats["annotations_removed"] += 1

        # ── 2. Remove watermark text via targeted redaction ──────────
        blocks = page.get_text("dict", flags=fitz.TEXT_PRESERVE_WHITESPACE)["blocks"]
        has_redactions = False

        for block in blocks:
            if block["type"] != 0:  # only text blocks
                continue
            for line in block["lines"]:
                for span in line["spans"]:
                    if is_watermark_text(span["text"]):
                        rect = fitz.Rect(span["bbox"])
                        # Use page background colour as fill (white)
                        page.add_redact_annot(
                            rect,
                            text="",           # replace with nothing
                            fill=(1, 1, 1),    # white fill
                        )
                        has_redactions = True
                        stats["text_removed"] += 1

        if has_redactions:
            # images=fitz.PDF_REDACT_IMAGE_NONE → don't touch images
            # so they stay compressed and untouched
            page.apply_redactions(images=fitz.PDF_REDACT_IMAGE_NONE)

    # Save with optimisations to keep file size small
    doc.save(
        dst,
        garbage=4,          # maximum garbage collection
        deflate=True,       # compress streams
        clean=True,         # clean up unused objects
    )
    doc.close()
    return stats


def main():
    print("=" * 55)
    print("  📚 Odisha Board PDF — Watermark Remover")
    print("=" * 55)

    pdfs = sorted(INPUT_DIR.glob("*.pdf"))
    if not pdfs:
        print(f"\n  ⚠️  No PDFs found in {INPUT_DIR.resolve()}")
        return

    print(f"\n  Found {len(pdfs)} PDF(s) in {INPUT_DIR}\n")

    for pdf in pdfs:
        out = OUTPUT_DIR / pdf.name
        src_size = pdf.stat().st_size / (1024 * 1024)  # MB

        print(f"  ⚙️  {pdf.name} ({src_size:.1f} MB)")
        t0 = time.perf_counter()

        stats = clean_pdf(pdf, out)

        elapsed = time.perf_counter() - t0
        dst_size = out.stat().st_size / (1024 * 1024)
        change = ((dst_size - src_size) / src_size) * 100

        print(f"      ✅ Done in {elapsed:.1f}s  │  "
              f"{stats['annotations_removed']} annot, "
              f"{stats['text_removed']} text removed  │  "
              f"{dst_size:.1f} MB ({change:+.1f}%)")

    print(f"\n{'=' * 55}")
    print(f"  📁 Clean PDFs → {OUTPUT_DIR.resolve()}")
    print("=" * 55)


if __name__ == "__main__":
    main()