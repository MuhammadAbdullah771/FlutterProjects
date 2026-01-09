#!/usr/bin/env python3
"""
Script to generate app icon PNG files from SVG
Requires: pip install cairosvg pillow
"""

import os
from pathlib import Path

try:
    import cairosvg
    from PIL import Image
except ImportError:
    print("Please install required packages:")
    print("pip install cairosvg pillow")
    exit(1)

# Icon sizes for Android
SIZES = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
}

def generate_icon_from_svg(svg_path, output_path, size):
    """Generate PNG icon from SVG"""
    png_data = cairosvg.svg2png(url=svg_path, output_width=size, output_height=size)
    
    # Save PNG
    with open(output_path, 'wb') as f:
        f.write(png_data)
    
    print(f"Generated: {output_path} ({size}x{size})")

def main():
    # Create assets/icon directory if it doesn't exist
    assets_dir = Path('assets/icon')
    assets_dir.mkdir(parents=True, exist_ok=True)
    
    # Check if SVG exists
    svg_path = assets_dir / 'icon.svg'
    if not svg_path.exists():
        print(f"Error: {svg_path} not found!")
        return
    
    # Generate icons for each density
    android_res = Path('android/app/src/main/res')
    
    for density, size in SIZES.items():
        mipmap_dir = android_res / f'mipmap-{density}'
        mipmap_dir.mkdir(parents=True, exist_ok=True)
        
        output_path = mipmap_dir / 'ic_launcher.png'
        generate_icon_from_svg(str(svg_path), str(output_path), size)
    
    # Generate 512x512 for Play Store
    play_store_path = assets_dir / 'icon_512.png'
    generate_icon_from_svg(str(svg_path), str(play_store_path), 512)
    
    print("\n✅ All icons generated successfully!")
    print(f"Play Store icon: {play_store_path}")

if __name__ == '__main__':
    main()

