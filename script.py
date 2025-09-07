import sys
import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# 変更・追加: スコープ（権限）を定義
# このスクリプトがドキュメントの編集権限を要求することを指定
SCOPES = ["https://www.googleapis.com/auth/documents"]

# Google ドキュメントの ID を指定します。
DOCUMENT_ID = '1XyJ__2k1xC4SPCZXIR9DmmBkrNLwzawX1uclOl7JjEs'

# コマンドライン引数が1つ（スクリプト名＋引数）の場合のみ処理を行う
if len(sys.argv) == 2:
    # 追加したいテキスト
    new_text = sys.argv[1]
else:
    # 引数が正しく渡されていない場合はエラーを表示して終了
    print("引数が正しく渡されていません。処理を中止します。")
    sys.exit(1)

def main():
    """Googleドキュメントの内容を全削除してから新しいテキストを追加するメイン関数"""
    creds = None
    # token.jsonファイルは、ユーザーのアクセストークンとリフレッシュトークンを保存します。
    # 認証フローが初めて完了すると自動的に作成されます。
    if os.path.exists("./secret/token.json"):
        creds = Credentials.from_authorized_user_file("./secret/token.json", SCOPES)

    # 有効な認証情報がない場合は、ユーザーにログインを要求します。
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                "./secret/credentials.json", SCOPES
            )
            creds = flow.run_local_server(port=0)
        # 次回のために認証情報を保存します
        with open("./secret/token.json", "w") as token:
            token.write(creds.to_json())

    try:
        # 認証情報を使ってサービスを構築
        service = build("docs", "v1", credentials=creds)

        # まず本文全体を削除するリクエスト
        doc = service.documents().get(documentId=DOCUMENT_ID).execute()
        # GoogleドキュメントAPIの仕様で、deleteContentRangeはセグメント末尾の改行文字（newline character）を含む範囲は削除できない
        # そのためend_indexを1減らして末尾の改行を含まないようにする
        end_index = doc['body']['content'][-1]['endIndex'] - 1
        requests = [
            {
                "deleteContentRange": {
                    "range": {
                        "startIndex": 1,
                        "endIndex": end_index
                    }
                }
            },
            {
                "insertText": {
                    "location": {"index": 1},
                    "text": new_text,
                }
            }
        ]
        _ = service.documents().batchUpdate(
            documentId=DOCUMENT_ID, body={"requests": requests}
        ).execute()
        print(f"ドキュメントの内容を全削除し、「{new_text}」を追加しました。")

    except HttpError as error:
        print(f"エラーが発生しました: {error}")
        print("スクリプトがドキュメントを編集する権限を持っているか確認してください。")

if __name__ == "__main__":
    main()