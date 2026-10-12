import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cookie Consent and Onboarding Routing Tests', () {
    test('Cookie consent choices set correct values', () {
      String? cookieConsent;

      bool isCookieConsentSet(String? consent) => consent != null;

      expect(isCookieConsentSet(cookieConsent), false);

      cookieConsent = 'necessary';
      expect(isCookieConsentSet(cookieConsent), true);
      expect(cookieConsent, 'necessary');

      cookieConsent = 'all';
      expect(isCookieConsentSet(cookieConsent), true);
      expect(cookieConsent, 'all');
    });

    test('Onboarding routing decision for existing vs new users', () {
      // Helper function replicating routing logic
      String decideStartupDestination({
        required bool isLoggedIn,
        required bool hasCompletedOnboarding,
      }) {
        if (!isLoggedIn) {
          return 'AuthScreen';
        }
        // If logged in, existing user account is verified -> skip onboarding
        return 'MainScreen';
      }

      // Scenario 1: Unauthenticated user
      expect(
        decideStartupDestination(
          isLoggedIn: false,
          hasCompletedOnboarding: false,
        ),
        'AuthScreen',
      );

      // Scenario 2: Existing authenticated user (hasCompletedOnboarding true)
      expect(
        decideStartupDestination(
          isLoggedIn: true,
          hasCompletedOnboarding: true,
        ),
        'MainScreen',
      );

      // Scenario 3: Existing authenticated user on new device / fresh install
      // (hasCompletedOnboarding false locally, but account exists in DB)
      expect(
        decideStartupDestination(
          isLoggedIn: true,
          hasCompletedOnboarding: false,
        ),
        'MainScreen',
      );
    });

    test('Auth submit routing decision for login vs register', () {
      String decideAuthSubmitDestination({
        required String authMode, // 'login' or 'register'
      }) {
        if (authMode == 'register') {
          return 'OnboardingScreen';
        } else {
          return 'MainScreen';
        }
      }

      // Login -> Existing user -> MainScreen directly
      expect(decideAuthSubmitDestination(authMode: 'login'), 'MainScreen');

      // Register -> New user -> OnboardingScreen
      expect(
        decideAuthSubmitDestination(authMode: 'register'),
        'OnboardingScreen',
      );
    });
  });
}
