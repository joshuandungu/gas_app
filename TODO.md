# TODO List for Implementing User-Type Based Logout Redirection

## Current Work
- Implement consistent logout redirection based on user type (seller to SellerLoginScreen, admin to AdminLoginScreen, buyer to LoginSelectionScreen).
- SellerScreen already handles seller logout correctly.
- Fix AdminScreen logout route.
- Update TopButton for dynamic redirection.

## Steps to Complete

1. [x] Modify `lib/features/admin/screens/admin_screen.dart`:
   - Add import for `AdminLoginScreen`.
   - Update the logout call to use `AdminLoginScreen.routeName` instead of the string 'AdminLoginScreen'.

2. [x] Modify `lib/features/account/widgets/top_button.dart`:
   - Add imports for `SellerLoginScreen` and `AdminLoginScreen`.
   - In the 'Log Out' button's onTap, determine the `logoutRedirectRouteName` based on `user.type`:
     - If 'seller', use `SellerLoginScreen.routeName`.
     - If 'admin', use `AdminLoginScreen.routeName`.
     - Else (buyer), use `LoginSelectionScreen.routeName`.
   - Pass the determined route to `AccountServices().logOut`.

3. [ ] Test the implementation:
   - Run the app and test logout from SellerScreen (should go to SellerLoginScreen).
   - Test logout from AdminScreen (should go to AdminLoginScreen).
   - Test logout from BottomBar/AccountScreen for a seller user (should go to SellerLoginScreen).
   - Test for admin and buyer users accordingly.

## Key Technical Concepts
- Flutter routing with `Navigator.pushNamedAndRemoveUntil`.
- User type checking via `UserProvider`.
- Imports for screen routes.

## Relevant Files
- `lib/features/admin/screens/admin_screen.dart`
- `lib/features/account/widgets/top_button.dart`
- `lib/features/account/services/account_services.dart` (used for logOut method)

## Problem Solving
- Ensure all logout points redirect correctly without hardcoding strings.
- Maintain existing functionality for other user actions.

## Next Steps After Completion
- Verify no breaking changes to navigation.
- Update TODO.md as steps are completed.
