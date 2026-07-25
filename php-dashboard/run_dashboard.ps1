Write-Host "======================================================" -ForegroundColor Green
Write-Host "  PlantSense AI - Admin Dashboard Server (PHP/JS)" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Server is starting! Open in your browser at:" -ForegroundColor Cyan
Write-Host "  --> http://localhost:8080" -ForegroundColor Yellow
Write-Host "  --> http://127.0.0.1:8080" -ForegroundColor Yellow
Write-Host ""

if (Test-Path "C:\xampp\php\php.exe") {
    Write-Host "[INFO] Using XAMPP PHP (C:\xampp\php\php.exe)..." -ForegroundColor Green
    & "C:\xampp\php\php.exe" -S localhost:8080
} elseif (Test-Path "C:\php\php.exe") {
    Write-Host "[INFO] Using PHP from C:\php\php.exe..." -ForegroundColor Green
    & "C:\php\php.exe" -S localhost:8080
} else {
    Write-Host "[INFO] Using system PATH PHP..." -ForegroundColor Green
    php -S localhost:8080
}
