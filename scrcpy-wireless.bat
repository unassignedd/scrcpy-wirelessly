@echo off

echo.
echo Connect your device via USB...
pause
REM Checking if anything is connected via USB
:start
adb devices -l | find "device product:" >nul
if errorlevel 1 (
    echo.
	echo No device found connected. Retrying... & pause & goto start	
) else (
    echo.
	echo Device found. Starting connection with ip request... & goto next
)

:next
REM First killing any server to avoid multiple device/emulator error
echo.
echo Stopping any other adb server to avoid connection issues...
adb kill-server
echo.
echo Servers stopped...

:ipget
REM Run ADB command to get IP address information and filter for lines starting with "inet"
echo.
echo Obtaining Wi-Fi dynamic IPv4 address...
adb shell ip addr show wlan0 | findstr /C:"inet" > temp.txt

REM Extract IPv4 address without subnet mask- without the /xy as found in adb view
for /f "tokens=2 delims= " %%A in (temp.txt) do (
    for /f "tokens=1 delims=/" %%B in ("%%A") do (
        set ip=%%B
        goto :ipcheck
    )
)

:ipcheck
REM Check if the 'ip' variable is empty (no 'inet' output found/no IPv4 address found)
if "%ip%"=="" (
	echo.
    echo IPv4 address not found. Please check if your device is connected to a Wi-Fi network and via USB. Retrying... & pause & del temp.txt
	goto ipget
)

:ipchecked

REM Display the IP address (optional)
echo.
echo Your IPv4 address has been found: %ip%

REM Enabling adb wirelessly
echo.
echo Enabling adb over TCP/IP... 
adb tcpip 5555

REM Connecting to the tcp 
echo.
echo Connecting adb over TCP/IP...
adb connect %ip%:5555

REM Device removable at this point
echo.
echo You can disconnect your device from USB...
pause

REM Clean up the temporary text file
echo.
echo Cleaning up temporary files...
del temp.txt
echo.
echo All done. Starting scrcpy service... 
echo.

REM Starting scrcpy with console 
scrcpy -e 

REM Lower bitrate option for better visual experience
REM -s (--serial), -d (--select-usb) or -e (--select-tcpip)

REM scrcpy -e --video-bit-rate 3M --max-size 1000 --max-fps 120
REM 
