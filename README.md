# Enterprise QR Code Generator

A powerful, customizable, and enterprise-grade QR code generator built with **Flutter**. Supports cross-platform execution on **Windows Desktop** and **Web** (hosted on GitHub Pages).

🌐 **Live Demo:** [https://true-outlaw.github.io/QRCodeGenerator/](https://true-outlaw.github.io/QRCodeGenerator/)

---

## ✨ Features

### 📡 Supported QR Code Content Types
- **URL / Website:** Generate scannable links with instant prefix handling (`https://`).
- **Plain Text:** Encode arbitrary text, notes, and messages.
- **Wi-Fi Network:** Encode SSID, password, and encryption type (`WPA/WPA2`, `WEP`, `None`) for quick connection.
- **vCard (Contact Card):** Name, phone number, email address, and organization.
- **Email:** Pre-filled recipient, subject line, and body.
- **Phone Number:** Quick dial `tel:` scheme.
- **Geo Location:** Latitude and longitude coordinates with Google Maps links.

### 🎨 Deep Visual Customization
- **Colors & Gradients:** Single colors or linear/radial gradients with customizable angle and direction.
- **Custom Dot Styles:** Square, rounded, or circular data modules.
- **Corner Eye / Finder Patterns:** Custom shapes (Square, Rounded, Circular, Leaf) with independent inner and outer eye color overrides.
- **Frames & Callouts:** Decorative "SCAN ME" banners and badge callouts with customizable placement (Top / Bottom), background colors, and action icons.
- **Embedded Logos:** Upload and overlay custom brand logos in the center of the QR code with adjustable scaling.
- **Error Correction Levels:** Selectable Reed-Solomon error correction (`L` - 7%, `M` - 15%, `Q` - 25%, `H` - 30%) to ensure scan reliability with logos.

### 💾 Export & Sharing
- **High-Resolution PNG:** Scalable export multipliers (1x, 2x, 4x, 8x) for print and digital media.
- **Scalable Vector Graphics (SVG):** Crisp vector output for graphic design and large-format printing.
- **Direct Clipboard Copy:** One-click image copy across Windows (native clipboard) and Web (HTML5 Clipboard API).

### 🌓 UI / UX
- **Responsive Adaptive Layout:** Wide split-screen view for desktop/web and stacked layout for mobile/smaller screens.
- **Dark / Light Mode:** Fully responsive theme switcher with high-contrast surfaces.
- **Live Real-Time Preview:** Interactive preview that updates instantaneously as options change.

---

## 🛠️ Architecture & Platform Abstraction

This project uses conditional compilation to maintain 100% feature parity on both **Windows Desktop** and **Modern Web Browsers**:

- `lib/platform/platform_io_native.dart`: Handles desktop file picker dialogs, direct disk I/O, and native Win32 clipboard pasteboard operations.
- `lib/platform/platform_io_web.dart`: Handles browser downloads (`Blob` / Anchor click) and modern Web Clipboard API (`navigator.clipboard.write`).
- `lib/platform/platform_io.dart`: Unified conditional export shim ensuring seamless multi-platform builds without compilation conflicts.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.12.2 or higher recommended)
- Chrome / Edge (for Web) or Visual Studio C++ Build Tools (for Windows Desktop)

### Clone & Install Dependencies
```bash
git clone https://github.com/Outlawdlaw/QRCodeGenerator.git
cd QRCodeGenerator
flutter pub get
```

### Run Locally

#### Run on Web
```bash
flutter run -d chrome
```

#### Run on Windows Desktop
```bash
flutter run -d windows
```

---

## 📦 Building & Deployment

### Build for Windows Desktop
```bash
flutter build windows --release
```
*Output executable will be in `build/windows/x64/runner/Release/`.*

### Build for Web (GitHub Pages)
```bash
flutter build web --release --base-href /QRCodeGenerator/
```

### Deploying to GitHub Pages (Automated via GitHub Actions)
The cleanest way to deploy without committing build artifacts into your source tree is via GitHub Actions:

1. Push your source code to the `master` branch.
2. In your GitHub repository, go to **Settings** &rarr; **Pages**.
3. Under **Build and deployment**, set **Source** to **GitHub Actions**.
4. The workflow will automatically compile the Flutter web app on each push and publish it to GitHub Pages.

---

## 📜 Terms of Use & License

Copyright © 2026 True Outlaw. All rights reserved.

- **Free to Use:** You are free to use this application to generate, customize, and export QR codes for both personal and commercial purposes.
- **Restrictions:** The source code, software design, and architecture are proprietary. You may not copy, replicate, modify, redistribute, publish, or sublicense this source code or application without explicit prior written authorization.
