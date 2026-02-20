@echo off
setlocal EnableDelayedExpansion
title Foggy Calm 1080p Video Builder — RANDOM AUDIO + RANDOM LENGTH

REM ===============================
REM PATHS
REM ===============================
set "DESKTOP=%USERPROFILE%\Desktop"
set "FFMPEG=%DESKTOP%\ffmpeg.exe"
set "IMAGES_FOLDER=%DESKTOP%\foggy"
set "AUDIO_FOLDER=%DESKTOP%\pixabaysongs"
set "OUTPUT_FOLDER=F:\foggyput"

REM ===============================
REM VIDEO SETTINGS
REM ===============================
set "WIDTH=1920"
set "HEIGHT=1080"

REM ===============================
REM SAFETY CHECKS
REM ===============================
if not exist "%FFMPEG%" (
    echo ❌ ffmpeg.exe not found on Desktop
    pause
    exit /b
)

if not exist "%IMAGES_FOLDER%" (
    echo ❌ Images folder not found: %IMAGES_FOLDER%
    pause
    exit /b
)

if not exist "%AUDIO_FOLDER%" (
    echo ❌ Audio folder not found: %AUDIO_FOLDER%
    pause
    exit /b
)

if not exist "%OUTPUT_FOLDER%" mkdir "%OUTPUT_FOLDER%"

REM Check if 3 audio files exist
for %%A in (1 2 3) do (
    if not exist "%AUDIO_FOLDER%\%%A.mp3" (
        echo ❌ Missing audio file: %%A.mp3
        pause
        exit /b
    )
)

REM ===============================
REM PROCESS EACH IMAGE
REM ===============================
for %%I in ("%IMAGES_FOLDER%\*.jpg") do (

    REM Random duration: 1h47m, 2h41m, or 3h
    set /a RAND_DUR=%RANDOM% %% 3

    if !RAND_DUR! EQU 0 (
        set "DURATION=6420"
        set "DUR_LABEL=1h47m"
    )

    if !RAND_DUR! EQU 1 (
        set "DURATION=9660"
        set "DUR_LABEL=2h41m"
    )

    if !RAND_DUR! EQU 2 (
        set "DURATION=10800"
        set "DUR_LABEL=3h"
    )

    REM Random audio order (1–6 combos)
    set /a RAND=%RANDOM% %% 6
    if !RAND! EQU 0 set "A1=1" & set "A2=2" & set "A3=3"
    if !RAND! EQU 1 set "A1=1" & set "A2=3" & set "A3=2"
    if !RAND! EQU 2 set "A1=2" & set "A2=1" & set "A3=3"
    if !RAND! EQU 3 set "A1=2" & set "A2=3" & set "A3=1"
    if !RAND! EQU 4 set "A1=3" & set "A2=1" & set "A3=2"
    if !RAND! EQU 5 set "A1=3" & set "A2=2" & set "A3=1"

    set "FILENAME=%%~nI"
    set "OUTPUT_FILE=%OUTPUT_FOLDER%\!FILENAME!_1080p_!DUR_LABEL!.mp4"

    echo =====================================
    echo Image: !FILENAME!
    echo Duration: !DUR_LABEL!
    echo Audio Order: !A1! !A2! !A3!
    echo =====================================

    "%FFMPEG%" -y ^
     -loop 1 -i "%%I" ^
     -stream_loop -1 -i "%AUDIO_FOLDER%\!A1!.mp3" ^
     -stream_loop -1 -i "%AUDIO_FOLDER%\!A2!.mp3" ^
     -stream_loop -1 -i "%AUDIO_FOLDER%\!A3!.mp3" ^
     -filter_complex "[1:a][2:a][3:a]concat=n=3:v=0:a=1[aout];[0:v]scale=%WIDTH%:%HEIGHT%,format=yuv420p[vout]" ^
     -map "[vout]" -map "[aout]" ^
     -c:v libx264 -preset veryfast -crf 18 ^
     -pix_fmt yuv420p ^
     -c:a aac -b:a 192k ^
     -t !DURATION! ^
     "!OUTPUT_FILE!"

    if exist "!OUTPUT_FILE!" (
        echo ✔ DONE: !OUTPUT_FILE!
    ) else (
        echo ❌ FAILED: !OUTPUT_FILE!
    )

    echo.
)

echo ===============================
echo 🎉 ALL IMAGES PROCESSED
echo ===============================
pause
exit /b
