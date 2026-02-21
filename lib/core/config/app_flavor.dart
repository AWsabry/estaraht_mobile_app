/// App flavor: compile-time app type for Patient vs Doctor apps.
///
/// Set via: --dart-define=APP_TYPE=patient or --dart-define=APP_TYPE=doctor
/// When using Flutter flavors: flutter run --flavor patient --dart-define=APP_TYPE=patient
const String _appType = String.fromEnvironment(
  'APP_TYPE',
  defaultValue: 'patient',
);

/// True when building the Patient app flavor.
bool get isPatientApp => _appType == 'patient';

/// True when building the Doctor app flavor.
bool get isDoctorApp => _appType == 'doctor';
