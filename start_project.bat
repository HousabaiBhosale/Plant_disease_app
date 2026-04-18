@echo off
echo ==========================================
echo   PLANT DISEASE APP - STARTUP SCRIPT
echo ==========================================

echo.
echo [1/3] Enabling Connection Tunnel (ADB Reverse)...
"C:\Users\HP\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000
if %errorlevel% neq 0 (
    echo [!] WARNING: Phone not detected or ADB failed. Make sure USB Debugging is ON.
) else (
    echo [OK] Tunnel established successfully.
)

echo.
echo [2/3] Opening Backend Server in a new window...
start "Plant Disease Backend" /D "plant_disease_backend" run.bat

echo.
echo [3/3] Ready! You can now run your Flutter app.
echo.
echo TIPS:
echo - Keep the Backend window open while using the app.
echo - Use Email: admin@gmail.com
echo - Use Password: admin123
echo.
pause
