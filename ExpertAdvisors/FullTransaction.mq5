//+------------------------------------------------------------------+
//|                                              FullTransaction.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#import "full_transaction.dll"
   bool get_latest_item(string &buffer, int bufferLength, string collection);
   bool save(string data, string apiPath);
#import

//getting last saved history deal and extracting deal date
string GetHistoryDealLastSavedDealDate() {
   string last_history_deal;
   StringInit(last_history_deal, 1024, 0);
   if(get_latest_item(last_history_deal, 1024, "HistoryDeals")) {
      string result[];
      int count = StringSplit(last_history_deal, StringGetCharacter(",", 0), result);
      if (count > 0) {
         for (int i = 0; i < count; i++) {
            if(StringFind(result[i], "deal_time") != -1) {
               string deal_date_info[];
               StringSplit(result[i], StringGetCharacter("\"", 0), deal_date_info);
               return deal_date_info[3];
            }
         }
      }
   }
   // if data is not saved then return following date for whole history deal
   return "1970.01.01 09:00";
}

// getting last saved history order and extracting executed date 
string GetHistoryOrdersLastSavedExecutedDate() {
   string last_history_order;
   StringInit(last_history_order, 1024, 0);
   if(get_latest_item(last_history_order, 1024, "HistoryOrders")) {
      string result[];
      int count = StringSplit(last_history_order, StringGetCharacter(",", 0), result);
      if (count > 0) {
         for (int i = 0; i < count; i++) {
            if(StringFind(result[i], "executed_time") != -1) {
               string executed_date_info[];
               StringSplit(result[i], StringGetCharacter("\"", 0), executed_date_info);
               return executed_date_info[3];
            }
         }
      }
   }
   // if data is not saved then return following date for whole history order
   return "1970.01.01 09:00";
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
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
   string latest_saved_deal_date = GetHistoryDealLastSavedDealDate();
   string history_deals_json = GetHistoryDeals(StringToTime(latest_saved_deal_date)+70); // 70 is added to change minute value
   if(StringLen(history_deals_json) > 5) {
     bool history_deals_json_sent = save(history_deals_json, "/history_deals");
     if(!history_deals_json_sent) {
         Print("failed to send history deals");
     }
   }

   string latest_saved_executed_date = GetHistoryOrdersLastSavedExecutedDate();
   string history_orders_json = GetHistoryOrders(StringToTime(latest_saved_executed_date)+70);// 70 is added to change minute value
   if(StringLen(history_orders_json) > 5) {
     bool history_orders_json_sent = save(history_orders_json, "/history_orders");
     if(!history_orders_json_sent) {
         Print("failed to send history orders");
     }
   }
   
   string positions_json = GetOpenPositions();
   if(StringLen(positions_json) > 5) {
     bool position_json_sent = save(positions_json, "/positions");
     if(!position_json_sent) {
      Print("failed to send position json");
     }
   } else { // means there is no data so delete from database
      save("[]", "/positions");
   }
   
   string account_json = GetAccountInfo();
   bool account_json_sent = save(account_json, "/account");
   if(!account_json_sent) {
      Print("failed to send account json");
   }
}

string GetHistoryDeals(datetime start) {
   HistorySelect(start, TimeCurrent());
   int totalDeals = HistoryDealsTotal();
   string deals = "[";
   for(int i = 0; i < totalDeals; i++) {
      ulong ticket = HistoryDealGetTicket(i);
      string deal_time = TimeToString(HistoryDealGetInteger(ticket, DEAL_TIME));
      string dealInfo = StringFormat(
         "{\"ticket\":%d,\"symbol\":\"%s\",\"deal_time\":\"%s\",\"deal_price\":%f," +
         "\"sl\":%f,\"tp\":%f,\"profit\":%f,\"type\":\"%s\",\"volume\":%d,\"comment\":\"%s\",\"commission\":%f," +
         "\"fee\":%f,\"order_id\":%d,\"position_id\":%d,\"magic\":%d},",
         ticket,
         HistoryDealGetString(ticket, DEAL_SYMBOL),
         deal_time,
         HistoryDealGetDouble(ticket, DEAL_PRICE),
         HistoryDealGetDouble(ticket, DEAL_SL),
         HistoryDealGetDouble(ticket, DEAL_TP),
         HistoryDealGetDouble(ticket, DEAL_PROFIT),
         HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY ? "BUY" : "SELL",
         HistoryDealGetDouble(ticket, DEAL_VOLUME),
         HistoryDealGetString(ticket, DEAL_COMMENT),
         HistoryDealGetDouble(ticket, DEAL_COMMISSION),
         HistoryDealGetDouble(ticket, DEAL_FEE),
         HistoryDealGetInteger(ticket, DEAL_ORDER),
         HistoryDealGetInteger(ticket, DEAL_POSITION_ID),
         HistoryDealGetInteger(ticket, DEAL_MAGIC)
      );
      StringAdd(deals, dealInfo);
      //GlobalVariableSet(LATEST_HISTORY_DEAL_DATE, (double)deal_time);
   }
   deals = StringSubstr(deals, 0, StringLen(deals) - 1);
   StringAdd(deals, "]");
   return deals;
}

