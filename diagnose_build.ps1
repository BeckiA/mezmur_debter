# Diagnostic script for Windows build issues
Write-Host "=== Flutter Build Diagnostics ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Checking Flutter installation..." -ForegroundColor Yellow
flutter --version
Write-Host ""

Write-Host "2. Checking Flutter doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

Write-Host "3. Checking if tool_backend.bat exists..." -ForegroundColor Yellow
$flutterRoot = flutter --version | Select-String -Pattern "Flutter" | ForEach-Object { $_.Line -replace '.*Flutter (.*) .*', '$1' }
$toolBackend = "$env:FLUTTER_ROOT\packages\flutter_tools\bin\tool_backend.bat"
if (Test-Path $toolBackend) {
    Write-Host "Found: $toolBackend" -ForegroundColor Green
} else {
    Write-Host "NOT FOUND: $toolBackend" -ForegroundColor Red
    Write-Host "FLUTTER_ROOT: $env:FLUTTER_ROOT" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "4. Testing tool_backend.bat directly..." -ForegroundColor Yellow
if (Test-Path $toolBackend) {
    & $toolBackend windows-x64 Release 2>&1 | Select-Object -First 10
}
Write-Host ""

Write-Host "5. Checking build directory..." -ForegroundColor Yellow
if (Test-Path "build\windows\x64") {
    Write-Host "Build directory exists" -ForegroundColor Green
    Get-ChildItem "build\windows\x64" -Directory | Select-Object Name
} else {
    Write-Host "Build directory does not exist" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== End Diagnostics ===" -ForegroundColor Cyan

