# TODO: Implement Email Verification for Account Creation

## Steps to Complete

- [x] Modify signup route in auth.js to set isEmailVerified: false, generate 6-digit verification code, save to user, and send verification email
- [x] Update signin route in auth.js to check isEmailVerified and return error if not verified
- [x] Uncomment and fix the /api/verify-email endpoint in auth.js to validate code and set isEmailVerified: true
- [x] Uncomment and fix the /api/resend-verification-code endpoint in auth.js to generate new code and resend email
- [x] Update /api/register-seller route in seller.js to check if user.isEmailVerified is true before proceeding
- [x] Update /api/register-seller-auth route in seller.js to check if user.isEmailVerified is true before proceeding

## Followup Steps
- [ ] Test signup with email verification (ensure email is sent)
- [ ] Test signin without verification (should fail)
- [ ] Test email verification process (verify code sets verified)
- [ ] Test seller registration with unverified account (should fail)
- [ ] Test seller registration with verified account (should succeed)

## Additional Task: Enable Sellers to Change Order Status Flexibly

## Steps to Complete

- [x] Update order_details_screens.dart to replace "Done" button with popup menu for status selection
- [x] Add changeOrderStatusTo method to handle specific status changes
- [x] Update stepper labels to match status values (Pending, Shipped, Out for Delivery, Delivered)
- [x] Allow cancellation up to "Out for Delivery" status (currentStep < 2)

## Followup Steps
- [ ] Test seller order status changes work correctly
- [ ] Verify cancelled orders cannot be modified
- [ ] Test that only sellers with products in order can change status
