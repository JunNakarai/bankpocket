# TagService Contract

**Service**: TagService
**Responsibility**: Tag CRUD operations and tag-account relationship management

## Interface Definition

### Protocol
```swift
protocol TagServiceProtocol {
    func createTag(name: String, color: String?) async throws -> Tag
    func getAllTags() async throws -> [Tag]
    func getTag(by id: UUID) async throws -> Tag?
    func getTag(by name: String) async throws -> Tag?
    func updateTag(_ tag: Tag, name: String?, color: String?) async throws -> Tag
    func deleteTag(_ tag: Tag) async throws
    func addTag(_ tag: Tag, to account: BankAccount) async throws
    func removeTag(_ tag: Tag, from account: BankAccount) async throws
    func getDefaultTags() -> [String]
}
```

## Operations

### Create Tag
**Input**:
- name: String (required, max 50 chars, unique)
- color: String? (optional, hex format #RRGGBB)

**Output**: Tag entity

**Business Rules**:
- Validate name is non-empty after trimming
- Check name uniqueness (case-insensitive)
- Validate color format if provided
- Throw TagError.duplicateName if name exists
- Throw TagError.invalidInput for validation failures

**Errors**:
- TagError.duplicateName
- TagError.invalidInput(field: String)
- TagError.persistenceError

### Get All Tags
**Input**: None

**Output**: [Tag] (ordered by name ascending)

**Business Rules**:
- Return empty array if no tags
- Order: name ASC
- Include account count in relationships

**Errors**:
- TagError.persistenceError

### Get Tag by ID
**Input**: UUID

**Output**: Tag? (nil if not found)

**Business Rules**:
- Return nil for non-existent ID
- Include account relationships

**Errors**:
- TagError.persistenceError

### Get Tag by Name
**Input**: name: String

**Output**: Tag? (nil if not found)

**Business Rules**:
- Case-insensitive name matching
- Return nil for non-existent name
- Include account relationships

**Errors**:
- TagError.persistenceError

### Update Tag
**Input**:
- tag: Tag (existing tag)
- name: String? (optional update)
- color: String? (optional update)

**Output**: Updated Tag

**Business Rules**:
- Only update provided fields (nil = no change)
- Validate name uniqueness if changing name
- Validate color format if changing color
- Preserve account relationships

**Errors**:
- TagError.tagNotFound
- TagError.duplicateName
- TagError.invalidInput(field: String)
- TagError.persistenceError

### Delete Tag
**Input**: Tag

**Output**: Void

**Business Rules**:
- Remove tag from all associated accounts
- Permanent deletion (no soft delete)
- Cannot delete if tag has accounts (business rule to prevent accidental deletion)

**Errors**:
- TagError.tagNotFound
- TagError.tagHasAccounts
- TagError.persistenceError

### Add Tag to Account
**Input**:
- tag: Tag
- account: BankAccount

**Output**: Void

**Business Rules**:
- Add many-to-many relationship
- No-op if relationship already exists
- Both entities must exist

**Errors**:
- TagError.tagNotFound
- TagError.accountNotFound
- TagError.persistenceError

### Remove Tag from Account
**Input**:
- tag: Tag
- account: BankAccount

**Output**: Void

**Business Rules**:
- Remove many-to-many relationship
- No-op if relationship doesn't exist
- Don't delete tag or account

**Errors**:
- TagError.tagNotFound
- TagError.accountNotFound
- TagError.persistenceError

### Get Default Tags
**Input**: None

**Output**: [String] (suggested tag names)

**Business Rules**:
- Return predefined list of common family tags
- Used for UI suggestions when creating tags
- Does not create actual Tag entities

**Errors**: None (pure function)

## Error Definitions

```swift
enum TagError: Error, LocalizedError {
    case duplicateName
    case tagNotFound
    case accountNotFound
    case tagHasAccounts
    case invalidInput(field: String)
    case persistenceError

    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "同じ名前のタグが既に存在します"
        case .tagNotFound:
            return "タグが見つかりません"
        case .accountNotFound:
            return "口座が見つかりません"
        case .tagHasAccounts:
            return "このタグは口座に関連付けられているため削除できません"
        case .invalidInput(let field):
            return "\(field)の入力が無効です"
        case .persistenceError:
            return "データの保存に失敗しました"
        }
    }
}
```

## Default Tag Definitions

```swift
extension TagService {
    func getDefaultTags() -> [String] {
        return ["私", "妻", "夫", "子供", "家計", "貯金", "投資", "共用"]
    }
}
```

## Test Contract Requirements

### Unit Tests Required
1. **testCreateTagSuccess** - Valid input creates tag
2. **testCreateTagDuplicate** - Duplicate name throws error
3. **testCreateTagInvalidColor** - Invalid color format throws error
4. **testGetAllTagsEmpty** - Returns empty array when no tags
5. **testGetAllTagsOrdered** - Returns tags in alphabetical order
6. **testGetTagByIdExists** - Returns correct tag for valid ID
7. **testGetTagByIdNotExists** - Returns nil for invalid ID
8. **testGetTagByNameExists** - Returns correct tag for valid name
9. **testGetTagByNameNotExists** - Returns nil for invalid name
10. **testUpdateTagSuccess** - Updates tag fields correctly
11. **testUpdateTagDuplicate** - Update creating duplicate throws error
12. **testDeleteTagSuccess** - Removes tag when no accounts
13. **testDeleteTagWithAccounts** - Throws error when tag has accounts
14. **testAddTagToAccount** - Creates relationship successfully
15. **testRemoveTagFromAccount** - Removes relationship successfully
16. **testGetDefaultTags** - Returns expected default tag list

### Integration Tests Required
1. **testTagAccountRelationshipBidirectional** - Relationship works both directions
2. **testTagDeletionCascade** - Tag deletion removes all account relationships
3. **testTagPersistence** - Created tags persist across app restarts

**Status**: ✅ COMPLETE - TagService contract defined