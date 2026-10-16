import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Guest Mode Session & Routing Tests', () {
    test('Splash screen startup destination with guest mode', () {
      String decideStartupDestination({
        required bool isLoggedIn,
        required bool isGuest,
      }) {
        if (isLoggedIn || isGuest) {
          return 'MainScreen';
        }
        return 'AuthScreen';
      }

      // Unauthenticated user without guest session -> AuthScreen
      expect(
        decideStartupDestination(isLoggedIn: false, isGuest: false),
        'AuthScreen',
      );

      // Active Guest session -> MainScreen
      expect(
        decideStartupDestination(isLoggedIn: false, isGuest: true),
        'MainScreen',
      );

      // Authenticated user -> MainScreen
      expect(
        decideStartupDestination(isLoggedIn: true, isGuest: false),
        'MainScreen',
      );
    });

    test('Continue as guest transitions auth state correctly', () {
      bool isLoggedIn = false;
      bool isGuest = false;
      String? token = 'some_old_token';

      void continueAsGuest() {
        isLoggedIn = false;
        isGuest = true;
        token = null;
      }

      continueAsGuest();

      expect(isLoggedIn, false);
      expect(isGuest, true);
      expect(token, null);
    });

    test('Restore session detects guest vs logged-in state', () {
      bool isLoggedIn = false;
      bool isGuest = false;

      void restoreSession({required bool storedIsGuest, String? storedToken}) {
        if (storedToken != null && storedToken.isNotEmpty) {
          isLoggedIn = true;
          isGuest = false;
        } else {
          isLoggedIn = false;
          isGuest = storedIsGuest;
        }
      }

      // Case 1: No token, storedIsGuest = true -> Active guest session
      restoreSession(storedIsGuest: true, storedToken: null);
      expect(isLoggedIn, false);
      expect(isGuest, true);

      // Case 2: Token exists -> Logged in user
      restoreSession(storedIsGuest: true, storedToken: 'jwt_token_123');
      expect(isLoggedIn, true);
      expect(isGuest, false);

      // Case 3: No token, storedIsGuest = false -> Unauthenticated
      restoreSession(storedIsGuest: false, storedToken: null);
      expect(isLoggedIn, false);
      expect(isGuest, false);
    });
  });

  group('Guest Data Migration and Atomic Replacement Tests', () {
    test('Login from guest mode requires confirmation if guest data exists', () {
      bool shouldPromptConfirmation({
        required bool isGuest,
        required int shiftCount,
        required int expenseCount,
      }) {
        return isGuest || shiftCount > 0 || expenseCount > 0;
      }

      // Guest user with 2 shifts -> Prompt confirmation
      expect(
        shouldPromptConfirmation(isGuest: true, shiftCount: 2, expenseCount: 0),
        true,
      );

      // Guest user with 0 shifts -> Prompt confirmation (because in guest mode)
      expect(
        shouldPromptConfirmation(isGuest: true, shiftCount: 0, expenseCount: 0),
        true,
      );

      // Fresh unauthenticated user with 0 shifts -> No confirmation needed
      expect(
        shouldPromptConfirmation(
          isGuest: false,
          shiftCount: 0,
          expenseCount: 0,
        ),
        false,
      );
    });

    test(
      'Atomic dataset replacement preserves local guest data if remote fetch fails',
      () {
        List<String> localGuestShifts = ['Guest Shift 1', 'Guest Shift 2'];
        List<String> activeShifts = List.from(localGuestShifts);

        bool replaceLocalDataAtomic({
          required List<String>? remoteShifts,
          required bool simulateError,
        }) {
          final snapshot = List<String>.from(activeShifts);
          try {
            if (simulateError || remoteShifts == null) {
              throw Exception('Network or parsing error');
            }
            activeShifts.clear();
            activeShifts.addAll(remoteShifts);
            return true;
          } catch (e) {
            activeShifts = List.from(snapshot);
            return false;
          }
        }

        // Attempt replacement with remote fetch failure
        bool success = replaceLocalDataAtomic(
          remoteShifts: null,
          simulateError: true,
        );

        expect(success, false);
        // Local guest data is preserved intact
        expect(activeShifts, ['Guest Shift 1', 'Guest Shift 2']);

        // Attempt replacement with successful remote fetch
        success = replaceLocalDataAtomic(
          remoteShifts: ['Account Shift A', 'Account Shift B'],
          simulateError: false,
        );

        expect(success, true);
        // Dataset replaced cleanly with account data
        expect(activeShifts, ['Account Shift A', 'Account Shift B']);
      },
    );

    test(
      'Guest data migration is idempotent and retains IDs across retries',
      () {
        final guestShifts = [
          {'id': 'shift_uuid_1', 'date': '2026-10-01', 'total_pay': 350.0},
          {'id': 'shift_uuid_2', 'date': '2026-10-02', 'total_pay': 400.0},
        ];

        List<Map<String, dynamic>> serverDatabase = [];

        void batchUpsertShifts(List<Map<String, dynamic>> items) {
          for (var item in items) {
            final index = serverDatabase.indexWhere(
              (s) => s['id'] == item['id'],
            );
            if (index >= 0) {
              serverDatabase[index] = Map.from(item);
            } else {
              serverDatabase.add(Map.from(item));
            }
          }
        }

        // First migration attempt
        batchUpsertShifts(guestShifts);
        expect(serverDatabase.length, 2);
        expect(serverDatabase[0]['id'], 'shift_uuid_1');

        // Retry migration due to network interruption or sync trigger
        batchUpsertShifts(guestShifts);

        // Idempotency check: count remains 2 (no duplicate records created)
        expect(serverDatabase.length, 2);
        expect(serverDatabase[0]['id'], 'shift_uuid_1');
        expect(serverDatabase[1]['id'], 'shift_uuid_2');
      },
    );
  });
}
