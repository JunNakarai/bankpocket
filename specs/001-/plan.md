# Implementation Plan: 銀行口座管理アプリ

**Branch**: `001-` | **Date**: 2025-09-18 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
家族の銀行口座情報を一元管理するiOSアプリ。口座の登録、一覧表示、タグ機能による分類を実装。外部連携なし、ローカルデータ保存のシンプルなアナログ入力ベースのアプローチ。SwiftとCoreDataを使用したネイティブiOSアプリケーション。

## Technical Context
**Language/Version**: Swift 5.9+
**Primary Dependencies**: UIKit, CoreData, Foundation
**Storage**: CoreData (ローカルデータベース)
**Testing**: XCTest (単体・統合テスト)
**Target Platform**: iOS 15.0+
**Project Type**: mobile (iOS単体アプリ)
**Performance Goals**: 60fps UI, <100ms データ操作レスポンス
**Constraints**: オフライン動作必須, メモリ使用量 <50MB
**Scale/Scope**: 個人・家族利用 (~10-50口座), シングルユーザー

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitution template is blank/placeholder - no specific constitutional requirements found. Proceeding with standard iOS development best practices:
- MVVM architecture for testability
- Core Data for data persistence
- Single app target (no complexity)
- Native iOS UI components

**PASS**: No constitutional violations detected

## Project Structure

### Documentation (this feature)
```
specs/001-/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 3: Mobile + API (iOS単体アプリ)
ios/
├── BankPocket/
│   ├── App/
│   │   ├── BankPocketApp.swift
│   │   └── ContentView.swift
│   ├── Models/
│   │   ├── BankAccount.swift
│   │   └── Tag.swift
│   ├── ViewModels/
│   │   ├── AccountListViewModel.swift
│   │   └── AccountFormViewModel.swift
│   ├── Views/
│   │   ├── AccountListView.swift
│   │   ├── AccountFormView.swift
│   │   └── Components/
│   ├── Services/
│   │   └── CoreDataService.swift
│   └── Resources/
│       └── BankPocket.xcdatamodeld
└── BankPocketTests/
    ├── Models/
    ├── ViewModels/
    └── Services/
```

**Structure Decision**: Option 3 (Mobile) - iOS単体アプリケーション

## Phase 0: Outline & Research
No NEEDS CLARIFICATION markers remain in Technical Context. All technical decisions are clear:
- Swift/iOS development stack
- CoreData for persistence
- Standard iOS app architecture
- Target iOS 15.0+

**Research Complete**: All technical unknowns resolved

## Phase 1: Design & Contracts

### 1. Data Model Design
From feature specification entities:
- **BankAccount**: bankName, branchName, branchNumber, accountNumber, tags
- **Tag**: name, accounts (relationship)

### 2. API Contracts (Local Operations)
Since this is a local-only app, "contracts" are internal service interfaces:
- AccountService: CRUD operations for bank accounts
- TagService: Tag management operations
- StorageService: CoreData persistence layer

### 3. Contract Tests
Unit tests for service layer interfaces ensuring data integrity and business rules

### 4. Integration Test Scenarios
Based on acceptance scenarios from spec:
- Account registration flow
- Account listing with tag filtering
- Account editing and deletion
- Tag assignment and management

### 5. Agent Context Update
Update CLAUDE.md with current iOS/Swift project context

**Design Phase Ready for Execution**

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each service interface → contract test task [P]
- Each Core Data entity → model creation task [P]
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation
- Dependency order: Models before ViewModels before Views
- Core Data setup before model tests
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 20-25 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md following iOS best practices)
**Phase 5**: Validation (run tests, execute quickstart.md, UI testing validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

No constitutional violations detected. Standard iOS app architecture used.

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*