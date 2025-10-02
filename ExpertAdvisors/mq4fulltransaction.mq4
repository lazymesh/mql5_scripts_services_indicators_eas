//+------------------------------------------------------------------+
//|                                              FullTransaction.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

input string host = "127.0.0.1";
input int port = 8000;
input string history_orders_api = "/mt4_history_orders";
input string open_positions_api = "/mt4_positions";
input string account_info_api = "/mt4_account";
input string history_orders_collection = "MT4HistoryOrders";

#import "full_transaction.dll"
   void set_connection_params(string host, int port);
   bool get_latest_item(string &buffer, int bufferLength, string collection);
   bool save(string data, string apiPath);
#import

// getting last saved history order and extracting opened date 
string GetHistoryOrdersLastSavedOpenDate() {
   string last_history_order;
   StringInit(last_history_order, 1024, 0);
   if(get_latest_item(last_history_order, 1024, history_orders_collection)) {
      string result[];
      int count = StringSplit(last_history_order, StringGetCharacter(",", 0), result);
      if (count > 0) {
         for (int i = 0; i < count; i++) {
            if(StringFind(result[i], "Open_time") != -1) {
               string opened_date_info[];
               StringSplit(result[i], StringGetCharacter("\"", 0), opened_date_info);
               return opened_date_info[3];
            }
         }
      }
   }
   // if data is not saved then return following date for whole history order
   return "1970.01.01 00:00";
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   set_connection_params(host, port);
   //setting timer to update every 15 minutes
   EventSetTimer(15 * 60);
   //saving data for the first time
   saveData();
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){}

void OnTimer() {
   saveData();
}

//passing the data to the api for saving
void saveData() {
   string latest_saved_executed_date = GetHistoryOrdersLastSavedOpenDate();
   string history_orders_json = GetAllHistoryOrders(latest_saved_executed_date);
   if(StringLen(history_orders_json) > 5) {
     bool history_orders_json_sent = save(history_orders_json, history_orders_api);
     if(!history_orders_json_sent) {
         Print("failed to send history orders");
     }
   }
   
   string positions_json = GetOpenPositions();
   if(StringLen(positions_json) > 5) {
     bool position_json_sent = save(positions_json, open_positions_api);
     if(!position_json_sent) {
      Print("failed to send position json");
     }
   } else { // means there is no data so delete from database
      save("[]", open_positions_api);
   }
   
   string account_json = GetAccountInfo();
   bool account_json_sent = save(account_json, account_info_api);
   if(!account_json_sent) {
      Print("failed to send account json");
   }
}

string GetOpenPositions(){
   int totalOpenTrades = OrdersTotal();
   datetime startDateTime = StringToTime("1970.01.01 00:00");
   string open_orders = GetTradeInfo(totalOpenTrades, MODE_TRADES, startDateTime);
   return open_orders;
}

string GetAllHistoryOrders(string lastSavedDateTime){
    int totalHistory = OrdersHistoryTotal();
    datetime startDateTime = StringToTime(lastSavedDateTime) + 70; // 70 is added so that minute value is one minute ahead than the last saved
    string history_orders = GetTradeInfo(totalHistory, MODE_HISTORY, startDateTime);
    return history_orders;
}

string GetTradeInfo(int totalTrades, int tradeMode, datetime startDateTime) {
   string trades = "[";
   for(int i = 0; i < totalTrades; i++){
        if(OrderSelect(i, SELECT_BY_POS, tradeMode)){
         if(OrderOpenTime() > startDateTime) {
            string trade = "{" +
               "\"Ticket\":" + OrderTicket() + "," +
               "\"Symbol\":\"" + OrderSymbol() + "\"," +
               "\"Type\":\"" + GetOrderTypeDescription(OrderType()) + "\"," +
               "\"Lots\":" + OrderLots() + "," +
               "\"Open_price\":" + DoubleToStr(OrderOpenPrice(), 5) + "," +
               "\"Open_time\":\"" + TimeToStr(OrderOpenTime()) + "\"," +
               "\"Profit\":" +  DoubleToStr(OrderProfit(), 2) + "," +
               "\"SL\":" + DoubleToStr(OrderStopLoss(), 5) + "," +
               "\"TP\":" + DoubleToStr(OrderTakeProfit(), 5) + "," +
               "\"Close_price\":" + DoubleToStr(OrderClosePrice(), 5) + "," +
               "\"Close_time\":\"" + TimeToStr(OrderCloseTime()) + "\"," +
               "\"Comment\":\"" + OrderComment() + "\"," +
               "\"Commission\":" + DoubleToStr(OrderCommission(), 5) + "," +
               "\"Expiration\":\"" + TimeToStr(OrderExpiration()) + "\"," +
               "\"Magic_number\":" + IntegerToString(OrderMagicNumber()) + "," +
               "\"Swap\":" + DoubleToStr(OrderSwap(), 5) + "},";
          }
        }
        StringAdd(trades, trade);
    }
    trades = StringSubstr(trades, 0, StringLen(trades) - 1);
    StringAdd(trades, "]");
    return trades;
}

