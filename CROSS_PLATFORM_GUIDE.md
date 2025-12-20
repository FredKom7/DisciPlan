# DisciPlan Cross-Platform Setup Guide

## 🌐 Cross-Platform Compatibility Status

Your DisciPlan app is built with Flutter and supports multiple platforms:

| Platform | Status | Notes |
|----------|--------|-------|
| ✅ **Web (Chrome)** | Working | Currently running |
| ✅ **Windows Desktop** | Ready | Should work out of the box |
| ⚠️ **Android** | Needs Setup | Environment variables required |
| ❌ **iOS** | Not Available | Requires macOS |

---

## 🚀 Quick Start: Run on All Available Platforms

### **1. Web (Chrome) - Already Working**
```powershell
flutter run -d chrome
```

### **2. Windows Desktop**
```powershell
flutter run -d windows
```

### **3. Android Emulator**

**Step 1: Run the setup script**
```powershell
.\setup-android-env.ps1
```

**Step 2: Start emulator and run**
```powershell
flutter emulators --launch Pixel_6
flutter run
```

---

## 🔧 Permanent Android Setup (Recommended)

To avoid running the setup script every time:

### **Option A: GUI Method (Easiest)**

1. Press `Win + R`, type `sysdm.cpl`, press Enter
2. Click **"Advanced"** tab → **"Environment Variables"**
3. Under **"System variables"**, click **"New"** and add:
   - Variable: `JAVA_HOME`
   - Value: `C:\Program Files\Android\Android Studio\jbr`
4. Click **"New"** again and add:
   - Variable: `GRADLE_USER_HOME`
   - Value: `C:\gradle-home`
5. Find **"Path"** in System variables, click **"Edit"**
6. Click **"New"** and add: `%JAVA_HOME%\bin`
7. Click **"OK"** on all dialogs
8. **Restart VS Code**

### **Option B: PowerShell Method (Advanced)**

Run PowerShell as Administrator:

```powershell
# Set JAVA_HOME
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Android\Android Studio\jbr', 'Machine')

# Set GRADLE_USER_HOME
[System.Environment]::SetEnvironmentVariable('GRADLE_USER_HOME', 'C:\gradle-home', 'Machine')

# Add Java to PATH
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
$newPath = "$currentPath;C:\Program Files\Android\Android Studio\jbr\bin"
[System.Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
```

Then restart your computer.

---

## 📱 Platform-Specific Features

### **Features Available on All Platforms:**
- ✅ Authentication (Firebase)
- ✅ Habit tracking
- ✅ Todo lists
- ✅ Monthly/Weekly planners
- ✅ Progress tracking
- ✅ Cloud sync (Firestore)

### **Platform-Specific Limitations:**

**Web:**
- ⚠️ No local notifications (browser limitations)
- ⚠️ No app blocking features

**Windows Desktop:**
- ⚠️ Limited notification support
- ⚠️ No app blocking features

**Android:**
- ✅ Full feature support
- ✅ Local notifications
- ✅ Background services
- ✅ App blocking (with proper permissions)

---

## 🎯 Testing Your App Cross-Platform

### **Quick Test Commands:**

```powershell
# Test on all available platforms
flutter run -d chrome          # Web
flutter run -d windows         # Desktop
flutter run -d emulator-5554   # Android (after emulator starts)

# List all available devices
flutter devices

# List available emulators
flutter emulators
```

### **Hot Reload (Works on All Platforms):**

While your app is running:
- Press `r` - Hot reload (instant UI updates)
- Press `R` - Hot restart (full app restart)
- Press `q` - Quit

---

## 🐛 Troubleshooting

### **Android Build Fails:**

1. **Run the setup script:**
   ```powershell
   .\setup-android-env.ps1
   ```

2. **Clean and rebuild:**
   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Check Java:**
   ```powershell
   java -version
   ```
   Should show: `openjdk version "21.0.x"`

### **Emulator Won't Start:**

1. **Open Android Studio**
2. Go to **Virtual Device Manager**
3. Start emulator from there
4. Then run `flutter run` (auto-detects running emulator)

### **Network Errors During Build:**

- Check your internet connection
- Try again (Gradle auto-retries)
- If persistent, try using a VPN

---

## 📊 Build for Production

### **Web:**
```powershell
flutter build web
# Output: build/web/
```

### **Windows:**
```powershell
flutter build windows
# Output: build/windows/runner/Release/
```

### **Android APK:**
```powershell
.\setup-android-env.ps1  # If not set permanently
flutter build apk
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### **Android App Bundle (for Play Store):**
```powershell
.\setup-android-env.ps1  # If not set permanently
flutter build appbundle
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🎨 Platform-Specific UI Adaptations

Your app uses:
- **Material Design** for Android
- **Responsive Framework** for web/desktop
- **Platform-aware widgets** that adapt automatically

The UI will automatically adapt to each platform's design guidelines.

---

## 🔄 Next Steps for Full Cross-Platform Support

1. ✅ **Test on Web** - Already working
2. ⬜ **Test on Windows Desktop** - Run `flutter run -d windows`
3. ⬜ **Fix Android Environment** - Run `.\setup-android-env.ps1`
4. ⬜ **Test on Android Emulator** - After environment setup
5. ⬜ **Set Environment Variables Permanently** - For long-term use

---

## 💡 Pro Tips

- **Use VS Code's device selector** (bottom right) to switch between platforms
- **Run on multiple platforms simultaneously** in different terminals
- **Test responsive design** by resizing windows on web/desktop
- **Use Chrome DevTools** for web debugging
- **Use Android Studio's Profiler** for Android performance testing
