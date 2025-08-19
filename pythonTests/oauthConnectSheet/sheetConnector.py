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
    spreadsheet_id = data['spreadSheetId']
    sheet_name = data["sheetName"]
    data_range = sheet_name + "!A1"
    values = data['data']  # list of lists

    try:
        service = build('sheets', 'v4', credentials=credentials)
        check_and_create_sheet(service, spreadsheet_id, sheet_name)
        result = service.spreadsheets().values().update(
            spreadsheetId=spreadsheet_id,
            range=data_range,
            valueInputOption='RAW',
            body={'values': values}
        ).execute()
        return jsonify({"status": "success", "updatedCells": result.get("updatedCells")})
    except Exception as e:
        print(str(e))
        return jsonify({"status": "error", "message": str(e)}), 500

# appends data either from specified range or below the cell that has value if specified range has data
@app.route('/append-sheet', methods=['POST'])
def append_sheet():
    data = request.json
    spreadsheet_id = data['spreadSheetId']
    sheet_name = data["sheetName"]
    data_range = sheet_name + "!A1"
    values = data['data']  # list of lists

    try:
        service = build('sheets', 'v4', credentials=credentials)
        check_and_create_sheet(service, spreadsheet_id, sheet_name)
        result = service.spreadsheets().values().append(
            spreadsheetId=spreadsheet_id,
            range=data_range,
            valueInputOption='RAW',
            body={'values': values}
        ).execute()
        updates = result.get("updates")
        return jsonify({"status": "success", "appendedCells": updates.get("updatedCells"), "rows": updates.get("updatedRows"), "columns": updates.get("updatedColumns")})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
def check_and_create_sheet(service, spreadsheet_id, sheet_name):
    spreadsheet = service.spreadsheets().get(spreadsheetId=spreadsheet_id).execute()
    sheets = spreadsheet.get("sheets", [])

    sheet_names = [s["properties"]["title"] for s in sheets]

    # ---- Step 2: Check & Create if needed ----
    if sheet_name not in sheet_names:
        requests = [
            {
                "addSheet": {
                    "properties": {
                        "title": sheet_name,
                        "gridProperties": {
                            "rowCount": 100,
                            "columnCount": 20
                        }
                    }
                }
            }
        ]
        body = {"requests": requests}
        response = service.spreadsheets().batchUpdate(
            spreadsheetId=spreadsheet_id, body=body
        ).execute()
        print(f"✅ Sheet '{sheet_name}' created")
    else:
        print(f"ℹ️ Sheet '{sheet_name}' already exists")

if __name__ == "__main__":
    app.run(port=8000)
