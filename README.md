# Tail Concerto Undub: Assets and Devnotes

*Last update: July 2021*  
[[RHDN project page](about:blank)]

> ## Table of Contents
> 
> * [Introduction](#introduction)
> * [ROM structure](#rom-structure)
> * [Required software](#required-software)
> * [Other software](#other-software)
> * [Assets](#assets)
> * [Process and pipeline](#process-and-pipeline)
> * [Fonts etc](#fonts-etc)

## Introduction

**This document may contain spoilers for Tail Concerto.**

I write this document hoping to convey that, with just a little bit of programming knowledge, anyone can fiddle about with a game and end up with a semidecent product in the end. Every time I tried to pick this game up I was instantly put off by its cringeworthy voice acting, so I waited for years on end in the vain hope of seeing an undub get released. When I decided to try and do it myself, it only took me a couple weeks’ worth of free time. For context, I am a humanities major, and while I do like programming, I don’t consider myself above any other power user.

The main feat I managed to achieve here was restoring full stereo audio in all FMVs: while the original dub was mastered in 18.9 kHz stereo audio, the American dub decided to sacrifice the second channel to double the bitrate, mastering in 37.8 kHz mono. This means that both versions use up the same number of samples (and therefore the same filesize) to encode any given length of time, but with a terrible incompatibility: sure, one could toss the Japanese FMV soundtracks on Audacity, flatten the channels to mono and output it with an artificially doubled bitrate and it all would be ready to be injected into the North American ROM, but that would incur in a very considerable loss of quality, especially when you consider that you’d also have to do it with the opening song that uses and abuses of the stereo sound with drums alternating sides for effect. KOKIA doesn’t deserve this, and neither do us. Much trial and error was needed to arrive at a solution – one of the first things I tried was altering jPSXdec’s source code to ignore XA audio incompatibility and inject regardless of format, but that very predictably resulted in amusingly horrible distorted sound. The binaries, by the way, are in [random-tools](https://github.com/rari-teh/random-tools), in case you want to torture yourself.

Enough beating around the bush: what I found out, much to my surprise, is that if you manually copy over the entire video with the soundtrack with a hex editor, leaving out the last sector and the first 0x40 bytes, it works without a problem. That goes as a testament to the amount of fucking around and finding out that was involved in the entire process here – and yes, I know how inelegant and how big a hackjob this is and how this probably amounts to a number of war crimes in Yugoslavia for some people out there, but pragmatically, *it works*. Perhaps I should also add that every time you plaster a STR in the ROM like this, you’ll have to rebuild the index with jPSXdec, because it (also very predictably) causes a plethora of malformed headers and one-sector-long corrupted soundfiles that are simply skipped on playback, and that make the index numbers of the ROM items change in jPSXdec’s eyes. Because of (gesticulates vaguely) all of this, I found it much easier to inject the subtitles on a copy of the Japanese ROM and then copy the whole videos over to the American ROM with the hex editor; this way both subtitles and sound would go all at once into the ROM and I wouldn’t risk prodding it to the point of breaking the apparently fragile stasis.

Now that I’ve finished everything, I also suspect that I might’ve done something wrong when I tried copying the videos over with the last sector in, and if that worked that would do away with the aforementioned one-sector-long corrupted soundfiles, but honestly they are not doing any harm the way they are there and the incurring loss is, as I understand it, effectively imperceptible.

Further along this file, I describe in detail the process that turns the assets included here into a working prototype. A copy of both the Japanese and the American ROMs will be needed.

## ROM structure

The Tail Concerto ROMs have a fairly simple structure, with only five main files: `SYSTEM.CNF`, which is a file required in every PSX game; a PSX executable named after the specific version’s product code; `DATA.BIN`, which contains the bulk of the game; `XA.BIN`, which contains all voiced lines from in-game cutscenes and BGM; and `STR.BIN` (named `STRA.BIN` in the American version), which contains all FMVs. The only files relevant to us are `XA.BIN` and `STR(A).BIN`.

In `XA.BIN`, voiced lines comprise tracks 19 to 87 in the US version and 19 to 90 in the Japanese version, the remaining soundfiles being BGM. Voiced lines are mastered in 37.8 kHz mono and BGM is in delightful 37.8 kHz stereo. Each dubbed track corresponds to a cutscene, with cues being separated by a bit of silence. When playing back these lines, the game uses the precise start and finish timestamps of each cue, making a straight undub impossible without altering game code, since most Japanese lines are way longer than their English counterparts.

The video container files are best described in table form:

### `STRA.BIN` (America)

| Video | Title in Waffle’s bed               | Notes                                       |
|-------|-------------------------------------|---------------------------------------------|
| 0     | 2\. Memory of Dreams                | First FMV (Waffle gifts Alicia the pendant) |
| 1     | 3\. Prairie, Our Home               |                                             |
| 2     | 4\. Enter the Three Sisters         |                                             |
| 3     | 5\. Imprisonment of Princess Terria |                                             |
| 4     | 6\. To Prairia Castle               | Aerial view of Prairia; no spoken lines     |
| 5     | 7\. The Legend of the Iron Giant    |                                             |
| 6     | 8\. Spying on the Enemy             |                                             |
| 7     | 9\. Two Civilizations               |                                             |
| 8     | 10\. The Pendant                    | No spoken lines (Alicia holds the pendant)  |
| 9     | 11\. Resurrection of the Iron Giant |                                             |
| 10    | 12\. The Attack                     |                                             |
| 11    | 13\. A New Day                      | Game ending                                 |
| 12    | N/A                                 | Bandai intro                                |
| 13    | N/A                                 | Atlus intro                                 |
| 14    | 1\. Opening Movie                   | KOKIA’s “For little tail” M/V (intro movie) |

Since they were published by Bandai only, its Japanese and French counterpart, `STR.BIN`, does not include video 13. Because of that, the intro movie is called video 13 in their ROMs. In this document and in the assets alike, we are going to use the numbers from the American ROM, so the intro movie is video 14 for us.

## Required software

### jPSXdec

*Version used: v1.05 beta*  
[[homepage](https://github.com/m35/jpsxdec)]

This is the main hacking tool for this project. I’ve tried to use numerous programs of varying age and mojibake, but this is the only one that in the end of the day managed to do the job. It has a GUI for basic stuff and uses the CLI for advanced options. **Requires Java.**

## Other software

### ffmpeg

*Version used: 4.4-full*  
[[Windows download page](https://www.gyan.dev/ffmpeg/builds/)]

Any video editing tool that is able to bake ASS subtitles into a video stream and decompose a video into its frames will work; ffmpeg is what did the best job out of everything I tried, so it’s what I used and what I’ll use in the process description below. Versions other than the full one may not include libass (i.e. ASS support), so go for the full if you can.

### Aegisub

*Version used: 3.2.2*  
[[homepage](https://github.com/Aegisub/Aegisub)]

Subtitling tool with ASS support. Any will do.

### HxD

*Version used: 2.5.0.0*  
[[homepage](https://mh-nexus.de/en/hxd/)]

GUI hex editor with tabs. Use the 64-bit version if you can, as we’re dealing with a lot of data. In the process section I will assume you’re using it, but any hex editor with the same functions will do just as well.

> **Note**
> 
> In addition to these, I also used a video editor, an audio editor and a graphics editor, but the tasks are so mundane pretty much anything will do — a proof of that is that the video editor I used was none other than [Windows Live Movie Maker 2012](https://archive.org/details/wlsetup-all_201802).

## Assets

* **`12`**  
  All assets pertaining to my substitution of video 12 (originally Bandai intro). Included mostly for completion’s sake.
* **`13`**  
  All assets from my project’s video 13 (originally Atlus intro). Includes individual frames, soundtrack, XML for automatic injection with jPSXdec, Windows Live Movie Maker project file that generates fading and its MP4 output.
* **`ass`**  
  Subtitle files for all FMVs. Video 8 has no spoken lines.
* **`automation`**
    * **`automation\*.xml`**  
	  jPSXdec XML files for automatic frame injection.
	* **`automation\frameren.cmd`**  
	  When decomposing a video file into its individual frames, ffmpeg starts numbering at 001, while jPSXdec starts at 0. This utility will rename all numbered BMP files in the same directory to one number below. Starts working at frame 100. Keep an eye at the highest-numbered frame as it runs; when it drops one number, you know you can close it.
	* **`automation\frameren0.cmd`**  
	  Same as above, but works solely on frames starting with one trailing zero (010 to 099). Yes, I am aware this is sloppy.
	* **`automation\replaceaudio.cmd`**  
	  Run it on the jPSXdec directory to automatically substitute all sound files in the ROM for the WAV files in the directory. Starts at sound 19 (i.e. the first that corresponds to a voiced line). **You will need to change this script for it to work:** as it is, it looks for the specific name of my index file. Be aware that the index number of the sound files might change depending on how you fiddle with the BIN! Change the initial value of the %POINTER% variable if needed.
* **`transcripts`**  
  Transcriptions of the American dub of each FMV, followed by transcriptions of the French subs, usually followed by drafts of the subs in the final project. Included mostly to help possible translation projects.
* **`garfunkel.7z`**  
  Sounds of Silence. (All voiced lines, muted with Audacity.)
* **`headers.txt`**  
  The first 0x40 bytes of each STR in the North American ROM.
* **`README.md`**  
  This very document.

## Process and pipeline

First of all: while I’m going to give out command syntaxes here, I highly recommend you to read the jPSXdec documentation. It is very interesting and enlightening; these are but a small fraction of the tools it stores under its hood.

Before we start mucking about in the hex editor, we should first do all interventions in the American ROM that require us to let jPSXdec touch it directly: replacing the voiced lines. Open jPSXdec and generate index files for both the American and Japanese ROMs, saving them in the jPSXdec directory. Place the audio files in WAV format to substitute in the same directory.

> **Audio replace command syntax:**
> 
>     java -jar jpsxdec.jar -x index_file.idx -i index_number -replaceaudio input.wav

If you’re going to inject all voiced lines in one go, you can use the included `replaceaudio.cmd` script – just be sure to edit its contents to match your index file and the index number of track 19.

Now, to substituting videos. Video streams are changed on a frame-by-frame basis; to automate the process, specially-crafted XML files are used. The syntax is very simple and anyone can understand it by looking at a conforming file – I recommend you take a gander at `0.xml` –; crafting the frames list can look daunting, but it’s piece of cake. There are many different ways to do it; one way is to run `dir /b *.bmp >out.txt` on the folder the frames are at to generate a fileslist, then paste it twice on Excel (or any spreadsheet program methinks) filling in the blanks with the rest of the XML lines’ syntax. Copying over to Notepad++, you’ll just need to find/replace to delete all tab characters and then record and play back a macro that deletes the `.bmp` on the first frames column and adds a tab character on the beginning of the line. This is probably not even the most efficient way to do it, but hey, it’s easy and it works. In any case, for the subtitled FMVs, the XML files I’m providing should be just as good if you’re not going to change the subs’ timing.

If you’re going to change Bandai and Atlus’ intros, this is the time. Place `12.wav` and `13.wav` on the jPSXdec directory and run the above audio replace command, using the index numbers of the 12.0 and 13.0 audio streams. Next, copy over the frames for video 12 and `12.xml` and use the following command:

> **Video frame replace command syntax:**
> 
>     java -jar jpsxdec.jar -x index_file.idx -i index_number -replaceframes input.xml

Remove all BMP and PNG files from the jPSXdec folder and repeat the process with video 13.

For the FMVs, like I mentioned before, as we’re going to need to copy things over from the Japanese ROM with a hex editor, it’s better to edit them into the Japanese ROM to make the process more streamlined and also safer.

But first, we’ll need to get the videos to subtitle. Open the Japanese ROM with jPSXdec through the GUI. Tick the checkboxes of all videos you’re going to subtitle, click any of the videos and choose the highest quality settings on the right pane (Video format: AVI (Uncompressed RGB); Decode quality: High quality (Slower); Chroma upsampling: Lanczos3). Since they are going to be subtitled, it’s best to mark “Emulate PSX a/v sync” to ensure that the subs you write will be right on cue. Click “Apply to all Videos” and then save all selected. Rename the videos so that they don’t have [square brackets] on the filename; i recommend number.avi. Name the last one 14.avi so that you don’t mistake it with the Atlus intro in the American ROM when you’re transplanting.

After you subtitle the videos, the process of baking the subs into the video stream, injecting them into the Japanese ROM and then transplanting them into the American ROM will be the same for all of them. If you’re subbing everything, you’ll do the entire rigamarole numerous times. For video 8, which lacks subtitles of any kind, you’ll only need to transplant it on the hex editor, skipping most of the process.

Put both the video and its subtitles on ffmpeg’s directory. The command for turning them into open subtitles is as follows:

> **Subtitle burning command syntax:**
> 
>     ffmpeg -i input.avi -vf "ass=input.ass" -vcodec mjpeg -b:v 6M -acodec pcm_s16le -b:a 605k output.avi

Now, I know what you’re probably thinking: why motion JPEG if we’re working with the finest quality possible? Simple but sad: unfortunately, ffmpeg’s encoders for motion BMP and motion PNG, which would in theory be the superior formats here, are broken beyond use. BMP yields completely corrupted video streams, and PNG fuzzes the image in an odd way that is very apparent every time there is a fine line onscreen. According to the jPSXdec documentation, the PlayStation FMV format, STR, is actually based on MJPEG and most of the times yields frames that are completely identical to it, making it the best lossy choice. For the quality to hold, though, you’ll have to mind the bitrate: since, when exporting the FMVs into highest quality MJPEG, the highest it goes is a bit over 5 Mbps, exporting everything with a 6 Mbps video stream should safely produce the best image possible within these limits. As for the audio codec and bitrate, they don’t really matter, as the only thing from this video that will make its way into the ROMs are the frames.

After baking the open subs, create a subfolder to dump the frames in and use ffmpeg again:

> **Frames dumping command syntax:**
> 
>     ffmpeg -i input.avi folder\%03d.bmp

Delete by hand all frames that do not include a subtitle, as those won’t need to be injected again, lest we lose a bit of image quality.

As previously mentioned, these frames will be numbered starting from 001, while jPSXdec numbers frames starting from 0. To align the numbers from the filenames with the corresponding frames, use `frameren.cmd` and `frameren0.cmd` to knock them down one number: take note of the highest-numbered file in the folder and only close the window when it goes one number down. If you’re going to need to replace frames 0 to 8 (files 001.bmp to 009.bmp as output by ffmpeg), don’t forget to rename them manually! Also don’t forget to rename 09.bmp into 009.bmp and 99.bmp into 099.bmp if needed :)

Copy the frames over to jPSXdec’s directory and then do the entire frame injecting process as I described above with videos 12 and 13, crafting the XML file and running the command. Just remember that this time you’re using the Japanese ROM’s index, not the American one!

The last step is to transplant the videos, sound and all, to the US ROM. Open both the American and Japanese ROMs on HxD and both their indices on jPSXdec. Expand all of the Japanese video files to also show their soundtracks as a file on jPSXdec. On a calculator, multiply the number of the first sector of the video by 2352 (number of bytes per sector in the ROM). Check whether the video or its corresponding soundtrack has a higher last sector; whatever it is, also multiply it by 2352. Back on HxD, use the Select Block tool (Ctrl+E) to select the entire video file: choose “dec” as we’re dealing with decimals and use the numbers you just multiplied as the start-offset and end-offset. Go to the jPSXdec window that has the American ROM, look at the first sector of its corresponding video and multiply it by 2352. Head over to the HxD tab that has the American ROM and use the Go to tool (Ctrl+G) to go to the start of the video file, selecting “dec” for decimal and using the number you just multiplied. Copy the first 0x40 bytes – that’s four rows of 16 bytes – after the position you just skipped to and paste it on Notepad (or, alternatively, use the `headers.txt` file included here). Then, go back to the tab with the Japanese ROM where the entire video is selected, copy it with Ctrl+C and take note of the selection length, visible on the “Length(h)” field on the bottom of the window. Go back to the American ROM’s tab one final time and use the Select Block tool (Ctrl+E) again, this time in “hex” for hexadecimal. Input the length you just took note of, and when the entire block is selected, finally press Ctrl+V to transplant the whole block. **If you get a message saying that the operation changes the filesize, you did something wrong and should start over from the beginning of this paragraph.** Use the Go to tool again to jump back to the beginning of the block you just transplanted, select the first 0x40 bytes again and paste over the original bytes you copied to Notepad. Click save and you’re done! Just **don’t forget to keep lots of backups**, as one false move in HxD and the entire ROM you’ve been working on for so long is dead beyond repair!

That should be it! If you have any questions, comments, or just want to talk about anything in particular, send me a PM on the Romhacking.net forums or email me at the address I included in the undub’s release notes! I did my best to try and explain the process with words, but that was about as tricky as it was to come up with it :)

## Fonts etc

As ASS subtitles include font metadata, all provided subtitles require Arial and Arial Italic. The Japanese/English subs for video 14 (intro/music video) also require Yu Gothic UI. All these fonts are included by default in Windows 10 as far as I know.

The font I used in the 12 and 13 intros is [Fairfax HD](http://www.kreativekorp.com/software/fonts/fairfaxhd.shtml) by KreativeKorp/Rebecca Bettencourt. The soundtrack is Nokia’s chiptune rendition of Ya Tareshy by Eidha Al-Menhali because yes.