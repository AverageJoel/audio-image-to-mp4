#!/usr/bin/env bash
# make_video_mac.command
# Double-click this file in Finder to run it.
# If macOS blocks it, right-click > Open the first time.

# Change to the folder this script lives in
cd "$(dirname "$0")"

echo "================================================"
echo "  Make Video for Mac"
echo "  Combines an image + audio file into an MP4"
echo "================================================"
echo ""

# Check ffmpeg — install automatically if missing
if ! command -v ffmpeg &>/dev/null; then
    echo "ffmpeg is not installed. Installing it now..."
    echo ""

    # Install Homebrew if needed
    if ! command -v brew &>/dev/null; then
        echo "Homebrew is not installed. Installing Homebrew first..."
        echo "(This may take a few minutes and may ask for your Mac password)"
        echo ""
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for this session (Apple Silicon = /opt/homebrew, Intel = /usr/local)
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        if ! command -v brew &>/dev/null; then
            echo ""
            echo "ERROR: Homebrew installation failed."
            echo "Please install ffmpeg manually from: https://ffmpeg.org/download.html"
            echo ""
            read -r -p "Press Enter to close..."
            exit 1
        fi
        echo ""
        echo "Homebrew installed successfully."
    fi

    echo ""
    echo "Installing ffmpeg..."
    brew install ffmpeg

    if ! command -v ffmpeg &>/dev/null; then
        echo ""
        echo "ERROR: ffmpeg installation failed."
        echo "Please install it manually from: https://ffmpeg.org/download.html"
        echo ""
        read -r -p "Press Enter to close..."
        exit 1
    fi

    echo ""
    echo "ffmpeg installed successfully!"
    echo ""
else
    echo "ffmpeg is already installed. Good to go!"
fi

# Image file
echo "Step 1 of 3: Image file"
echo "  Drag your image file (jpg, png) into this window,"
echo "  or type the full file path, then press Enter."
echo ""
read -r -p "  Image file: " IMAGE

# Strip surrounding quotes if drag-dropped from Finder
IMAGE="${IMAGE%\'}"
IMAGE="${IMAGE#\'}"
IMAGE="${IMAGE%\"}"
IMAGE="${IMAGE#\"}"
IMAGE="${IMAGE// /\\ }"
IMAGE=$(eval echo "$IMAGE")

if [[ ! -f "$IMAGE" ]]; then
    echo ""
    echo "ERROR: Could not find that file. Check the path and try again."
    echo ""
    read -r -p "Press Enter to close..."
    exit 1
fi

# Audio file
echo ""
echo "Step 2 of 3: Audio file"
echo "  Drag your audio file (wav, mp3, flac) into this window,"
echo "  or type the full file path, then press Enter."
echo ""
read -r -p "  Audio file: " AUDIO

AUDIO="${AUDIO%\'}"
AUDIO="${AUDIO#\'}"
AUDIO="${AUDIO%\"}"
AUDIO="${AUDIO#\"}"
AUDIO="${AUDIO// /\\ }"
AUDIO=$(eval echo "$AUDIO")

if [[ ! -f "$AUDIO" ]]; then
    echo ""
    echo "ERROR: Could not find that file. Check the path and try again."
    echo ""
    read -r -p "Press Enter to close..."
    exit 1
fi

# Output name
echo ""
echo "Step 3 of 3: Output file name"
echo "  What do you want to name your video?"
echo "  (just the name, no extension — e.g.: my_song)"
echo ""
read -r -p "  Output name: " OUTNAME
if [[ -z "$OUTNAME" ]]; then OUTNAME="output"; fi
OUTPUT="${OUTNAME}.mp4"

# Resolution choice
echo ""
echo "Choose a resolution:"
echo "  1. 4K  - 3840x2160  (best quality, larger file) [default]"
echo "  2. HD  - 1920x1080  (good quality, smaller file)"
echo "  3. SD  - 1280x720   (smallest file)"
echo ""
read -r -p "  Enter 1, 2, or 3 (or press Enter for 4K): " RESCHOICE

case "$RESCHOICE" in
    2) W=1920; H=1080 ;;
    3) W=1280; H=720  ;;
    *) W=3840; H=2160 ;;
esac

# Confirm overwrite
if [[ -f "$OUTPUT" ]]; then
    echo ""
    echo "WARNING: \"$OUTPUT\" already exists."
    read -r -p "  Overwrite it? Type YES to continue: " OVERWRITE
    if [[ "${OVERWRITE^^}" != "YES" ]]; then
        echo "Cancelled."
        read -r -p "Press Enter to close..."
        exit 0
    fi
fi

echo ""
echo "------------------------------------------------"
echo "  Creating your video, please wait..."
echo "  (this may take a few minutes for long songs)"
echo "------------------------------------------------"
echo ""

ffmpeg -y \
    -loop 1 \
    -i "$IMAGE" \
    -i "$AUDIO" \
    -c:v libx264 \
    -preset slow \
    -crf 18 \
    -vf "scale=${W}:${H}:force_original_aspect_ratio=decrease,pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:color=black" \
    -pix_fmt yuv420p \
    -tune stillimage \
    -r 24 \
    -c:a aac \
    -b:a 320k \
    -movflags +faststart \
    -shortest \
    "$OUTPUT"

if [[ $? -ne 0 ]]; then
    echo ""
    echo "ERROR: Something went wrong. Check the messages above for details."
    echo ""
    read -r -p "Press Enter to close..."
    exit 1
fi

echo ""
echo "================================================"
echo "  Done! Your video is ready:"
echo "  $OUTPUT"
echo "================================================"
echo ""
read -r -p "Press Enter to close..."
