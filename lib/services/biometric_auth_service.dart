import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  // Check if device has biometrics enrolled (Face ID or Touch ID)
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  // Get biometric type name for display
  Future<String> getBiometricTypeName() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else if (availableBiometrics.contains(BiometricType.strong) ||
               availableBiometrics.contains(BiometricType.weak)) {
      return 'Biometrikus azonosítás';
    }
    return 'Biometrikus azonosítás';
  }

  // Check if biometrics are available (either Face ID or Touch ID)
  Future<bool> isBiometricsAvailable() async {
    final bool canCheck = await canCheckBiometrics();
    final bool isSupported = await isDeviceSupported();
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    return canCheck && isSupported && availableBiometrics.isNotEmpty;
  }

  // Authenticate using biometrics
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool canAuthenticateWithBiometrics = await canCheckBiometrics();

      if (!canAuthenticateWithBiometrics) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Biometrics not available
        return false;
      } else if (e.code == auth_error.notEnrolled) {
        // No biometrics enrolled
        return false;
      } else if (e.code == auth_error.lockedOut ||
                 e.code == auth_error.permanentlyLockedOut) {
        // Too many attempts
        return false;
      }
      return false;
    }
  }

  // Stop authentication (cancel)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException {
      // Ignore errors when stopping
    }
  }
}
