//+------------------------------------------------------------------+
//|                                        ImbalanceDetectorfull.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| LuxAlgo Imbalance Detector (MT4)                                 |
//| Ported from Pine Script                                          |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window

//--- Inputs
input bool ShowFVG = true;
input color BullFVGColor = clrBlue;
input color BearFVGColor = clrRed;

input bool ShowOG = false;
input color BullOGColor = clrBlue;
input color BearOGColor = clrRed;

input bool ShowVI = false;
input color BullVIColor = clrBlue;
input color BearVIColor = clrRed;

input int LookbackBars = 500;

//--- Internal
int fvgCount = 0;
int ogCount = 0;
int viCount = 0;

//+------------------------------------------------------------------+
int OnInit()
{
   ObjectsDeleteAll(0,"IMB_"); // clean old boxes
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
   fvgCount = ogCount = viCount = 0;

   int start = MathMin(rates_total - 3, LookbackBars);

   for(int i=2; i<start; i++)
   {
      //=================== FVG ===================//
      if(ShowFVG)
      {
         // Bullish FVG
         if(low[i] > high[i+2] && close[i+1] > high[i+2] && !(BullOG(i, high, low) || BullOG(i + 1, high, low)))
         {
            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BullFVGColor, "FVG");
            fvgCount++;
            //Alert("Bullish FVG detected at bar ", i);
         }

         // Bearish FVG
         if(high[i] < low[i+2] && close[i+1] < low[i+2] && !(BearOG(i, high, low) || BearOG(i + 1, high, low)))
         {
            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BearFVGColor, "FVG");
            fvgCount++;
            //Alert("Bearish FVG detected at bar ", i);
         }
      }

      //=================== Opening Gap ===================//
      if(ShowOG){
         // Bullish OG
         if(BullOG(i, high, low)){
            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BullOGColor, "OG");
            ogCount++;
            //Alert("Bullish OG detected at bar ", i);
         }

         // Bearish OG
         if(BearOG(i, high, low)){
            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BearOGColor, "OG");
            ogCount++;
            //Alert("Bearish OG detected at bar ", i);
         }
      }

      //=================== Volume Imbalance ===================//
      if(ShowVI){
         // Bullish VI
         if(open[i] > close[i-1] && 
            high[i-1] > low[i] && 
            close[i] > close[i-1] && 
            open[i] > open[i-1] && 
            high[i-1] < MathMin(open[i], close[i])){
            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BullVIColor, "VI");
            viCount++;
            //Alert("Bullish VI detected at bar ", i);
         }

         // Bearish VI
         if(open[i] < close[i-1] && 
         low[i-1] < high[i] && 
         close[i] < close[i-1] && 
         open[i] < open[i-1] && 
         low[i-1] > MathMax(open[i], close[i])){
            DrawBox(i, time[i-1], time[i+1], open[i], close[i], BearVIColor, "VI");
            viCount++;
            //Alert("Bearish VI detected at bar ", i);
         }
      }
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