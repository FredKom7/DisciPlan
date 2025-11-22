# Flutter PATH Fix Script for Windows
# Run this script in PowerShell (you may need to run as Administrator)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter PATH Configuration Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Find Flutter installation
Write-Host "Step 1: Searching for Flutter installation..." -ForegroundColor Yellow

# Common installation locations
$possiblePaths = @(
    "C:\src\flutter",
    "C:\flutter",
    "C:\Development\flutter",
    "C:\Tools\flutter",
    "$env:USERPROFILE\flutter",
    "$env:USERPROFILE\Downloads\flutter"
)

$flutterPath = $null
foreach ($path in $possiblePaths) {
    if (Test-Path "$path\bin\flutter.bat") {
        $flutterPath = $path
        Write-Host "Found Flutter at: $flutterPath" -ForegroundColor Green
        break
    }
}

if (-not $flutterPath) {
    Write-Host "Flutter not found in common locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please enter the full path where you extracted Flutter:" -ForegroundColor Yellow
    Write-Host "Example: C:\src\flutter" -ForegroundColor Gray
    $flutterPath = Read-Host "Flutter path"
    
    if (-not (Test-Path "$flutterPath\bin\flutter.bat")) {
        Write-Host "Error: flutter.bat not found at $flutterPath\bin\flutter.bat" -ForegroundColor Red
        Write-Host "Please verify the path and try again." -ForegroundColor Red
        pause
        exit
    }
}

$flutterBinPath = "$flutterPath\bin"

# Step 2: Check if already in PATH
Write-Host ""
Write-Host "Step 2: Checking current PATH..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -like "*$flutterBinPath*") {
    Write-Host "Flutter is already in your PATH!" -ForegroundColor Green
    Write-Host "If it's still not working, try:" -ForegroundColor Yellow
    Write-Host "  1. Close and reopen your terminal" -ForegroundColor Gray
    Write-Host "  2. Restart your computer" -ForegroundColor Gray
} else {
    Write-Host "Flutter is NOT in your PATH. Adding it now..." -ForegroundColor Yellow
    
    # Add to User PATH
    try {
        $newPath = $currentPath + ";$flutterBinPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Successfully added Flutter to PATH!" -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANT: You must close and reopen your terminal for changes to take effect!" -ForegroundColor Cyan
        Write-Host ""
        
        # Update current session PATH temporarily
        $env:Path += ";$flutterBinPath"
        Write-Host "Temporarily added to current session. Testing..." -ForegroundColor Yellow
        
        # Test Flutter
        try {
            $flutterVersion = & "$flutterBinPath\flutter.bat" --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Flutter is working!" -ForegroundColor Green
                Write-Host $flutterVersion
            }
        } catch {
            Write-Host "Could not test Flutter in current session, but it's added to PATH." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error adding to PATH. You may need to run this script as Administrator." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. CLOSE this terminal window" -ForegroundColor Yellow
Write-Host "2. Open a NEW Command Prompt or PowerShell window" -ForegroundColor Yellow
Write-Host "3. Run: flutter --version" -ForegroundColor Yellow
Write-Host "4. If it works, run: flutter doctor" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
pause


