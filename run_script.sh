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

# 監視対象のファイルを固定値で指定
TARGET_FILE="./summarized/summarized.txt"

# 監視対象ファイルが存在するかチェック
if [ ! -f "$TARGET_FILE" ]; then
  echo "Error: File '$TARGET_FILE' not found."
  exit 1
fi

# fswatchコマンドが存在するかチェック
if ! command -v fswatch &> /dev/null; then
    echo "Error: fswatch command could not be found."
    echo "Please install it first. On macOS, you can use Homebrew: brew install fswatch"
    exit 1
fi

echo "Watching for changes in '$TARGET_FILE'..."
echo "Press Ctrl+C to stop."

# fswatchを使用して、指定されたファイルの更新を監視
# --event Updated: ファイルが更新された
fswatch --event Updated "$TARGET_FILE" | xargs -n1 -I{} sh -c '
  echo "File changed: $1"
  echo "Starting script execution..."

  uv run python script.py "$(cat "$1")"

  echo "Script execution completed."
' _ {}
