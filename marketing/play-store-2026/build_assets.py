from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path("/Users/rudra/projects/vidyalaya")
OUT = ROOT / "marketing/play-store-2026"
SCREENSHOT_OUT = OUT / "screenshots"
ATTACHMENT_ROOT = Path(
    "/tmp/codex-remote-attachments/01a0d788-7ffb-7150-ae17-421305c9b42a"
)
PORTRAIT_BACKGROUND = OUT / "source/portrait-background.png"
FEATURE_BACKGROUND = OUT / "source/feature-background.png"

DISPLAY_FONT = "/System/Library/Fonts/SFNS.ttf"

SCREENSHOTS = [
    (
        "01-home.png",
        ATTACHMENT_ROOT / "5464797d-00ba-47cf-8707-312d1f9865b0/3-1000118199.jpg",
        "Learn Smarter.\nEvery Day.",
        "Your complete school companion",
    ),
    (
        "02-ai-learning.png",
        ATTACHMENT_ROOT / "5464797d-00ba-47cf-8707-312d1f9865b0/2-1000118197.jpg",
        "Your AI Tutor for\nEvery Subject",
        "Clear answers in English, Odia or Hindi",
    ),
    (
        "03-explore.png",
        ATTACHMENT_ROOT / "5464797d-00ba-47cf-8707-312d1f9865b0/1-1000118195.jpg",
        "Explore. Practice.\nUnderstand.",
        "Interactive tools that make learning click",
    ),
    (
        "04-science-lab.png",
        ATTACHMENT_ROOT / "5464797d-00ba-47cf-8707-312d1f9865b0/4-1000118201.jpg",
        "Experiment. Discover.\nUnderstand.",
        "Learn science through hands-on simulations",
    ),
    (
        "05-ai-qa.png",
        ATTACHMENT_ROOT / "cf04fac1-8f7f-49d2-a5a1-50f14929bbe9/2-1000118209.jpg",
        "Ask Doubts.\nGet Clear Answers.",
        "Study in the language you understand best",
    ),
    (
        "06-diagrams.png",
        ATTACHMENT_ROOT / "cf04fac1-8f7f-49d2-a5a1-50f14929bbe9/1-1000118211.jpg",
        "See Science\nCome Alive",
        "Explore clear, labelled diagrams",
    ),
    (
        "07-periodic-table.png",
        ATTACHMENT_ROOT / "cf04fac1-8f7f-49d2-a5a1-50f14929bbe9/3-1000118203.jpg",
        "Master Every\nElement",
        "A periodic table in your language",
    ),
    (
        "08-sudoku.png",
        ATTACHMENT_ROOT / "cf04fac1-8f7f-49d2-a5a1-50f14929bbe9/4-1000118205.jpg",
        "Train Your Brain.\nHave Fun.",
        "Build focus with puzzles and games",
    ),
    (
        "09-python-playground.png",
        ATTACHMENT_ROOT / "cf04fac1-8f7f-49d2-a5a1-50f14929bbe9/5-1000118207.jpg",
        "Learn Python\nby Doing",
        "Write code and see results instantly",
    ),
]


def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(DISPLAY_FONT, size=size)


def cover(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    return ImageOps.fit(image, size, method=Image.Resampling.LANCZOS)


def add_top_shade(image: Image.Image) -> None:
    shade = Image.new("RGBA", image.size, (0, 0, 0, 0))
    alpha = Image.new("L", (1, 560))
    alpha.putdata([int(95 * (1 - y / 559) ** 1.5) for y in range(560)])
    alpha = alpha.resize((image.width, 560))
    shade.paste((4, 43, 30, 255), (0, 0, image.width, 560), alpha)
    image.alpha_composite(shade)


def rounded_screenshot(source: Image.Image, size: tuple[int, int], radius: int) -> Image.Image:
    image = source.resize(size, Image.Resampling.LANCZOS).convert("RGBA")
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    image.putalpha(mask)
    return image


def phone_card(source_path: Path, width: int = 706) -> Image.Image:
    source = Image.open(source_path).convert("RGB")
    inner_width = width - 24
    inner_height = round(source.height * inner_width / source.width)
    outer_size = (width, inner_height + 24)

    shadow_pad = 50
    layer = Image.new(
        "RGBA", (outer_size[0] + shadow_pad * 2, outer_size[1] + shadow_pad * 2), (0, 0, 0, 0)
    )
    shadow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(shadow)
    box = (shadow_pad, shadow_pad + 12, shadow_pad + width, shadow_pad + 12 + outer_size[1])
    draw.rounded_rectangle(box, radius=58, fill=(0, 20, 14, 145))
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))
    layer.alpha_composite(shadow)

    frame = Image.new("RGBA", outer_size, (12, 18, 16, 255))
    frame_mask = Image.new("L", outer_size, 0)
    ImageDraw.Draw(frame_mask).rounded_rectangle(
        (0, 0, outer_size[0], outer_size[1]), radius=50, fill=255
    )
    frame.putalpha(frame_mask)
    frame.alpha_composite(rounded_screenshot(source, (inner_width, inner_height), 40), (12, 12))
    layer.alpha_composite(frame, (shadow_pad, shadow_pad))
    return layer


