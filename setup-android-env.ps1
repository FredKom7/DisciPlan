# DisciPlan Android Environment Setup Script
# This script sets up the required environment variables for Android development

Write-Host "Setting up Android development environment..." -ForegroundColor Green

# Set JAVA_HOME
$javaHome = "C:\Program Files\Android\Android Studio\jbr"
$gradleHome = "C:\gradle-home"

# Check if Java exists
if (Test-Path "$javaHome\bin\java.exe") {
    Write-Host "✓ Found Java at: $javaHome" -ForegroundColor Green
    
    # Set environment variables for current session
    $env:JAVA_HOME = $javaHome
    $env:GRADLE_USER_HOME = $gradleHome
    $env:PATH = "$javaHome\bin;$env:PATH"
    
    Write-Host "✓ Environment variables set for current session" -ForegroundColor Green
    Write-Host ""
    Write-Host "JAVA_HOME = $env:JAVA_HOME" -ForegroundColor Cyan
    Write-Host "GRADLE_USER_HOME = $env:GRADLE_USER_HOME" -ForegroundColor Cyan
    Write-Host ""
    
    # Test Java
    Write-Host "Testing Java installation..." -ForegroundColor Yellow
    java -version
    
    Write-Host ""
    Write-Host "✓ Setup complete! You can now run:" -ForegroundColor Green
    Write-Host "  flutter emulators --launch Pixel_6" -ForegroundColor Cyan
    Write-Host "  flutter run" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Note: These variables are only set for this PowerShell session." -ForegroundColor Yellow
    Write-Host "To make them permanent, follow the instructions in the walkthrough.md" -ForegroundColor Yellow
    
} else {
    Write-Host "✗ Java not found at: $javaHome" -ForegroundColor Red
    Write-Host "Please check your Android Studio installation." -ForegroundColor Red
}
