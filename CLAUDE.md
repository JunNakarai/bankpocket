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
- タグ機能 (私、妻、子供など) - 色付きタグ、多対多関係
- 一覧表示・検索・編集・削除
- **長押しドラッグで順序変更** (リマインダーアプリ風)
- **CSVインポート・エクスポート機能**
- **右下浮動プラスボタン** (口座追加)
- **設定メニュー統合** (タグ管理・データ管理)
- 外部連携なし・完全ローカル動作
- オフライン必須
- タブバー廃止でスペース最大化
- **口座番号マスキングなし** (完全表示)

### Core Entities

- **BankAccount**: 銀行口座情報エンティティ (@Model)
  - 銀行名 (必須)、支店名、支店番号、口座番号 (任意)
  - **sortOrder**: 並び順管理用プロパティ
  - **tags**: タグとの多対多関係
  - **双方向関係管理**: addTag/removeTagメソッド
- **Tag**: タグエンティティ (@Model)
  - 名前、色 (hex)、デフォルトタグ付き
  - **accounts**: 口座との逆参照関係
  - **双方向関係管理**: addAccount/removeAccountメソッド

## Project Structure

```text
bankpocket/
├── Models/ (SwiftData @Model classes)
│   ├── BankAccount.swift (sortOrder付き、多対多関係)
│   ├── Tag.swift (双方向関係管理)
│   └── ValidationError.swift (Equatable準拠)
├── Views/ (SwiftUI Views)
│   ├── AccountListView.swift (検索・フィルター・並び替え・ドラッグ&ドロップ)
│   ├── AccountFormView.swift (バリデーション・タグ選択)
│   ├── TagManagementView.swift (タグCRUD・削除確認)
│   └── TagFormView.swift (タグ作成・編集・色選択)
├── Services/ (Business Logic)
│   └── CSVService.swift (インポート・エクスポート・バリデーション)
├── Utils/ (Utilities)
│   ├── ShareSheet.swift (iOS共有シート・UIViewControllerRepresentable)
│   └── PreviewHelper.swift (テスト用・@MainActor)
├── ContentView.swift (メインエントリーポイント・NavigationStack)
├── bankpocketApp.swift (App起動・ModelContainer設定)
├── Info.plist (CFBundleIconName設定)
├── bankpocket.entitlements (ファイルアクセス権限のみ)
└── Assets.xcassets (AppIcon・全サイズ対応)
├── Tests/
│   ├── bankpocketTests/ (Unit Tests)
│   │   ├── BankAccountTests.swift (モデル・バリデーション)
│   │   ├── TagTests.swift (タグ・関係性)
│   │   └── bankpocketTests.swift (基本テスト)
│   └── bankpocketUITests/ (UI Tests)
│       ├── bankpocketUITests.swift
│       └── bankpocketUITestsLaunchTests.swift
```

## UI Navigation

- **Single Screen**: NavigationStack with AccountListView (タブバー廃止)
- **Toolbar**: 右上に2つのアイコン
  - タグ管理 (tag.circle) → TagManagementView sheet
  - インポート・エクスポート (arrow.up.arrow.down.circle) → CSV機能
- **Floating Action Button**: 右下の青い円形プラスボタン
  - iOS Reminders風デザイン (影付き)
  - タップで AccountFormView sheet表示
- **Modal Sheets**: 全機能をシート形式で表示
  - 口座追加・編集フォーム
  - タグ管理画面 (作成・編集・削除)
- **No Title**: ナビゲーションタイトル非表示でスペース最大化
- **Drag & Drop**:
  - .onMove(perform: moveAccounts) 実装
  - 長押しで口座の順序変更 (sortOrder自動更新)
  - リマインダーアプリ風の操作感

## Data Management

- **SwiftData Integration**: @Query/@Environment(\.modelContext) 直接利用
- **Validation**:
  - BankAccount.validate() - 銀行名のみ必須
  - Tag.validate() - 名前・色形式チェック
  - 日本語エラーメッセージ (ValidationError enum)
