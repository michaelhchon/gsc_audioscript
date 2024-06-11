using System;
using System.Diagnostics;
using System.IO;

class Program
{
    static void Main(string[] args)
    {
        string inputVideo = "input_video.mp4";
        string audioFile = "output_audio.wav";
        string processedAudio = "processed_audio.wav";
        string outputVideo = "output_video.mp4";

        // Step 1: Extract audio from video
        ExtractAudio(inputVideo, audioFile);

        // Step 2: Process audio with Audacity
        ProcessAudio(audioFile, processedAudio);

        // Step 3: Combine processed audio with the original video
        CombineAudioWithVideo(inputVideo, processedAudio, outputVideo);

        Console.WriteLine("Processing complete!");
    }

    static void ExtractAudio(string inputVideo, string audioFile)
    {
        var ffmpeg = new ProcessStartInfo
        {
            FileName = "ffmpeg",
            Arguments = $"-i \"{inputVideo}\" -q:a 0 -map a \"{audioFile}\"",
            RedirectStandardOutput = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        using (var process = Process.Start(ffmpeg))
        {
            process.WaitForExit();
        }

        Console.WriteLine("Extracted Audio...");
    }

    static void ProcessAudio(string inputAudio, string outputAudio)
    {
        // Ensure Audacity is closed before starting a new instance
        foreach (var process in Process.GetProcessesByName("audacity"))
        {
            process.Kill();
        }

        var audacityScriptPath = Path.Combine(Directory.GetCurrentDirectory(), "audacity_script.txt");

        var audacity = new ProcessStartInfo
        {
            FileName = "audacity",
            Arguments = $"--batch --load-project \"{inputAudio}\" --apply-chain \"{audacityScriptPath}\" --export \"{outputAudio}\"",
            RedirectStandardOutput = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        using (var process = Process.Start(audacity))
        {
            process.WaitForExit();
        }

        Console.WriteLine("Processed Audio...");
    }

    static void CombineAudioWithVideo(string inputVideo, string processedAudio, string outputVideo)
    {
        var ffmpeg = new ProcessStartInfo
        {
            FileName = "ffmpeg",
            Arguments = $"-i \"{inputVideo}\" -i \"{processedAudio}\" -c:v copy -map 0:v:0 -map 1:a:0 \"{outputVideo}\"",
            RedirectStandardOutput = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        using (var process = Process.Start(ffmpeg))
        {
            process.WaitForExit();
        }

        Console.WriteLine("Recombined Aduio with Video...");
    }
}
