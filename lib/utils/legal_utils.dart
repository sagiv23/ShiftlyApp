import 'package:flutter/material.dart';
import 'package:shiftly/widgets/cookie_consent_banner.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralized utility helper for presenting legal documents and privacy/cookie preferences.
class LegalUtils {
  LegalUtils._();

  /// Opens the Privacy Policy web page.
  static Future<void> showPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse('https://sagiv23.github.io/Shiftly/privacy.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the Terms of Service web page.
  static Future<void> showTermsOfService(BuildContext context) async {
    final Uri url = Uri.parse('https://sagiv23.github.io/Shiftly/terms.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the Accessibility Statement web page.
  static Future<void> showAccessibilityStatement(BuildContext context) async {
    final Uri url = Uri.parse(
      'https://sagiv23.github.io/Shiftly/accessibility.html',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the Cookie & Privacy Preferences modal sheet.
  static Future<void> showCookiePreferences(BuildContext context) {
    return CookiePreferencesModal.show(context);
  }
}
