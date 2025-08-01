#property copyright "Copyright 2023, NhujaTrades Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

input group "app script url"
input string apps_script_url = "https://script.google.com/macros/s/AKfycbyQBwA8PWxG7rIll_xDsSbb6WE3Fyjb7rAzItjlld3TP63fp0MGV4fLMgTOYrqKWQqZ-g/exec"; // google sheet apps script deployed url
input group "exports"
input bool export_trade_history = false; // export trade history
input bool export_position_infos = false;   // export position info
input bool export_account_details = false; // export account details
input bool export_tick_data = false;   //export tick data

CAccountInfo accountInfo;
CSymbolInfo symbolInfo;

int updateTimeFrameInSeconds;

int OnInit(){
   //checking timeframe of chart
   updateTimeFrameInSeconds = PeriodSeconds(ChartPeriod());
   
   return(INIT_SUCCEEDED);
}


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
   if(export_account_details) {
      string account_info_json = StringFormat("{" +
         "\"symbol\":\"%s\", " +
         "\"name\":\"%s\", \"currency\":\"%s\", \"company\":\"%s\", " +
         "\"balance\": %f, \"credit\": %f, \"profit\": %f, \"equity\": %f, \"margin\": %f, " +
         "\"login\": %d, \"trade_mode\": %d, \"leverage\": %d, \"limit_orders\": %d, \"margin_mode\": %d" +
         "}",
         Symbol(),
         accountInfo.Name(), accountInfo.Currency(), accountInfo.Company(),
         accountInfo.Balance(), accountInfo.Credit(), accountInfo.Profit(), accountInfo.Equity(), accountInfo.Margin(),
         accountInfo.Login(), accountInfo.TradeMode(), accountInfo.Leverage(), accountInfo.LimitOrders(), accountInfo.MarginMode()
      );
      Print(account_info_json);
   }
   
   if(export_position_infos) {
      //if(symbolInfo.Name(Symbol())) {
      //   symbolInfo.RefreshRates();
         string symbol_info_json = StringFormat("{" +
            //"\"symbol\": \"%s\", \"is_synchronized\": \"%s\", \"time\": \"%s\", " +
            "\"price\": %f, \"day_price_high\": %f, \"day_price_low\": %f, " +
            "\"bid\": %f, \"day_bid_high\": %f, \"day_bid_low\": %f, " +
            "\"ask\": %f, \"day_ask_high\": %f, \"day_ask_low\": %f, " +
            "\"spread\": %d, " +
            "\"session_deals\": %d, " +
            "}",
           // Symbol(), symbolInfo.IsSynchronized() ? "true" : "false", TimeToString(symbolInfo.Time(), TIME_DATE | TIME_SECONDS),
            symbolInfo.Last(), symbolInfo.LastHigh(), symbolInfo.LastLow(),
            symbolInfo.Bid(), symbolInfo.BidHigh(), symbolInfo.BidLow(),
            symbolInfo.Ask(), symbolInfo.AskHigh(), symbolInfo.AskLow(),
            symbolInfo.Spread(), 
            symbolInfo.SessionDeals()
         );
         Print(symbol_info_json);
      //}
   }
   if(export_tick_data) {
      symbolInfo.RefreshRates();
      MqlTick last_tick;
      SymbolInfoTick(_Symbol, last_tick);
      string tick_info_json = StringFormat(
         "{\"symbol\":\"%s\", " +
         //"\"bid\":%f, \"day_bid_high\": %f, \"day_bid_low\": %f, " +
         //"\"ask\":%f, \"day_ask_high\": %f, \"day_ask_low\": %f, " +
         "\"spread\":%d, \"current_price\": %f, \"volume\":%d, \"time\":%s}",
          Symbol(), 
          //last_tick.bid, SymbolInfoDouble(_Symbol, SYMBOL_BIDHIGH), SymbolInfoDouble(_Symbol, SYMBOL_BIDLOW),
          //last_tick.ask, SymbolInfoDouble(_Symbol, SYMBOL_ASKHIGH), SymbolInfoDouble(_Symbol, SYMBOL_ASKLOW),
          symbolInfo.Spread(), last_tick.last, last_tick.volume, TimeToString(last_tick.time, TIME_DATE | TIME_SECONDS)
      );
      Print(tick_info_json);
   }
   //// Update every minute
   //if(TimeCurrent() - lastUpdate >= 20)
   //{
   //   lastUpdate = TimeCurrent();
   //   MqlTick last_tick;
   //   SymbolInfoTick(_Symbol, last_tick);
   //   SendToGoogleSheets(Symbol(), last_tick.bid, last_tick.ask, last_tick.volume);
   //}
}