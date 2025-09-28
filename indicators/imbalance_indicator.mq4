#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#property strict
#property indicator_chart_window
#property indicator_buffers 2

//--- Inputs
input group "FVG";
input bool ShowFVG = true;
input color BullFVGColor = clrBlue;
input color BearFVGColor = clrRed;

//input group "OG";
//input bool ShowOG = false;
//input color BullOGColor = clrBlue;
//input color BearOGColor = clrRed;
//
//input group "VI";
//input bool ShowVI = false;
//input color BullVIColor = clrBlue;
//input color BearVIColor = clrRed;

//--- Internal
int fvgCount = 0;
//int ogCount = 0;
//int viCount = 0;

double BuySignals[];
double SellSignals[];

//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, BuySignals);
   SetIndexBuffer(1, SellSignals);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 3, clrGreen);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 3, clrRed);
   SetIndexArrow(0, 233); // Buy arrow
   SetIndexArrow(1, 234); // Sell arrow
   ObjectsDeleteAll(0,"IMB_"); // clean old boxes
   fvgCount = 0;
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < 5) return(rates_total);

   
   ObjectsDeleteAll(0,"IMB_"); // remove previous drawings

   if(prev_calculated == 0) {
      ArrayInitialize(BuySignals, 0.0);
      ArrayInitialize(SellSignals, 0.0);
   }
   int start = prev_calculated == 0 ? 0 : prev_calculated;

   for(int i=start; i<rates_total - 2; i++)
   {
      double buy_signal = iCustom(NULL, 0, "X-Brain Method", "X-Brain_Settings", 4, 0, 1, 1, 1, "", 
         "X-Brain_Alerts", 3, 1, 1, 1, 1, 1, 
         "Session Settings", 3, 22, 23, 7, 12,
         "channel detection", 0, 2, 3, 0, 12.0, 0, 50, 1, 1, 1, 1,
         "alerts & email", 0, 1, 5, 5, "alert.wav", "alert2.wav", 0, 1, 0, 1, i);  // buffer 0
        
      double sell_signal = iCustom(NULL, 0, "X-Brain Method", "X-Brain_Settings", 4, 0, 1, 1, 1, "", 
         "X-Brain_Alerts", 3, 1, 1, 1, 1, 1, 
         "Session Settings", 3, 22, 23, 7, 12,
         "channel detection", 0, 2, 3, 0, 12.0, 0, 50, 1, 1, 1, 1,
         "alerts & email", 0, 1, 5, 5, "alert.wav", "alert2.wav", 0, 1, 0, 0, i); // buffer 1
     BuySignals[i] = buy_signal;
     SellSignals[i] = sell_signal;
      //=================== FVG ===================//
      if(ShowFVG)
      {
         // Bullish FVG
         if(low[i] > high[i+2] && close[i+1] > high[i+2] && !(BullOG(i, high, low) || BullOG(i + 1, high, low)))
         {
            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BullFVGColor, "FVG");
            fvgCount++;
            if(BuySignals[i] != 0.0) {
               //do the trade for buy
               Alert("Buy signal for ", Symbol(), " as both imbalance fvg and xbrain confirms");
            } else {
               Alert("Bullish (Buy) FVG detected");
            }
         }

         // Bearish FVG
         if(high[i] < low[i+2] && close[i+1] < low[i+2] && !(BearOG(i, high, low) || BearOG(i + 1, high, low)))
         {
            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BearFVGColor, "FVG");
            fvgCount++;
             if(SellSignals[i] != 0.0) {
               //do the trade for sell
               Alert("Sell signal for ", Symbol(), " as both imbalance fvg and xbrain confirms");
            } else {
               Alert("Bearish (sell) FVG detected");
            }
         }
      }

      //=================== Opening Gap ===================//
//      if(ShowOG){
//         // Bullish OG
//         if(BullOG(i, high, low)){
//            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BullOGColor, "OG");
//            ogCount++;
//            //Alert("Bullish OG detected at bar ", i);
//         }
//
//         // Bearish OG
//         if(BearOG(i, high, low)){
//            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BearOGColor, "OG");
//            ogCount++;
//            //Alert("Bearish OG detected at bar ", i);
//         }
//      }

      //=================== Volume Imbalance ===================//
//      if(ShowVI){
//         // Bullish VI
//         if(open[i] > close[i-1] && 
//            high[i-1] > low[i] && 
//            close[i] > close[i-1] && 
//            open[i] > open[i-1] && 
//            high[i-1] < MathMin(open[i], close[i])){
//            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BullVIColor, "VI");
//            viCount++;
//            //Alert("Bullish VI detected at bar ", i);
//         }
//
//         // Bearish VI
//         if(open[i] < close[i-1] && 
//         low[i-1] < high[i] && 
//         close[i] < close[i-1] && 
//         open[i] < open[i-1] && 
//         low[i-1] > MathMax(open[i], close[i])){
//            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BearVIColor, "VI");
//            viCount++;
//            //Alert("Bearish VI detected at bar ", i);
//         }
//      }
   }

   return(rates_total);
}

bool BullOG(int i, const double &high[], const double &low[]) {
   return low[i] > high[i+1];
}

bool BearOG(int i, const double &high[], const double &low[]) {
   return high[i] < low[i+1];
}

//+------------------------------------------------------------------+
void DrawBox(
   int barIndex,
   datetime t1,
   datetime t2,
   double open, 
   double close,
   color c,
   string type
){
   string name = "IMB_" + type + "_" + IntegerToString(barIndex);
   // --- Candle body rectangle
   double body_top    = MathMax(open, close);
   double body_bottom = MathMin(open, close);
   double center = (body_top + body_bottom) / 2;
   double top = (body_top + center) / 2;
   double bottom = (body_bottom + center) / 2;
   
   if(ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, top, t2, bottom))
   {
      ObjectSetInteger(0, name, OBJPROP_COLOR, c);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   }
}


void OnDeinit(const int reason)
{
   // Delete only objects created by this indicator
   int total = ObjectsTotal();
   for(int i = total-1; i >= 0; i--)
   {
      string name = ObjectName(i);
      if(StringFind(name, "IMB_") == 0) // starts with "IMB_"
      {
         ObjectDelete(name);
      }
   }
}