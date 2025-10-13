# TODO: Fix Cloudinary Image Upload 400 Error

## Problem
- Product upload fails with DioException [bad response]: status code 400
- Error occurs during image upload to Cloudinary
- "Client error - the request contains bad syntax or cannot be fulfilled"

## Root Cause Analysis
- Potential issues: invalid folder name with special characters, incorrect Cloudinary credentials, upload preset configuration

## Changes Made
- [x] Added dio import to access DioException for better error handling
- [x] Sanitized folder name by replacing special characters with underscores
- [x] Added detailed error logging including response status and data

## Next Steps
- [ ] Test the upload again to see if sanitization fixes the issue
- [ ] If still failing, verify Cloudinary cloud name and upload preset
- [ ] Check if upload preset is configured for unsigned uploads
- [ ] Ensure image format and size are supported by Cloudinary
- [ ] Consider switching to signed uploads if unsigned preset is not configured properly

## Testing
- Run the app and attempt to add a product with images
- Check debug logs for detailed error information
- If 400 persists, investigate Cloudinary dashboard settings
