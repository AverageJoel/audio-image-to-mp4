# audio-image-to-mp4

Combine a static image (logo, cover art, etc.) with an audio file to produce an MP4 video. Useful for uploading music to YouTube or other video platforms.

---

## Beginner's Guide

No coding experience needed. Just follow the steps for your operating system.

### Windows

**Step 1 — Install ffmpeg (one time only)**

1. Click the Start menu and search for **Terminal** or **Command Prompt**, then open it
2. Paste the following and press Enter:
   ```
   winget install ffmpeg
   ```
3. Wait for it to finish, then close the window

**Step 2 — Download this tool**

1. On this GitHub page, click the green **Code** button
2. Click **Download ZIP**
3. Unzip the folder somewhere easy to find (e.g. your Desktop)

**Step 3 — Make your video**

1. Copy your image file (jpg or png) and your audio file (wav, mp3, etc.) into the unzipped folder
2. Double-click **`make_video_windows.bat`**
3. Follow the prompts — type or drag-and-drop your filenames when asked
4. Your MP4 will appear in the same folder when it's done

---

### Mac

**Step 1 — Install ffmpeg (one time only)**

1. Open **Terminal** (press Cmd+Space, type `Terminal`, press Enter)
2. Install Homebrew if you don't have it — paste this and press Enter:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Then install ffmpeg:
   ```
   brew install ffmpeg
   ```

**Step 2 — Download this tool**

1. On this GitHub page, click the green **Code** button
2. Click **Download ZIP**
3. Unzip the folder somewhere easy to find (e.g. your Desktop)

**Step 3 — Allow the script to run (first time only)**

macOS may block the script the first time. To allow it:
1. Right-click **`make_video_mac.command`** in Finder
2. Click **Open**
3. Click **Open** again in the security dialog

**Step 4 — Make your video**

1. Copy your image file and audio file into the unzipped folder
2. Double-click **`make_video_mac.command`**
3. Follow the prompts — type or drag-and-drop your filenames when asked
4. Your MP4 will appear in the same folder when it's done

---

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
