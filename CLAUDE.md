# Claude Code Context: BankPocket

## Project Overview
**Type**: iOS アプリケーション
**Purpose**: 家族の銀行口座情報を一元管理するシンプルなアプリ

## Tech Stack
**Language**: Swift 5.9+
**Platform**: iOS 15.0+
**UI Framework**: SwiftUI
**Architecture**: SwiftUI標準パターン (直接モデルアクセス)
**Data Persistence**: SwiftData
**Testing**: XCTest

## Current Feature: 001- 銀行口座管理アプリ
家族全員の銀行口座情報を登録・管理し、タグ機能で分類できるローカルアプリ

### Key Requirements
- 口座情報登録 (銀行名必須、その他任意)
- タグ機能 (私、妻、子供など) - 色付きタグ
- 一覧表示・検索・編集・削除
- 外部連携なし・完全ローカル動作
- オフライン必須
- タブバー廃止でスペース最大化

### Core Entities
- **BankAccount**: 銀行口座情報エンティティ (@Model)
  - 銀行名 (必須)、支店名、支店番号、口座番号 (任意)
  - タグとの多対多関係
- **Tag**: タグエンティティ (@Model)
  - 名前、色 (hex)、デフォルトタグ付き

## Project Structure
```
bankpocket/
├── Models/ (SwiftData @Model classes)
│   ├── BankAccount.swift
│   ├── Tag.swift
│   └── ValidationError.swift
├── Views/ (SwiftUI Views)
│   ├── AccountListView.swift
│   ├── AccountFormView.swift
│   └── TagManagementView.swift
├── ContentView.swift (メインエントリーポイント)
└── Assets.xcassets
```

## UI Navigation
- **Single Screen**: NavigationStack with AccountListView
- **Toolbar**: 右上に口座追加(+)とタグ管理(tag.circle)アイコン
- **Modal Sheets**: 口座フォーム、タグ管理画面
- **No Title**: ナビゲーションタイトル非表示でスペース節約

## Data Management
- **Direct Model Access**: @Query/@Environment(\.modelContext)
- **Validation**: モデルレベルでのバリデーション実装
- **Error Handling**: 日本語バリデーションエラー

## Development Guidelines
- **TDD Approach**: テストファースト開発
- **Japanese UI**: 全てのUI要素は日本語
- **Error Handling**: ユーザーフレンドリーな日本語エラーメッセージ
- **Performance**: 60fps UI, <100ms データ操作
- **Memory**: <50MB使用量制限
- **Validation**: 銀行名のみ必須、他フィールド任意

## Testing Strategy
- Unit tests for model validation
- Model relationship tests
- UI component tests (XCTest)
- Performance tests for validation

## Recent Changes
- SwiftData models implemented
- Single-screen UI with toolbar navigation
- Validation updated: only bank name required
- Navigation title removed for space optimization
- Tag management moved to modal sheet

---
*Generated for Claude Code AI Assistant*
*Last Updated: 2025-09-19*