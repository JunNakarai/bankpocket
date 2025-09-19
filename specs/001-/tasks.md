# Tasks: 銀行口座管理アプリ

**Input**: Design documents from `/specs/001-/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Mobile iOS**: `ios/BankPocket/` for source, `ios/BankPocketTests/` for tests
- Paths follow iOS project structure from plan.md

## Phase 3.1: Setup
- [ ] T001 Create iOS project structure with BankPocket.xcodeproj and folder hierarchy
- [ ] T002 Configure iOS project with SwiftUI, Core Data framework dependencies
- [ ] T003 [P] Setup SwiftLint configuration file (.swiftlint.yml) in project root
- [ ] T004 [P] Create Core Data model file ios/BankPocket/Resources/BankPocket.xcdatamodeld

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

### Service Contract Tests
- [ ] T005 [P] CoreDataService contract test in ios/BankPocketTests/Services/CoreDataServiceTests.swift
- [ ] T006 [P] AccountService contract test in ios/BankPocketTests/Services/AccountServiceTests.swift
- [ ] T007 [P] TagService contract test in ios/BankPocketTests/Services/TagServiceTests.swift

### Model Tests
- [ ] T008 [P] BankAccount model test in ios/BankPocketTests/Models/BankAccountTests.swift
- [ ] T009 [P] Tag model test in ios/BankPocketTests/Models/TagTests.swift

### Integration Tests
- [ ] T010 [P] Account registration integration test in ios/BankPocketTests/Integration/AccountRegistrationTests.swift
- [ ] T011 [P] Tag assignment integration test in ios/BankPocketTests/Integration/TagAssignmentTests.swift
- [ ] T012 [P] Account search integration test in ios/BankPocketTests/Integration/AccountSearchTests.swift
- [ ] T013 [P] Data persistence integration test in ios/BankPocketTests/Integration/DataPersistenceTests.swift

## Phase 3.3: Core Implementation (ONLY after tests are failing)

### Core Data Models
- [ ] T014 [P] BankAccount Core Data entity in ios/BankPocket/Models/BankAccount.swift
- [ ] T015 [P] Tag Core Data entity in ios/BankPocket/Models/Tag.swift
- [ ] T016 Configure Core Data relationships and constraints in BankPocket.xcdatamodeld

### Services Layer
- [ ] T017 [P] CoreDataService implementation in ios/BankPocket/Services/CoreDataService.swift
- [ ] T018 AccountService implementation in ios/BankPocket/Services/AccountService.swift (depends on T017)
- [ ] T019 TagService implementation in ios/BankPocket/Services/TagService.swift (depends on T017)

### ViewModels (MVVM)
- [ ] T020 [P] AccountListViewModel in ios/BankPocket/ViewModels/AccountListViewModel.swift
- [ ] T021 [P] AccountFormViewModel in ios/BankPocket/ViewModels/AccountFormViewModel.swift
- [ ] T022 [P] TagManagementViewModel in ios/BankPocket/ViewModels/TagManagementViewModel.swift

### Views (SwiftUI)
- [ ] T023 [P] AccountListView in ios/BankPocket/Views/AccountListView.swift
- [ ] T024 [P] AccountFormView in ios/BankPocket/Views/AccountFormView.swift
- [ ] T025 [P] TagManagementView in ios/BankPocket/Views/TagManagementView.swift
- [ ] T026 [P] EmptyStateView component in ios/BankPocket/Views/Components/EmptyStateView.swift
- [ ] T027 [P] AccountRowView component in ios/BankPocket/Views/Components/AccountRowView.swift
- [ ] T028 [P] TagChipView component in ios/BankPocket/Views/Components/TagChipView.swift

### Error Handling
- [ ] T029 [P] AccountError enum in ios/BankPocket/Models/AccountError.swift
- [ ] T030 [P] TagError enum in ios/BankPocket/Models/TagError.swift
- [ ] T031 [P] CoreDataError enum in ios/BankPocket/Models/CoreDataError.swift

## Phase 3.4: Integration
- [ ] T032 App lifecycle integration in ios/BankPocket/App/BankPocketApp.swift
- [ ] T033 Main ContentView with navigation in ios/BankPocket/App/ContentView.swift
- [ ] T034 Core Data stack initialization and service injection
- [ ] T035 Input validation and error message localization (Japanese)
- [ ] T036 Search functionality integration across ViewModels

## Phase 3.5: Polish
- [ ] T037 [P] Unit tests for validation logic in ios/BankPocketTests/Unit/ValidationTests.swift
- [ ] T038 [P] Unit tests for ViewModels in ios/BankPocketTests/Unit/ViewModelTests.swift
- [ ] T039 Performance tests for Core Data operations (<100ms requirement)
- [ ] T040 [P] UI accessibility labels and VoiceOver support
- [ ] T041 Memory usage optimization (target <50MB)
- [ ] T042 Execute quickstart.md validation scenarios
- [ ] T043 Code review and refactoring for SwiftLint compliance

## Dependencies
- Setup (T001-T004) before everything
- Tests (T005-T013) before implementation (T014-T036)
- Core Data setup (T014-T016) before services (T017-T019)
- Services (T017-T019) before ViewModels (T020-T022)
- ViewModels before Views (T023-T028)
- Error models (T029-T031) before services that use them
- Core implementation before integration (T032-T036)
- Everything before polish (T037-T043)

## Detailed Dependencies
- T017 (CoreDataService) blocks T018, T019
- T018 (AccountService) blocks T020, T021
- T019 (TagService) blocks T022
- T020 (AccountListViewModel) blocks T023
- T021 (AccountFormViewModel) blocks T024
- T022 (TagManagementViewModel) blocks T025
- T032 blocks T033, T034
- T034 blocks T035, T036

## Parallel Example
```
# Launch contract tests together (T005-T007):
Task: "CoreDataService contract test in ios/BankPocketTests/Services/CoreDataServiceTests.swift"
Task: "AccountService contract test in ios/BankPocketTests/Services/AccountServiceTests.swift"
Task: "TagService contract test in ios/BankPocketTests/Services/TagServiceTests.swift"

