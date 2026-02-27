#!/usr/bin/env bash
# make_video.sh - Combine a static image with audio to create an MP4.
#
# Requires ffmpeg to be installed and available on your PATH.
#
# Usage:
#   ./make_video.sh [OPTIONS] <image> <audio> <output>
#
# Examples:
#   ./make_video.sh logo.jpg song.wav output.mp4
#   ./make_video.sh -r 1920x1080 logo.png song.wav output.mp4
#   ./make_video.sh -q 23 -p medium logo.jpg song.wav output.mp4
#   ./make_video.sh -c white -f 30 logo.jpg song.wav output.mp4

set -euo pipefail

# Defaults
RESOLUTION="3840x2160"
CRF=18
PRESET="slow"
BG_COLOR="black"
FPS=24
AUDIO_BITRATE="320k"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <image> <audio> <output>

Combine a static image with audio to produce an MP4.
Requires ffmpeg on your PATH.

Arguments:
  image       Input image file (jpg, png, etc.)
  audio       Input audio file (wav, mp3, flac, etc.)
  output      Output MP4 file path

Options:
  -r WxH      Output resolution          (default: $RESOLUTION)
  -q 0-51     CRF quality, lower=better  (default: $CRF)
  -p PRESET   libx264 preset             (default: $PRESET)
              Choices: ultrafast superfast veryfast faster fast
                       medium slow slower veryslow
  -c COLOR    Background/padding color   (default: $BG_COLOR)
  -f FPS      Output frame rate          (default: $FPS)
  -b BITRATE  AAC audio bitrate          (default: $AUDIO_BITRATE)
  -h          Show this help

Examples:
  $(basename "$0") logo.jpg song.wav output.mp4
  $(basename "$0") -r 1920x1080 -q 23 logo.png song.wav output.mp4
  $(basename "$0") -c white -f 30 -b 192k logo.jpg song.wav output.mp4
EOF
}

# Parse options
while getopts ":r:q:p:c:f:b:h" opt; do
    case $opt in
        r) RESOLUTION="$OPTARG" ;;
        q) CRF="$OPTARG" ;;
        p) PRESET="$OPTARG" ;;
        c) BG_COLOR="$OPTARG" ;;
        f) FPS="$OPTARG" ;;
        b) AUDIO_BITRATE="$OPTARG" ;;
        h) usage; exit 0 ;;
        :) echo "Error: -$OPTARG requires an argument."; usage; exit 1 ;;
        \?) echo "Error: Unknown option -$OPTARG"; usage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Validate positional args
if [[ $# -lt 3 ]]; then
    echo "Error: Missing required arguments."
    usage
    exit 1
fi

IMAGE="$1"
AUDIO="$2"
OUTPUT="$3"

# Validate ffmpeg
if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg not found. Install it and make sure it's on your PATH."
    echo "  https://ffmpeg.org/download.html"
    exit 1
fi

# Validate input files
if [[ ! -f "$IMAGE" ]]; then
    echo "Error: image file not found: $IMAGE"
    exit 1
fi
if [[ ! -f "$AUDIO" ]]; then
    echo "Error: audio file not found: $AUDIO"
    exit 1
fi

# Confirm overwrite
if [[ -f "$OUTPUT" ]]; then
    read -r -p "Output file '$OUTPUT' already exists. Overwrite? [y/N] " answer
    if [[ "${answer,,}" != "y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Parse WxH
W="${RESOLUTION%%[xX]*}"
H="${RESOLUTION##*[xX]}"

VF="scale=${W}:${H}:force_original_aspect_ratio=decrease,pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:color=${BG_COLOR}"

echo "  Image:      $IMAGE"
echo "  Audio:      $AUDIO"
echo "  Output:     $OUTPUT"
echo "  Resolution: ${W}x${H}"
echo "  CRF:        $CRF  Preset: $PRESET"
echo "  Audio:      AAC $AUDIO_BITRATE  FPS: $FPS"
echo

ffmpeg \
    -loop 1 \
    -i "$IMAGE" \
    -i "$AUDIO" \
    -c:v libx264 \
    -preset "$PRESET" \
    -crf "$CRF" \
    -vf "$VF" \
    -pix_fmt yuv420p \
    -tune stillimage \
    -r "$FPS" \
    -c:a aac \
    -b:a "$AUDIO_BITRATE" \
    -movflags +faststart \
    -shortest \
    "$OUTPUT"

echo
echo "Done: $OUTPUT"
