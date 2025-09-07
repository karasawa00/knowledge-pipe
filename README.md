# Knowledge Pipe プロジェクト

## フォルダ構成と概要

```
├── .venv/                  # Python仮想環境フォルダ
├── original/               # 各メモファイルの格納場所
│   ├── (仮) memo1.txt
│   ├── (仮) memo2.txt
│   └── (仮) memo3.txt
├── secret/                 # 認証情報・トークン保存用フォルダ
│   ├── credentials.json    # Google API認証情報ファイル
│   └── token.json          # Google API認証トークン
├── summarized/             # 各メモファイルの要約結果(summarized.txt)の格納場所
│   └── summarized.txt
├── GEMINI.md               # Gemini API関連の説明・ルール
├── README.md               # プロジェクト説明・セットアップ手順
├── requirements.txt        # Python依存パッケージ一覧
├── run_script.sh           # 要約結果ファイルの変更監視＆Pythonスクリプト実行
├── script.py               # Googleドキュメントへ要約結果を反映するPythonスクリプト
├── uv.lock                 # Python環境ロックファイル
├── watch_changes.sh        # 監視ディレクトリ配下のファイル変更検知＆要約生成
```

- `original/`：各メモファイルの格納場所
- `secret/`：Google API 認証情報（`credentials.json`、`token.json`）を保存
- `summarized/`：最新の要約結果（全ファイル分を集約）を保存
- `.venv/`：Python 仮想環境（uv で作成）
- `watch_changes.sh`：`original`ディレクトリ配下のファイル変更を監視し、要約を生成
- `run_script.sh`：`summarized/summarized.txt`の変更を監視し、内容を Python スクリプトに渡す
- `script.py`：要約結果を Google ドキュメントへ反映
- `GEMINI.md`/`PROMPT.md`：Gemini API や要約ルールの説明

# フォルダ変更監視スクリプト

指定されたフォルダ配下でファイルが追加されたり、既存のファイルが編集されたりした際に、その変更を検知してコンソールに表示するシェルスクリプトです。

## 依存関係

このスクリプトは `fswatch` を使用します。

はじめに、以下のコマンドを実行して`fswatch`がインストールされているか確認します。

```sh
command -v fswatch
```

コマンド実行後にパス（例: `/usr/local/bin/fswatch`）が表示されればインストール済みです。何も表示されない場合は、macOS であれば Homebrew を使ってインストールしてください。

```sh
brew install fswatch
```

##################################
#########　 sh section 　##########
##################################

## 使い方

1.  **スクリプトに実行権限を付与します。**

    ターミナルを開き、以下のコマンドを実行してください。

    ```sh
    chmod +x watch_changes.sh
    chmod +x run_script.sh
    ```

2.  **スクリプトを実行します。**

    監視対象はスクリプト内で固定値となっています。

    - `watch_changes.sh` は `original` ディレクトリ配下のファイルを監視します。
    - `run_script.sh` は `./summarized/summarized.txt` の更新を監視します。

    引数は不要です。引数を渡すとエラーになります。

    - **実行例:**

      ```sh
      ./watch_changes.sh
      ./run_script.sh
      ```

スクリプトが実行されると、監視が開始されます。ファイルが追加または変更されると、以下のようにターミナルに変更が通知されます。

```
Watching for changes in 'original'...
Press Ctrl+C to stop.
File changed: ./original/new_file.txt
```

監視を停止するには、`Ctrl+C`を押してください。

##################################
#######　 python section 　#######
##################################

## Python スクリプトの実行環境

`script.py`を実行するための環境を`uv`を使って構築します。

### 1. `uv`のインストール

`uv`は高速な Python パッケージ管理ツールです。macOS の場合、Homebrew を使ってインストールできます。

```sh
brew install uv
```

### 2. 環境構築

プロジェクトに必要なライブラリをインストールします。

1.  **仮想環境の作成**

    プロジェクトのルートで以下のコマンドを実行し、仮想環境（`.venv`フォルダ）を作成します。

    ```sh
    uv venv
    ```

2.  **依存関係のインストール**

    `requirements.txt`に記載されているライブラリをインストールします。

    ```sh
    uv pip install -r requirements.txt
    ```

3.  **依存関係の一覧**

    現環境内にインストールされているライブラリを一覧表示します。

    ```sh
    uv pip list
    ```

### 3. スクリプトの実行

以下のいずれかの方法で`script.py`を実行します。

**方法 A: `source`コマンドで環境を有効化**

```sh
# 仮想環境を有効にする
source .venv/bin/activate

# スクリプトを実行
python script.py
```

**方法 B: `uv run`を使う**

```sh
# 仮想環境の有効化とスクリプトの実行を同時に行う
uv run python script.py
```

##################################
######## docs api section ########
##################################

## Google Docs API セットアップガイド

Google Docs API を Python で使用するための手順です。

### 1. GCP プロジェクトの設定

- **プロジェクト作成**: Google Cloud コンソールで新しいプロジェクトを作成します。
- **API 有効化**: 「API とサービス」から「ライブラリ」に移動し、「Google Docs API」を有効化します。

### 2. 認証情報の作成

- **OAuth クライアント ID 作成**: 「認証情報」から「OAuth クライアント ID」を選択し、「デスクトップ アプリケーション」を作成します。
- **JSON ダウンロード**: 作成後、表示される JSON ファイルを`credentials.json`という名前に変更して保存します。

### 3. OAuth 同意画面の設定

- **OAuth 同意画面**: 「OAuth 同意画面」に移動します。
- **テストユーザー追加**: API を使用する Google アカウントのメールアドレスを「テストユーザー」として追加し、保存します。これにより、未審査のアプリでも特定のユーザーが認証できるようになります。

### 4. ライブラリのインストール

必要なライブラリをインストールします:

```bash
uv pip install -r requirements.txt
```

### 5. サンプルコードの実行

- **コードの準備**: Python スクリプトを作成し、`credentials.json`と同じディレクトリに保存します。ドキュメント ID をコードに設定します。
- **実行と認証**: スクリプトを実行すると、ブラウザが開き、認証が求められます。許可すると、`token.json`が生成され、以降の認証が省略されます。
