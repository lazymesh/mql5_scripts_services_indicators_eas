//+------------------------------------------------------------------+
//|                                                   TickSocket.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property service
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

int socket;

string server = "localhost";
int port = 9070;
  
void SocketInit() {
   socket=SocketCreate();
   bool connect = SocketConnect(socket, server, port, 1000);
   if(connect) {
      Print("socket is connected", " ", server, " port ", port);
   }
}

//+------------------------------------------------------------------+
//| Service program start function                                   |
//+------------------------------------------------------------------+
void OnStart() {
   SocketInit();
   MqlTick latestTick;
   long next = ChartFirst();
   string payload;
   while(true) {
      payload = "";
      while (next != -1) {
         string chartSymbol = ChartSymbol(next);
         if(!SocketIsConnected(socket)){
            Print("socket is not initialized yet retrying to connect");
            SocketInit();
         }
         SymbolInfoTick(chartSymbol, latestTick);
         double bid = latestTick.bid;
         double ask = latestTick.ask;
         string tickTime = TimeToString(latestTick.time, TIME_SECONDS);
         bool stringAdded = StringAdd(payload, StringFormat("{\"pair\": \"%s\", \"time\": \"%s\", \"bid\": %f, \"ask\": %f}", chartSymbol, tickTime, bid, ask));
              
         next = ChartNext(next);
         if (next != -1 && stringAdded) {
            stringAdded = StringAdd(payload, "#@#");
         }
      }
      uchar data[];
      int len = StringToCharArray(payload, data);
      SocketSend(socket, data, len-1);
      next = ChartFirst();
      if(!SocketIsConnected(socket)){
         Print("socket is not initialized yet so stopping the service");
         break;
      }
   }
}
  
  
//+------------------------------------------------------------------+
