# Implementation Plan - Bug Fixes for Sign Out, Signup Redirection, and Splash Screen

Fixing three reported bugs related to authentication flow and navigation.

## Proposed Changes

### 1. Authentication & Navigation Logic

#### [app_router.dart](file:///D:/abdi/mikuplay/lib/core/router/app_router.dart)

- Update `isSignupPage` to be more robust using `startsWith('/signup')`.
- Modify `redirect` logic to allow `Routes.splash` to finish its animation without immediate redirection when logged in.
- Refine the conditions for redirection to `Routes.onboarding` and `Routes.home`.

#### [signup_step1_screen.dart](file:///D:/abdi/mikuplay/lib/features/auth/presentation/screens/signup_step1_screen.dart)

- Change `context.push(Routes.signupStep2)` to `context.go(Routes.signupStep2)` to ensure a clean transition in the auth flow.

---

### 2. Profile & Sign Out

#### [profile_screen.dart](file:///D:/abdi/mikuplay/lib/features/profile/presentation/screens/profile_screen.dart)

- Call `AuthService.instance.signOut()` in the logout confirmation dialog.
- Also clear the local cache using `FirestoreService.instance.clearLocalCache()`.

---

## Detailed Redirect Logic Improvements

In `app_router.dart`, the `redirect` function will be updated as follows:

```dart
  redirect: (context, state) async {
    final user       = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final loc        = state.matchedLocation;

    final isSplash       = loc == Routes.splash;
    final isSignupPage   = loc.startsWith('/signup');
    final isBaseAuthPage = isSplash ||
                           loc == Routes.onboarding ||
                           loc == Routes.login ||
                           loc == Routes.forgotPassword;

    // ── Case: NOT LOGGED IN ──
    if (!isLoggedIn) {
      if (isBaseAuthPage || isSignupPage) return null;
      return Routes.login;
    }

    // ── Case: LOGGED IN ──
    if (isLoggedIn) {
      // Allow Splash and Signup pages to stay without redirection
      if (isSplash || isSignupPage) return null;

      final done = await FirestoreService.instance.isOnboardingDone(user.uid);

      // If onboarding not done, force to onboarding (unless already there)
      if (!done && loc != Routes.onboarding) {
        return Routes.onboarding;
      }

      // If onboarding done, redirect away from entry pages (Login/Onboarding) to Home
      if (done && (loc == Routes.login || loc == Routes.onboarding)) {
        return Routes.home;
      }
    }

    return null;
  },
```

## Verification Plan

### Manual Verification
- **Bug 1 (Sign Out)**:
  1. Open the app and log in.
  2. Go to Profile screen.
  3. Click "Log Out" and confirm.
  4. Verify that you are redirected to the Login screen and cannot go back to the Home screen using the system back button.
- **Bug 2 (Signup Step 2)**:
  1. Go to Signup screen.
  2. Complete Step 1.
  3. Verify that you are redirected to Signup Step 2 (Profile Customization) and NOT the Onboarding screen.
- **Bug 3 (Splash Screen)**:
  1. Log in and finish onboarding.
  2. Close the app completely.
  3. Reopen the app.
  4. Verify that the Splash Screen animation plays fully before you are redirected to the Home screen.
