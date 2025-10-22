# TODO: Add Category and Date Filters to Sales Overview

## Backend Changes
- [ ] Add new route `/admin/sales-overview` in `server/routes/admin.js` to support category and date filtering
- [ ] Implement aggregation logic for sales data with filters (category, startDate, endDate)

## Client Changes
- [ ] Update `AdminServices` in `lib/features/admin/services/admin_services.dart` to add `getSalesOverview` method with filters
- [ ] Modify `SalesOverviewScreen` in `lib/features/admin/screens/sales_overview_screen.dart` to include:
  - [ ] Category dropdown filter
  - [ ] Date range picker (start and end date)
  - [ ] Update UI layout to accommodate filters
  - [ ] Update data fetching logic to use filters
  - [ ] Update aggregation logic for filtered data

## Testing
- [ ] Test backend route with different filter combinations
- [ ] Test UI filters and data display
- [ ] Verify data accuracy with filters applied
