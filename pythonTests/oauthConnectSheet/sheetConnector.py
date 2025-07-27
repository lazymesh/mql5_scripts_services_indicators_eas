from flask import Flask, request, jsonify
from google.oauth2 import service_account
from googleapiclient.discovery import build

app = Flask(__name__)

# Load service account credentials
SERVICE_ACCOUNT_FILE = 'service_account.json'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_FILE, scopes=SCOPES
)

@app.route("/")
def home():
    return "<h1>Hello from Flask!</h1>"

@app.route('/update-sheet', methods=['POST'])
def update_sheet():
    data = request.json
    print(data)
    sheet_id = data['sheet_id']
    range_ = data['range']
    values = data['values']  # list of lists

    try:
        service = build('sheets', 'v4', credentials=credentials)
        result = service.spreadsheets().values().update(
            spreadsheetId=sheet_id,
            range=range_,
            valueInputOption='RAW',
            body={'values': values}
        ).execute()
        return jsonify({"status": "success", "updatedCells": result.get("updatedCells")})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(port=8000)
