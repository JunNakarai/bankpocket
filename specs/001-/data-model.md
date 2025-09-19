# Data Model: 銀行口座管理アプリ

**Date**: 2025-09-18
**Feature**: 銀行口座管理アプリ

## Core Data Model

### Entities

#### BankAccount
Primary entity for storing bank account information.

**Attributes**:
- `id`: UUID (Primary Key, Auto-generated)
- `bankName`: String (Required, Max 100 characters)
- `branchName`: String (Required, Max 100 characters)
- `branchNumber`: String (Required, Max 10 characters, Numeric)
- `accountNumber`: String (Required, Max 20 characters)
- `createdAt`: Date (Auto-generated)
- `updatedAt`: Date (Auto-updated)

**Relationships**:
- `tags`: To-many relationship to Tag entity
- Inverse: Tag.accounts

**Validation Rules**:
- bankName: Non-empty string, trimmed
- branchName: Non-empty string, trimmed
- branchNumber: Numeric string, 1-10 digits
- accountNumber: Non-empty string, no specific format validation (banks vary)

#### Tag
Entity for categorizing bank accounts (family member classification).

**Attributes**:
- `id`: UUID (Primary Key, Auto-generated)
- `name`: String (Required, Unique, Max 50 characters)
- `color`: String (Optional, Hex color code)
- `createdAt`: Date (Auto-generated)

**Relationships**:
- `accounts`: To-many relationship to BankAccount entity
- Inverse: BankAccount.tags

**Validation Rules**:
- name: Non-empty string, trimmed, unique across all tags
- color: Optional hex color code format (#RRGGBB)

## Entity Relationships

```
BankAccount ||--o{ Tag
    (Many-to-Many)

- One account can have multiple tags (私, 妻, 子供, etc.)
- One tag can be applied to multiple accounts
- Relationship is optional (accounts can exist without tags)
```

## Business Rules

### Account Management
1. **Unique Account Identification**: No two accounts with identical (bankName + branchNumber + accountNumber) combination
2. **Required Fields**: All core account fields must be provided during creation
3. **Account Deletion**: Cascade delete removes all tag relationships
4. **Account Updates**: updatedAt timestamp automatically updated on any change

### Tag Management
1. **Unique Tag Names**: No duplicate tag names allowed
2. **Tag Deletion**: When tag deleted, remove from all associated accounts
3. **Default Tags**: System provides suggested tags (私, 妻, 子供) but users can create custom tags
4. **Tag Colors**: Optional visual identification for better UX

### Data Integrity
1. **Referential Integrity**: Core Data handles relationship consistency
2. **Cascade Rules**: Account deletion removes tag relationships
3. **Validation**: All string inputs trimmed and validated before persistence
4. **Backup/Recovery**: Core Data automatic journaling for crash recovery

## Core Data Configuration

### Persistent Container
- Store Type: SQLite
- Store Location: Application Documents Directory
- Migration: Automatic lightweight migration enabled
- Concurrency: MainQueue context for UI, PrivateQueue for background operations

### Fetch Requests
- **Default Account List**: Ordered by bankName ascending, then branchName ascending
- **Tagged Accounts**: Filtered by specific tag relationship
- **Search**: NSPredicate on bankName, branchName, or accountNumber containing search term

### Performance Considerations
- Index on bankName for faster sorting
- Index on tag.name for filtering operations
- Batch size: 50 accounts per fetch for large datasets
- Faulting: Lazy loading of tag relationships

## Schema Evolution

### Version 1.0 (Initial)
- BankAccount and Tag entities as specified above
- Many-to-many relationship between entities

### Future Considerations
- Account balance tracking (if requested)
- Account notes/memo fields
- Account status (active/inactive)
- Export/import functionality
- Backup to iCloud (if requested)

## Test Data Structure

### Sample Accounts
```
Account 1:
- Bank: みずほ銀行
- Branch: 渋谷支店
- Branch Number: 123
- Account Number: 1234567
- Tags: [私]

Account 2:
- Bank: 三菱UFJ銀行
- Branch: 新宿支店
- Branch Number: 456
- Account Number: 9876543
- Tags: [妻, 家計]
```

### Sample Tags
```
Tag 1: 私 (Blue)
Tag 2: 妻 (Pink)
Tag 3: 子供 (Green)
Tag 4: 家計 (Orange)
Tag 5: 貯金 (Purple)
```

**Status**: ✅ COMPLETE - Data model design finalized