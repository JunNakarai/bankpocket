# Quickstart Guide: 銀行口座管理アプリ

**Date**: 2025-09-18
**Purpose**: Manual testing and validation of core functionality

## Prerequisites

### Development Environment
- Xcode 15.0+
- iOS Simulator 15.0+
- Swift 5.9+

### Project Setup
1. Open BankPocket.xcodeproj in Xcode
2. Select iOS Simulator (iPhone 14 or newer)
3. Build and run (⌘+R)

## Core Feature Validation

### 1. Initial App Launch
**Expected Behavior**:
- App launches successfully
- Empty account list is displayed
- "口座を追加" (Add Account) button is visible
- No crash or error messages

**Test Steps**:
1. Launch app from Xcode
2. Verify empty state UI is shown
3. Check console for any error messages

**Success Criteria**:
- ✅ App launches without crash
- ✅ Empty state UI displayed
- ✅ No error messages in console

### 2. Add First Bank Account
**Test Data**:
- Bank Name: みずほ銀行
- Branch Name: 渋谷支店
- Branch Number: 123
- Account Number: 1234567

**Test Steps**:
1. Tap "口座を追加" button
2. Fill in all required fields
3. Tap "保存" (Save) button
4. Return to account list

**Expected Behavior**:
- Form accepts all input
- No validation errors
- Account appears in list
- Account shows correct information

**Success Criteria**:
- ✅ Form submission successful
- ✅ Account visible in list
- ✅ All data displayed correctly
- ✅ Empty state no longer shown

### 3. Add Multiple Accounts
**Test Data Set**:
```
Account 2:
- Bank: 三菱UFJ銀行
- Branch: 新宿支店
- Branch Number: 456
- Account Number: 9876543

Account 3:
- Bank: 三井住友銀行
- Branch: 池袋支店
- Branch Number: 789
- Account Number: 5555555
```

**Test Steps**:
1. Add Account 2 using above data
2. Add Account 3 using above data
3. Verify list shows all 3 accounts
4. Check account ordering (by bank name)

**Expected Behavior**:
- All accounts added successfully
- List shows accounts in alphabetical order by bank name
- No duplicate entries
- Performance remains smooth

**Success Criteria**:
- ✅ 3 accounts total in list
- ✅ Correct alphabetical ordering
- ✅ No duplicates or corruption

### 4. Create and Assign Tags
**Test Tags**:
- 私 (Blue color)
- 妻 (Pink color)
- 家計 (Orange color)

**Test Steps**:
1. Navigate to tags section
2. Create "私" tag with blue color
3. Create "妻" tag with pink color
4. Create "家計" tag with orange color
5. Assign "私" tag to first account
6. Assign "妻" tag to second account
7. Assign "家計" tag to third account

**Expected Behavior**:
- Tags created successfully
- Colors displayed correctly
- Tag assignment works
- Accounts show assigned tags

**Success Criteria**:
- ✅ All tags created with correct colors
- ✅ Tag assignment successful
- ✅ Tags visible on accounts

### 5. Filter by Tags
**Test Steps**:
1. Select "私" tag filter
2. Verify only accounts with "私" tag shown
3. Select "妻" tag filter
4. Verify only accounts with "妻" tag shown
5. Clear filter to show all accounts

**Expected Behavior**:
- Filtering works correctly
- Only matching accounts displayed
- Clear filter restores all accounts
- UI indicates active filter

**Success Criteria**:
- ✅ Tag filtering works correctly
- ✅ Filter clear restores all accounts
- ✅ UI feedback for active filters

### 6. Edit Account Information
**Test Steps**:
1. Select first account (みずほ銀行)
2. Edit account number to: 7777777
3. Save changes
4. Verify account list shows updated number

**Expected Behavior**:
- Edit form pre-populated with current data
- Changes saved successfully
- List reflects updated information
- updatedAt timestamp updated

**Success Criteria**:
- ✅ Edit form works correctly
- ✅ Changes persisted and visible
- ✅ Data integrity maintained

### 7. Search Functionality
**Test Steps**:
1. Enter "みずほ" in search field
2. Verify only みずほ銀行 account shown
3. Enter "123" in search field
4. Verify account with branch number 123 shown
5. Clear search to show all accounts

**Expected Behavior**:
- Search works on bank name
- Search works on branch number
- Case-insensitive matching
- Real-time search results

**Success Criteria**:
- ✅ Bank name search works
- ✅ Branch number search works
- ✅ Case-insensitive matching
- ✅ Search clear restores all results

### 8. Delete Account
**Test Steps**:
1. Select account to delete (third account)
2. Tap delete option
3. Confirm deletion
4. Verify account removed from list
5. Check that associated tags remain

**Expected Behavior**:
- Confirmation dialog shown
- Account deleted from storage
- Tag relationships removed
- Tags not deleted (still available for other accounts)
- List updates correctly

**Success Criteria**:
- ✅ Deletion confirmation required
- ✅ Account permanently removed
- ✅ Tags preserved for other accounts
- ✅ List updated correctly

### 9. App State Persistence
**Test Steps**:
1. Force quit app
2. Relaunch app
3. Verify all data persists
4. Check accounts, tags, and relationships

**Expected Behavior**:
- All accounts preserved
- All tags preserved
- Tag-account relationships preserved
- No data corruption

**Success Criteria**:
- ✅ Accounts persist across launches
- ✅ Tags persist across launches
- ✅ Relationships preserved
- ✅ No data loss or corruption

### 10. Error Handling
**Test Steps**:
1. Try to create account with empty bank name
2. Try to create account with invalid branch number (letters)
3. Try to create duplicate account
4. Try to delete tag that's assigned to accounts

**Expected Behavior**:
- Validation errors displayed
- User-friendly error messages in Japanese
- No crashes or data corruption
- Clear guidance on fixing errors

**Success Criteria**:
- ✅ Input validation works
- ✅ Error messages in Japanese
- ✅ No crashes during error conditions
- ✅ Clear user guidance provided

## Performance Validation

### Memory Usage
**Test Steps**:
1. Monitor app in Xcode Memory Debug Navigator
2. Add 20+ accounts with tags
3. Navigate through all screens
4. Check memory usage stays under 50MB

**Success Criteria**:
- ✅ Memory usage < 50MB with 20+ accounts
- ✅ No memory leaks detected
- ✅ Smooth performance maintained

### UI Responsiveness
**Test Steps**:
1. Add 50+ accounts (stress test)
2. Scroll through account list
3. Filter by tags with many accounts
4. Search with many results

**Success Criteria**:
- ✅ 60fps scrolling performance
- ✅ < 100ms response time for data operations
- ✅ No UI freezing or lag

## Acceptance Checklist

### Core Functionality
- [ ] App launches successfully
- [ ] Account creation works
- [ ] Account list displays correctly
- [ ] Tag creation and assignment works
- [ ] Tag filtering works
- [ ] Account editing works
- [ ] Account deletion works
- [ ] Search functionality works
- [ ] Data persistence works

### User Experience
- [ ] All text in Japanese
- [ ] Intuitive navigation
- [ ] Error messages user-friendly
- [ ] Responsive UI (60fps)
- [ ] Memory efficient (<50MB)

### Data Integrity
- [ ] No data corruption
- [ ] Proper validation
- [ ] Referential integrity maintained
- [ ] Graceful error handling

**Status**: ✅ COMPLETE - Quickstart guide ready for testing