string GetHistoryOrders(datetime start) {
   HistorySelect(start, TimeCurrent());
   int totalOrders = HistoryOrdersTotal();
   string orders = "[";
   for(int i = 0; i < totalOrders; i++) {
      ulong ticket = HistoryOrderGetTicket(i);
      string executed_time = TimeToString(HistoryOrderGetInteger(ticket,ORDER_TIME_DONE));
      string orderInfo = StringFormat(
         "{\"ticket\":%d,\"symbol\":\"%s\",\"setup_time\":\"%s\",\"executed_time\":\"%s\"," +
         "\"price_opened\":%f,\"type\":\"%s\",\"volume_initial\":%f,\"comment\":\"%s\",\"sl\":%f," +
         "\"tp\":%f,\"state\":%d,\"order_time_done\":\"%s\",\"order_expire\":\"%s\",\"position_id\":%d,\"magic\":%d},",
         ticket,
         HistoryOrderGetString(ticket, ORDER_SYMBOL),
         TimeToString(HistoryOrderGetInteger(ticket,ORDER_TIME_SETUP)),
         executed_time,
         HistoryOrderGetDouble(ticket, ORDER_PRICE_OPEN),
         HistoryOrderGetInteger(ticket, ORDER_TYPE) == ORDER_TYPE_BUY ? "BUY" : "SELL",
         HistoryOrderGetDouble(ticket, ORDER_VOLUME_INITIAL),
         HistoryOrderGetString(ticket, ORDER_COMMENT),
         HistoryOrderGetDouble(ticket, ORDER_SL),
         HistoryOrderGetDouble(ticket, ORDER_TP),
         HistoryOrderGetInteger(ticket, ORDER_STATE),
         TimeToString(HistoryOrderGetInteger(ticket,ORDER_TIME_DONE)),
         TimeToString(HistoryOrderGetInteger(ticket, ORDER_TIME_EXPIRATION)),
         HistoryOrderGetInteger(ticket, ORDER_POSITION_ID),
         HistoryOrderGetInteger(ticket, ORDER_MAGIC)
      );
      StringAdd(orders, orderInfo);
      //GlobalVariableSet(LATEST_HISTORY_ORDER_EXECUTED_DATE, (double)executed_time);
   }
   orders = StringSubstr(orders, 0, StringLen(orders) - 1);
   StringAdd(orders, "]");
   return orders;
}

string GetOpenPositions() {
   int total=PositionsTotal();
   string positions = "[";
   for(int i=0; i<total; i++) {
      ulong ticket = PositionGetTicket(i);
      PositionSelectByTicket(ticket);
      string positionInfo = StringFormat(
        "{\"symbol\":\"%s\",\"ticket\":%d,\"open_time\":\"%s\",\"update_time\":\"%s\"," +
      "\"type\":\"%s\",\"magic\":%d,\"reason\":%d,\"price_open\":%f,\"sl\":%f,\"tp\":%f,\"current_price\":%f," +
      "\"volume\":%f,\"profit\":%f,\"comment\":\"%s\"},",
        PositionGetSymbol(i),
        ticket,
        TimeToString(PositionGetInteger(POSITION_TIME)),
        TimeToString(PositionGetInteger(POSITION_TIME_UPDATE)),
        PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? "BUY" : "SELL",
        PositionGetInteger(POSITION_MAGIC),
        PositionGetInteger(POSITION_REASON),
        PositionGetDouble(POSITION_PRICE_OPEN),
        PositionGetDouble(POSITION_SL),
        PositionGetDouble(POSITION_TP),
        PositionGetDouble(POSITION_PRICE_CURRENT),
        PositionGetDouble(POSITION_VOLUME),
        PositionGetDouble(POSITION_PROFIT),
        PositionGetString(POSITION_COMMENT)
        
      );
      StringAdd(positions, positionInfo);
   }
   positions = StringSubstr(positions, 0, StringLen(positions) - 1);
   StringAdd(positions, "]");
   return positions;
}

string GetAccountInfo() {
   string accountInfo = StringFormat(
      "[{\"Name\":\"%s\",\"Server\":\"%s\",\"Currency\":\"%s\",\"Company\":\"%s\"," +
      "\"Assets\":%f,\"Balance\":%f,\"Commission_blocked\":%f,\"Credit\":%f,\"Equity\":%f," +
      "\"Liabilities\":%f,\"Margin\":%f,\"Margin_free\":%f,\"Margin_initial\":%f,\"Margin_level\":%f," +
      "\"Margin_maintenance\":%f,\"Margin_so_call\":%f,\"Margin_so_so\":%f,\"" +
      "Profit\":%f,\"currency_digit\":%d,\"fifo_close\":%d,\"Hedge_allowed\":%d,\"Leverage\":%d," +
      "\"Limit_orders\":%d,\"Login\":%d,\"Margin_mode\":%d," + 
      "\"Trade_allowed\":%d,\"Trade_expert\":%d,\"Trade_mode\":%d}]",      
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
      AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS),
      AccountInfoInteger(ACCOUNT_FIFO_CLOSE),
      AccountInfoInteger(ACCOUNT_HEDGE_ALLOWED),
      AccountInfoInteger(ACCOUNT_LEVERAGE),
      AccountInfoInteger(ACCOUNT_LIMIT_ORDERS),
      AccountInfoInteger(ACCOUNT_LOGIN),
      AccountInfoInteger(ACCOUNT_MARGIN_MODE),
      AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE),
      AccountInfoInteger(ACCOUNT_TRADE_ALLOWED),
      AccountInfoInteger(ACCOUNT_TRADE_EXPERT),
      AccountInfoInteger(ACCOUNT_TRADE_MODE)
   );
   return accountInfo;
}