# GSC Audio Script

Michael Chon, Elliott Kim

## About
Script to take audio and run it through Audacity to normalize volumes, add a limiter, add a compressor, and then export it.

## Contents
- audacity_script.txt
> Nyquist script through Audacity to normalize volumes, add limiter, add compressor
- processor.cs
> C# script to run the process of extracting audio, running audacity_script.txt, recombining audio and video.

## Notes
- Requires FFmpeg and Audacity (utilizes Audacity's Nyquist scripts)
- If using a video instead of an audio run command to extract audio:
- ffmpeg -i input_video.mp4 -q:a 0 -map a output_audio.wav

- Nothing with API yet, no integration yet for uploading online (soley audio code so far)
