# Estaraht App Flavors (Patient & Doctor)

This project builds two separate apps from one codebase: **Estaraht Patient** and **Estaraht Doctor**.

## Build commands

Always pass the flavor and the matching `APP_TYPE` so the app shows the correct flow and routes:

**Patient app**

```bash
# Run
flutter run --flavor patient --dart-define=APP_TYPE=patient

# Android release (App Bundle for Play Store)
flutter build appbundle --flavor patient --dart-define=APP_TYPE=patient

# Android release (APK for direct install)
flutter build apk --flavor patient --dart-define=APP_TYPE=patient --release

# iOS release (use scheme "patient" in Xcode or)
flutter build ipa --flavor patient --dart-define=APP_TYPE=patient
```

**Doctor app**

```bash
# Run
flutter run --flavor doctor --dart-define=APP_TYPE=doctor

# Android release (App Bundle for Play Store)
flutter build appbundle --flavor doctor --dart-define=APP_TYPE=doctor

# Android release (APK for direct install)
flutter build apk --flavor doctor --dart-define=APP_TYPE=doctor --release

# iOS release
flutter build ipa --flavor doctor --dart-define=APP_TYPE=doctor
```

**Release APK output:** `build/app/outputs/flutter-apk/`
- Patient: `app-patient-release.apk`
- Doctor: `app-doctor-release.apk`

## App IDs

| App     | Android applicationId              | iOS bundle ID                     |
|---------|------------------------------------|-----------------------------------|
| Patient | com.owldots.estarhtapppro.patient  | com.owldots.estarhtapppro.patient |
| Doctor  | com.owldots.estarhtapppro.doctor   | com.owldots.estarhtapppro.doctor  |

## Firebase (two apps in one project)

1. In [Firebase Console](https://console.firebase.google.com), open project **estaraht-84839**.
2. Register a second Android app with package name `com.owldots.estarhtapppro.patient` (if building Patient) and a third with `com.owldots.estarhtapppro.doctor` (if building Doctor). Or keep the existing app and add only the new package names.
3. Download the generated `google-services.json` for each package.
4. Place them in the flavor source sets:
   - **Patient:** `android/app/src/patient/google-services.json`
   - **Doctor:** `android/app/src/doctor/google-services.json`
5. **iOS** – see “iOS: GoogleService-Info.plist” below.

Until you add flavor-specific config, the build may use the default `google-services.json` from `android/app/`. For correct FCM/Crashlytics per app, use the steps above.

### iOS: GoogleService-Info.plist

Put **two** plist files in the **Runner** folder (same place as the main app target), with distinct names:

| App     | File to add | Bundle ID in Firebase |
|---------|-------------|------------------------|
| Patient | `ios/Runner/GoogleService-Info-Patient.plist` | `com.owldots.estarhtapppro.patient` |
| Doctor  | `ios/Runner/GoogleService-Info-Doctor.plist`  | `com.owldots.estarhtapppro.doctor` |

**Steps:**

1. In Firebase Console, add two **iOS** apps (if not already): bundle ID `com.owldots.estarhtapppro.patient` and `com.owldots.estarhtapppro.doctor`. Download each app’s **GoogleService-Info.plist**.
2. Put them in the Runner folder with the names above:
   - **Patient:** `c:\Estaraht\ios\Runner\GoogleService-Info-Patient.plist`
   - **Doctor:** `c:\Estaraht\ios\Runner\GoogleService-Info-Doctor.plist`
3. Add a **Run Script** build phase to the **Runner** target so the correct plist is used per scheme:
   - In Xcode: select the **Runner** target → **Build Phases** → **+** → **New Run Script Phase**.
   - Name it e.g. **Copy GoogleService-Info for flavor**.
   - Drag it **after** “Copy Bundle Resources” (so it runs after the default plist is copied and can overwrite it for patient/doctor).
   - In the script body, paste:

   ```bash
   if [[ "$CONFIGURATION" == *"patient"* ]]; then
     cp "${SRCROOT}/Runner/GoogleService-Info-Patient.plist" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/GoogleService-Info.plist"
   elif [[ "$CONFIGURATION" == *"doctor"* ]]; then
     cp "${SRCROOT}/Runner/GoogleService-Info-Doctor.plist" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/GoogleService-Info.plist"
   fi
   ```

   When you build with the **patient** or **doctor** scheme, this overwrites the bundled plist with the matching file. The default **Runner** scheme keeps using the existing `GoogleService-Info.plist` from Copy Bundle Resources.

## Firebase options (Dart)

The app uses **flavor-specific** Firebase options so each build gets the right `appId` and bundle IDs:

- **Patient:** `lib/firebase_options_patient.dart` → class `PatientFirebaseOptions`
- **Doctor:** `lib/firebase_options_doctor.dart` → class `DoctorFirebaseOptions`

`main.dart` initializes Firebase with `PatientFirebaseOptions.currentPlatform` or `DoctorFirebaseOptions.currentPlatform` based on `APP_TYPE`.

**To get options for each app after registering them in Firebase:**

1. Run `dart run flutterfire_cli:flutterfire configure`.
2. Select the **Patient** app (e.g. `com.owldots.estarhtapppro.patient`). This overwrites `lib/firebase_options.dart`.
3. Copy the generated `lib/firebase_options.dart` content into `lib/firebase_options_patient.dart`, rename the class from `DefaultFirebaseOptions` to `PatientFirebaseOptions`, and fix the `iosBundleId` to `com.owldots.estarhtapppro.patient` if needed.
4. Run `flutterfire configure` again and select the **Doctor** app.
5. Copy the new `lib/firebase_options.dart` content into `lib/firebase_options_doctor.dart`, rename the class to `DoctorFirebaseOptions`, and set `iosBundleId` to `com.owldots.estarhtapppro.doctor`.

You can keep `lib/firebase_options.dart` as a backup or delete it; the app only uses the two flavor files.

## Flow per app

- **Patient app:** Splash → (optional) Language → **Patient onboarding** → Login/Register → Patient tabs. No role selection.
- **Doctor app:** Splash → (optional) Language → **Therapist onboarding** → Login/Register → Doctor tabs. No role selection.
