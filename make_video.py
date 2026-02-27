#!/usr/bin/env python3
"""
make_video.py - Combine a static image with an audio file to create an MP4.

Requires ffmpeg to be installed and available on your PATH.

Usage:
    python make_video.py logo.jpg audio.wav output.mp4
    python make_video.py logo.png audio.wav output.mp4 --resolution 1920x1080 --crf 23
"""

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path


def check_ffmpeg():
    if shutil.which("ffmpeg") is None:
        print("Error: ffmpeg not found. Install it and make sure it's on your PATH.")
        print("  https://ffmpeg.org/download.html")
        sys.exit(1)


def parse_resolution(value):
    match = re.fullmatch(r"(\d+)[xX](\d+)", value)
    if not match:
        raise argparse.ArgumentTypeError(
            f"Invalid resolution '{value}'. Use WxH format, e.g. 1920x1080"
        )
    return int(match.group(1)), int(match.group(2))


def parse_args():
    parser = argparse.ArgumentParser(
        description="Combine a static image with audio to create an MP4.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python make_video.py logo.jpg song.wav output.mp4
  python make_video.py logo.png song.wav output.mp4 --resolution 1920x1080
  python make_video.py logo.jpg song.wav output.mp4 --crf 23 --preset medium
  python make_video.py logo.jpg song.wav output.mp4 --bg-color white --fps 30
        """,
    )

    parser.add_argument("image", type=Path, help="Input image file (jpg, png, etc.)")
    parser.add_argument("audio", type=Path, help="Input audio file (wav, mp3, flac, etc.)")
    parser.add_argument("output", type=Path, help="Output MP4 file path")

    parser.add_argument(
        "--resolution",
        type=parse_resolution,
        default=(3840, 2160),
        metavar="WxH",
        help="Output resolution (default: 3840x2160)",
    )
    parser.add_argument(
        "--crf",
        type=int,
        default=18,
        choices=range(0, 52),
        metavar="0-51",
        help="Video quality: lower = better, larger file (default: 18)",
    )
    parser.add_argument(
        "--preset",
        default="slow",
        choices=["ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow"],
        help="libx264 encoding preset (default: slow)",
    )
    parser.add_argument(
        "--bg-color",
        default="black",
        metavar="COLOR",
        help="Background/padding color (default: black). Accepts color names or hex #rrggbb.",
    )
    parser.add_argument(
        "--fps",
        type=int,
        default=24,
        metavar="FPS",
        help="Output frame rate (default: 24)",
    )
    parser.add_argument(
        "--audio-bitrate",
        default="320k",
        metavar="BITRATE",
        help="AAC audio bitrate (default: 320k)",
    )

    return parser.parse_args()


def build_ffmpeg_command(args):
    w, h = args.resolution
    bg = args.bg_color

    vf = (
        f"scale={w}:{h}:force_original_aspect_ratio=decrease,"
        f"pad={w}:{h}:(ow-iw)/2:(oh-ih)/2:color={bg}"
    )

    return [
        "ffmpeg",
        "-loop", "1",
        "-i", str(args.image),
        "-i", str(args.audio),
        "-c:v", "libx264",
        "-preset", args.preset,
        "-crf", str(args.crf),
        "-vf", vf,
        "-pix_fmt", "yuv420p",
        "-tune", "stillimage",
        "-r", str(args.fps),
        "-c:a", "aac",
        "-b:a", args.audio_bitrate,
        "-movflags", "+faststart",
        "-shortest",
        str(args.output),
    ]


def main():
    check_ffmpeg()
    args = parse_args()

    if not args.image.exists():
        print(f"Error: image file not found: {args.image}")
        sys.exit(1)
    if not args.audio.exists():
        print(f"Error: audio file not found: {args.audio}")
        sys.exit(1)

    if args.output.exists():
        answer = input(f"Output file '{args.output}' already exists. Overwrite? [y/N] ")
        if answer.strip().lower() != "y":
            print("Aborted.")
            sys.exit(0)

    w, h = args.resolution
    print(f"  Image:      {args.image}")
    print(f"  Audio:      {args.audio}")
    print(f"  Output:     {args.output}")
    print(f"  Resolution: {w}x{h}")
    print(f"  CRF:        {args.crf}  Preset: {args.preset}")
    print(f"  Audio:      AAC {args.audio_bitrate}  FPS: {args.fps}")
    print()

    cmd = build_ffmpeg_command(args)
    result = subprocess.run(cmd)

    if result.returncode == 0:
        print(f"\nDone: {args.output}")
    else:
        print(f"\nffmpeg exited with code {result.returncode}")
        sys.exit(result.returncode)


if __name__ == "__main__":
    main()
