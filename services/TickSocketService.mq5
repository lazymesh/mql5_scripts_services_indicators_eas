//+------------------------------------------------------------------+
//|                                                   TickSocket.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property service
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Service program start function                                   |
//+------------------------------------------------------------------+

double bid;
double ask;
double minBid;
double minAsk;
double maxBid;
double maxAsk;

void OnStart() {
//---
    MqlTick latestTick;
    long firstChart=ChartFirst();
    string prevTick = "";
    Print(ChartSymbol(firstChart), " ii ", ChartSymbol(ChartNext(firstChart)));
    while(true) {
        SymbolInfoTick(ChartSymbol(prevChart), latestTick);
        string currentTick = latestTick.bid + " " + latestTick.ask + " " + latestTick.time;
        if(prevTick != currentTick) {
           Print("servvvvice ", ChartSymbol(prevChart), " bid ", latestTick.bid, " time ", latestTick.time);
           prevTick = currentTick;
        }
        
     }
  }
  
  
//+------------------------------------------------------------------+
