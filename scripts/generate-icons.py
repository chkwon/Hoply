#!/usr/bin/env python3
"""
Generate Hoply app icons and HWP / HWPX document icons.

Outputs into ios/Hoply/Assets.xcassets/.

Run via the bundled venv:
    scripts/.icon-venv/bin/python scripts/generate-icons.py
or through the npm script:
    npm run build:icons
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

PROJECT_ROOT = Path(__file__).resolve().parent.parent
ASSETS_ROOT = PROJECT_ROOT / "ios" / "Hoply" / "Assets.xcassets"

BRAND_BLUE = (47, 107, 255, 255)
BRAND_TEAL = (20, 184, 166, 255)
PAPER_WHITE = (255, 255, 255, 255)
PAPER_FOLD = (224, 234, 255, 255)
PAPER_SHADOW = (210, 222, 247, 255)
GLYPH_WHITE = (255, 255, 255, 255)

FONT_CANDIDATES = [
    ("/System/Library/Fonts/Avenir Next.ttc", 8),
    ("/System/Library/Fonts/HelveticaNeue.ttc", 9),
    ("/System/Library/Fonts/HelveticaNeue.ttc", 1),
    ("/System/Library/Fonts/Supplemental/Arial Black.ttf", 0),
    ("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 0),
    ("/System/Library/Fonts/Helvetica.ttc", 1),
]

APP_ICON_SIZES = {
    "Icon-20.png": 20,
    "Icon-20@2x.png": 40,
    "Icon-20@3x.png": 60,
    "Icon-29.png": 29,
    "Icon-29@2x.png": 58,
    "Icon-29@3x.png": 87,
    "Icon-40.png": 40,
    "Icon-40@2x.png": 80,
    "Icon-40@3x.png": 120,
    "Icon-60@2x.png": 120,
    "Icon-60@3x.png": 180,
    "Icon-76.png": 76,
    "Icon-76@2x.png": 152,
    "Icon-83.5@2x.png": 167,
    "Icon-1024.png": 1024,
}

DOC_ICON_SCALES = [
    # (filename suffix, scale, pixel)
    (".png",     "1x", 320),
    ("@2x.png",  "2x", 640),
    ("@3x.png",  "3x", 960),
]


def load_font(size: int) -> ImageFont.FreeTypeFont:
    for path, index in FONT_CANDIDATES:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, size=size, index=index)
            except OSError:
                continue
    raise RuntimeError("No usable heavy sans-serif font found on this system.")


def draw_glyph_centered(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    text: str,
    fill: tuple[int, int, int, int],
    target_height_fraction: float,
) -> None:
    """Render `text` so its visible glyph fills `target_height_fraction` of `box` height, centered."""
    x0, y0, x1, y1 = box
    box_w = x1 - x0
    box_h = y1 - y0
    target_h = box_h * target_height_fraction

    size = max(8, int(target_h * 1.35))
    font = load_font(size)
    # Pillow's textbbox returns the visible-ink bounding box for the rendered string.
    bbox = draw.textbbox((0, 0), text, font=font)
    visible_h = bbox[3] - bbox[1]
    if visible_h <= 0:
        return

    # Refine: scale so visible height matches target_h.
    scale = target_h / visible_h
    size = max(8, int(size * scale))
    font = load_font(size)
    bbox = draw.textbbox((0, 0), text, font=font)
    visible_w = bbox[2] - bbox[0]
    visible_h = bbox[3] - bbox[1]
    # Anchor at top-left ink-bbox so we can position by visible center.
    x = x0 + (box_w - visible_w) / 2 - bbox[0]
    y = y0 + (box_h - visible_h) / 2 - bbox[1]
    draw.text((x, y), text, font=font, fill=fill)


def render_app_icon(size: int) -> Image.Image:
    """Solid brand-blue square with a centered lowercase 'h'."""
    img = Image.new("RGBA", (size, size), BRAND_BLUE)
    draw = ImageDraw.Draw(img)
    draw_glyph_centered(
        draw,
        box=(0, 0, size, size),
        text="h",
        fill=GLYPH_WHITE,
        target_height_fraction=0.58,
    )
    return img


def render_document_icon(size: int, label: str, band_color: tuple[int, int, int, int]) -> Image.Image:
    """Stylized document with a folded corner and a colored bottom band carrying `label`."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    margin_x = int(size * 0.14)
    margin_top = int(size * 0.08)
    margin_bottom = int(size * 0.08)
    paper_left = margin_x
    paper_right = size - margin_x
    paper_top = margin_top
    paper_bottom = size - margin_bottom

    radius = max(4, int(size * 0.06))
    fold_size = max(8, int(size * 0.18))

    # Soft outer drop shadow under the paper.
    shadow_offset = max(1, int(size * 0.012))
    draw.rounded_rectangle(
        (paper_left, paper_top + shadow_offset, paper_right, paper_bottom + shadow_offset),
        radius=radius,
        fill=PAPER_SHADOW,
    )

    # Paper body.
    draw.rounded_rectangle(
        (paper_left, paper_top, paper_right, paper_bottom),
        radius=radius,
        fill=PAPER_WHITE,
    )

    # Folded top-right corner: a triangle in fold color.
    fold_polygon = [
        (paper_right - fold_size, paper_top),
        (paper_right, paper_top + fold_size),
        (paper_right - fold_size, paper_top + fold_size),
    ]
    draw.polygon(fold_polygon, fill=PAPER_FOLD)
    # Subtle shadow under the fold.
    crease = [
        (paper_right - fold_size, paper_top + fold_size),
        (paper_right - fold_size, paper_top),
    ]
    draw.line(crease, fill=PAPER_SHADOW, width=max(1, size // 320))

    # Bottom band carrying the format label.
    band_height = int(size * 0.30)
    band_top = paper_bottom - band_height
    # Clip the band to the paper's rounded shape by drawing it inside, then layering a
    # rounded-rect mask via paste with mask.
    band_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    band_draw = ImageDraw.Draw(band_layer)
    band_draw.rounded_rectangle(
        (paper_left, band_top, paper_right, paper_bottom),
        radius=radius,
        fill=band_color,
    )
    # Square off the top of the band so it doesn't round into the middle of the paper.
    band_draw.rectangle(
        (paper_left, band_top, paper_right, band_top + radius),
        fill=band_color,
    )
    img.alpha_composite(band_layer)

    # Label.
    draw = ImageDraw.Draw(img)
    label_box = (paper_left, band_top, paper_right, paper_bottom)
    # Make HWPX text slightly smaller so it fits the same band width.
    label_fraction = 0.46 if label == "HWP" else 0.36
    draw_glyph_centered(
        draw,
        box=label_box,
        text=label,
        fill=GLYPH_WHITE,
        target_height_fraction=label_fraction,
    )

    return img


def write_app_icons(out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    master = render_app_icon(1024)
    for filename, target_size in APP_ICON_SIZES.items():
        if target_size == 1024:
            img = master
        else:
            img = master.resize((target_size, target_size), Image.Resampling.LANCZOS)
        # iOS marketing icon must be opaque RGB.
        img.convert("RGB").save(out_dir / filename, format="PNG", optimize=True)
        print(f"  app  {filename:24s}  {target_size:>4}px")


def write_document_icons(asset_root: Path, name: str, label: str, band_color: tuple[int, int, int, int]) -> None:
    imageset = asset_root / f"{name}.imageset"
    imageset.mkdir(parents=True, exist_ok=True)

    # Remove stale PNGs from any previous (wrong-format) generation.
    for stale in imageset.glob("*.png"):
        stale.unlink()

    master = render_document_icon(960, label, band_color)
    images = []
    for suffix, scale, pixel in DOC_ICON_SCALES:
        filename = f"{name}{suffix}"
        if pixel == 960:
            img = master
        else:
            img = master.resize((pixel, pixel), Image.Resampling.LANCZOS)
        img.save(imageset / filename, format="PNG", optimize=True)
        print(f"  doc  {name}/{filename:36s}  {pixel:>4}px  (universal {scale})")
        images.append(
            {
                "filename": filename,
                "idiom": "universal",
                "scale": scale,
            }
        )

    contents = {
        "images": images,
        "info": {"author": "xcode", "version": 1},
    }
    (imageset / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=ASSETS_ROOT,
        help="Path to Assets.xcassets (default: %(default)s)",
    )
    parser.add_argument("--app-only", action="store_true", help="Generate the app icon only.")
    parser.add_argument("--docs-only", action="store_true", help="Generate document icons only.")
    args = parser.parse_args()

    asset_root = args.output
    if not args.docs_only:
        print("Rendering app icon (Hoply lowercase 'h' on confident blue)…")
        write_app_icons(asset_root / "AppIcon.appiconset")

    if not args.app_only:
        print("Rendering HWP document icon…")
        write_document_icons(asset_root, "HWPDocumentIcon", "HWP", BRAND_BLUE)
        print("Rendering HWPX document icon…")
        write_document_icons(asset_root, "HWPXDocumentIcon", "HWPX", BRAND_TEAL)

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
