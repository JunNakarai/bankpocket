# リポジトリガイドライン

日本語で簡潔かつ丁寧に回答してください

## プロジェクト構成とモジュールの整理

SwiftUIアプリケーションのソースは`bankpocket/`にあり、エントリーポイントは`bankpocketApp.swift`と`ContentView.swift`です。ドメインモデル、SwiftDataスキーマ、バリデーションロジックは`bankpocket/Models/`に配置し、プレゼンテーションコンポーネントは`Views/`、再利用可能なヘルパーは`Utils/`に分割します。永続化、インポート/エクスポート、APIロジックは`Services/`にまとめ、ステートフルなコードを分離します。テストはこのレイアウトを反映し、ユニットテストは`bankpocketTests/`、UIスモークテストは`bankpocketUITests/`に配置します。新機能追加時は、ビュー・モデル・サービスヘルパーを同じ場所に置き、対応するテストファイルも同じテストターゲットに作成してください。

## ビルド・テスト・開発コマンド

日常開発には`xed bankpocket.xcodeproj`でXcodeプロジェクトを開いてください。プッシュ前にはヘッドレスでビルドを検証します：`xcodebuild build -project bankpocket.xcodeproj -scheme bankpocket -destination 'generic/platform=iOS'`。テストは`xcodebuild test -project bankpocket.xcodeproj -scheme bankpocket -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'`で全マトリクスを実行します。CSVインポート/エクスポート検証時は、SwiftDataコンテナが期待通りにシードされるようスキーム固有の設定を使ってください。

## コーディングスタイルと命名規則

インデントは4スペース、`guard`による早期リターンパターンを使用し、Swift APIデザインガイドラインを採用します。ビューは`View`で終わり、モデルは単数形（例：`BankAccount`, `Tag`）、計算ヘルパーはプロパティとして読みやすくします（例：`displayAccountNumber`）。`// MARK:`セパレータでライフサイクル・バリデーション・永続化コードをグループ化します。ローカライズ対応の文字列は集中管理し、`Services/`内ではシングルトンより依存性注入を優先してください。

## テストガイドライン

`XCTestCase`を継承し、スイート名は本番型に合わせて`<Subject>Tests`とします。バリデーション分岐やSwiftDataフェッチパスを網羅し、UIアサーション追加前にカバーしてください。`bankpocket/Utils/`のプレビュー用ヘルパーで決定論的なフィクスチャを使うことを推奨します。プルリク前にはローカルで`xcodebuild test ...`を実行し、非同期処理が`@MainActor`要件を守っているか確認してください。

## コミット・プルリクエストガイドライン

既存のConventional Commitスタイル（`feat:`, `fix:`, `chore:`, `docs:`）に従ってください。コミットは単一の関心事に絞り、SwiftDataスキーマ変更時はマイグレーションノートを含めます。プルリクは関連Issueをリンクし、ユーザー向け変更点を記述し、ビュー変更時はUIスクリーンショットを添付、最新のビルド/テストコマンド出力も貼り付けてください。永続化やエンタイトルメント変更時は必ずレビューを依頼してください。

## セキュリティと設定の注意

`bankpocket.entitlements`の更新は必ずレビュアーと確認し、必要以上に権限を広げないでください。実際の口座データを含むサンプルCSVは絶対にコミットせず、APIキーや秘密情報はリポジトリ外で管理してください。共有`ModelContainer`を操作する際は、スキーマ変更を文書化し、データ損失防止のためアップグレード手順も記載してください。
