# TODO: Allow Admin to Edit About App Information

## Tasks
- [x] Add fetchAboutApp method in AccountServices to retrieve about app data from backend.
- [x] Add updateAboutApp method in AccountServices to update about app data.
- [x] Refactor AboutAppScreen to be stateful and fetch data on init.
- [x] Add conditional UI: editable text fields and save button for admins, read-only text for others.
- [x] Create AboutApp model for storing app information in database.
- [x] Add GET /api/about-app route for fetching about app data.
- [x] Add POST /admin/update-about-app route for updating about app data (admin only).
- [ ] Test the functionality: verify admin can edit and save, others see read-only view.
