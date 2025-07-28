#property copyright "Copyright 2023, NhujaTrades Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#property script_show_inputs

input group "app script url"
input string apps_script_url = "https://script.google.com/macros/s/AKfycbyQBwA8PWxG7rIll_xDsSbb6WE3Fyjb7rAzItjlld3TP63fp0MGV4fLMgTOYrqKWQqZ-g/exec"; // google sheet apps script deployed url
input group "exports"
input bool export_trade_history = true; // export trade history
input bool export_positions = true;   // export current and closed positions
input bool export_chart_infos = true;  //export chart price data
input bool export_tick_data = false;   //export tick data

void SendToGoogleSheets(string symbol, double bid, double ask, long volume) {
  string headers = "Content-Type: application/json\r\n";
  char postData[], result[];
  string responseHeaders;
  
  // Prepare JSON payload
  string json = StringFormat(
    "{\"symbol\":\"%s\",\"bid\":%f,\"ask\":%f,\"volume\":%d}",
    symbol, bid, ask, volume
  );
  
  // Convert to char array
  StringToCharArray(json, postData, 0, StringLen(json));
  
  // Send POST request
  int res = WebRequest(
    "POST", apps_script_url, headers, 5000, postData, result, responseHeaders
  );
  
  // Check response
  if(res == 200) {
    Print("Data sent: ", CharArrayToString(result));
    int file_handle=FileOpen("excelwrite.csv",FILE_READ|FILE_WRITE|FILE_CSV);
      if(file_handle!=INVALID_HANDLE)
        {
         FileWrite(file_handle, CharArrayToString(result));
         //--- write the time and value
        }
  } else {
    Print("Error ", res, ": ", CharArrayToString(result), " data ", CharArrayToString(postData));
  }
}

void GetGoogleSheets() {
  string headers = "Content-Type: application/json\r\n";
  char postData[], result[];
  string responseHeaders;
  
  // Send POST request
  int res = WebRequest(
    "GET", apps_script_url, headers, 5000, postData, result, responseHeaders
  );
  
  // Check response
  if(res == 200) {
    Print("Data sent: ", CharArrayToString(result));
    int file_handle=FileOpen("excelwrite.csv",FILE_READ|FILE_WRITE|FILE_CSV);
   if(file_handle!=INVALID_HANDLE)
     {
      FileWrite(file_handle, CharArrayToString(result));
      //--- write the time and value
     }
  } else {
    Print("Error ", res, ": ", CharArrayToString(result), " data ", CharArrayToString(postData));
  }
}


void OnTick()
{
    static datetime lastUpdate = 0;
    
    GetGoogleSheets();
    
    //// Update every minute
    //if(TimeCurrent() - lastUpdate >= 20)
    //{
    //   lastUpdate = TimeCurrent();
    //   MqlTick last_tick;
    //   SymbolInfoTick(_Symbol, last_tick);
    //   SendToGoogleSheets(Symbol(), last_tick.bid, last_tick.ask, last_tick.volume);
    //}
}