# Deploying Both Apps (Patient & Doctor)

Steps to build and publish **استرحت - Estaraht** (patient) and **استرحت للمعالج - Est Therapist** (doctor) to Google Play and the App Store.

---

## Before You Deploy

### 1. Signing (Android)

- Create or use an existing **keystore** for release builds.
- Add `android/key.properties` (do **not** commit this file; add it to `.gitignore` if needed):

  ```properties
  storePassword=your_keystore_password
  keyPassword=your_key_password
  keyAlias=your_key_alias
  storeFile=path/to/your/upload-keystore.jks
  ```

  Use a path relative to the project root (e.g. `../keystore/upload.jks`) or absolute.

### 2. Version

- Set version in `pubspec.yaml`, e.g. `version: 1.0.0+1` (name + build number).
- For each new store upload, increase the **build number** (the `+1` part) for that app. Patient and doctor can have independent version numbers if you prefer.

### 3. Firebase

- **Android:** `android/app/src/patient/google-services.json` and `android/app/src/doctor/google-services.json` must match the Firebase Android apps for `com.owldots.estarhtapppro.patient` and `com.owldots.estarhtapppro.doctor`.
- **iOS:** Use `GoogleService-Info-Patient.plist` and `GoogleService-Info-Doctor.plist` in `ios/Runner/` and the Run Script from [FLAVORS.md](FLAVORS.md#ios-googleservice-infoplist) so the correct file is used per scheme.

### 4. Privacy Policy & Delete Account URLs

- **Privacy Policy** and **Delete account** links in Settings (More) open external URLs. Configure them in `lib/core/constants/app_urls.dart`:
  - `AppUrls.privacyPolicy` – e.g. `https://estaraht.com/privacy-policy`
  - `AppUrls.deleteAccount` – e.g. `https://estaraht.com/delete-account` (for a web page explaining deletion or a request form)
- In-app **Delete account** in Settings permanently deletes the Firebase account (after password confirmation) and clears local data.

---

## Android (Google Play)

### Step 1: Build App Bundles (recommended for Play Store)

From the project root:

**Patient app**

```bash
flutter build appbundle --flavor patient --dart-define=APP_TYPE=patient --release
```

Output: `build/app/outputs/bundle/patientRelease/app-patient-release.aab`

**Doctor app**

```bash
flutter build appbundle --flavor doctor --dart-define=APP_TYPE=doctor --release
```

Output: `build/app/outputs/bundle/doctorRelease/app-doctor-release.aab`

### Step 2: Play Console

1. Go to [Google Play Console](https://play.google.com/console).
2. Create **two** apps (if not already):
   - One for the patient app (e.g. “استرحت - Estaraht”).
   - One for the doctor app (e.g. “استرحت للمعالج - Est Therapist”).
3. For **each** app:
   - Complete **Store listing** (title, short/long description, screenshots, etc.).
   - Complete **Data safety** and declare how you use sensitive data and permissions.
   - Under **Release** → **Production** (or Testing), create a new release and upload the **correct** `.aab`:
     - Patient listing → upload `app-patient-release.aab`.
     - Doctor listing → upload `app-doctor-release.aab`.
4. Enroll in **Play App Signing** when prompted. Google will give you an **App signing key** (SHA-1, SHA-256).

### Step 3: Firebase after first upload (important)

After the first release for each app, add the **Play App Signing** key to Firebase so Google Sign-In and FCM work in production:

1. In Play Console → your app → **Release** → **Setup** → **App signing**: copy **SHA-1** and **SHA-256** of the **App signing key** (not the upload key).
2. In [Firebase Console](https://console.firebase.google.com) → your project → **Project settings** → **Your apps**:
   - For the **Patient** Android app (`com.owldots.estarhtapppro.patient`): add the SHA-1 and SHA-256.
   - For the **Doctor** Android app (`com.owldots.estarhtapppro.doctor`): add the SHA-1 and SHA-256.
3. Re-download `google-services.json` for each app if Firebase regenerates it, and replace the files in `android/app/src/patient/` and `android/app/src/doctor/`.

### Optional: APK for direct install / testing

```bash
# Patient
flutter build apk --flavor patient --dart-define=APP_TYPE=patient --release

# Doctor
flutter build apk --flavor doctor --dart-define=APP_TYPE=doctor --release
```

APKs: `build/app/outputs/flutter-apk/app-patient-release.apk` and `app-doctor-release.apk`.

---

## iOS (App Store)

### Step 1: Xcode setup

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target and ensure:
   - **Signing & Capabilities**: correct Team and **Automatically manage signing** (or your distribution profile).
   - For **patient** and **doctor** schemes, the correct Bundle IDs are used:
     - Patient: `com.owldots.estarhtapppro.patient`
     - Doctor: `com.owldots.estarhtapppro.doctor`
3. Confirm the Run Script for copying the correct `GoogleService-Info-*.plist` is in place (see [FLAVORS.md](FLAVORS.md#ios-googleservice-infoplist)).

### Step 2: Build IPA

From the project root:

**Patient app**

```bash
flutter build ipa --flavor patient --dart-define=APP_TYPE=patient
```

**Doctor app**

```bash
flutter build ipa --flavor doctor --dart-define=APP_TYPE=doctor
```

Outputs are under `build/ios/ipa/`. You can also **Archive** in Xcode (Product → Archive) with the **patient** or **doctor** scheme, then distribute from the Organizer.

### Step 3: App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com).
2. Create **two** apps (if not already):
   - Patient: Bundle ID `com.owldots.estarhtapppro.patient`, name e.g. “استرحت - Estaraht”.
   - Doctor: Bundle ID `com.owldots.estarhtapppro.doctor`, name e.g. “استرحت للمعالج - Est Therapist”.
3. For each app, complete the listing (screenshots, description, privacy, etc.).
4. In Xcode Organizer (or Transporter), upload the IPA that matches the Bundle ID and app in App Store Connect.

---

## Quick reference

| Task              | Patient command                                                                 | Doctor command                                                               |
|-------------------|----------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| Run (debug)       | `flutter run --flavor patient --dart-define=APP_TYPE=patient`                   | `flutter run --flavor doctor --dart-define=APP_TYPE=doctor`                  |
| Android AAB        | `flutter build appbundle --flavor patient --dart-define=APP_TYPE=patient`       | `flutter build appbundle --flavor doctor --dart-define=APP_TYPE=doctor`      |
| Android APK        | `flutter build apk --flavor patient --dart-define=APP_TYPE=patient --release`   | `flutter build apk --flavor doctor --dart-define=APP_TYPE=doctor --release`  |
| iOS IPA            | `flutter build ipa --flavor patient --dart-define=APP_TYPE=patient`             | `flutter build ipa --flavor doctor --dart-define=APP_TYPE=doctor`             |

| App    | Android package ID                      | iOS bundle ID                         |
|--------|-----------------------------------------|----------------------------------------|
| Patient| com.owldots.estarhtapppro.patient       | com.owldots.estarhtapppro.patient      |
| Doctor | com.owldots.estarhtapppro.doctor        | com.owldots.estarhtapppro.doctor       |

---

## Checklist before first release

- [ ] `key.properties` configured and keystore safe; release builds succeed.
- [ ] Version/build number set in `pubspec.yaml` and incremented for new releases.
- [ ] Correct `google-services.json` in `android/app/src/patient/` and `android/app/src/doctor/`.
- [ ] iOS: `GoogleService-Info-Patient.plist` and `GoogleService-Info-Doctor.plist` in place; Run Script copies the right one per scheme.
- [ ] After first Play upload: add Play App Signing SHA-1/SHA-256 to Firebase for both Android apps.
- [ ] Play Console: Store listing, Data safety, and content rating done for **both** apps.
- [ ] App Store Connect: Listing and metadata complete for **both** apps.
