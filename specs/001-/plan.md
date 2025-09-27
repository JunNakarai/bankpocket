# 実装計画: 銀行口座管理アプリ

**ブランチ**: `001-`  |  **日付**: 2025-09-18  |  **仕様書**: [spec.md](./spec.md)  
**入力**: `/specs/001-/spec.md` のフィーチャ仕様

## 実行手順（/plan コマンド想定）

```text
1. 指定パスから仕様書を読み込む
   → 見つからない場合は "No feature spec at {path}" で終了
2. 技術コンテキスト欄を埋める（不明点は NEEDS CLARIFICATION として記録）
   → プロジェクト種別を判定し、構成方針を決定
3. 憲法チェック（constitution）を参照し、違反があれば記録
4. Phase 0 研究: 不明点があれば洗い出し、解決できない場合はエラー
5. Phase 1 設計: contracts / data-model / quickstart などのドキュメントを出力
6. 憲法チェックを再実行し、設計時の逸脱がないか確認
7. Phase 2 ではタスク生成方針のみ整理（実際の tasks.md 生成は /tasks）
8. 以降の実装フェーズは /plan の対象外として終了
```text

## サマリー

家族が保有する複数の銀行口座をタグで整理する iOS アプリ。
SwiftUI + SwiftData を採用し、オフライン利用と軽量な CSV 入出力をサポート。
UI は日本語のみ、外部 API 連携なし。

## 技術コンテキスト

- **言語 / バージョン**: Swift 5.9 以上
- **主要依存**: SwiftUI, SwiftData, Foundation, UniformTypeIdentifiers
- **データストア**: SwiftData (SQLite バックエンド)
- **テスト**: XCTest（ユニット / 統合 / UI）
- **ターゲット OS**: iOS 17.0 以上（シミュレータ iPhone 16 を想定）
- **プロジェクト種別**: モバイル単体アプリ（サーバ連携なし）
- **パフォーマンス目標**: UI 60fps、主要操作 100ms 以内
- **制約**: 完全オフライン対応、メモリ使用量 50MB 以内

## 憲法チェック

- 現時点で constitution に特別な制約なし
- MVVM を基本に View とモデルを分離
- ネイティブ UI を利用し、プラットフォーム規約に従う

**判定**: PASS（違反なし）

## プロジェクト構成

### ドキュメント（仕様ディレクトリ）

```text
specs/001-/
├── spec.md            # 仕様書
├── plan.md            # この計画書
├── data-model.md      # データモデル定義
├── quickstart.md      # 手動検証手順
├── tasks.md           # タスク一覧（/tasks で生成）
└── contracts/         # サービス契約定義（必要時）
### ソースコード

```text

bankpocket/
├── bankpocketApp.swift
├── ContentView.swift
├── Models/
├── Services/
├── Utils/
└── Views/

bankpocketTests/
└── ...（ユニット・統合テスト）

bankpocketUITests/
└── ...（UI テスト）

```

## Phase 0: 調査状況

- 仕様上の不明点は quickstart と data-model で補完済み
- CoreData ではなく SwiftData を採用する方針を確定
- 追加の事前調査は不要

## Phase 1: 設計結果

1. **データモデル**: BankAccount / Tag / AccountTagAssignment の 3 エンティティとバリデーションを定義
2. **サービス契約**: 口座操作、タグ操作、CSV 入出力のインターフェースを整理（contracts 配下）
3. **受け入れシナリオ**: quickstart.md に 10 個の検証ケースを記載
4. **View / ViewModel 方針**: SwiftUI + MVVM、DI は `@Environment(\.modelContext)` を基本に構成

## Phase 2: タスク生成方針（説明のみ）

- `/tasks` では tests → implementation → polish の順にタスク化
- 各契約/エンティティ/受け入れシナリオから最低 1 つずつテストタスクを作成
- 並列実行可能なタスクは `[P]` を付け、依存関係を明示
- 出力ファイルは `specs/001-/tasks.md`

## Phase 3 以降（参考）

- Phase 3: `/tasks` でタスク生成、進捗管理の起点
- Phase 4: タスクに沿って実装、テスト、リファクタリング
- Phase 5: quickstart.md と自動テストで検証 → リリース準備

## 複雑性トラッキング

- 特筆すべき憲法違反や例外対応なし

## 進捗トラッキング

- [x] Phase 0: 調査完了
- [x] Phase 1: 設計完了
- [x] Phase 2: タスク生成方針の整理完了
- [ ] Phase 3: タスク生成（未実施）
- [ ] Phase 4: 実装（未実施）
- [ ] Phase 5: 検証（未実施）

### ゲート確認

- [x] 初回憲法チェック: PASS
- [x] 設計後憲法チェック: PASS
- [x] 不明点の解消: 完了
- [x] 逸脱記録: 不要

---
*Constitution v2.1.1 を参照。必要に応じて `/memory/constitution.md` を更新してください。*
