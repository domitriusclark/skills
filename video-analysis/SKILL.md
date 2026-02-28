---
name: video-analysis
description: Download and analyze videos by extracting frames. Use when the user wants to analyze a video, review footage, extract frames, or understand what happens in a video. Supports YouTube URLs and local video files.
---

# Video Analysis Skill

Analyze videos by downloading them (if remote) and extracting frames at regular intervals for visual inspection.

## Prerequisites Check

Before starting, verify that required tools are installed:

```bash
# Check for yt-dlp (video downloader)
command -v yt-dlp || echo "MISSING: yt-dlp"

# Check for ffmpeg (frame extraction)
command -v ffmpeg || echo "MISSING: ffmpeg"
```

If either is missing, install them:

```bash
# macOS (Homebrew)
brew install yt-dlp ffmpeg

# Linux (apt)
# sudo apt install ffmpeg && pip install yt-dlp

# pip fallback for yt-dlp
# pip install yt-dlp
```

Do NOT proceed until both tools are confirmed installed. If brew/pip is unavailable, inform the user and suggest installation methods for their platform.

## Workflow

### Step 1: Create a temp working directory

```bash
WORK_DIR=$(mktemp -d)
echo "Working directory: $WORK_DIR"
```

### Step 2: Download the video (if URL provided)

For YouTube or other supported URLs:

```bash
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
  --merge-output-format mp4 \
  -o "$WORK_DIR/video.mp4" \
  "VIDEO_URL"
```

For local files, just note the path — no download needed.

### Step 3: Get video duration and info

```bash
ffprobe -v quiet -print_format json -show_format -show_streams "$WORK_DIR/video.mp4" 2>/dev/null | head -50
```

Use the duration to determine a good frame extraction interval.

### Step 4: Extract frames

Extract frames at a regular interval. Adjust the rate based on video length:

| Video Length | Recommended Rate | Approx Frames |
|---|---|---|
| < 1 min | 1 frame/sec (`-r 1`) | ~60 |
| 1-5 min | 1 frame/2sec (`-r 0.5`) | ~75-150 |
| 5-15 min | 1 frame/5sec (`-r 0.2`) | ~60-180 |
| 15-60 min | 1 frame/10sec (`-r 0.1`) | ~90-360 |
| 60+ min | 1 frame/30sec (`-r 0.033`) | ~120+ |

Target roughly 60-200 frames for a good balance of coverage and manageability.

```bash
mkdir -p "$WORK_DIR/frames"
ffmpeg -i "$WORK_DIR/video.mp4" \
  -r RATE \
  -q:v 2 \
  "$WORK_DIR/frames/frame_%04d.jpg"
```

For analyzing a specific segment, use `-ss START -to END`:

```bash
ffmpeg -i "$WORK_DIR/video.mp4" \
  -ss 00:01:30 -to 00:03:00 \
  -r 1 \
  -q:v 2 \
  "$WORK_DIR/frames/frame_%04d.jpg"
```

### Step 5: Analyze frames

Use the Read tool to view extracted frame images. Claude can read image files directly (PNG, JPG).

- Start with a sampling of frames spread across the video to get an overview
- Then focus on specific sections of interest
- Reference frames by their number to map back to timestamps:
  - `frame_NNNN.jpg` → timestamp = `(NNNN - 1) / RATE` seconds

### Step 6: Clean up

After analysis is complete, remove the temp directory:

```bash
rm -rf "$WORK_DIR"
```

Always confirm with the user before cleanup in case they want to keep the frames.

## Usage Notes

- For very long videos (1hr+), consider extracting frames from specific segments rather than the entire video
- If the user wants higher quality analysis of specific moments, re-extract those segments at a higher frame rate (e.g., 2-5 fps)
- Frame images are typically 50-150KB each at quality level 2, so disk usage is manageable
- yt-dlp supports YouTube, Vimeo, Twitter/X, Twitch, and hundreds of other sites
- For private/authenticated videos, the user may need to provide cookies or auth tokens to yt-dlp
