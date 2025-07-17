void SendToGoogleSheets(string symbol, double bid, double ask, long volume) {
  string url = "https://script.google.com/macros/s/AKfycbyGQ1qRnGVKk43gaDYHCWKHjMC8FATwLOxuBvMlNShK4wIX33q4lrYGbVfxAbgBFFio6A/exec"; // Replace with your Apps Script URL
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
    "POST", url, headers, 5000, postData, result, responseHeaders
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
    
    // Update every minute
    if(TimeCurrent() - lastUpdate >= 20)
    {
       lastUpdate = TimeCurrent();
       MqlTick last_tick;
       SymbolInfoTick(_Symbol, last_tick);
       SendToGoogleSheets(Symbol(), last_tick.bid, last_tick.ask, last_tick.volume);
    }
}