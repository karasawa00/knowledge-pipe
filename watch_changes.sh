#!/bin/bash

# スクリプトの使用方法を表示する関数
usage() {
  echo "Usage: $0"
  echo "This script does not accept any arguments."
  exit 1
}

# 引数が渡されていた場合はエラーにする
if [ "$#" -ne 0 ]; then
  usage
fi

# 監視対象のディレクトリを固定値で指定
TARGET_DIR="original"

# 監視対象ディレクトリが存在するかチェック
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' not found."
  exit 1
fi

# fswatchコマンドが存在するかチェック
if ! command -v fswatch &> /dev/null; then
    echo "Error: fswatch command could not be found."
    echo "Please install it first. On macOS, you can use Homebrew: brew install fswatch"
    exit 1
fi

echo "Watching for changes in '$TARGET_DIR'..."
echo "Press Ctrl+C to stop."

# fswatchを使用して、指定されたディレクトリ内のファイルの作成と更新を監視
# -r: 再帰的にサブディレクトリも監視
# --event Created: ファイルやディレクトリが作成された
# --event Updated: ファイルやディレクトリが更新された
# xargs -n1 -I{} echo "File changed: {}": イベントが発生したファイルパスを整形して出力
fswatch -r --event Created --event Updated "$TARGET_DIR" | xargs -n1 -I{} sh -c '
  # $TARGET_DIRで受け取ったフォルダ名を取得
  target_dir="./$1"

  # 変更されたファイルの元の名前を取得
  changed_filepath="$2"

  # 出力先のファイルパスを構築
  output_filepath="./summarized/summarized.txt"

  echo "File changed: $changed_filepath"
  echo "Generating summary to: $output_filepath"

  # geminiコマンドを実行し、結果をファイルに出力
  gemini --prompt "$target_dir 配下にある全てのtxtファイルの内容を要約して。説明や前置きは不要です。要約のみを出力してください。" -m gemini-2.5-flash > "$output_filepath"
' _ "$TARGET_DIR" {}
