# audio-image-to-mp4

Combine a static image (logo, cover art, etc.) with an audio file to produce an MP4 video. Useful for uploading music to YouTube or other video platforms.

## Requirements

- [ffmpeg](https://ffmpeg.org/download.html) installed and available on your `PATH`
- Python 3.6+ *(for `make_video.py` only)*

## Usage

### Python (cross-platform)

```bash
python make_video.py <image> <audio> <output> [OPTIONS]
```

```bash
# Basic usage
python make_video.py logo.jpg song.wav output.mp4

# 1080p with medium quality
python make_video.py logo.png song.wav output.mp4 --resolution 1920x1080 --crf 23 --preset medium

# White background, 30fps, lower audio bitrate
python make_video.py logo.jpg song.wav output.mp4 --bg-color white --fps 30 --audio-bitrate 192k
```

### Bash (macOS / Linux / WSL)

```bash
chmod +x make_video.sh
./make_video.sh <image> <audio> <output> [OPTIONS]
```

```bash
# Basic usage
./make_video.sh logo.jpg song.wav output.mp4

# 1080p with medium quality
./make_video.sh -r 1920x1080 -q 23 -p medium logo.png song.wav output.mp4

# White background, 30fps, lower audio bitrate
./make_video.sh -c white -f 30 -b 192k logo.jpg song.wav output.mp4
```

## Options

| Python flag         | Bash flag | Default      | Description                                          |
|---------------------|-----------|--------------|------------------------------------------------------|
| `--resolution WxH`  | `-r WxH`  | `3840x2160`  | Output resolution. Image is scaled to fit with letterboxing. |
| `--crf 0-51`        | `-q 0-51` | `18`         | Video quality. Lower = better quality, larger file.  |
| `--preset PRESET`   | `-p`      | `slow`       | libx264 preset. Slower = better compression.         |
| `--bg-color COLOR`  | `-c`      | `black`      | Letterbox/padding color. Accepts names or `#rrggbb`. |
| `--fps FPS`         | `-f`      | `24`         | Output frame rate.                                   |
| `--audio-bitrate BR`| `-b`      | `320k`       | AAC audio bitrate.                                   |

### Preset options (slowest → fastest encode, best → worst compression)
`veryslow` `slower` `slow` `medium` `fast` `faster` `veryfast` `superfast` `ultrafast`

## How it works

ffmpeg loops the image as a static video stream, pads it to the target resolution while preserving its aspect ratio, then muxes it with the audio encoded as AAC. The output stops when the audio ends (`-shortest`).

## Installing ffmpeg

| Platform | Command |
|----------|---------|
| macOS    | `brew install ffmpeg` |
| Ubuntu/Debian | `sudo apt install ffmpeg` |
| Windows  | [Download from ffmpeg.org](https://ffmpeg.org/download.html) or `winget install ffmpeg` |
