# TestFlight Upload Guide for Estaraht Pro

This guide will walk you through uploading your Flutter app to TestFlight for iOS beta testing.

## Prerequisites

### Required Tools
1. **Mac computer** with macOS (required for iOS builds)
2. **Xcode** (latest version recommended - download from Mac App Store)
3. **Apple Developer Account** (paid - $99/year)
4. **Flutter SDK** (already installed)

### Apple Developer Account Setup
1. Enroll in Apple Developer Program at https://developer.apple.com/programs/
2. Complete enrollment and payment ($99/year)
3. Wait for approval (usually 24-48 hours)

## Step 1: App Store Connect Setup

### 1.1 Create App ID
1. Go to https://developer.apple.com/account/
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+** button
4. Select **App IDs** → **Continue**
5. Configure:
   - **Description**: Estaraht Pro
   - **Bundle ID**: `com.estaraht.app` (Explicit)
   - **Capabilities** - Enable the following:
     - Push Notifications
     - Sign in with Apple (if needed)
     - Associated Domains
     - HealthKit
     - Background Modes
     - App Groups
     - Keychain Sharing
     - Time Sensitive Notifications
6. Click **Continue** → **Register**

### 1.2 Create App on App Store Connect
1. Go to https://appstoreconnect.apple.com/
2. Click **My Apps** → **+** → **New App**
3. Fill in the details:
   - **Platform**: iOS
   - **Name**: Estaraht Pro - استرحت برو
   - **Primary Language**: Arabic or English
   - **Bundle ID**: Select `com.estaraht.app`
   - **SKU**: `estaraht-pro-001` (unique identifier)
   - **User Access**: Full Access
4. Click **Create**

### 1.3 Configure App Information
1. In your new app, go to **App Information**
2. Set:
   - **Category**: Primary: Medical, Secondary: Health & Fitness
   - **Content Rights**: Own or licensed
   - **Age Rating**: Complete questionnaire (likely 12+ or 17+ for medical apps)

## Step 2: Certificates and Provisioning Profiles

### 2.1 Create Distribution Certificate
1. On your Mac, open **Keychain Access**
2. Menu: **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
3. Enter your email and name
4. Select **Saved to disk** → **Continue**
5. Save the CSR file

6. Go to https://developer.apple.com/account/
7. **Certificates, Identifiers & Profiles** → **Certificates** → **+**
8. Select **Apple Distribution** → **Continue**
9. Upload the CSR file → **Continue**
10. Download the certificate and double-click to install in Keychain Access

### 2.2 Create App Store Provisioning Profile
1. In Apple Developer Portal: **Profiles** → **+**
2. Select **App Store** → **Continue**
3. Select App ID: `com.estaraht.app` → **Continue**
4. Select the Distribution Certificate you just created → **Continue**
5. Name: `Estaraht Pro App Store` → **Generate**
6. Download the provisioning profile

## Step 3: Configure Xcode Project

### 3.1 Open Project in Xcode
On your Mac:
```bash
cd /path/to/estaraht_mobile_app
open ios/Runner.xcworkspace
```

### 3.2 Configure Signing & Capabilities
1. In Xcode, select **Runner** project in the navigator
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Uncheck **Automatically manage signing**
5. Configure for Release:
   - **Provisioning Profile**: Select the App Store profile you created
   - **Team**: Select your Apple Developer team
   - **Bundle Identifier**: Verify it's `com.estaraht.app`

### 3.3 Add Required Capabilities
In **Signing & Capabilities**, click **+ Capability** and add:
- Push Notifications
- Background Modes (enable: Audio, VoIP, Background fetch, Remote notifications)
- Associated Domains
- App Groups (add: `group.com.estaraht.app`)
- Keychain Sharing
- HealthKit (if using health features)

### 3.4 Verify Info.plist
The Info.plist has been updated with all permission descriptions. Verify in Xcode that all NSUsageDescription keys are present.

## Step 4: Build the App for Release

### 4.1 Update Version and Build Number
In `pubspec.yaml`:
```yaml
version: 1.0.0+1
```
- First number (1.0.0) is the version (CFBundleShortVersionString)
- Second number (+1) is the build number (CFBundleVersion)

For each new upload, increment the build number (e.g., 1.0.0+2, 1.0.0+3)

### 4.2 Clean and Build
On your Mac:
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build for iOS release
flutter build ios --release

