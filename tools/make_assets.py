#!/usr/bin/env python3
"""Generate a real-content payload for the Polisite ISO (200 MB demo).

Produces a tar containing:
  - splash.rgb : a real, deterministic RGB gradient image (viewable, not padding)
  - the project's own DESIGN.md / ROADMAP.md / README.md / LICENSE (real docs)
Target size is ISO_MB (default 190 MiB) so the ISO is ~200 MB with the
kernel and bootloader.
"""
import os, sys, tarfile
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ISO_MB = int(os.environ.get("ISO_MB", "190"))

def make_splash(path: str, target_bytes: int) -> int:
    width = 4096
    row_bytes = width * 3
    height = max(1, target_bytes // row_bytes)
    with open(path, "wb") as f:
        for y in range(height):
            t = y / max(1, height - 1)
            r = int(20 + 215 * t)
            b = int(235 - 200 * t)
            g = int(40 + 90 * (0.5 + 0.5 * (1 - abs(2 * t - 1))))
            row = bytes([r, g, b]) * width
            f.write(row)
    return height * row_bytes

def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPO_ROOT, "build", "output", "assets")
    iso_mb = int(sys.argv[2]) if len(sys.argv) > 2 else ISO_MB
    os.makedirs(out_dir, exist_ok=True)
    splash = os.path.join(out_dir, "splash.rgb")
    splash_size = make_splash(splash, iso_mb * 1024 * 1024 - 512 * 1024)
    tar_path = os.path.join(out_dir, "polisite-assets.tar")
    docs = ["docs/DESIGN.md", "docs/ROADMAP.md", "README.md", "LICENSE"]
    with tarfile.open(tar_path, "w") as tar:
        tar.add(splash, arcname="splash.rgb")
        for d in docs:
            p = os.path.join(REPO_ROOT, d)
            if os.path.exists(p):
                tar.add(p, arcname=os.path.basename(d))
    print(f"assets: splash {splash_size:,} B, tar {os.path.getsize(tar_path):,} B ({os.path.getsize(tar_path)/1024/1024:.1f} MiB)")

if __name__ == "__main__":
    main()
