# bankpocket

銀行口座を安全に整理し、タグとCSVインポート/エクスポートで管理できるSwiftUIアプリです。SwiftDataによる永続化とアクセシビリティを考慮したUIを備え、個人から小規模チームまでの家計・資産管理をサポートします。

## 主な機能

- 口座情報（銀行名・支店名・支店番号・口座番号）の登録・編集・削除
- タグの作成・色指定・口座への割り当て、タグフィルタによる絞り込み
- 銀行名・支店名による検索、ドラッグ&ドロップでの表示順並び替え
- CSV形式での口座データのインポート/エクスポート、共有シートからの外部共有
- VoiceOverラベルやヒントを含むアクセシビリティ対応

## 動作環境

- macOS 14.0 以降
- Xcode 15.0 以降
- iOS 17.0 以降（シミュレータ/デバイス）
- Swift 5.9 以降

## セットアップ

1. リポジトリをクローンします。
2. `xed bankpocket.xcodeproj` でXcodeプロジェクトを開きます。
3. `bankpocket` スキームを選択し、iOSシミュレータまたは接続済みデバイスを指定します。
4. ⌘R でビルド＆実行し、初回起動時に空の口座リストが表示されることを確認します。

## ビルドとテスト

継続的な検証のため、プッシュ前に以下のコマンドを実行してください。

```bash
xcodebuild build \
  -project bankpocket.xcodeproj \
  -scheme bankpocket \
  -destination 'generic/platform=iOS'

xcodebuild test \
  -project bankpocket.xcodeproj \
  -scheme bankpocket \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'
```

## データインポート/エクスポート

- アプリ右上の「インポート・エクスポート」アクションからCSV入出力を選択できます。
- エクスポート時は `口座一覧.csv` が一時ディレクトリに生成され、共有シートから保存・共有が可能です。
- インポートするCSVはUTF-8で、タグ名はセミコロン区切り（例: `家計;貯金`）で指定します。既存タグ名と一致する場合のみ割り当てられます。
- バリデーションエラーや重複検出が発生した場合は、どの行で問題が起きたかをダイアログに表示します。

## ディレクトリ構成

```text
bankpocket/
├── Models/        # BankAccount, TagなどSwiftDataモデルとバリデーション
├── Views/         # SwiftUIビュー（リスト、フォーム、タグ管理など）
├── Services/      # CSV入出力などの永続化・外部連携ロジック
├── Utils/         # カラーヘルパーや共有シートなど再利用可能なコンポーネント
├── Assets.xcassets
├── bankpocketApp.swift
└── ContentView.swift
bankpocketTests/     # ドメインロジック・サービスのユニットテスト
bankpocketUITests/   # UIスモークテスト
```

## 開発ガイドライン

- モデルは `bankpocket/Models/`、ビューは `bankpocket/Views/`、サービスは `bankpocket/Services/` に配置します。
- 依存関係は可能な限り依存性注入で扱い、シングルトンは避けます。
- `guard` を用いた早期リターンと `// MARK:` セクションで責務を整理してください。
- コミットメッセージは Conventional Commits（例: `feat:`, `fix:`）に従います。
- SwiftDataスキーマを変更する場合はマイグレーション手順を文書化し、レビュアーへ共有します。

## コントリビューション

バグ報告・機能提案・プルリクエストを歓迎します。詳細な手順やチェックリストは `CONTRIBUTING.md` を参照してください。

## ライセンス

本リポジトリのライセンスは未定です。利用・公開前にプロジェクトオーナーへ確認してください。

## 連絡先

改善提案やサポートの問い合わせは、Issue もしくはプロジェクトオーナーまでご連絡ください。