# Or build with specific version
flutter build ios --release --build-name=1.0.0 --build-number=1
```

## Step 5: Archive and Upload

### 5.1 Archive in Xcode
1. In Xcode, select **Any iOS Device (arm64)** as the destination (not simulator)
2. Menu: **Product** → **Archive**
3. Wait for the archive process to complete (5-15 minutes)
4. The **Organizer** window will open automatically

### 5.2 Upload to App Store Connect
1. In Organizer, select your archive
2. Click **Distribute App**
3. Select **App Store Connect** → **Next**
4. Select **Upload** → **Next**
5. Configure options:
   - **Include bitcode**: No (for iOS 14+)
   - **Upload your app's symbols**: Yes (recommended for crash reports)
   - **Manage Version and Build Number**: Xcode managed
6. Select Distribution Certificate and Provisioning Profile
7. Click **Upload**
8. Wait for upload to complete (10-30 minutes depending on size)

### 5.3 Verify Upload
1. Go to https://appstoreconnect.apple.com/
2. Select your app → **TestFlight** tab
3. Wait for processing (30-60 minutes)
4. Once processed, the build will appear under **iOS builds**

## Step 6: TestFlight Setup

### 6.1 Provide Export Compliance
1. In App Store Connect → **TestFlight** → Select your build
2. Answer export compliance questions:
   - **Does your app use encryption?** → Yes (if using HTTPS/SSL)
   - **Is your app exempt from encryption?** → Yes (if only using standard HTTPS)
3. Submit the information

### 6.2 Add Testers
1. Go to **TestFlight** → **Internal Testing** or **External Testing**
2. For Internal Testing:
   - Add up to 100 testers from your App Store Connect team
   - No app review required

3. For External Testing:
   - Add up to 10,000 external testers
   - First build requires App Review (submit beta review info)

### 6.3 Configure Test Information
1. Fill in **Test Information**:
   - **Beta App Description**: Brief description of your app
   - **Feedback Email**: Support email address
   - **What to Test**: Instructions for testers

2. For External Testing, also fill in:
   - **Privacy Policy URL** (required)
   - **Test Account** credentials (if app requires login)
   - **App Review Information**

### 6.4 Invite Testers
1. Click **Add Testers** or **Add External Testers**
2. Enter email addresses
3. Select the build to test
4. Click **Start Testing** or **Submit for Review** (external)

Testers will receive an email invitation to install TestFlight and your app.

## Step 7: Automated Upload (Alternative Method)

You can automate uploads using Flutter build commands:

### 7.1 Using Fastlane (Recommended for automation)
```bash
# Install fastlane
sudo gem install fastlane

# Initialize fastlane in ios directory
cd ios
fastlane init

# Configure fastlane to upload to TestFlight
# Edit ios/fastlane/Fastfile
```

Example Fastfile:
```ruby
default_platform(:ios)

platform :ios do
  desc "Push a new beta build to TestFlight"
  lane :beta do
    build_app(scheme: "Runner")
    upload_to_testflight
  end
end
```

Run:
```bash
cd ios
fastlane beta
```

## Step 8: Common Issues and Solutions

### Issue: "No suitable provisioning profile found"
**Solution**:
- Verify Bundle ID matches in Xcode and Apple Developer Portal
- Download and install the provisioning profile
- Restart Xcode

### Issue: "App icon required"
**Solution**:
- Ensure `assets/appstore.png` exists (1024x1024)
- Run: `flutter pub run flutter_launcher_icons`

### Issue: "Missing compliance"
**Solution**:
- Add to Info.plist:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

### Issue: "Invalid binary - Missing required architecture"
**Solution**:
- Ensure you're building for arm64
- In Xcode Build Settings, set Architectures to `arm64`

### Issue: "Invalid entitlements"
**Solution**:
- Verify all capabilities in entitlements match Apple Developer Portal App ID
- Enable required capabilities in Developer Portal first

## Step 9: App Review Preparation

Before submitting for full App Store release:

### 9.1 Required Materials
- App screenshots (various iPhone sizes)
- App preview video (optional but recommended)
- App description (multiple languages if needed)
- Keywords
- Support URL
- Privacy Policy URL
- App icon (1024x1024)

### 9.2 Review Information
- Contact information
- Demo account credentials
- Notes for reviewer

### 9.3 Age Rating
Complete the age rating questionnaire accurately for a medical app.

## Step 10: Monitoring and Updates

### 10.1 Check Build Status
- Monitor build processing in App Store Connect
- Check for any warnings or errors
- Review crash reports and feedback

### 10.2 Release New Builds
For each new version:
1. Increment version/build number in `pubspec.yaml`
2. Build and archive
3. Upload to App Store Connect
4. Add "What to Test" notes for testers
5. Notify testers of new build

### 10.3 Crash Reporting
- Enable crash reporting in App Store Connect
- Review crashes regularly
- Upload dSYM files for symbolication

## Additional Resources

- Apple Developer Documentation: https://developer.apple.com/documentation/
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios
- TestFlight Beta Testing: https://developer.apple.com/testflight/
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/

## Quick Reference Commands

```bash
# Clean and get dependencies
flutter clean && flutter pub get

# Build iOS release
flutter build ios --release

# Build with specific version
flutter build ios --release --build-name=1.0.1 --build-number=2

# Generate app icons
flutter pub run flutter_launcher_icons

# Check Flutter doctor
flutter doctor -v

# Run on physical device for testing
flutter run --release -d <device-id>
```

## Checklist Before Upload

- [ ] Apple Developer Account active and paid
- [ ] App created in App Store Connect
- [ ] App ID created with required capabilities
- [ ] Distribution certificate created and installed
- [ ] Provisioning profile downloaded and configured
- [ ] All Info.plist permissions configured
- [ ] Entitlements file updated
- [ ] Version and build numbers incremented
- [ ] App icon generated (1024x1024)
- [ ] Build successful with no errors
- [ ] Tested on physical device
- [ ] Privacy policy URL ready
- [ ] Test account credentials prepared
- [ ] Beta app description written

## Notes

- **First upload takes the longest** - subsequent uploads are faster
- **TestFlight internal builds** are available immediately after processing
- **External TestFlight builds** require App Review (24-48 hours)
- **Keep build numbers unique** - never reuse a build number
- **Archive your builds** - keep .ipa files for reference
- **Test thoroughly** before releasing to production

## Support

If you encounter issues:
1. Check Apple Developer Forums
2. Review Flutter iOS deployment documentation
3. Check Xcode console logs for detailed error messages
4. Verify all certificates and profiles are valid

---

**Good luck with your TestFlight deployment!**
