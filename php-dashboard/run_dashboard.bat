@echo off
cd /d "%~dp0"
echo ======================================================
echo   PlantSense AI - Admin Dashboard Server (PHP/JS)
echo ======================================================
echo.
echo Server is starting! To open in your browser on this PC, go to:
echo   --> http://localhost:8080
echo   --> http://127.0.0.1:8080
echo.
echo (IMPORTANT: Do NOT type 0.0.0.0 in Chrome! Use localhost:8080)
echo.

if exist "C:\xampp\php\php.exe" (
    echo [INFO] Using XAMPP PHP (C:\xampp\php\php.exe)...
    "C:\xampp\php\php.exe" -S localhost:8080
) else if exist "C:\php\php.exe" (
    echo [INFO] Using PHP from C:\php\php.exe...
    "C:\php\php.exe" -S localhost:8080
) else (
    echo [INFO] Using system PATH PHP...
    php -S localhost:8080
)
pause
