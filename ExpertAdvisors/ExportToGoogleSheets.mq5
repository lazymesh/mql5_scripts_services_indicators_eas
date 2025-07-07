#import "MT5ToGoogleSheets.dll"
    string GetAccessToken(string client_id, string client_secret, string refresh_token);
    bool WriteToGoogleSheet(string access_token, string spreadsheet_id, string range, string data);
#import

input string GoogleClientID = "your-client-id.apps.googleusercontent.com";
input string GoogleClientSecret = "your-client-secret";
input string GoogleRefreshToken = "your-refresh-token";
input string SpreadsheetID = "your-spreadsheet-id";
input string SheetRange = "Sheet1!A1";

string AccessToken = "";

void OnTick()
{
    static datetime lastUpdate = 0;
    
    // Update every minute
    if(TimeCurrent() - lastUpdate >= 60)
    {
        lastUpdate = TimeCurrent();
        
        // Get new access token if needed
        if(AccessToken == "") {
            AccessToken = GetAccessToken(GoogleClientID, GoogleClientSecret, GoogleRefreshToken);
            if(AccessToken == NULL) {
                Print("Failed to get access token");
                return;
            }
        }
        
        // Prepare JSON data
        string jsonData = "{"
            "\"values\": [["
            "\"" + TimeToString(TimeCurrent()) + "\","
            "\"" + Symbol() + "\","
            "\"" + DoubleToString(Bid, Digits()) + "\","
            "\"" + DoubleToString(Ask, Digits()) + "\","
            "\"" + DoubleToString(Volume[0], 0) + "\""
            "]]"
        "}";
        
        // Write to Google Sheets
        if(!WriteToGoogleSheet(AccessToken, SpreadsheetID, SheetRange, jsonData)) {
            Print("Failed to write to Google Sheets");
            AccessToken = ""; // Force token refresh on next attempt
        }
        else {
            Print("Data successfully written to Google Sheets");
        }
    }
}