# ボルダルマ

ボルダリングの課題管理アプリ

[![Flutter 3.x](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)

## 概要

このアプリは、ボルダリング初心者～中級者をターゲットにした課題管理・活動記録アプリです。

## 目的

下記の手段でボルダリングに対するモチベーションを向上させる。
- 可視化: 課題管理を通して、自分の向き合うべき課題を整理・可視化
- 集中: 集中タイマーを使用し、登ることに集中させる
- エンジョイ: 課題ランダム生成などのユニークな機能で楽しく遊ぶ

## 特徴（予定）

- **ウォール管理**: 壁の写真を管理します。
- **課題管理**: 課題を管理します。
- **集中タイマー**: Work/Restの時間を設定でき、運動/休憩のバランスを保ちます。
- **課題ランダム生成**: AIを活用し、課題をランダム生成します。

## 技術スタック

- **フレームワーク**: [Flutter](https://flutter.dev/)
- **ルーティング**: [go_router](https://pub.dev/packages/go_router)
- **ローカルデータベース**: [Isar](https://pub.dev/packages/isar)
- **コードチェック (Linter)**: [flutter_lints](https://pub.dev/packages/flutter_lints)

## 開発環境のセットアップ

### 前提条件

- Flutter SDK (3.x)
- Android NDK `27.0.12077973`

#### Android NDK のインストール方法

Android Studioをインストールしている場合は、Android Studioから **SDK Manager** を開き、「SDK Tools」タブから `NDK (Side by side)` を選択し、`27.0.12077973` をインストールします。<br>
（※右下の「Show Package Details」チェックボックスにチェックを入れることでバージョン一覧が出てきます）

※SDK Managerの場所について
- プロジェクトを開いている場合: 右上の歯車マークからSDK Managerを選択
- プロジェクトを開いていない場合: 左下の歯車マークからSettings→Languages & Frameworks→Android SDKを選択

#### セットアップで困ったら

Flutter doctorを使用すると、Flutter/Android SDKあたりに問題が無いかどうかをチェックできます。
```sh
flutter doctor
```

### インストールと実行

1. **依存パッケージをインストール:**
  ```sh
  flutter pub get
  ```

2. **アプリケーションを実行:**
  ```sh
  flutter run
  ```

### コード生成

当プロジェクトでは [`build_runner`](https://pub.dev/packages/build_runner) を使用して、主にIsarのモデルに関するコードを自動生成しています。

データモデル（`@collection`アノテーションが付いたファイル）を変更した場合は、以下のコマンドを実行してください。

```sh
dart run build_runner build --delete-conflicting-outputs
```

### アイコンの更新

アプリアイコンを変更する場合は`assets/icons/icon.png`を変更後、以下のコマンドで各プラットフォーム用のアイコンを更新します。

```sh
dart run flutter_launcher_icons
```

## ディレクトリ構造

プロジェクトは機能ごとにモジュールを分割するFeature-Firstアプローチを採用しています。

```
lib/
├── core/          # コア機能 (ルーティング, ユーティリティなど)
│   └── router/
├── features/      # 機能ベースのモジュール
│   └── [feature_name]/
│       ├── data/         # データソース (リポジトリなど)
│       ├── model/        # データモデル
│       └── presentation/ # UI (スクリーン, ウィジェット)
├── shared/        # 複数の機能で共有されるウィジェットやユーティリティ
│   ├── widgets/
│   └── utils/
└── main.dart      # アプリケーションのエントリポイント
```

## コードスタイル

[`flutter_lints`](https://pub.dev/packages/flutter_lints) を使用してコードスタイルを統一しています。
詳細は `analysis_options.yaml` を参照してください。

コードを解析するには、以下のコマンドを実行します。

```sh
flutter analyze
```