# Launch model tests together (T008-T009):
Task: "BankAccount model test in ios/BankPocketTests/Models/BankAccountTests.swift"
Task: "Tag model test in ios/BankPocketTests/Models/TagTests.swift"

# Launch integration tests together (T010-T013):
Task: "Account registration integration test in ios/BankPocketTests/Integration/AccountRegistrationTests.swift"
Task: "Tag assignment integration test in ios/BankPocketTests/Integration/TagAssignmentTests.swift"
Task: "Account search integration test in ios/BankPocketTests/Integration/AccountSearchTests.swift"
Task: "Data persistence integration test in ios/BankPocketTests/Integration/DataPersistenceTests.swift"

# Launch Core Data models together (T014-T015):
Task: "BankAccount Core Data entity in ios/BankPocket/Models/BankAccount.swift"
Task: "Tag Core Data entity in ios/BankPocket/Models/Tag.swift"

# Launch ViewModels together after services complete (T020-T022):
Task: "AccountListViewModel in ios/BankPocket/ViewModels/AccountListViewModel.swift"
Task: "AccountFormViewModel in ios/BankPocket/ViewModels/AccountFormViewModel.swift"
Task: "TagManagementViewModel in ios/BankPocket/ViewModels/TagManagementViewModel.swift"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- All UI text must be in Japanese
- Follow iOS Human Interface Guidelines
- Maintain 60fps performance and <50MB memory usage

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - CoreDataService.md → T005, T017
   - AccountService.md → T006, T018
   - TagService.md → T007, T019

2. **From Data Model**:
   - BankAccount entity → T008, T014
   - Tag entity → T009, T015
   - Relationships → T016, service dependencies

3. **From User Stories** (quickstart.md):
   - Account registration → T010
   - Tag assignment → T011
   - Search functionality → T012
   - Data persistence → T013

4. **Ordering**:
   - Setup → Tests → Models → Services → ViewModels → Views → Integration → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [x] All contracts have corresponding tests (T005-T007)
- [x] All entities have model tasks (T008-T009, T014-T015)
- [x] All tests come before implementation (Phase 3.2 before 3.3)
- [x] Parallel tasks truly independent (different files, no shared dependencies)
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] ViewModels follow MVVM pattern
- [x] Core Data stack properly configured
- [x] iOS project structure matches plan.md
- [x] Japanese localization requirements included
- [x] Performance requirements addressed (60fps, <50MB, <100ms)