- **CSV Import/Export**:
  - CSVService クラス - 完全なCRUD操作
  - 重複チェック・詳細エラーレポート
  - iOS DocumentPicker & ShareSheet統合
  - UTF-8エンコーディング対応
- **Sort Order Management**:
  - sortOrder プロパティでユーザー定義順序
  - .onMove でのドラッグ&ドロップ対応
  - 自動的な順序再計算・永続化
- **Many-to-Many Relationships**:
  - BankAccount ↔ Tag 双方向関係
  - addTag/removeTag, addAccount/removeAccount メソッド
  - 自動整合性維持・循環参照回避
  - SwiftData @Relationship マクロ不使用 (手動管理)

## Development Guidelines

- **TDD Approach**: テストファースト開発
- **Japanese UI**: 全てのUI要素は日本語
- **Error Handling**: ユーザーフレンドリーな日本語エラーメッセージ
- **Performance**: 60fps UI, <100ms データ操作
- **Memory**: <50MB使用量制限
- **Validation**: 銀行名のみ必須、他フィールド任意

## Testing Strategy

- Unit tests for model validation (BankAccountTests, TagTests)
- Model relationship tests (多対多関係)
- UI component tests (XCTest)
- Performance tests for validation
- CSV import/export functionality tests

## App Configuration

- **App Icon**: 青背景にクレジットカードデザイン
- **Entitlements**: ファイル読み取り権限のみ (完全ローカル)
- **Info.plist**: 最小限設定 (CFBundleIconName)
- **Platform Support**: iOS 15.0+

## Recent Major Changes

### 2025-09-19 - 完全実装完了

- **UI Architecture**: タブバー廃止 → 単一画面 + 浮動ボタン
- **Drag & Drop**: 長押しドラッグ順序変更実装 (.onMove)
- **CSV Features**: インポート・エクスポート機能追加 (CSVService)
- **Validation**: 銀行名のみ必須に変更、他フィールド任意
- **Many-to-Many Fix**: タグ関係性バグ修正 (双方向管理)
- **UI Polish**: 口座番号マスキング削除、iOS Reminders風デザイン
- **SwiftData**: Core Data完全移行、ModelContainer設定完了
- **App Config**: アプリアイコン全サイズ作成、entitlements最適化
- **Testing**: 全テスト通過、ValidationError Equatable対応
- **Documentation**: GitHub Spec Kit プロセス文書化

### 開発完了状況

- ✅ 全機能実装完了
- ✅ テスト全通過
- ✅ ビルド・実行確認済み
- ✅ 仕様書更新完了

## Architecture Notes

- **SwiftData Migration**: Core Data → SwiftData完全移行済み
- **ModelContainer**:
  - bankpocketApp.swift でのコンテナ設定
  - スキーマ変更時の自動リセット機能 (do-catch)
  - inMemory: false でのローカル永続化
- **@Query vs @Relationship**:
  - sortOrder による並び順管理
  - 手動関係管理でSwiftDataバグ回避
- **Error Recovery**:
  - データベース互換性問題の自動解決
  - ModelContainer生成失敗時の fallback 実装
- **Threading**:
  - @MainActor for UI context access
  - PreviewHelper の MainActor 対応

## GitHub Spec Kit 仕様書更新方法

### 手動更新プロセス

1. **実装変更時**: 機能追加・修正後にCLAUDE.mdを更新
2. **定期更新**: 開発マイルストーン毎に見直し
3. **バージョン管理**: Recent Changesセクションで変更履歴を管理

### 更新するべきタイミング

- 新機能実装完了時
- アーキテクチャ変更時
- 主要バグ修正時
- UI/UX大幅変更時

### 更新内容

- Key Requirements (機能要件)
- Project Structure (ファイル構成)
- UI Navigation (ナビゲーション)
- Data Management (データ管理)
- Recent Changes (変更履歴)

---
*Generated for Claude Code AI Assistant*
*Last Updated: 2025-09-19 (Final Implementation)*