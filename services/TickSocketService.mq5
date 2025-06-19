//+------------------------------------------------------------------+
//|                                                   TickSocket.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property service
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\HashMap.mqh>

int socket;
int file;
MqlDateTime dateTime;
int prevHour;
double prevBid;
double prevAsk;
double maxBid;
double maxAsk;
double minBid;
double minAsk;
CHashMap<string, int> currencyPorts;

void Init(string symbol)
  {   
   currencyPorts.Add("AUDUSD", 9070);
   currencyPorts.Add("AUDJPY", 9071);
   currencyPorts.Add("AUDCAD", 9072);
   currencyPorts.Add("AUDNZD", 9073);
   currencyPorts.Add("AUDCHF", 9074);
   currencyPorts.Add("CADJPY", 9075);
   currencyPorts.Add("CADCHF", 9076);
   currencyPorts.Add("CHFJPY", 9077);
   currencyPorts.Add("EURUSD", 9078);
   currencyPorts.Add("EURJPY", 9079);
   currencyPorts.Add("EURGBP", 9080);
   currencyPorts.Add("EURCAD", 9081);
   currencyPorts.Add("EURAUD", 9082);
   currencyPorts.Add("EURNZD", 9083);
   currencyPorts.Add("EURCHF", 9084);
   currencyPorts.Add("GBPUSD", 9085);
   currencyPorts.Add("GBPJPY", 9086);
   currencyPorts.Add("GBPCAD", 9087);
   currencyPorts.Add("GBPAUD", 9088);
   currencyPorts.Add("GBPNZD", 9089);
   currencyPorts.Add("GBPCHF", 9090);
   currencyPorts.Add("NZDUSD", 9091);
   currencyPorts.Add("NZDJPY", 9092);
   currencyPorts.Add("NZDCAD", 9093);
   currencyPorts.Add("USDCHF", 9094);
   currencyPorts.Add("USDJPY", 9095);
   currencyPorts.Add("USDCAD", 9096);
   currencyPorts.Add("NZDCHF", 9097);
   
   SocketInit(symbol);
   
   TimeCurrent(dateTime);
   prevHour = dateTime.hour;
   
   MqlTick firstTick;  
   SymbolInfoTick(Symbol(), firstTick);
   resetTicks(firstTick.bid, firstTick.ask);
   
  }
  
void resetTicks(double bid, double ask) {
   prevBid = bid;
   prevAsk = ask;
   maxBid = bid;
   maxAsk = ask;
   minBid = bid;
   minAsk = ask;
}

void setMinMax(double bid, double ask) {
   TimeCurrent(dateTime);
   if(prevHour != dateTime.hour) {
      resetTicks(bid, ask);
   } else {
      if(maxBid < bid) {
         maxBid = bid;
      }
      if(maxAsk < ask) {
         maxAsk = ask;
      }
      if(minBid > bid) {
         minBid = bid;
      }
      if(minAsk > ask) {
         minAsk = ask;
      }
   }
   //prevHour = dateTime.hour;
}
  
void SocketInit(string symbol) {
   socket=SocketCreate();
   int port;
   bool value = currencyPorts.TryGetValue(symbol, port);
   SocketConnect(socket, "localhost", port, 1000);
   uchar data[];
   int len = StringToCharArray("mt5", data) - 1;
   SocketSend(socket, data, len);
}
//+------------------------------------------------------------------+
//| Service program start function                                   |
//+------------------------------------------------------------------+

void OnStart()
  {
//---
      MqlTick latestTick;
      string firstChartSymbol = ChartSymbol(ChartFirst());
      Init(firstChartSymbol);
      string prevTick = "";
      // Print(ChartSymbol(firstChart), " ii ", ChartSymbol(ChartNext(firstChart)));
      while(true) {
         SymbolInfoTick(firstChartSymbol, latestTick);
         double bid = latestTick.bid;
         double ask = latestTick.ask;
         string tickTime = TimeToString(latestTick.time, TIME_DATE|TIME_SECONDS);
         setMinMax(bid, ask);
         string payload = 
            StringFormat("{\"pair\": \"%s\", \"time\": \"%s\", \"bid\": %f, \"ask\": %f, \"prevbid\": %f, \"prevask\": %f, \"minbid\": %f, \"minask\": %f, \"maxbid\": %f, \"maxask\": %f}",
            firstChartSymbol, tickTime, bid, ask, prevBid, prevAsk, minBid, minAsk, maxBid, maxAsk);
         string currentTick = DoubleToString(latestTick.bid) + " " + DoubleToString(latestTick.ask) + " " + TimeToString(latestTick.time);
         if(prevTick != currentTick) {
            
            uchar data[];
            int len = StringToCharArray(payload, data) - 1;
            SocketSend(socket, data, len);
            prevBid = bid;
            prevAsk = ask;
            Print("servvvvice ", payload);
            prevTick = currentTick;
         }
         
      }
  }
  
  
//+------------------------------------------------------------------+
