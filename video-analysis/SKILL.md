---
name: video-analysis
description: "Download and analyze videos by extracting frames for visual inspection. Use when the user wants to: (1) analyze or review a video, (2) understand what happens in a video, (3) extract frames or screenshots from footage, (4) compare moments across a video, (5) review gameplay footage, tutorials, or recordings. Supports YouTube, Vimeo, Twitter/X, Twitch URLs and local video files. Requires yt-dlp and ffmpeg."
---

# Video Analysis

Extract frames from a video, then read them for visual analysis.

## Prerequisites

Requires `ffmpeg` and `yt-dlp` (for URLs). Verify before starting:

```bash
command -v ffmpeg && command -v yt-dlp
```

Install if missing: `brew install yt-dlp ffmpeg`

## Extract Frames

Run the bundled script:

```bash
scripts/extract_frames.sh <url_or_path> [output_dir] [--start HH:MM:SS] [--end HH:MM:SS] [--rate N]
```

The script auto-selects an appropriate frame rate based on video duration (targeting 60-200 frames). Override with `--rate`.

| Video Length | Auto Rate | Approx Frames |
|---|---|---|
| < 1 min | 1 fps | ~60 |
| 1-5 min | 0.5 fps | ~75-150 |
| 5-15 min | 0.2 fps | ~60-180 |
| 15-60 min | 0.1 fps | ~90-360 |
| 60+ min | 0.033 fps | ~120+ |

## Analyze

Read extracted frame images with the Read tool. Strategy:

1. Sample frames spread across the video for an overview (e.g., every 10th frame)
2. Focus on sections of interest at higher density
3. Map frame number to timestamp: `frame_NNNN.jpg` → `(NNNN - 1) / rate` seconds

For long videos (60+ min), extract specific segments with `--start`/`--end` rather than the full video.

## Clean Up

Confirm with the user, then remove the output directory.
