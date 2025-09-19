# CoreDataService Contract

**Service**: CoreDataService
**Responsibility**: Core Data stack management and low-level persistence operations

## Interface Definition

### Protocol
```swift
protocol CoreDataServiceProtocol {
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }

    func saveContext() async throws
    func saveContext(_ context: NSManagedObjectContext) async throws
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T
    func reset() async throws
}
```

## Core Data Stack

### Persistent Container Configuration
- **Store Type**: NSSQLiteStoreType
- **Store Name**: "BankPocket.sqlite"
- **Store Location**: Application Documents Directory
- **Migration**: Automatic lightweight migration enabled
- **WAL Mode**: Enabled for better performance
- **Foreign Key Constraints**: Enabled

### Context Configuration
- **Main Context**: NSMainQueueConcurrencyType for UI operations
- **Background Context**: NSPrivateQueueConcurrencyType for heavy operations
- **Merge Policy**: NSMergeByPropertyObjectTrumpMergePolicy
- **Undo Manager**: Disabled for performance

## Operations

### Save Context (Main)
**Input**: None (operates on viewContext)

**Output**: Void

**Business Rules**:
- Only save if context has changes
- Automatic merge with background context changes
- Handle save conflicts with merge policy

**Errors**:
- CoreDataError.saveError(NSError)
- CoreDataError.contextError

### Save Context (Specific)
**Input**: NSManagedObjectContext

**Output**: Void

**Business Rules**:
- Save specific context to persistent store
- Handle parent context chain saves
- Merge changes to other contexts

**Errors**:
- CoreDataError.saveError(NSError)
- CoreDataError.contextError

### Perform Background Task
**Input**: Block returning generic type T

**Output**: T (result of block execution)

**Business Rules**:
- Execute block on background context
- Automatic context save if changes made
- Exception handling for block execution

**Errors**:
- CoreDataError.backgroundTaskError
- CoreDataError.saveError(NSError)

### Reset
**Input**: None

**Output**: Void

**Business Rules**:
- Reset both main and background contexts
- Clear all in-memory changes
- Used for testing and error recovery

**Errors**:
- CoreDataError.resetError

## Error Definitions

```swift
enum CoreDataError: Error, LocalizedError {
    case initializationError
    case saveError(NSError)
    case contextError
    case backgroundTaskError
    case resetError

    var errorDescription: String? {
        switch self {
        case .initializationError:
            return "データベースの初期化に失敗しました"
        case .saveError(let error):
            return "データの保存に失敗しました: \(error.localizedDescription)"
        case .contextError:
            return "データコンテキストエラーが発生しました"
        case .backgroundTaskError:
            return "バックグラウンド処理でエラーが発生しました"
        case .resetError:
            return "データベースのリセットに失敗しました"
        }
    }
}
```

## Core Data Model Configuration

### Entity Configurations

#### BankAccount Entity
```swift
// Entity: BankAccount
// Code Generation: Category/Extension
@objc(BankAccount)
public class BankAccount: NSManagedObject {
    // Auto-generated properties and relationships
}

extension BankAccount {
    @NSManaged public var id: UUID
    @NSManaged public var bankName: String
    @NSManaged public var branchName: String
    @NSManaged public var branchNumber: String
    @NSManaged public var accountNumber: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var tags: NSSet?
}
```

#### Tag Entity
```swift
// Entity: Tag
// Code Generation: Category/Extension
@objc(Tag)
public class Tag: NSManagedObject {
    // Auto-generated properties and relationships
}

extension Tag {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var accounts: NSSet?
}
```

### Fetch Request Templates
- **AllAccounts**: Fetch all accounts ordered by bankName
- **AllTags**: Fetch all tags ordered by name
- **AccountsByTag**: Fetch accounts filtered by specific tag
- **SearchAccounts**: Fetch accounts matching search criteria

### Performance Configurations
- **Batch Size**: 50 for large result sets
- **Fetch Limit**: 1000 maximum per request
- **Relationship Faulting**: Enabled for memory efficiency
- **Indexes**: bankName, tag.name for faster queries

## Migration Strategy

### Version 1.0 → 1.1 (Example Future Migration)
- **Lightweight Migration**: Add optional fields
- **Heavyweight Migration**: For relationship changes
- **Migration Policy**: Custom NSEntityMigrationPolicy if needed
- **Data Validation**: Post-migration data integrity checks

## Test Configuration

### Test Core Data Stack
- **In-Memory Store**: NSInMemoryStoreType for fast tests
- **Isolated Context**: Each test gets fresh context
- **Test Data Factory**: Predefined test entities
- **Context Reset**: Automatic cleanup between tests

## Test Contract Requirements

### Unit Tests Required
1. **testCoreDataStackInitialization** - Stack initializes correctly
2. **testSaveContextWithChanges** - Save succeeds with changes
3. **testSaveContextWithoutChanges** - Save no-op without changes
4. **testSaveContextError** - Handle save errors gracefully
5. **testBackgroundTaskSuccess** - Background task executes correctly
6. **testBackgroundTaskWithSave** - Background changes saved automatically
7. **testBackgroundTaskError** - Handle background task errors
8. **testContextMerging** - Changes merge between contexts
9. **testResetContext** - Reset clears all changes
10. **testConcurrentAccess** - Multiple contexts access safely

### Integration Tests Required
1. **testPersistenceAcrossLaunches** - Data persists between app launches
2. **testMigrationCompatibility** - Schema migrations work correctly
3. **testMemoryManagement** - No memory leaks in Core Data operations

**Status**: ✅ COMPLETE - CoreDataService contract defined