# VandCloud

<p align="center">
  <img src="assets/logo.png" alt="VandCloud Logo" width="100">
</p>

**VandCloud** is a cross-platform application that provides a categorized directory of APIs and services. It allows users to browse, test, and monitor the availability of various online services with real-time status checking.

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/code3-dev/VandCloud?style=for-the-badge)](https://github.com/code3-dev/VandCloud/releases)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/code3-dev/VandCloud/build.yaml?style=for-the-badge)](https://github.com/code3-dev/VandCloud/actions)
[![GitHub all releases](https://img.shields.io/github/downloads/code3-dev/VandCloud/total?style=for-the-badge)](https://github.com/code3-dev/VandCloud/releases)
[![License](https://img.shields.io/github/license/code3-dev/VandCloud?style=for-the-badge)](https://github.com/code3-dev/VandCloud/blob/main/LICENSE)

## 🌟 Features

- **Multi-Platform Support** - Available for Android, Windows, Linux, and macOS
- **Categorized API Directory** - Organized collection of APIs and services
- **Real-Time Status Checking** - Test host availability with ping measurements
- **Responsive Design** - Optimized for mobile, tablet, desktop, and TV
- **Dark/Light Theme** - Customizable theme preferences
- **Filter & Sort Options** - Hide failed items and sort by name or ping

## 📱 Platforms

| Platform | Status | Download |
|----------|--------|----------|
| Android | ✅ Supported | [APK Releases](https://github.com/code3-dev/VandCloud/releases) |
| Windows | ✅ Supported | [Installer](https://github.com/code3-dev/VandCloud/releases) |
| Linux | ✅ Supported | [Packages](https://github.com/code3-dev/VandCloud/releases) |
| macOS | ✅ Supported | [Packages](https://github.com/code3-dev/VandCloud/releases) |
| Web | ⏳ Planned | - |

## 🚀 Installation

### Android
Download the APK file from the [releases page](https://github.com/code3-dev/VandCloud/releases):
- **Universal APK** - Works on all Android devices
- **Architecture-specific APKs** - Smaller downloads for specific device types

### Windows
Download the installer from the [releases page](https://github.com/code3-dev/VandCloud/releases):
- **Installer** - Easy installation with setup wizard
- **ZIP Package** - Portable version for manual installation

### Linux
Download the appropriate package for your distribution from the [releases page](https://github.com/code3-dev/VandCloud/releases):
- **DEB Package** - For Debian/Ubuntu-based distributions
- **RPM Package** - For Red Hat/Fedora-based distributions
- **AppImage** - Universal Linux package that runs on most distributions
- **Tar.gz Archive** - Portable version for manual installation

### macOS
Download the macOS package from the [releases page](https://github.com/code3-dev/VandCloud/releases):
- **DMG Installer** - Standard macOS installer package
- **ZIP Package** - Portable version for manual installation

## 🛠️ Development

### Prerequisites
- Flutter SDK
- Android Studio / VS Code
- Android SDK (for mobile development)
- Desktop Development Tools:
  - **Windows**: Visual Studio 2022 or Visual Studio Build Tools with C++ development tools
  - **Linux**: GCC, CMake, Ninja build system
  - **macOS**: Xcode command line tools

### Getting Started
```bash
# Clone the repository
git clone https://github.com/code3-dev/VandCloud.git

# Navigate to the project directory
cd VandCloud

# Install dependencies
flutter pub get

# Run the app
flutter run

# For desktop builds:
# Windows: Ensure Visual Studio or C++ Build Tools are installed
# Linux: Install build dependencies with: sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
# macOS: Ensure Xcode command line tools are installed
```

### Build Commands

#### Android
```bash
# Build APK for all architectures
flutter build apk --no-tree-shake-icons

# Build split APKs for each architecture
flutter build apk --split-per-abi --no-tree-shake-icons

# Build app bundle for Play Store
flutter build appbundle --no-tree-shake-icons
```

#### Windows
```bash
# Build Windows desktop application
flutter build windows

# Build Windows installer (requires Inno Setup)
cd windows/installer
iscc VandCloud.iss
```

#### Linux
```bash
# Build Linux desktop application
flutter build linux

# Install packaging dependencies (Ubuntu/Debian)
sudo apt-get install rpm ruby ruby-dev rubygems build-essential

# Create DEB and RPM packages
# (This is handled automatically in the CI/CD pipeline)
```

#### macOS
```bash
# Build macOS desktop application
flutter build macos --no-tree-shake-icons
```

### GitHub Actions Build Setup

To set up GitHub Actions for building and releasing your forked version of VandCloud:

1. **Fork and Clone Your Fork**
   ```bash
   # Fork the repository on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/VandCloud.git
   cd VandCloud
   ```

2. **Create Android Keystore**
   ```bash
   # Generate a new keystore for Android signing (examples for different OS)
   
   # On Windows
   keytool -genkey -v -keystore ~/vand.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vandcloud
   
   # On macOS
   keytool -genkey -v -keystore ~/vand.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vandcloud
   
   # On Linux
   keytool -genkey -v -keystore ~/vand.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vandcloud
   ```
   
   When prompted, enter the following information:
   - First and Last Name: `Hossein Pira`
   - Organizational Unit: `VandCloud`
   - Organization: `IRDevs`
   - City: `New York`
   - State: `New York`
   - Country: `US`
   - Confirm: `yes`

3. **Convert Keystore to Base64**
   ```bash
   # On Windows (PowerShell)
   [convert]::ToBase64String((Get-Content -Path "vand.jks" -AsByteStream -Raw)) | Out-File -Encoding ascii "vand.base64"
   
   # On macOS/Linux
   base64 -i vand.jks -o vand.base64
   
   # Alternative for older Linux systems
   base64 vand.jks > vand.base64
   ```

4. **Add Secrets to GitHub Repository**
   
   Go to your GitHub repository settings → Secrets and variables → Actions, and add the following secrets:
   
   | Secret Name | Value |
   |-------------|-------|
   | `KEY_STORE` | Content of the base64 encoded keystore file |
   | `KEY_STORE_PASSWORD` | Keystore password |
   | `KEY_PASSWORD` | Key password |
   | `KEY_ALIAS` | Key alias (vandcloud) |

5. **GitHub Actions Workflow**
   
   The workflow will automatically use these secrets to sign Android builds. The relevant section in the workflow looks like this:
   
   ```yaml
   - name: Decode Keystore
     run: |
       $bytes = [System.Convert]::FromBase64String("${{ secrets.KEY_STORE }}")
       [IO.File]::WriteAllBytes("android/app/keystore.jks", $bytes)
     shell: powershell

   - name: Create keystore properties file
     run: |
       echo storePassword=${{ secrets.KEY_STORE_PASSWORD }} > android/key.properties
       echo keyPassword=${{ secrets.KEY_PASSWORD }} >> android/key.properties
       echo keyAlias=${{ secrets.KEY_ALIAS }} >> android/key.properties
       echo storeFile=keystore.jks >> android/key.properties
     shell: bash
   ```

6. **Push Changes and Trigger Build**
   ```bash
   # Make your code changes
   git add .
   git commit -m "Your changes"
   git push origin main
   ```
   
   This will trigger the GitHub Actions workflow to build and release your version.

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Hossein Pira**

- Email: h3dev.pira@gmail.com
- Telegram: [@h3dev](https://t.me/h3dev)
- GitHub: [@code3-dev](https://github.com/code3-dev)

## 🙏 Acknowledgments

- Thanks to all contributors who have helped with the project
- Inspired by the need for a comprehensive API directory and testing tool