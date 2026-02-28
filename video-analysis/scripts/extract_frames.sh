#!/usr/bin/env bash
set -euo pipefail

# Extract frames from a video for visual analysis.
# Usage: extract_frames.sh <video_url_or_path> [output_dir] [--start HH:MM:SS] [--end HH:MM:SS] [--rate N]
#
# Examples:
#   extract_frames.sh https://youtube.com/watch?v=abc123
#   extract_frames.sh ./local_video.mp4 /tmp/my-frames
#   extract_frames.sh https://youtube.com/watch?v=abc123 /tmp/frames --start 00:01:30 --end 00:03:00
#   extract_frames.sh ./video.mp4 /tmp/frames --rate 0.5

# ── Dependency check ──
for cmd in ffmpeg ffprobe; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd is not installed. Install via: brew install ffmpeg" >&2
    exit 1
  fi
done

# ── Parse args ──
SOURCE="${1:?Usage: extract_frames.sh <video_url_or_path> [output_dir] [--start HH:MM:SS] [--end HH:MM:SS] [--rate N]}"
OUTPUT_DIR="${2:-$(mktemp -d)}"
START=""
END=""
RATE=""

shift 2 2>/dev/null || shift $# 2>/dev/null
while [[ $# -gt 0 ]]; do
  case "$1" in
    --start) START="$2"; shift 2 ;;
    --end)   END="$2";   shift 2 ;;
    --rate)  RATE="$2";  shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

mkdir -p "$OUTPUT_DIR/frames"

# ── Download if URL ──
if [[ "$SOURCE" =~ ^https?:// ]]; then
  if ! command -v yt-dlp &>/dev/null; then
    echo "ERROR: yt-dlp is not installed. Install via: brew install yt-dlp" >&2
    exit 1
  fi
  echo "Downloading video..."
  yt-dlp -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
    --merge-output-format mp4 \
    -o "$OUTPUT_DIR/video.mp4" \
    "$SOURCE"
  VIDEO="$OUTPUT_DIR/video.mp4"
else
  VIDEO="$SOURCE"
  if [[ ! -f "$VIDEO" ]]; then
    echo "ERROR: File not found: $VIDEO" >&2
    exit 1
  fi
fi

# ── Get duration ──
DURATION=$(ffprobe -v quiet -print_format json -show_format "$VIDEO" \
  | grep -o '"duration": "[^"]*"' | head -1 | grep -o '[0-9.]*')
echo "Video duration: ${DURATION}s"

# ── Auto-select rate if not specified ──
if [[ -z "$RATE" ]]; then
  DUR_INT=${DURATION%.*}
  if   (( DUR_INT < 60 ));   then RATE="1"
  elif (( DUR_INT < 300 ));  then RATE="0.5"
  elif (( DUR_INT < 900 ));  then RATE="0.2"
  elif (( DUR_INT < 3600 )); then RATE="0.1"
  else                            RATE="0.033"
  fi
  echo "Auto-selected rate: $RATE fps"
fi

# ── Extract frames ──
FFMPEG_ARGS=(-i "$VIDEO" -r "$RATE" -q:v 2)
[[ -n "$START" ]] && FFMPEG_ARGS+=(-ss "$START")
[[ -n "$END" ]]   && FFMPEG_ARGS+=(-to "$END")
FFMPEG_ARGS+=("$OUTPUT_DIR/frames/frame_%04d.jpg")

echo "Extracting frames..."
ffmpeg "${FFMPEG_ARGS[@]}" -loglevel warning

FRAME_COUNT=$(ls "$OUTPUT_DIR/frames/" | wc -l | tr -d ' ')
echo ""
echo "Done! Extracted $FRAME_COUNT frames"
echo "Output: $OUTPUT_DIR/frames/"
echo "Rate: $RATE fps (frame N → timestamp = (N-1) / $RATE seconds)"