def centered_text(draw: ImageDraw.ImageDraw, text: str, y: int, text_font: ImageFont.FreeTypeFont, fill: str, spacing: int = 4) -> None:
    box = draw.multiline_textbbox((0, 0), text, font=text_font, spacing=spacing, align="center")
    width = box[2] - box[0]
    draw.multiline_text(((1080 - width) / 2, y), text, font=text_font, fill=fill, spacing=spacing, align="center")


def build_screenshot(filename: str, source: Path, headline: str, subline: str) -> Path:
    background = cover(Image.open(PORTRAIT_BACKGROUND).convert("RGB"), (1080, 1920)).convert("RGBA")
    add_top_shade(background)
    draw = ImageDraw.Draw(background)

    pill_font = font(30)
    pill_text = "VIDYA AI"
    pill_box = draw.textbbox((0, 0), pill_text, font=pill_font)
    pill_width = pill_box[2] - pill_box[0] + 52
    pill_x = (1080 - pill_width) // 2
    draw.rounded_rectangle((pill_x, 58, pill_x + pill_width, 112), radius=27, fill=(255, 255, 255, 50), outline=(255, 255, 255, 95), width=2)
    draw.text((pill_x + 26, 68), pill_text, font=pill_font, fill="#FFF2C6")

    centered_text(draw, headline, 137, font(68), "#FFFFFF", spacing=-2)
    centered_text(draw, subline, 298, font(29), "#E2F7EB")

    phone = phone_card(source)
    x = (1080 - phone.width) // 2
    background.alpha_composite(phone, (x, 342))

    output = SCREENSHOT_OUT / filename
    background.convert("RGB").save(output, "PNG", optimize=True)
    return output


def mini_phone(source_path: Path, width: int, angle: float) -> Image.Image:
    source = Image.open(source_path).convert("RGB")
    inner_width = width - 14
    inner_height = round(source.height * inner_width / source.width)
    frame = Image.new("RGBA", (width, inner_height + 14), (11, 20, 17, 255))
    frame_mask = Image.new("L", frame.size, 0)
    ImageDraw.Draw(frame_mask).rounded_rectangle((0, 0, *frame.size), radius=30, fill=255)
    frame.putalpha(frame_mask)
    frame.alpha_composite(rounded_screenshot(source, (inner_width, inner_height), 23), (7, 7))
    return frame.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)


def build_feature_graphic() -> Path:
    canvas = cover(Image.open(FEATURE_BACKGROUND).convert("RGB"), (1024, 500)).convert("RGBA")
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    overlay_draw.rectangle((0, 0, 610, 500), fill=(0, 47, 32, 98))
    overlay = overlay.filter(ImageFilter.GaussianBlur(28))
    canvas.alpha_composite(overlay)
    draw = ImageDraw.Draw(canvas)

    draw.text((70, 72), "VIDYA AI", font=font(29), fill="#FFD76A")
    draw.multiline_text((66, 118), "Learn. Explore.\nGrow.", font=font(70), fill="#FFFFFF", spacing=-4)
    draw.text((70, 302), "AI-powered learning for every student", font=font(27), fill="#DDF5E7")
    draw.rounded_rectangle((70, 366, 365, 422), radius=28, fill="#F4C852")
    draw.text((102, 378), "Study in your language", font=font(24), fill="#123F2F")

    home_source = SCREENSHOTS[0][1]
    ai_source = SCREENSHOTS[1][1]
    phone_back = mini_phone(ai_source, 210, 5)
    phone_front = mini_phone(home_source, 228, -5)

    for phone, position in ((phone_back, (794, 30)), (phone_front, (628, 36))):
        shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        shadow.alpha_composite(phone, (position[0] + 10, position[1] + 14))
        alpha = shadow.getchannel("A").filter(ImageFilter.GaussianBlur(18))
        black = Image.new("RGBA", canvas.size, (0, 16, 11, 115))
        black.putalpha(alpha)
        canvas.alpha_composite(black)
        canvas.alpha_composite(phone, position)

    output = OUT / "feature-graphic-1024x500.png"
    canvas.convert("RGB").save(output, "PNG", optimize=True)
    return output


def build_icon() -> Path:
    source = Image.open(
        ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"
    ).convert("RGBA")
    icon = source.resize((512, 512), Image.Resampling.LANCZOS)
    output = OUT / "app-icon-512x512.png"
    icon.save(output, "PNG", optimize=True)
    return output


def build_contact_sheet(paths: list[Path]) -> Path:
    thumb_size = (270, 480)
    sheet = Image.new("RGB", (thumb_size[0] * 3, thumb_size[1] * 3), "#102D23")
    for index, path in enumerate(paths):
        thumb = Image.open(path).convert("RGB").resize(thumb_size, Image.Resampling.LANCZOS)
        sheet.paste(thumb, ((index % 3) * thumb_size[0], (index // 3) * thumb_size[1]))
    output = OUT / "screenshots-preview.jpg"
    sheet.save(output, "JPEG", quality=88, optimize=True)
    return output


def main() -> None:
    SCREENSHOT_OUT.mkdir(parents=True, exist_ok=True)
    screenshot_paths = [build_screenshot(*spec) for spec in SCREENSHOTS]
    feature = build_feature_graphic()
    icon = build_icon()
    preview = build_contact_sheet(screenshot_paths)
    for path in [*screenshot_paths, feature, icon, preview]:
        with Image.open(path) as image:
            print(f"{path}: {image.size} {image.mode}")


if __name__ == "__main__":
    main()
