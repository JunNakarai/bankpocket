# AccountService Contract

**Service**: AccountService
**Responsibility**: Bank account CRUD operations and business logic

## Interface Definition

### Protocol
```swift
protocol AccountServiceProtocol {
    func createAccount(bankName: String, branchName: String, branchNumber: String, accountNumber: String) async throws -> BankAccount
    func getAllAccounts() async throws -> [BankAccount]
    func getAccount(by id: UUID) async throws -> BankAccount?
    func updateAccount(_ account: BankAccount, bankName: String?, branchName: String?, branchNumber: String?, accountNumber: String?) async throws -> BankAccount
    func deleteAccount(_ account: BankAccount) async throws
    func searchAccounts(query: String) async throws -> [BankAccount]
    func getAccountsByTag(_ tag: Tag) async throws -> [BankAccount]
}
```

## Operations

### Create Account
**Input**:
- bankName: String (required, max 100 chars)
- branchName: String (required, max 100 chars)
- branchNumber: String (required, numeric, max 10 chars)
- accountNumber: String (required, max 20 chars)

**Output**: BankAccount entity

**Business Rules**:
- Validate all inputs are non-empty after trimming
- Check for duplicate account (same bank + branch number + account number)
- Throw AccountError.duplicateAccount if exists
- Throw AccountError.invalidInput for validation failures

**Errors**:
- AccountError.duplicateAccount
- AccountError.invalidInput(field: String)
- AccountError.persistenceError

### Get All Accounts
**Input**: None

**Output**: [BankAccount] (ordered by bank name, then branch name)

**Business Rules**:
- Return empty array if no accounts
- Include all tag relationships
- Order: bankName ASC, branchName ASC

**Errors**:
- AccountError.persistenceError

### Get Account by ID
**Input**: UUID

**Output**: BankAccount? (nil if not found)

**Business Rules**:
- Return nil for non-existent ID
- Include tag relationships

**Errors**:
- AccountError.persistenceError

### Update Account
**Input**:
- account: BankAccount (existing account)
- bankName: String? (optional update)
- branchName: String? (optional update)
- branchNumber: String? (optional update)
- accountNumber: String? (optional update)

**Output**: Updated BankAccount

**Business Rules**:
- Only update provided fields (nil = no change)
- Validate updated fields using same rules as create
- Check for duplicates with new values
- Update updatedAt timestamp

**Errors**:
- AccountError.accountNotFound
- AccountError.duplicateAccount
- AccountError.invalidInput(field: String)
- AccountError.persistenceError

### Delete Account
**Input**: BankAccount

**Output**: Void

**Business Rules**:
- Remove all tag relationships automatically
- Soft delete not required (permanent deletion)

**Errors**:
- AccountError.accountNotFound
- AccountError.persistenceError

### Search Accounts
**Input**: query: String (search term)

**Output**: [BankAccount] (matching accounts)

**Business Rules**:
- Search in bankName, branchName, accountNumber
- Case-insensitive partial matching
- Return empty array if no matches
- Trim query string

**Errors**:
- AccountError.persistenceError

### Get Accounts by Tag
**Input**: Tag

**Output**: [BankAccount] (accounts with specified tag)

**Business Rules**:
- Return empty array if tag has no accounts
- Order same as getAllAccounts

**Errors**:
- AccountError.persistenceError

## Error Definitions

```swift
enum AccountError: Error, LocalizedError {
    case duplicateAccount
    case accountNotFound
    case invalidInput(field: String)
    case persistenceError

    var errorDescription: String? {
        switch self {
        case .duplicateAccount:
            return "同じ口座が既に登録されています"
        case .accountNotFound:
            return "口座が見つかりません"
        case .invalidInput(let field):
            return "\(field)の入力が無効です"
        case .persistenceError:
            return "データの保存に失敗しました"
        }
    }
}
```

## Test Contract Requirements

### Unit Tests Required
1. **testCreateAccountSuccess** - Valid input creates account
2. **testCreateAccountDuplicate** - Duplicate throws error
3. **testCreateAccountInvalidInput** - Invalid input throws error
4. **testGetAllAccountsEmpty** - Returns empty array when no accounts
5. **testGetAllAccountsOrdered** - Returns accounts in correct order
6. **testGetAccountByIdExists** - Returns correct account for valid ID
7. **testGetAccountByIdNotExists** - Returns nil for invalid ID
8. **testUpdateAccountSuccess** - Updates account fields correctly
9. **testUpdateAccountDuplicate** - Update creating duplicate throws error
10. **testDeleteAccountSuccess** - Removes account and relationships
11. **testSearchAccountsSuccess** - Returns matching accounts
12. **testSearchAccountsEmpty** - Returns empty array for no matches
13. **testGetAccountsByTag** - Returns accounts for specific tag

### Integration Tests Required
1. **testAccountTagRelationshipCascade** - Deleting account removes tag relationships
2. **testAccountPersistence** - Created accounts persist across app restarts
3. **testConcurrentOperations** - Multiple operations don't corrupt data

**Status**: ✅ COMPLETE - AccountService contract defined