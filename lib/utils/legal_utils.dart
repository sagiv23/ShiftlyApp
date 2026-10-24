import 'package:flutter/material.dart';
import 'package:shiftly/widgets/cookie_consent_banner.dart';
import 'package:shiftly/widgets/legal_document_viewer.dart';

/// Centralized utility helper for presenting legal documents and privacy/cookie preferences.
class LegalUtils {
  LegalUtils._();

  /// Opens the Privacy Policy document viewer.
  static void showPrivacyPolicy(BuildContext context) {
    LegalDocumentViewer.show(context, LegalDocumentType.privacyPolicy);
  }

  /// Opens the Terms of Service document viewer.
  static void showTermsOfService(BuildContext context) {
    LegalDocumentViewer.show(context, LegalDocumentType.termsOfService);
  }

  /// Opens the Accessibility Statement document viewer.
  static void showAccessibilityStatement(BuildContext context) {
    LegalDocumentViewer.show(context, LegalDocumentType.accessibilityStatement);
  }

  /// Opens the Cookie & Privacy Preferences modal sheet.
  static Future<void> showCookiePreferences(BuildContext context) {
    return CookiePreferencesModal.show(context);
  }
}
