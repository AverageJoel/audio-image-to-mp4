@echo off
setlocal enabledelayedexpansion
title Make Video - Windows

echo ================================================
echo   Make Video for Windows
echo   Combines an image + audio file into an MP4
echo ================================================
echo.

:: Check ffmpeg — install automatically if missing
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo ffmpeg is not installed. Installing it now...
    echo.

    where winget >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Could not auto-install ffmpeg.
        echo Please download it manually from: https://ffmpeg.org/download.html
        echo.
        pause
        exit /b 1
    )

    echo Installing ffmpeg. This may take a minute...
    echo.
    winget install --id Gyan.FFmpeg -e --accept-package-agreements --accept-source-agreements
    if errorlevel 1 (
        echo.
        echo ERROR: Installation failed.
        echo Please download ffmpeg manually from: https://ffmpeg.org/download.html
        echo.
        pause
        exit /b 1
    )

    echo.
    echo ffmpeg installed! Relaunching...
    timeout /t 2 /nobreak >nul
    start "" "%~f0"
    exit
)
echo ffmpeg is already installed. Good to go!

:: Image file
echo Step 1 of 3: Image file
echo   Drag your image file ^(jpg, png^) into this window,
echo   or type the full file path, then press Enter.
echo.
set /p IMAGE="  Image file: "

:: Strip surrounding quotes if drag-dropped
set IMAGE=%IMAGE:"=%

if not exist "%IMAGE%" (
    echo.
    echo ERROR: Could not find that file. Check the path and try again.
    echo.
    pause
    exit /b 1
)

echo.
echo Step 2 of 3: Audio file
echo   Drag your audio file ^(wav, mp3, flac^) into this window,
echo   or type the full file path, then press Enter.
echo.
set /p AUDIO="  Audio file: "
set AUDIO=%AUDIO:"=%

if not exist "%AUDIO%" (
    echo.
    echo ERROR: Could not find that file. Check the path and try again.
    echo.
    pause
    exit /b 1
)

echo.
echo Step 3 of 3: Output file name
echo   What do you want to name your video?
echo   ^(just the name, no extension — e.g.: my_song^)
echo.
set /p OUTNAME="  Output name: "
if "%OUTNAME%"=="" set OUTNAME=output
set OUTPUT=%OUTNAME%.mp4

:: Resolution choice
echo.
echo Choose a resolution:
echo   1. 4K  - 3840x2160  ^(best quality, larger file^) [default]
echo   2. HD  - 1920x1080  ^(good quality, smaller file^)
echo   3. SD  - 1280x720   ^(smallest file^)
echo.
set /p RESCHOICE="  Enter 1, 2, or 3 (or press Enter for 4K): "

if "%RESCHOICE%"=="2" (
    set W=1920
    set H=1080
) else if "%RESCHOICE%"=="3" (
    set W=1280
    set H=720
) else (
    set W=3840
    set H=2160
)

:: Confirm overwrite
if exist "%OUTPUT%" (
    echo.
    echo WARNING: "%OUTPUT%" already exists.
    set /p OVERWRITE="  Overwrite it? Type YES to continue: "
    if /i not "!OVERWRITE!"=="YES" (
        echo Cancelled.
        pause
        exit /b 0
    )
)

echo.
echo ------------------------------------------------
echo   Creating your video, please wait...
echo   ^(this may take a few minutes for long songs^)
echo ------------------------------------------------
echo.

ffmpeg -y -loop 1 -i "%IMAGE%" -i "%AUDIO%" -c:v libx264 -preset slow -crf 18 -vf "scale=%W%:%H%:force_original_aspect_ratio=decrease,pad=%W%:%H%:(ow-iw)/2:(oh-ih)/2:color=black" -pix_fmt yuv420p -tune stillimage -r 24 -c:a aac -b:a 320k -movflags +faststart -shortest "%OUTPUT%"

if errorlevel 1 (
    echo.
    echo ERROR: Something went wrong. Check the messages above for details.
    echo.
    pause
    exit /b 1
)

echo.
echo ================================================
echo   Done! Your video is ready:
echo   %OUTPUT%
echo ================================================
echo.
pause
