import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() async {
  // Path to the source logo
  final String sourceLogoPath = 'assets/logo.png';
  
  // Check if source logo exists
  final File sourceLogo = File(sourceLogoPath);
  if (!await sourceLogo.exists()) {
    print('Error: Source logo not found at $sourceLogoPath');
    return;
  }
  
  print('Generating app icons from $sourceLogoPath');
  
  // Load the source image
  final Uint8List sourceBytes = await sourceLogo.readAsBytes();
  final img.Image? sourceImage = img.decodeImage(sourceBytes);
  
  if (sourceImage == null) {
    print('Error: Could not decode source image');
    return;
  }
  
  print('Source image loaded: ${sourceImage.width}x${sourceImage.height}');
  
  // Generate icons for all platforms
  await _generateAndroidIcons(sourceImage);
  await _generateIOSIcons(sourceImage);
  await _generateWebIcons(sourceImage);
  await _generateWindowsIcons(sourceImage);
  await _generateMacIcons(sourceImage);
  await _generateLinuxIcons(sourceImage);
  
  // Update configuration files
  await _updateWebManifest();
  await _updateWebIndex();
  
  print('Icon generation completed!');
}

// Generate icons for Android
Future<void> _generateAndroidIcons(img.Image sourceImage) async {
  print('Generating Android icons...');
  
  // Android mipmap sizes
  final Map<String, int> androidSizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };
  
  // Android adaptive icon sizes (for API 26+)
  final Map<String, int> androidAdaptiveSizes = {
    'mipmap-mdpi': 108,
    'mipmap-hdpi': 162,
    'mipmap-xhdpi': 216,
    'mipmap-xxhdpi': 324,
    'mipmap-xxxhdpi': 432,
  };
  
  // Generate standard launcher icons
  for (final entry in androidSizes.entries) {
    final String folder = entry.key;
    final int size = entry.value;
    
    final Directory dir = Directory('android/app/src/main/res/$folder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final img.Image resizedImage = img.copyResize(sourceImage, width: size, height: size);
    final Uint8List pngBytes = img.encodePng(resizedImage);
    final File iconFile = File('${dir.path}/ic_launcher.png');
    await iconFile.writeAsBytes(pngBytes);
    print('Generated ${iconFile.path}');
  }
  
  // Generate adaptive icons (foreground)
  for (final entry in androidAdaptiveSizes.entries) {
    final String folder = entry.key;
    final int size = entry.value;
    
    final Directory dir = Directory('android/app/src/main/res/$folder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final img.Image resizedImage = img.copyResize(sourceImage, width: size, height: size);
    final Uint8List pngBytes = img.encodePng(resizedImage);
    final File iconFile = File('${dir.path}/ic_launcher_foreground.png');
    await iconFile.writeAsBytes(pngBytes);
    print('Generated ${iconFile.path}');
  }
  
  print('Android icons generated successfully');
}

// Generate icons for iOS
Future<void> _generateIOSIcons(img.Image sourceImage) async {
  print('Generating iOS icons...');
  
  // iOS icon sizes
  final List<int> iosSizes = [
    20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024
  ];
  
  // Create iOS AppIcon.appiconset directory
  final Directory iosDir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
  if (!await iosDir.exists()) {
    await iosDir.create(recursive: true);
  }
  
  // Generate icons
  for (final size in iosSizes) {
    final img.Image resizedImage = img.copyResize(sourceImage, width: size, height: size);
    final Uint8List pngBytes = img.encodePng(resizedImage);
    final File iconFile = File('${iosDir.path}/Icon-$size.png');
    await iconFile.writeAsBytes(pngBytes);
    print('Generated ${iconFile.path}');
  }
  
  print('iOS icons generated successfully');
}

// Generate icons for Web
Future<void> _generateWebIcons(img.Image sourceImage) async {
  print('Generating Web icons...');
  
  // Web icon sizes
  final List<int> webSizes = [16, 32, 96, 192, 512];
  
  // Create web directory if it doesn't exist
  final Directory webDir = Directory('web/icons');
  if (!await webDir.exists()) {
    await webDir.create(recursive: true);
  }
  
  // Generate icons
  for (final size in webSizes) {
    final img.Image resizedImage = img.copyResize(sourceImage, width: size, height: size);
    final Uint8List pngBytes = img.encodePng(resizedImage);
    final File iconFile = File('${webDir.path}/Icon-$size.png');
    await iconFile.writeAsBytes(pngBytes);
    print('Generated ${iconFile.path}');
  }
  
  // Generate favicon
  final img.Image faviconImage = img.copyResize(sourceImage, width: 32, height: 32);
  final Uint8List faviconBytes = img.encodePng(faviconImage);
  final File faviconFile = File('web/favicon.png');
  await faviconFile.writeAsBytes(faviconBytes);
  print('Generated ${faviconFile.path}');
  
  // Generate maskable icons
  final img.Image maskable192 = img.copyResize(sourceImage, width: 192, height: 192);
  final Uint8List maskable192Bytes = img.encodePng(maskable192);
  final File maskable192File = File('${webDir.path}/Icon-maskable-192.png');
  await maskable192File.writeAsBytes(maskable192Bytes);
  print('Generated ${maskable192File.path}');
  
  final img.Image maskable512 = img.copyResize(sourceImage, width: 512, height: 512);
  final Uint8List maskable512Bytes = img.encodePng(maskable512);
  final File maskable512File = File('${webDir.path}/Icon-maskable-512.png');
  await maskable512File.writeAsBytes(maskable512Bytes);
  print('Generated ${maskable512File.path}');
  
  print('Web icons generated successfully');
}

// Generate icons for Windows
Future<void> _generateWindowsIcons(img.Image sourceImage) async {
  print('Generating Windows icons...');
  
  // Windows icon sizes (common sizes used in Windows applications)
  final List<int> windowsSizes = [16, 24, 32, 48, 64, 96, 128, 256];
  
  // Create windows directory if it doesn't exist
  final Directory windowsDir = Directory('windows/runner/resources/app_icons');
  if (!await windowsDir.exists()) {
    await windowsDir.create(recursive: true);
  }
  
  // Generate PNG icons
  for (final size in windowsSizes) {
    final img.Image resizedImage = img.copyResize(sourceImage, width: size, height: size);
    final Uint8List pngBytes = img.encodePng(resizedImage);
    final File iconFile = File('${windowsDir.path}/app_icon_$size.png');
    await iconFile.writeAsBytes(pngBytes);
    print('Generated ${iconFile.path}');
  }
  
  // Generate the main ICO file
  await _generateWindowsICO(sourceImage);
  
  print('Windows icons generated successfully');
}

// Generate the main Windows ICO file
Future<void> _generateWindowsICO(img.Image sourceImage) async {
  print('Generating Windows ICO file...');
  
  // For ICO files, we'll use a single high-resolution image
  // Windows will automatically scale it as needed
  final img.Image resizedImage = img.copyResize(sourceImage, width: 256, height: 256);
  
  // Encode as ICO
  final Uint8List icoBytes = img.encodeIco(resizedImage);
  final File icoFile = File('windows/runner/resources/app_icon.ico');
  await icoFile.writeAsBytes(icoBytes);
  print('Generated ${icoFile.path}');
}

// Generate icons for macOS
Future<void> _generateMacIcons(img.Image sourceImage) async {
  print('Generating macOS icons...');
  
  // macOS icon sizes
  final List<int> macSizes = [16, 32, 64, 128, 256, 512, 1024];
  
  // Create macOS directory if it doesn't exist
  final Directory macDir = Directory('macos/Runner/Assets.xcassets/AppIcon.appiconset');
  if (!await macDir.exists()) {
    await macDir.create(recursive: true);
  }
  
  // Generate icons
  for (final size in macSizes) {
    final img.Image resizedImage = img.copyResize(sourceImage, width: size, height: size);
    final Uint8List pngBytes = img.encodePng(resizedImage);
    final File iconFile = File('${macDir.path}/app_icon_$size.png');
    await iconFile.writeAsBytes(pngBytes);
    print('Generated ${iconFile.path}');
  }
  
  // Generate Contents.json for macOS
  await _generateMacOSContentsJson();
  
  print('macOS icons generated successfully');
}

// Generate Contents.json for macOS
Future<void> _generateMacOSContentsJson() async {
  final String contentsJson = '''
{
  "images": [
    {
      "size": "16x16",
      "idiom": "mac",
      "filename": "app_icon_16.png",
      "scale": "1x"
    },
    {
      "size": "16x16",
      "idiom": "mac",
      "filename": "app_icon_32.png",
      "scale": "2x"
    },
    {
      "size": "32x32",
      "idiom": "mac",
      "filename": "app_icon_32.png",
      "scale": "1x"
    },
    {
      "size": "32x32",
      "idiom": "mac",
      "filename": "app_icon_64.png",
      "scale": "2x"
    },
    {
      "size": "128x128",
      "idiom": "mac",
      "filename": "app_icon_128.png",
      "scale": "1x"
    },
    {
      "size": "128x128",
      "idiom": "mac",
      "filename": "app_icon_256.png",
      "scale": "2x"
    },
    {
      "size": "256x256",
      "idiom": "mac",
      "filename": "app_icon_256.png",
      "scale": "1x"
    },
    {
      "size": "256x256",
      "idiom": "mac",
      "filename": "app_icon_512.png",
      "scale": "2x"
    },
    {
      "size": "512x512",
      "idiom": "mac",
      "filename": "app_icon_512.png",
      "scale": "1x"
    },
    {
      "size": "512x512",
      "idiom": "mac",
      "filename": "app_icon_1024.png",
      "scale": "2x"
    }
  ],
  "info": {
    "version": 1,
    "author": "xcode"
  }
}
''';
  
  final File contentsFile = File('macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json');
  await contentsFile.writeAsString(contentsJson);
  print('Generated ${contentsFile.path}');
}

// Update web manifest.json
Future<void> _updateWebManifest() async {
  print('Updating web manifest.json...');
  
  final String manifestJson = '''
{
    "name": "VandCloud",
    "short_name": "VandCloud",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2",
    "description": "A new Flutter project.",
    "orientation": "portrait-primary",
    "prefer_related_applications": false,
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-maskable-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "maskable"
        },
        {
            "src": "icons/Icon-maskable-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "maskable"
        }
    ]
}
''';
  
  final File manifestFile = File('web/manifest.json');
  await manifestFile.writeAsString(manifestJson);
  print('Updated ${manifestFile.path}');
}

// Update web index.html
Future<void> _updateWebIndex() async {
  print('Updating web index.html...');
  
  final String indexHtml = '''
<!DOCTYPE html>
<html>
<head>
  <!--
    If you are serving your web app in a path other than the root, change the
    href value below to reflect the base path you are serving from.

    The path provided below has to start and end with a slash "/" in order for
    it to work correctly.

    For more details:
    * https://developer.mozilla.org/en-US/docs/Web/HTML/Element/base

    This is a placeholder for base href that will be replaced by the value of
    the \`--base-href\` argument provided to \`flutter build\`.
  -->
  <base href="\$FLUTTER_BASE_HREF">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="A new Flutter project.">

  <!-- iOS meta tags & icons -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="VandCloud">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>VandCloud</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
''';
  
  final File indexFile = File('web/index.html');
  await indexFile.writeAsString(indexHtml);
  print('Updated ${indexFile.path}');
}

// Generate icons for Linux
Future<void> _generateLinuxIcons(img.Image sourceImage) async {
  print('Generating Linux icons...');
  
  // Linux icon sizes (following Freedesktop.org icon specification)
  final List<int> linuxSizes = [16, 22, 24, 32, 48, 64, 128, 256, 512];
  
  // Create Linux directory if it doesn't exist
  final Directory linuxDir = Directory('linux/assets/icons');
  if (!await linuxDir.exists()) {
    await linuxDir.create(recursive: true);
  }
  
  // Generate icons
  for (final size in linuxSizes) {
    final img.Image resizedImage = img.copyResize(sourceImage, width: size, height: size);
    final Uint8List pngBytes = img.encodePng(resizedImage);
    final File iconFile = File('${linuxDir.path}/icon_$size.png');
    await iconFile.writeAsBytes(pngBytes);
    print('Generated ${iconFile.path}');
  }
  
  print('Linux icons generated successfully');
}