#import "SheetConnector.dll"
    string GetGoogleAccessToken(string client_id, string client_secret, string refresh_token);
    bool WriteToGoogleSheet(string access_token, string spreadsheet_id, string range, string data);
#import

input string GoogleClientID = "your-client-id.apps.googleusercontent.com";
input string GoogleClientSecret = "your-client-secret";
input string GoogleRefreshToken = "your-refresh-token";
input string SpreadsheetID = "your-spreadsheet-id";
input string SheetRange = "Sheet1!A1test";

string AccessToken = "";

void OnTick()
{
    static datetime lastUpdate = 0;
    Print(GetGoogleAccessToken(GoogleClientID, GoogleClientSecret, GoogleRefreshToken));
    
    // Update every minute
//    if(TimeCurrent() - lastUpdate >= 60)
//    {
//        lastUpdate = TimeCurrent();
//        
//        // Get new access token if needed
//        if(AccessToken == "") {
//            AccessToken = GetGoogleAccessToken(GoogleClientID, GoogleClientSecret, GoogleRefreshToken);
//            if(AccessToken == NULL) {
//                Print("Failed to get access token");
//                return;
//            }
//        }
//        
//        MqlTick last_tick;
//        SymbolInfoTick(_Symbol, last_tick);
//        // Prepare JSON data
//        string jsonData = "{"
//            "\"values\": [["
//            "\"" + TimeToString(TimeCurrent()) + "\","
//            "\"" + Symbol() + "\","
//            "\"" + DoubleToString(last_tick.bid, Digits()) + "\","
//            "\"" + DoubleToString(last_tick.ask, Digits()) + "\","
//            "\"" + DoubleToString(last_tick.volume, 0) + "\""
//            "]]"
//        "}";
//        
//        // Write to Google Sheets
//        if(!WriteToGoogleSheet(AccessToken, SpreadsheetID, SheetRange, jsonData)) {
//            Print("Failed to write to Google Sheets");
//            AccessToken = ""; // Force token refresh on next attempt
//        }
//        else {
//            Print("Data successfully written to Google Sheets");
//        }
//    }
}