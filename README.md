# GSC Audio Script

Michael Chon, Elliott Kim

## About
Script to take audio and run it through Audacity to normalize volumes, add a limiter, add a compressor, and then export it.

## Contents
- audacity_script.txt
- 

## Notes
- Requires FFmpeg and Audacity (utiziles Audacity's Nyquist scripts)
- If using a video instead of an audio run command to extract audio:
- ffmpeg -i input_video.mp4 -q:a 0 -map a output_audio.wav
