@echo off
REM ----------------------------
REM GitHub-ready batch for Foggy Video Factory
REM ----------------------------

REM Step 1 — Ensure output folder exists
if not exist output (
    mkdir output
)

REM Step 2 — Pick random image from foggy folder
setlocal enabledelayedexpansion
set /a count=0
for %%i in (foggy\*.*) do (
    set /a count+=1
    set file!count!=%%i
)

if %count%==0 (
    echo No images found in foggy/ folder!
    exit /b 1
)

set /a rnd=%random% %% count + 1
set IMAGE=!file%rnd%!

echo Selected image: %IMAGE%

REM Step 3 — Pick random audio from pixabaysongs folder
set /a count=0
for %%i in (pixabaysongs\*.*) do (
    set /a count+=1
    set audio!count!=%%i
)

if %count%==0 (
    echo No audio found in pixabaysongs/ folder!
    exit /b 1
)

set /a rnd=%random% %% count + 1
set AUDIO=!audio%rnd%!

echo Selected audio: %AUDIO%

REM Step 4 — Generate a random duration (between 30s and 60s)
set /a duration=%random% %% 31 + 30
echo Video duration: %duration% seconds

REM Step 5 — Build the video with FFmpeg
REM Output file is always in output/ folder
set OUTPUT_FILE=output\video_%RANDOM%.mp4

ffmpeg -loop 1 -i "%IMAGE%" -i "%AUDIO%" -c:v libx264 -t %duration% -pix_fmt yuv420p -c:a aac "%OUTPUT_FILE%"

if %errorlevel% neq 0 (
    echo FFmpeg failed!
    exit /b 1
)

echo Video created successfully: %OUTPUT_FILE%
pause