string GetOrderTypeDescription(int type)
{
    switch(type)
    {
        case OP_BUY: return "BUY";
        case OP_SELL: return "SELL";
        case OP_BUYLIMIT: return "BUY LIMIT";
        case OP_SELLLIMIT: return "SELL LIMIT";
        case OP_BUYSTOP: return "BUY STOP";
        case OP_SELLSTOP: return "SELL STOP";
        default: return "UNKNOWN";
    }
}

string GetAccountInfo() {
   string accountInfo = StringFormat(
      "[{\"Name\":\"%s\",\"Server\":\"%s\",\"Currency\":\"%s\",\"Company\":\"%s\"," +
      "\"Assets\":%f,\"Balance\":%f,\"Commission_blocked\":%f,\"Credit\":%f,\"Equity\":%f," +
      "\"Liabilities\":%f,\"Margin\":%f,\"Margin_free\":%f,\"Margin_initial\":%f,\"Margin_level\":%f," +
      "\"Margin_maintenance\":%f,\"Margin_so_call\":%f,\"Margin_so_so\":%f,\"" +
      "Profit\":%f,\"Leverage\":%d,\"Limit_orders\":%d,\"Login\":%d,\"Margin_so_mode\":\"%s\"," + 
      "\"Trade_allowed\":%d,\"Trade_expert\":%d,\"Trade_mode\":\"%s\"}]",      
      AccountInfoString(ACCOUNT_NAME),
      AccountInfoString(ACCOUNT_SERVER),
      AccountInfoString(ACCOUNT_CURRENCY),
      AccountInfoString(ACCOUNT_COMPANY),
      AccountInfoDouble(ACCOUNT_ASSETS),
      AccountInfoDouble(ACCOUNT_BALANCE),
      AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED),
      AccountInfoDouble(ACCOUNT_CREDIT),
      AccountInfoDouble(ACCOUNT_EQUITY),
      AccountInfoDouble(ACCOUNT_LIABILITIES),
      AccountInfoDouble(ACCOUNT_MARGIN),
      AccountInfoDouble(ACCOUNT_MARGIN_FREE),
      AccountInfoDouble(ACCOUNT_MARGIN_INITIAL),
      AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),
      AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE),
      AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL),
      AccountInfoDouble(ACCOUNT_MARGIN_SO_SO),
      AccountInfoDouble(ACCOUNT_PROFIT),
      AccountInfoInteger(ACCOUNT_LEVERAGE),
      AccountInfoInteger(ACCOUNT_LIMIT_ORDERS),
      AccountInfoInteger(ACCOUNT_LOGIN),
      GetAccountMarginSOMode(AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)),
      AccountInfoInteger(ACCOUNT_TRADE_ALLOWED),
      AccountInfoInteger(ACCOUNT_TRADE_EXPERT),
      GetAccountTradeMode(AccountInfoInteger(ACCOUNT_TRADE_MODE))
   );
   return accountInfo;
}

string GetAccountMarginSOMode(int mode)
{
    switch(mode)
    {
        case ACCOUNT_STOPOUT_MODE_PERCENT: return "Account stop out mode in percents";
        case ACCOUNT_STOPOUT_MODE_MONEY: return "Account stop out mode in money";
        default: return "UNKNOWN";
    }
}

string GetAccountTradeMode(int mode)
{
    switch(mode)
    {
        case ACCOUNT_TRADE_MODE_DEMO: return "Demo account";
        case ACCOUNT_TRADE_MODE_CONTEST: return "Contest account";
        case ACCOUNT_TRADE_MODE_REAL: return "Real account";
        default: return "UNKNOWN";
    }
}