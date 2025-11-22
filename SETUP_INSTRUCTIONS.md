# Flutter Installation & Setup Guide for Windows

## Step 1: Install Flutter

### Option A: Using Winget (Recommended - Easiest)

1. Open **PowerShell as Administrator** (Right-click PowerShell → Run as Administrator)
2. Run this command:
   ```powershell
   winget install -e --id Flutter.Flutter
   ```
3. Wait for the installation to complete
4. **Close and reopen** your Command Prompt/PowerShell window
5. Verify installation:
   ```powershell
   flutter --version
   ```

### Option B: Manual Installation

1. Download Flutter SDK:
   - Go to: https://docs.flutter.dev/release/windows
   - Download the latest stable release ZIP file
   - Extract it to `C:\src\flutter` (avoid OneDrive paths like your Desktop)

2. Add Flutter to PATH:

   **Method 1: Using PowerShell (Easiest)**
   
   Open PowerShell and run (replace `C:\src\flutter` with your actual Flutter path):
   ```powershell
   # Replace with your actual Flutter installation path
   $flutterPath = "C:\src\flutter"
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$flutterPath\bin", "User")
   ```
   
   **OR use the automated script:**
   ```powershell
   # Navigate to your project folder
   cd "C:\Users\Freddy Kom\OneDrive\Desktop\DisciPlan"
   # Run the fix script
   .\fix_flutter_path.ps1
   ```
   
   **Method 2: Using GUI**
   - Press `Win + R`, type `sysdm.cpl`, press Enter
   - Click "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\src\flutter\bin` (replace with your actual path)
   - Click OK on all dialogs

3. **CRITICAL: Close and reopen** your Command Prompt/PowerShell completely
   - The PATH changes only take effect in NEW terminal windows
   - Close ALL terminal/command prompt windows
   - Open a fresh Command Prompt or PowerShell

4. Verify installation:
   ```powershell
   flutter --version
   ```

## Step 2: Run Flutter Doctor

After Flutter is installed, check your setup:

```powershell
flutter doctor
```

This will show you what else needs to be installed (like Android Studio for Android development).

## Step 3: Install Dependencies

Once Flutter is working, navigate to your project and get dependencies:

```powershell
cd "C:\Users\Freddy Kom\OneDrive\Desktop\DisciPlan\disciplan"
flutter pub get
```

## Step 4: Run the Project

### For Windows Desktop:
```powershell
flutter config --enable-windows-desktop
flutter run -d windows
```

### For Web:
```powershell
flutter config --enable-web
flutter run -d chrome
```

### For Android:
1. Install Android Studio first
2. Set up an Android emulator or connect a physical device
3. Run:
   ```powershell
   flutter run
   ```

## Troubleshooting

### Flutter command not recognized after extraction:

1. **Verify Flutter installation location:**
   - Check that you have `flutter\bin\flutter.bat` file
   - Common locations: `C:\src\flutter`, `C:\flutter`, or where you extracted it

2. **Add Flutter to PATH using PowerShell:**
   ```powershell
   # Find where you extracted Flutter, then run:
   $flutterPath = "C:\src\flutter"  # CHANGE THIS to your actual path
   $flutterBinPath = "$flutterPath\bin"
   
   # Verify flutter.bat exists
   Test-Path "$flutterBinPath\flutter.bat"
   
   # Add to PATH
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$flutterBinPath", "User")
   ```

3. **CLOSE and REOPEN your terminal:**
   - Close ALL Command Prompt/PowerShell windows
   - Open a NEW terminal window
   - Try `flutter --version` again

4. **If still not working:**
   - Restart your computer (ensures PATH is fully reloaded)
   - Verify the path is correct: Check System Properties → Environment Variables → User variables → Path
   - Make sure you're not installing Flutter in a OneDrive-synced folder (use `C:\src\flutter` instead)

5. **Run the automated fix script:**
   - Use the `fix_flutter_path.ps1` script in the project root
   - It will automatically find Flutter and add it to PATH

6. **Test Flutter:**
   ```powershell
   flutter --version
   flutter doctor
   ```
