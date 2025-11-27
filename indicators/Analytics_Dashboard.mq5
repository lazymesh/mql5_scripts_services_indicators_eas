//+------------------------------------------------------------------+
//| Trade Analytics Dashboard - Corrected for MQL5                   |
//| Author: GPT-5 | 2025                                             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
#property indicator_buffers 0
#property strict

#include <ramesh\TickHelpers.mqh>;
TickHelpers tickHelp;

#include <Generic\HashMap.mqh>;

#define ADString "AnalyticsDashboard_"
long chartWidth = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
long chartHeight = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);

string pNames[] = {ADString+"WR",ADString+"E",ADString+"PF",ADString+"TP", ADString+"TL",ADString+"ARRR",ADString+"MaxDD",ADString+"MRU",
                   ADString+"TT",ADString+"W",ADString+"LS",ADString+"HoldT",ADString+"SLS",ADString+"TPS",ADString+"ManualS",
                   ADString+"SLIPPAGE",ADString+"ENTSPRD",ADString+"EXTSPRD",ADString+"OTHFEE",ADString+"IMPCTPRFT",ADString+"IMPCTLS",
                   ADString+"TOTRDS",ADString+"TPTRDS",ADString+"TLTRDS"};
string chTitles[] = {"win-rates(%)","expectancy","profit-factor","gross-profit","gross-loss","average-risk-reward-ratio","max-draw-down","max-round-up",
                     "total-trades","wins","losses","avg-hold-times (seconds)","stop-loss-stopped","take-profit-stopped","manual-stopped",
                     "avg-slippage","avg-entry-spread","avg-exit-spread","commission+swap","impact-on-profit","impact-on-loss",
                     "total-open-trades","open-profit-trades","open-loss-trades"};

input int smallChartWidth = 850; //small chart width
input int smallChartHeight = 900; //small chart height
input bool sendPieChartsBack = false; //send pie charts to back
input int pieChartFontSize = 30; //pie chart font size

input int subBtnFontSize = 9;

#include <ramesh\HelperFunctions.mqh>;
HelperFunctions helper;

#include <ramesh\ObjectLabel.mqh>;
ObjectLabel objLabel;

#include <ramesh\PieChartHelper.mqh>;
// performance pie charts
PieChartHelper *p_winR = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_expectancy = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_profitF = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_totalProfit = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_totalLoss = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_arrr = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_maxDD = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_maxRU = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
//trade behaviour pie charts              
PieChartHelper *p_totalT = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_win = new PieChartHelper(smallChartWidth, smallChartHeight,true,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_losses = new PieChartHelper(smallChartWidth, smallChartHeight,true,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_holdTime = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_slStopped = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_tpStopped = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_manualStopped = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
// execution pie charts
PieChartHelper *p_slippage = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_entrySpread = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_exitSpread = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_otherFees = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_impactOnProfit = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_impactOnLoss = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
// position pie charts
PieChartHelper *p_totalOTrades = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_totalPTrades = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);
PieChartHelper *p_totalLTrades = new PieChartHelper(smallChartWidth, smallChartHeight,false,sendPieChartsBack,pieChartFontSize);

PieChartHelper *perfPieChartObjs[] = {p_winR, p_expectancy, p_profitF, p_totalProfit, p_totalLoss, p_arrr, p_maxDD, p_maxRU,
                                      p_totalT, p_win, p_losses, p_holdTime, p_slStopped, p_tpStopped, p_manualStopped,
                                      p_slippage, p_entrySpread, p_exitSpread, p_otherFees, p_impactOnProfit, p_impactOnLoss,
                                      p_totalOTrades, p_totalPTrades, p_totalLTrades};

#include <ramesh/Button.mqh>;
Button mainBtns(ADString + "_mains");
Button chartBtn(ADString + "_performance");
Button refreshBtn(ADString+"_refresh");

#include <ramesh\RectangleLabelObject.mqh>;
RectangleLabelObject rectObj;
int rectWidth = 0;

struct PeakAndTrough {
   double balance;
   double peak;
   double trough;
   double maxDrawDown;
   double maxRunUp;
   datetime peakDateTime;
   datetime troughDateTime;
   string drawdownValueRange;
   string riseupValueRange;
   string ddDatetimeRange;
   string ruDatetimeRange;
   PeakAndTrough() {
      balance = 0;
      peak = 0;
      trough = 0;
      maxDrawDown = 0;
      maxRunUp = 0;
   }
};

class PerformanceSummary
{
public:
   int totalTrades;
   int wins;
   int losses;
   double totalProfit;
   double totalLoss;
   double otherFees;
   double winRate;
   double profitFactor;
   double expectancy;
   double avgRRRatio;
   double avgHoldTime;
   double avgTradeLot;
   int stopLossStop;
   int takeProfitStop;
   int manualStop;
   double avgSlippage;
   double avgSpreadAtEntry;
   double avgSpreadATExit;
   PeakAndTrough pat;
   
   PerformanceSummary(){};
};

CHashMap<string, PerformanceSummary*> perf;
PerformanceSummary ts;
string symbolKeys[];


string analytics[] = {"Performance", "Trade Behaviours", "Execution Quality", "Position Level"};
color analyticsClr[] = {clrRed, clrOrange, clrGreen, clrBlue};

string perfomanceAnalyticsMetricsName = ADString + "_performance_analytics_metrics";
string detailsView = "Symbol Wise";

string tradeAnalyticsMetricsName = ADString + "_trade_analytics_metrics";

string executionAnalyticsMetricsName = ADString + "_execution_analytics_metrics";

string positionAnalyticsMetricsName = ADString + "_position_analytics_metrics";

int mainBtnHeight = 25; //main buttons height
int mainBtnFontSize = 10;
int TextLenInPixel(string text, int fontSize){
   return (StringLen(text) * fontSize) - 20;  
};

int detailBtnWidth = TextLenInPixel(detailsView, subBtnFontSize);

int totalOpenPositions = 0;

void ResetMetricsValues(PerformanceSummary &ps, datetime dt){
   double equity = AccountInfoDouble(ACCOUNT_BALANCE);
   ps.totalTrades = 0; ps.wins = 0; ps.losses = 0; ps.totalProfit = 0; ps.totalLoss = 0; ps.avgHoldTime = 0;
   ps.pat.balance = equity; ps.pat.trough = equity; ps.pat.peak = equity;
   ps.pat.peakDateTime = dt; ps.pat.troughDateTime = dt;
   ps.avgTradeLot = 0; ps.stopLossStop = 0; ps.takeProfitStop = 0; ps.manualStop = 0;
   ps.avgSlippage = 0; ps.avgSpreadAtEntry = 0; ps.avgSpreadATExit = 0;
}
void CalculateTrades()
{
   datetime from = 0, to = TimeCurrent();
   HistorySelect(from,to);
   int deals = HistoryDealsTotal();

   PerformanceSummary* cs;
   bool first = true;
   for(int i=0;i<deals;i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
       
      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY && entry!=DEAL_ENTRY_INOUT)
          continue; // skip non-closing deals
      
      ENUM_DEAL_TYPE type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
          continue; // skip balance, commission, credit, etc.

      double otherFee = HistoryDealGetDouble(ticket, DEAL_SWAP) + HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      double profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
      datetime time = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      ulong orderType = HistoryDealGetInteger(ticket,DEAL_TYPE);
      string dealSymbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
      ulong positionId = HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
      double tradeLot = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double closePrice = HistoryDealGetDouble(ticket, DEAL_PRICE);
      double sl = HistoryDealGetDouble(ticket, DEAL_SL);
      double tp = HistoryDealGetDouble(ticket, DEAL_TP);
      
      if(first){
         ResetMetricsValues(ts, time);
         first = false;
      }

      ts.totalTrades++; ts.avgTradeLot += tradeLot; ts.otherFees += otherFee;
      if(profit>0){ ts.wins++; ts.totalProfit+=profit; }
      else if(profit<0){ ts.losses++; ts.totalLoss+=profit; }
      CheckDrawDownRunUp(ts.pat, profit, time);
      double slippage = 0; double entrySpread = 0; double exitSpread = 0;
      double holdTime = (double)CalcHoldingTime(dealSymbol, positionId, time, i, slippage, entrySpread);
      ts.avgHoldTime += holdTime;
      ts.avgSlippage += slippage;
      ts.avgSpreadAtEntry += entrySpread;
      MqlTick ticks[];
      if(tickHelp.CopyTicksPerCandle(dealSymbol, time, ticks)) {
         exitSpread = ticks[0].ask - ticks[0].bid;
      }
      ts.avgSpreadATExit += exitSpread;
      StopBySLTPManual(ts, closePrice, sl, tp, orderType);
      
      if(!perf.ContainsKey(dealSymbol))
      {
         ArrayResize(symbolKeys, ArraySize(symbolKeys)+1);
         symbolKeys[ArraySize(symbolKeys)-1] = dealSymbol;
         cs = new PerformanceSummary();
         ResetMetricsValues(cs, time);
      }
      perf.TryGetValue(dealSymbol, cs);
      cs.totalTrades++; cs.avgTradeLot += tradeLot; cs.otherFees += otherFee;
      if(profit>0){ cs.wins++; cs.totalProfit+=profit; }
      else if(profit<0){ cs.losses++; cs.totalLoss+=profit; }
      CheckDrawDownRunUp(cs.pat, profit, time);
      cs.avgHoldTime += holdTime;
      cs.avgSlippage += slippage;
      cs.avgSpreadAtEntry += entrySpread; cs.avgSpreadATExit += exitSpread;
      StopBySLTPManual(cs, closePrice, sl, tp, orderType);
      perf.TrySetValue(dealSymbol, cs);
   }
   for(int i=0; i<ArraySize(symbolKeys); i++){
      perf.TryGetValue(symbolKeys[i], cs);
      if(cs.totalTrades>0)
      {
         cs.winRate = (double)cs.wins/cs.totalTrades*100;
         cs.profitFactor = (cs.totalLoss==0)?cs.totalProfit:cs.totalProfit/MathAbs(cs.totalLoss);
         cs.expectancy = (cs.totalProfit+cs.totalLoss)/cs.totalTrades;
         cs.avgRRRatio = cs.wins==0 || cs.losses?cs.profitFactor:MathAbs((cs.totalProfit/cs.wins)/(cs.totalLoss/cs.losses));
         cs.avgHoldTime = cs.avgHoldTime/cs.totalTrades;
         cs.avgTradeLot = cs.avgTradeLot/cs.totalTrades;
         cs.avgSlippage = cs.avgSlippage/cs.totalTrades;
         cs.avgSpreadAtEntry = cs.avgSpreadAtEntry/cs.totalTrades;
         cs.avgSpreadATExit = cs.avgSpreadATExit/cs.totalTrades;
      }
      perf.TrySetValue(symbolKeys[i], cs);
   }

   if(ts.totalTrades>0)
   {
      ts.winRate = (double)ts.wins/ts.totalTrades*100;
      ts.profitFactor = (ts.totalLoss==0)?ts.totalProfit:ts.totalProfit/MathAbs(ts.totalLoss);
      ts.expectancy = (ts.totalProfit+ts.totalLoss)/ts.totalTrades;
      ts.avgRRRatio = (ts.totalProfit/ts.wins)/(ts.totalLoss/ts.losses);
      ts.avgHoldTime = ts.avgHoldTime/ts.totalTrades;
      ts.avgTradeLot = ts.avgTradeLot/ts.totalTrades;
      ts.avgSlippage = ts.avgSlippage/ts.totalTrades;
      ts.avgSpreadAtEntry = ts.avgSpreadAtEntry/ts.totalTrades;
      ts.avgSpreadATExit = ts.avgSpreadATExit/ts.totalTrades;
   }
}

void StopBySLTPManual(PerformanceSummary &ps, double closePrice, double sl, double tp, ulong dealType){
   if((dealType == ORDER_TYPE_BUY && closePrice <= sl) || (dealType == ORDER_TYPE_SELL && closePrice >= sl)) ps.stopLossStop++;
   else if((dealType == ORDER_TYPE_BUY && closePrice >= tp) || (dealType == ORDER_TYPE_SELL && closePrice <= sl)) ps.takeProfitStop++;
   else ps.manualStop++;
}

long CalcHoldingTime(string symbol, ulong closePositionId, datetime closeTime, int index, double &slippage, double &entrySpread)
{   
   for(int i=index-1;i>=0;i--)
   {
      ulong ticket = HistoryDealGetTicket(i);
       
      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_IN)
          continue; // skip non-opening deals
      
      ENUM_DEAL_TYPE type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
          continue; // skip balance, commission, credit, etc.
          
      ulong openPositionId = HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
      string dealSymbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
      if(openPositionId == closePositionId && symbol == dealSymbol)
      {
         datetime openTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         if(openTime < closeTime)
         {
            double dealPrice = HistoryDealGetDouble(ticket, DEAL_PRICE);
            MqlTick ticks[];
            if(tickHelp.CopyTicksPerCandle(symbol, openTime, ticks)) {
               slippage = type == DEAL_TYPE_BUY ? dealPrice = ticks[0].ask : dealPrice - ticks[0].bid;
               entrySpread = ticks[0].ask - ticks[0].bid;
            }
             return closeTime - openTime; // Returns seconds
         }
      }
   }
   return 0;
}

void CheckDrawDownRunUp(PeakAndTrough &pat, double profit, datetime dt)
{
   double prevBalance = pat.balance;
   pat.balance += profit;
   if(pat.balance > pat.peak)
   {
      double runUp = CalcRunUp(pat.balance, pat.trough);
      SetMaxRUAndDate(pat, runUp, dt);
      pat.peak = pat.balance; // setting peak to new high point
      pat.peakDateTime = dt;
   }
   if(pat.balance < pat.trough)
   {
      double drawDown = CalcDrawDown(pat.peak, pat.balance);
      SetMaxDDAndDate(pat, drawDown, dt);
      pat.trough = pat.balance;
      pat.troughDateTime = dt;
   }
   if(pat.balance > pat.trough && pat.balance < pat.peak && prevBalance < pat.balance)
   {
      double runUp = CalcRunUp(pat.balance, pat.trough);
      SetMaxRUAndDate(pat, runUp, dt);
   }
   if(pat.balance > pat.trough && pat.balance < pat.peak && prevBalance > pat.balance)
   {
      double drawDown = CalcDrawDown(pat.peak, pat.balance);
      SetMaxDDAndDate(pat, drawDown, dt);
   }
}

void SetMaxDDAndDate(PeakAndTrough &pat, double dd, datetime dt){
   if(dd > pat.maxDrawDown) {
      pat.maxDrawDown = dd;
      pat.drawdownValueRange = StringFormat("value dropped from %.2f to %.2f",pat.peak, pat.balance);
      pat.ddDatetimeRange = StringFormat("from datetime %s to datetime %s",TimeToString(pat.peakDateTime),TimeToString(dt));
   }
}
void SetMaxRUAndDate(PeakAndTrough &pat, double ru, datetime dt){
   if(ru > pat.maxRunUp) {
      pat.maxRunUp = ru;
      pat.riseupValueRange = StringFormat("value rose from %.2f to %.2f",pat.trough, pat.balance);
      pat.ruDatetimeRange = StringFormat("from datetime %s to datetime %s",TimeToString(pat.troughDateTime),TimeToString(dt));
   }
}

double CalcDrawDown(double peak, double trough)
{
   return ((peak - trough)/peak)*100; 
}

double CalcRunUp(double peak, double trough)
{
   return ((peak - trough)/trough)*100; 
}

void PerformanceAnalytics()
{
   string name = perfomanceAnalyticsMetricsName;
   helper.DeleteAllMatchingObjects(0, name);
   string title = "PERFORMANCE ANALYTICS";
   double maxProfit = 0; string mostProfitedSymbol = "";
   double maxLoss = INT_MAX; string mostLostSymbol = "";
   double highPF = 0; string highPFSymbol = "";
   double maxExpectancy = 0; string mostExpectedSymbol = "";
   double maxWinRate = 0; string maxWinRateSymbol = "";
   double maxDDS = 0; string maxDDSymbol = ""; string drop = ""; string ddRange = "";
   double maxRUS = 0; string maxRUSymbol = ""; string rise = ""; string ruRange = "";
   PerformanceSummary *perf_data;
   for(int i=0;i<ArraySize(symbolKeys);i++){
      perf.TryGetValue(symbolKeys[i], perf_data);
      if(perf_data.totalProfit > maxProfit) {
         maxProfit = perf_data.totalProfit;
         mostProfitedSymbol = symbolKeys[i];
      }
      if(perf_data.totalLoss < maxLoss){
         maxLoss = perf_data.totalLoss;
         mostLostSymbol = symbolKeys[i];
      }
      if(perf_data.profitFactor > highPF){
         highPF = perf_data.profitFactor;
         highPFSymbol = symbolKeys[i];
      }
      if(perf_data.expectancy > maxExpectancy){
         maxExpectancy = perf_data.expectancy;
         mostExpectedSymbol = symbolKeys[i];
      }
      if(perf_data.winRate > maxWinRate){
         maxWinRate = perf_data.winRate;
         maxWinRateSymbol = symbolKeys[i];
      }
      if(maxDDS < perf_data.pat.maxDrawDown){
         maxDDS = perf_data.pat.maxDrawDown;
         maxDDSymbol = symbolKeys[i];
         drop = perf_data.pat.drawdownValueRange;
         ddRange = perf_data.pat.ddDatetimeRange;
      }
      if(maxRUS < perf_data.pat.maxRunUp){
         maxRUS = perf_data.pat.maxRunUp;
         maxRUSymbol = symbolKeys[i];
         rise = perf_data.pat.riseupValueRange;
         ruRange = perf_data.pat.ruDatetimeRange;
      }
   }
   string totalProfit = StringFormat("Gross Profit: %.2f",ts.totalProfit);
   string mostProfited = StringFormat("Most profitted symbol is %s with %.2f profit",mostProfitedSymbol, maxProfit);
   string totalLoss = StringFormat("Gross Loss: %.2f",ts.totalLoss);
   string mostLost = StringFormat("Most lost symbol is %s with %.2f loss",mostLostSymbol, maxLoss);
   string profitFactor = StringFormat("Overall Profit Factor: %.2f",ts.profitFactor);
   string highestPF = StringFormat("%s has the highest profit factor of %.2f",highPFSymbol, highPF);
   string expectancy = StringFormat("Overall Expectancy: %.2f",ts.expectancy);
   string mostExpected = StringFormat("Most expected symbol is %s with expectancy of %.2f",mostExpectedSymbol, maxExpectancy);
   string winRate = StringFormat("Overall Win Rate: %.1f%%",ts.winRate);
   string maxWinR = StringFormat("%.2f%% is the max win rate of %s", maxWinRate, maxWinRateSymbol);
   string arrr = StringFormat("Average Risk Reward Ratio: %.2f",ts.avgRRRatio);
   string maxDD = StringFormat("Max Draw Down: %.4f%%",ts.pat.maxDrawDown);
   string maxDDOValueRange = ts.pat.drawdownValueRange;
   string maxDDODateRange = ts.pat.ddDatetimeRange;
   string maxDDSValue = StringFormat("Max Draw Down is of %s is %.2f%%",maxDDSymbol,maxDDS);
   string maxDDSDateRange = ddRange;
   string maxDDSValueRange = drop;
   string maxRU = StringFormat("Max Run Up: %.4f%%",ts.pat.maxRunUp);
   string maxRUOValueRange = ts.pat.riseupValueRange;
   string maxRUODateRange = ts.pat.ruDatetimeRange;
   string maxRUSValue = StringFormat("Max Run Up is of %s is %.2f%%",maxRUSymbol,maxRUS);
   string maxRUSDateRange = ruRange;
   string maxRUSValueRange = rise;
   color clrText = clrBlack;
   ENUM_BASE_CORNER bseCrnr = CORNER_LEFT_UPPER;
   objLabel.LabelCreate(0, name + "_title", 0, -1500, 50, bseCrnr, title, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_totalProfit", 0, -1500, 80, bseCrnr, totalProfit, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_totalProfit_view", -1500, 80, detailBtnWidth, 20, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_mostProfited", 0, -1500, 100, bseCrnr, mostProfited, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_totalLoss", 0, -1500, 120, bseCrnr, totalLoss, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_totalLoss_view", -1500, 120, detailBtnWidth, 20, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_mostLost", 0, -1500, 140, bseCrnr, mostLost, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_profitFactor", 0, -1500, 160, bseCrnr, profitFactor, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_profitFactor_view", -1500, 160, detailBtnWidth, 20, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_highestPF", 0, -1500, 180, bseCrnr, highestPF, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_expectancy", 0, -1500, 200, bseCrnr, expectancy, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_expectancy_view", -1500, 200, detailBtnWidth, 20, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_mostExpected", 0, -1500, 220, bseCrnr, mostExpected, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_winRate", 0, -1500, 240, bseCrnr, winRate, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_winRate_view", -1500, 240, detailBtnWidth, 20, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_maxWinR", 0, -1500, 260, bseCrnr, maxWinR, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_arrr", 0, -1500, 280, bseCrnr, arrr, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_arrr_view", -1500, 280, detailBtnWidth, 20, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   
   objLabel.LabelCreate(0, name + "_maxDD", 0, -1500, 310, bseCrnr, maxDD, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_maxDD_view", -1500, 310, detailBtnWidth, 20, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_maxDDOValueRange", 0, -1500, 330, bseCrnr, maxDDOValueRange, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_maxDDODateRange", 0, -1500, 345, bseCrnr, maxDDODateRange, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_maxDDSValue", 0, -1500, 360, bseCrnr, maxDDSValue, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_maxDDSValueRange", 0, -1500, 375, bseCrnr, maxDDSValueRange, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_maxDDSDateRange", 0, -1500, 390, bseCrnr, maxDDSDateRange, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
      
   objLabel.LabelCreate(0, name + "_maxRU", 0, -1500, 410, bseCrnr, maxRU, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_maxRU_view", -1500, 410, detailBtnWidth, 20, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_maxRUOValueRange", 0, -1500, 430, bseCrnr, maxRUOValueRange, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_maxRUODateRange", 0, -1500, 445, bseCrnr, maxRUODateRange, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_maxRUSValue", 0, -1500, 460, bseCrnr, maxRUSValue, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_maxRUSValueRange", 0, -1500, 475, bseCrnr, maxRUSValueRange, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_maxRUSDateRange", 0, -1500, 490, bseCrnr, maxRUSDateRange, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
}

void PerformanceAnalyticsMove(int index)
{  
   int x = -1500;
   if(index == 0) x = 5;
   int prevX = (int)ObjectGetInteger(0, perfomanceAnalyticsMetricsName + "_title", OBJPROP_XDISTANCE);
   if(x != prevX) {
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName + "_title", x, 50);
      
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName + "_totalProfit", x, 80);
      int changedX = x + TextLenInPixel(ObjectGetString(0,perfomanceAnalyticsMetricsName + "_totalProfit",OBJPROP_TEXT), subBtnFontSize) + 120;
      chartBtn.Move("_totalProfit_view", changedX, 80, detailBtnWidth, 20);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_mostProfited", x, 100);
      
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName + "_totalLoss", x, 120);
      changedX = x + TextLenInPixel(ObjectGetString(0,perfomanceAnalyticsMetricsName + "_totalLoss",OBJPROP_TEXT), subBtnFontSize) + 110;
      chartBtn.Move("_totalLoss_view", changedX, 120, detailBtnWidth, 20);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_mostLost", x, 140);
      
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName + "_profitFactor", x, 160);
      changedX = x + TextLenInPixel(ObjectGetString(0,perfomanceAnalyticsMetricsName + "_profitFactor",OBJPROP_TEXT), subBtnFontSize) + 40;
      chartBtn.Move("_profitFactor_view", changedX, 160, detailBtnWidth, 20);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_highestPF", x, 180);
      
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName + "_expectancy", x, 200);
      changedX = x + TextLenInPixel(ObjectGetString(0,perfomanceAnalyticsMetricsName + "_expectancy",OBJPROP_TEXT), subBtnFontSize) + 140;
      chartBtn.Move("_expectancy_view", changedX, 200, detailBtnWidth, 20);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_mostExpected", x, 220);
      
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName + "_winRate", x, 240);
      changedX = x + TextLenInPixel(ObjectGetString(0,perfomanceAnalyticsMetricsName + "_winRate",OBJPROP_TEXT), subBtnFontSize) + 130;
      chartBtn.Move("_winRate_view", changedX, 240, detailBtnWidth, 20);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxWinR", x, 260);
      
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName + "_arrr", x, 280);
      changedX = x + TextLenInPixel(ObjectGetString(0,perfomanceAnalyticsMetricsName + "_arrr",OBJPROP_TEXT), subBtnFontSize) + 130;
      chartBtn.Move("_arrr_view", changedX, 280, detailBtnWidth, 20);
      
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName + "_maxDD", x, 310);
      changedX = x + TextLenInPixel(ObjectGetString(0,perfomanceAnalyticsMetricsName + "_maxDD",OBJPROP_TEXT), subBtnFontSize) + 150;
      chartBtn.Move("_maxDD_view", changedX, 310, detailBtnWidth, 20);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxDDOValueRange", x, 330);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxDDODateRange", x, 345);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxDDSValue", x, 360);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxDDSValueRange", x, 375);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxDDSDateRange", x, 390);
      
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName + "_maxRU", x, 410);
      changedX = x + TextLenInPixel(ObjectGetString(0,perfomanceAnalyticsMetricsName + "_maxRU",OBJPROP_TEXT), subBtnFontSize) + 180;
      chartBtn.Move("_maxRU_view", changedX, 410, detailBtnWidth, 20);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxRUOValueRange", x, 430);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxRUODateRange", x, 445);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxRUSValue", x, 460);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxRUSValueRange", x, 475);
      objLabel.LabelMove(0, perfomanceAnalyticsMetricsName+"_maxRUSDateRange", x, 490);
   }
}

void TradeAnalytics()
{
   string name = tradeAnalyticsMetricsName;
   helper.DeleteAllMatchingObjects(0, name);
   string title = "TRADE BEHAVIOUR ANALYTICS";
   string totalTrades = StringFormat("Total Trades: %d",ts.totalTrades);
   string totalWins = StringFormat("Total Wins: %d",ts.wins);
   string totalLosses = StringFormat("Total Losses: %d",ts.losses);
   string totalHoldTime = StringFormat("Total average hold time: %.2f secs",ts.avgHoldTime);
   double maxHold = 0; string maxHoldSymbol = ""; PerformanceSummary *perf_data; 
   string mostTradedSymbol = ""; int tradedTimes = 0;
   int winTimes = 0; string winSymbol = "";
   int lostTimes = 0; string lostSymbol = "";
   int maxSLStop = 0; string slStoppedSymbol = "";
   int maxTPStop = 0; string tpStoppedSymbol = "";   
   int maxManualStop = 0; string manualStoppedSymbol = "";
   double maxTradeSize = 0; string maxTradeSizeSymbol = "";
   double minTradeSize = INT_MAX; string minTradeSizeSymbol = "";
   for(int i=0;i<ArraySize(symbolKeys);i++){
      perf.TryGetValue(symbolKeys[i], perf_data);
      if(perf_data.avgHoldTime > maxHold){
         maxHold = perf_data.avgHoldTime;
         maxHoldSymbol = symbolKeys[i];
      }
      if(perf_data.totalTrades > tradedTimes){
         mostTradedSymbol = symbolKeys[i];
         tradedTimes = perf_data.totalTrades;
      }
      if(perf_data.wins > winTimes){
         winTimes = perf_data.wins;
         winSymbol = symbolKeys[i];
      }
      if(perf_data.losses > lostTimes){
         lostTimes = perf_data.losses;
         lostSymbol = symbolKeys[i];
      }
      if(perf_data.stopLossStop > maxSLStop){
         maxSLStop = perf_data.stopLossStop;
         slStoppedSymbol = symbolKeys[i];
      }
      if(perf_data.takeProfitStop > maxTPStop){
         maxTPStop = perf_data.takeProfitStop;
         tpStoppedSymbol = symbolKeys[i];
      }
      if(perf_data.avgTradeLot > maxTradeSize){
         maxTradeSize = perf_data.avgTradeLot;
         maxTradeSizeSymbol = symbolKeys[i];
      }
      if(perf_data.avgTradeLot < minTradeSize){
         minTradeSize = perf_data.avgTradeLot;
         minTradeSizeSymbol = symbolKeys[i];
      }
      
   }
   string maxHoldStr = StringFormat("Max average hold time: %.2f seconds of %s",maxHold, maxHoldSymbol);
   string mostTraded = StringFormat("Most traded symbol is %s traded %d times",mostTradedSymbol, tradedTimes);
   string mostWon = StringFormat("Most won symbol is %s won %d times",winSymbol, winTimes);
   string mostLost = StringFormat("Most lost symbol is %s lost %d times",lostSymbol, lostTimes);
   string avgTradeSize = StringFormat("Average trade size used: %.2f", ts.avgTradeLot);
   string maxAvgTradeSize = StringFormat("%s has max average trade size used: %.2f",maxTradeSizeSymbol,maxTradeSize);
   string minAvgTradeSize = StringFormat("%s has min average trade size used: %.2f",minTradeSizeSymbol,minTradeSize);
   string slStopTrade = StringFormat("Total Trades stopped by hitting sl: %d", ts.stopLossStop);
   string maxSlStopTrade = StringFormat("%s is stopped max %d by hitting stoploss",slStoppedSymbol,maxSLStop);
   string tpStopTrade = StringFormat("Total Trades stopped by hitting tp: %d", ts.takeProfitStop);
   string maxTPStopTrade = StringFormat("%s is stopped max %d by hitting take profit",tpStoppedSymbol,maxTPStop);
   string manualStopTrade = StringFormat("Total Trades stopped manually: %d", ts.manualStop);
   string maxManualStopTrade = StringFormat("%s is stopped max %d manually",manualStoppedSymbol,maxManualStop);
   color clrText = clrBlack;
   ENUM_BASE_CORNER bseCrnr = CORNER_LEFT_UPPER;
   objLabel.LabelCreate(0, name + "_title", 0, -1500, 100, bseCrnr, title, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_totalTrades", 0, -1500, 180, bseCrnr, totalTrades, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_totalTrades_view", -1500, 180, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_mostTraded", 0, -1500, 220, bseCrnr, mostTraded, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_totalWins", 0, -1500, 280, bseCrnr, totalWins, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_totalWins_view", -1500, 280, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_mostWon", 0, -1500, 320, bseCrnr, mostWon, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_totalLosses", 0, -1500, 380, bseCrnr, totalLosses, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_totalLosses_view", -1500, 380, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_mostLost", 0, -1500, 420, bseCrnr, mostLost, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_totalHoldTime", 0, -1500, 480, bseCrnr, totalHoldTime, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_totalHoldTime_view", -1500, 480, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_maxHoldStr", 0, -1500, 520, bseCrnr, maxHoldStr, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_avgTradeLot", 0, -1500, 580, bseCrnr, avgTradeSize, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_maxAvgTradeLot", 0, -1500, 620, bseCrnr, maxAvgTradeSize, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_minAvgTradeLot", 0, -1500, 640, bseCrnr, minAvgTradeSize, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_slStopTrade", 0, -1500, 700, bseCrnr, slStopTrade, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_slStopTrade_view", -1500, 700, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_maxSlStopTrade", 0, -1500, 740, bseCrnr, maxSlStopTrade, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_tpStopTrade", 0, -1500, 800, bseCrnr, tpStopTrade, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_tpStopTrade_view", -1500, 800, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_maxTPStopTrade", 0, -1500, 840, bseCrnr, maxTPStopTrade, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_manualStopTrade", 0, -1500, 900, bseCrnr, manualStopTrade, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_manualStopTrade_view", -1500, 900, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   objLabel.LabelCreate(0, name + "_maxManualStopTrade", 0, -1500, 940, bseCrnr, maxManualStopTrade, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
}


void TradeAnalyticsMove(int index)
{  
   int x = -1500;
   if(index == 1) x = 5;
   int prevX = (int)ObjectGetInteger(0, tradeAnalyticsMetricsName + "_title", OBJPROP_XDISTANCE);
   if(x != prevX) {
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_title", x, 100);
      
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_totalTrades", x, 180);
      int changedX = x + TextLenInPixel(ObjectGetString(0,tradeAnalyticsMetricsName + "_totalTrades",OBJPROP_TEXT), subBtnFontSize) + 100;
      chartBtn.Move("_totalTrades_view", changedX, 180, detailBtnWidth, 40);
      objLabel.LabelMove(0, tradeAnalyticsMetricsName+"_mostTraded", x, 220);
      
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_totalWins", x, 280);
      changedX = x + TextLenInPixel(ObjectGetString(0,tradeAnalyticsMetricsName + "_totalWins",OBJPROP_TEXT), subBtnFontSize) + 100;
      chartBtn.Move("_totalWins_view", changedX, 280, detailBtnWidth, 40);
      objLabel.LabelMove(0, tradeAnalyticsMetricsName+"_mostWon", x, 320);
      
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_totalLosses", x, 380);
      changedX = x + TextLenInPixel(ObjectGetString(0,tradeAnalyticsMetricsName + "_totalLosses",OBJPROP_TEXT), subBtnFontSize) + 120;
      chartBtn.Move("_totalLosses_view", changedX, 380, detailBtnWidth, 40);
      objLabel.LabelMove(0, tradeAnalyticsMetricsName+"_mostLost", x, 420);
      
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_totalHoldTime", x, 480);
      changedX = x + TextLenInPixel(ObjectGetString(0,tradeAnalyticsMetricsName + "_totalHoldTime",OBJPROP_TEXT), subBtnFontSize) + 310;
      chartBtn.Move("_totalHoldTime_view", changedX, 480, detailBtnWidth, 40);    
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_maxHoldStr", x, 520); 
         
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_avgTradeLot", x, 580);
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_maxAvgTradeLot", x, 620);
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_minAvgTradeLot", x, 640);
      
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_slStopTrade", x, 700); 
      changedX = x + TextLenInPixel(ObjectGetString(0,tradeAnalyticsMetricsName + "_slStopTrade",OBJPROP_TEXT), subBtnFontSize) + 290;
      chartBtn.Move("_slStopTrade_view", changedX, 700, detailBtnWidth, 40);
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_maxSlStopTrade", x, 740);
      
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_tpStopTrade", x, 800); 
      changedX = x + TextLenInPixel(ObjectGetString(0,tradeAnalyticsMetricsName + "_tpStopTrade",OBJPROP_TEXT), subBtnFontSize) + 290;
      chartBtn.Move("_tpStopTrade_view", changedX, 800, detailBtnWidth, 40);
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_maxTPStopTrade", x, 840);
      
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_manualStopTrade", x, 900); 
      changedX = x + TextLenInPixel(ObjectGetString(0,tradeAnalyticsMetricsName + "_manualStopTrade",OBJPROP_TEXT), subBtnFontSize) + 290;
      chartBtn.Move("_manualStopTrade_view", changedX, 900, detailBtnWidth, 40);
      objLabel.LabelMove(0, tradeAnalyticsMetricsName + "_maxManualStopTrade", x, 940);
   }
}


void ExectionAnalytics()
{
   string name = executionAnalyticsMetricsName;
   helper.DeleteAllMatchingObjects(0, name);
   string title = "EXECUTION QUALITY ANALYTICS";
   PerformanceSummary *perf_data;
   double maxSlippage = 0; string maxSlippageSymbol = "";
   double minSlippage = INT_MAX; string minSlippageSymbol = "";
   for(int i=0;i<ArraySize(symbolKeys);i++){
      perf.TryGetValue(symbolKeys[i], perf_data);
      if(perf_data.avgSlippage > maxSlippage){
         maxSlippage = perf_data.avgSlippage;
         maxSlippageSymbol = symbolKeys[i];
      }
      if(perf_data.avgSlippage < minSlippage){
         minSlippage = perf_data.avgSlippage;
         minSlippageSymbol = symbolKeys[i];
      }
   }
   string slippageInfo1 = "Slippage not calculated for charts without historical data";
   string slippageInfo2 = "Indicator or EA in strategy tester must be run for that chart";
   
   string entrySpreadInfo1 = "Entry spread not calculated for charts without historical data";
   string entrySpreadInfo2 = "Indicator or EA in strategy tester must be run for that chart";
   
   string exitSpreadInfo1 = "Exit spread not calculated for charts without historical data";
   string exitSpreadInfo2 = "Indicator or EA in strategy tester must be run for that chart";
   
   string totalOtherFees = StringFormat("Total commission + swap fee: %.2f", ts.otherFees);
   string impactOnProfit = StringFormat("Impact on gross profit: %.2f%%", (ts.otherFees/ts.totalProfit)*100);
   string impactOnLoss = StringFormat("Impact on gross loss: %.2f%%", (ts.otherFees/MathAbs(ts.totalLoss))*100);
   
   color clrText = clrBlack;
   ENUM_BASE_CORNER bseCrnr = CORNER_LEFT_UPPER;
   objLabel.LabelCreate(0, name + "_title", 0, -1500, 100, bseCrnr, title, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   
   objLabel.LabelCreate(0, name + "_slippageInfo1", 0, -1500, 180, bseCrnr, slippageInfo1, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_slippageInfo2", 0, -1500, 210, bseCrnr, slippageInfo2, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_avgSlippage_view", -1500, 240, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   
   objLabel.LabelCreate(0, name + "_entrySpread1", 0, -1500, 300, bseCrnr, entrySpreadInfo1, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_entrySpread2", 0, -1500, 330, bseCrnr, entrySpreadInfo2, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_entryAvgSpread_view", -1500, 360, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   
   objLabel.LabelCreate(0, name + "_exitSpreadInfo1", 0, -1500, 420, bseCrnr, exitSpreadInfo1, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   objLabel.LabelCreate(0, name + "_exitSpreadInfo2", 0, -1500, 450, bseCrnr, exitSpreadInfo2, "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_exitAvgSpread_view", -1500, 480, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   
   objLabel.LabelCreate(0, name + "_totalOtherFee", 0, -1500, 540, bseCrnr, totalOtherFees, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_otherFees_view", -1500, 540, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   
   objLabel.LabelCreate(0, name + "_impactOnProfit", 0, -1500, 600, bseCrnr, impactOnProfit, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_impactOnProfit_view", -1500, 600, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   
   objLabel.LabelCreate(0, name + "_impactOnLoss", 0, -1500, 660, bseCrnr, impactOnLoss, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   chartBtn.Create("_impactOnLoss_view", -1500, 660, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
}


void ExecutionAnalyticsMove(int index)
{  
   int x = -1500;
   if(index == 2) x = 5;
   int buttonx = index == 2 ? rectWidth/3 : x;
   int prevX = (int)ObjectGetInteger(0, executionAnalyticsMetricsName + "_title", OBJPROP_XDISTANCE);
   if(x != prevX) {
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_title", x, 100);  
      
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_slippageInfo1", x, 180);
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_slippageInfo2", x, 210);
      chartBtn.Move("_avgSlippage_view", buttonx, 240, detailBtnWidth, 40);
      
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_entrySpread1", x, 300);
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_entrySpread2", x, 330);
      chartBtn.Move("_entryAvgSpread_view", buttonx, 360, detailBtnWidth, 40);
      
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_exitSpreadInfo1", x, 420);
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_exitSpreadInfo2", x, 450);
      chartBtn.Move("_exitAvgSpread_view", buttonx, 480, detailBtnWidth, 40);
      
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_totalOtherFee", x, 540); 
      int changedX = x + TextLenInPixel(ObjectGetString(0,executionAnalyticsMetricsName + "_totalOtherFee",OBJPROP_TEXT), subBtnFontSize) + 290;
      chartBtn.Move("_otherFees_view", changedX, 540, detailBtnWidth, 40);
      
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_impactOnProfit", x, 600); 
      changedX = x + TextLenInPixel(ObjectGetString(0,executionAnalyticsMetricsName + "_impactOnProfit",OBJPROP_TEXT), subBtnFontSize) + 290;
      chartBtn.Move("_impactOnProfit_view", changedX, 600, detailBtnWidth, 40);
      
      objLabel.LabelMove(0, executionAnalyticsMetricsName + "_impactOnLoss", x, 660); 
      changedX = x + TextLenInPixel(ObjectGetString(0,executionAnalyticsMetricsName + "_impactOnLoss",OBJPROP_TEXT), subBtnFontSize) + 290;
      chartBtn.Move("_impactOnLoss_view", changedX, 660, detailBtnWidth, 40);
   }
}


void PositionAnalytics()
{
   string name = positionAnalyticsMetricsName;
   helper.DeleteAllMatchingObjects(0, name);
   string title = "POSITION LEVEL ANALYTICS";
   string totalHoldTime = StringFormat("Total average hold time: %d",ts.avgHoldTime);
   color clrText = clrBlack;
   ENUM_BASE_CORNER bseCrnr = CORNER_LEFT_UPPER;
   objLabel.LabelCreate(0, name + "_title", 0, -1500, 100, bseCrnr, title, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   totalOpenPositions = PositionsTotal();
   if(totalOpenPositions > 0) {
      double totalProfit = 0; double totalLoss = 0; CHashMap<string, double> openTradesCount;
      CHashMap<string, double> symbolWiseProfit; CHashMap<string, double> symbolWiseLoss;
      for(int i=0; i<totalOpenPositions; i++) {
         ulong ticket = PositionGetTicket(i);
         PositionSelectByTicket(ticket);
         string symbol = PositionGetSymbol(i);
         AddDoubleInStringHashMap(openTradesCount, symbol, 1, 1);
         double profit = PositionGetDouble(POSITION_PROFIT);
         if(profit > 0) {
            totalProfit += profit;
            AddDoubleInStringHashMap(symbolWiseProfit, symbol, profit, profit);
         }
         if(profit < 0) {
            totalLoss += profit;
            AddDoubleInStringHashMap(symbolWiseLoss, symbol, profit, profit);
         }
      }
      PopulatePositionLevelCharts(openTradesCount, symbolWiseProfit, symbolWiseLoss);
      string openTrades = StringFormat("Total open positions: %d",totalOpenPositions);
      string totalOpenProfit = StringFormat("Total open profits: %.2f",totalProfit);
      string totalOpenLoss = StringFormat("Total open losses: %.2f", totalLoss);
      
      objLabel.LabelCreate(0, name + "_totalOpenTrades", 0, -1500, 180, bseCrnr, openTrades, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
      chartBtn.Create("_openTrades_view", -1500, 180, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
      
      objLabel.LabelCreate(0, name + "_totalOpenProfits", 0, -1500, 240, bseCrnr, totalOpenProfit, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
      chartBtn.Create("_openProfits_view", -1500, 240, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
      
      objLabel.LabelCreate(0, name + "_totalOpenLosses", 0, -1500, 300, bseCrnr, totalOpenLoss, "Arial", 15, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
      chartBtn.Create("_openLosses_view", -1500, 300, detailBtnWidth, 40, detailsView, clrOrangeRed, clrWheat, subBtnFontSize);
   }
   else {
      objLabel.LabelCreate(0, name + "_noOpenTrades", 0, -1500, 180, bseCrnr, "No open trades yet", "Arial", 9, clrText, 0.0, ANCHOR_LEFT_UPPER, false);
   }
}

void AddDoubleInStringHashMap(CHashMap<string, double> &map, string key, double updateValue, double defaultValue) {
   double updatingValue;
   if(map.TryGetValue(key, updatingValue)) {
      updatingValue += updateValue;
      Print(key, " ", updateValue, " ", updatingValue);
      map.TrySetValue(key, updatingValue);
   } else {
      map.TrySetValue(key, defaultValue);
   }
}

void PopulatePositionLevelCharts(CHashMap<string, double> &tradeCounts, CHashMap<string, double> &profitTrades, CHashMap<string, double> &lossTrades){
   string keys[]; double dvalues[];
   
   tradeCounts.CopyTo(keys, dvalues, 0);
   p_totalOTrades.SetData(dvalues, keys);
   
   profitTrades.CopyTo(keys, dvalues, 0);
   p_totalPTrades.SetData(dvalues, keys);
   
   lossTrades.CopyTo(keys, dvalues, 0);
   p_totalLTrades.SetData(dvalues, keys);
}


void PositionAnalyticsMove(int index)
{  
   int x = -1500;
   if(index == 3) x = 5;
   int prevX = (int)ObjectGetInteger(0, positionAnalyticsMetricsName + "_title", OBJPROP_XDISTANCE);
   if(x != prevX) {
      objLabel.LabelMove(0, positionAnalyticsMetricsName + "_title", x, 100); 
      
      if(totalOpenPositions > 0){
         objLabel.LabelMove(0, positionAnalyticsMetricsName + "_totalOpenTrades", x, 180);
         int changedX = x + TextLenInPixel(ObjectGetString(0,positionAnalyticsMetricsName + "_totalOpenTrades",OBJPROP_TEXT), subBtnFontSize) + 290;
         chartBtn.Move("_openTrades_view", changedX, 180, detailBtnWidth, 40);
         
         objLabel.LabelMove(0, positionAnalyticsMetricsName + "_totalOpenProfits", x, 240); 
         changedX = x + TextLenInPixel(ObjectGetString(0,positionAnalyticsMetricsName + "_totalOpenProfits",OBJPROP_TEXT), subBtnFontSize) + 290;
         chartBtn.Move("_openProfits_view", changedX, 240, detailBtnWidth, 40);
         
         objLabel.LabelMove(0, positionAnalyticsMetricsName + "_totalOpenLosses", x, 300); 
         changedX = x + TextLenInPixel(ObjectGetString(0,positionAnalyticsMetricsName + "_totalOpenLosses",OBJPROP_TEXT), subBtnFontSize) + 290;
         chartBtn.Move("_openLosses_view", changedX, 300, detailBtnWidth, 40);
      }
      else {
         objLabel.LabelMove(0, positionAnalyticsMetricsName + "_noOpenTrades", x, 180); 
      }    
   }
}

//+------------------------------------------------------------------+
int OnInit()
{  
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   IndicatorSetString(INDICATOR_SHORTNAME,"Trade Analytics Dashboard Corrected");
   EventSetTimer(5);
   CreateAllPieCharts();
   int rectHeight = (int)chartHeight - 20;
   for(int i = 0; i < ArraySize(analytics); i++)
      rectWidth += TextLenInPixel(analytics[i], mainBtnFontSize) + 6;
   rectObj.RectLabelCreate(0,ADString+"_rect",0,0,0,rectWidth,rectHeight,clrAliceBlue);
   CreateMainButtons();
   CreateNonPressedText();
   CalculateTrades();
   ProcessData();
   return(INIT_SUCCEEDED);
}

void ProcessData(){
   PopulatePerformancePieCharts();
   PopulateTradeBehaviourCharts();
   PopulateExecutionQualityCharts();
   PerformanceAnalytics();
   TradeAnalytics();
   ExectionAnalytics();
   PositionAnalytics();
}

void CreateMainButtons() {
   int x = 3;
   int y = 25;
   for(int i=0;i<ArraySize(analytics);i++){
      int btnWidth = TextLenInPixel(analytics[i], mainBtnFontSize);
      mainBtns.Create(analytics[i], x, y, btnWidth, mainBtnHeight, analytics[i], analyticsClr[i], clrWhite, mainBtnFontSize);
      x = x + btnWidth + 5;
   }
}
void CreateAllPieCharts()
{
   int xPos = -1100;
   int yPos = 160;
   for(int i=0;i<ArraySize(perfPieChartObjs);i++)
   {
      perfPieChartObjs[i].CreatePieChart(pNames[i],chTitles[i],xPos, yPos);
   }
}
void HideAllPieCharts(int xPos = -1100, int yPos = 160)
{
   for(int i=0;i<ArraySize(perfPieChartObjs);i++)
   {
      perfPieChartObjs[i].ChangeLocation(xPos, yPos);
   }
}

void PopulatePerformancePieCharts()
{
   PerformanceSummary *perf_data;
   int count = ArraySize(symbolKeys);
   double winrates[]; ArrayResize(winrates, count);
   double expectancies[]; ArrayResize(expectancies, count);
   double profitfactors[]; ArrayResize(profitfactors, count);
   double totalProfit[]; ArrayResize(totalProfit, count);
   double totalLoss[]; ArrayResize(totalLoss, count);
   double arrr[]; ArrayResize(arrr, count);
   double maxDD[]; ArrayResize(maxDD, count);
   double maxRU[]; ArrayResize(maxRU, count);
   
   for(int i = 0; i < count; i++) {
      if(perf.TryGetValue(symbolKeys[i], perf_data))
      {
         winrates[i] = perf_data.winRate;
         expectancies[i] = perf_data.expectancy;
         profitfactors[i] = perf_data.profitFactor;
         totalProfit[i] = perf_data.totalProfit;
         totalLoss[i] = perf_data.totalLoss;
         arrr[i] = perf_data.avgRRRatio;
         maxDD[i] = perf_data.pat.maxDrawDown;
         maxRU[i] = perf_data.pat.maxRunUp;
      }
   }
   p_winR.SetData(winrates, symbolKeys);
   p_expectancy.SetData(expectancies, symbolKeys);
   p_profitF.SetData(profitfactors, symbolKeys);
   p_totalProfit.SetData(totalProfit, symbolKeys);
   p_totalLoss.SetData(totalLoss, symbolKeys);
   p_arrr.SetData(arrr, symbolKeys);
   p_maxDD.SetData(maxDD, symbolKeys);
   p_maxRU.SetData(maxRU, symbolKeys);
}

void PopulateTradeBehaviourCharts(){
   PerformanceSummary *perf_data;
   int count = ArraySize(symbolKeys);
   double totals[]; ArrayResize(totals, count);
   double wins[]; ArrayResize(wins, count);
   double losses[]; ArrayResize(losses, count);
   double avgHoldTimes[]; ArrayResize(avgHoldTimes, count);
   double slStopped[]; ArrayResize(slStopped, count);
   double tpStopped[]; ArrayResize(tpStopped, count);
   double manualStopped[]; ArrayResize(manualStopped, count);
   for(int i=0;i<count;i++){
      if(perf.TryGetValue(symbolKeys[i], perf_data)){
         totals[i] = perf_data.totalTrades;
         wins[i] = perf_data.wins;
         losses[i] = perf_data.losses;
         avgHoldTimes[i] = perf_data.avgHoldTime;
         slStopped[i] = perf_data.stopLossStop;
         tpStopped[i] = perf_data.takeProfitStop;
         manualStopped[i] = perf_data.manualStop;
      }
   }
   p_totalT.SetData(totals, symbolKeys);
   p_win.SetData(wins, symbolKeys);
   p_losses.SetData(losses, symbolKeys);
   p_holdTime.SetData(avgHoldTimes, symbolKeys);
   p_slStopped.SetData(slStopped, symbolKeys);
   p_tpStopped.SetData(tpStopped, symbolKeys);
   p_manualStopped.SetData(manualStopped, symbolKeys);
}

void PopulateExecutionQualityCharts(){
   PerformanceSummary *perf_data;
   int count = ArraySize(symbolKeys);
   double slippage[]; ArrayResize(slippage, count);
   double entrySpread[]; ArrayResize(entrySpread, count);
   double exitSpread[]; ArrayResize(exitSpread, count);
   double otherFees[]; ArrayResize(otherFees, count);
   double impactOnProfit[]; ArrayResize(impactOnProfit, count);
   double impactOnLoss[]; ArrayResize(impactOnLoss, count);
   
   for(int i=0;i<count;i++){
      if(perf.TryGetValue(symbolKeys[i], perf_data)){
         slippage[i] = perf_data.avgSlippage;
         entrySpread[i] = perf_data.avgSpreadAtEntry;
         exitSpread[i] = perf_data.avgSpreadATExit;
         otherFees[i] = perf_data.otherFees;
         impactOnProfit[i] = (perf_data.otherFees/perf_data.totalProfit)*100;
         impactOnLoss[i] = MathAbs(perf_data.otherFees/perf_data.totalLoss)*100;
      }
   }
   p_slippage.SetData(slippage, symbolKeys);
   p_entrySpread.SetData(entrySpread, symbolKeys);
   p_exitSpread.SetData(exitSpread, symbolKeys);
   p_otherFees.SetData(otherFees, symbolKeys);
   p_impactOnProfit.SetData(impactOnProfit, symbolKeys);
   p_impactOnLoss.SetData(impactOnLoss, symbolKeys);
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
   if(prev_calculated == 0) {
      ArraySetAsSeries(close, true);
      ArraySetAsSeries(time, true);
   }
   return(rates_total);
}


int mainBtnPressedIndex = -1;
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK){
      HideAllPieCharts();
      if(StringFind(sparam, "_view", 0) >=0) {
         if(StringFind(sparam, "_winRate_view") >= 0)
            p_winR.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_totalTrades_view") >= 0)
            p_totalT.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_totalWins_view") >= 0)
            p_win.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_totalLosses_view") >= 0)
            p_losses.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_totalProfit_view") >= 0)
            p_totalProfit.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_totalLoss_view") >= 0)
            p_totalLoss.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_profitFactor_view") >= 0)
            p_profitF.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_expectancy_view") >= 0)
            p_expectancy.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_arrr_view") >= 0)
            p_arrr.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_maxDD_view") >= 0)
            p_maxDD.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_maxRU_view") >= 0)
            p_maxRU.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_totalHoldTime_view") >= 0)
            p_holdTime.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_slStopTrade_view") >= 0)
            p_slStopped.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_tpStopTrade_view") >= 0)
            p_tpStopped.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_manualStopTrade_view") >= 0)
            p_manualStopped.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_avgSlippage_view") >= 0)
            p_slippage.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_entryAvgSpread_view") >= 0)
            p_entrySpread.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_exitAvgSpread_view") >= 0)
            p_exitSpread.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_otherFees_view") >= 0)
            p_otherFees.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_impactOnProfit_view") >= 0)
            p_impactOnProfit.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_impactOnLoss_view") >= 0)
            p_impactOnLoss.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_openTrades_view") >= 0)
            p_totalOTrades.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_openProfits_view") >= 0)
            p_totalPTrades.ChangeLocation(1100, 160);
         if(StringFind(sparam, "_openLosses_view") >= 0)
            p_totalLTrades.ChangeLocation(1100, 160);
      }
      else {
         for(int i=0;i<ArraySize(analytics);i++)
            if(mainBtns.OnClick(analytics[i], id, sparam))
               mainBtnPressedIndex = i;
         for(int i=0;i<ArraySize(analytics);i++){
            if(mainBtnPressedIndex == i){
               mainBtns.SetColors(analytics[i], clrGray, clrBlack);
               if(StringFind(sparam, analytics[3]) >= 0){
                  PositionAnalytics();
               }
               //else{
               //   CalculateTrades();
               //   if(StringFind(sparam, analytics[0]) >= 0){
               //      PopulatePerformancePieCharts();
               //      PerformanceAnalytics();
               //   }
               //   if(StringFind(sparam, analytics[1]) >= 0){
               //      PopulateTradeBehaviourCharts();
               //      TradeAnalytics();
               //   }
               //   if(StringFind(sparam, analytics[2]) >= 0){
               //      PopulateExecutionQualityCharts();
               //      ExectionAnalytics();
               //   }
               //}
               
            } else {
               mainBtns.SetColors(analytics[i], analyticsClr[i], clrWhite);
            }
         }
         PerformanceAnalyticsMove(mainBtnPressedIndex);
         TradeAnalyticsMove(mainBtnPressedIndex);
         ExecutionAnalyticsMove(mainBtnPressedIndex);
         PositionAnalyticsMove(mainBtnPressedIndex);
         if(mainBtnPressedIndex != -1){
            objLabel.LabelMove(0, ADString+"_nothing_to_show", -2000);
         } else {
            objLabel.LabelMove(0, ADString+"_nothing_to_show", 10, (int)chartHeight/3);
         }
      }
   }
}

void CreateNonPressedText(){
   string name = ADString + "_nothing_to_show";
   string text = "Please press one of the buttons above";
   objLabel.LabelCreate(0, name, 0, 10, (int)chartHeight/3, CORNER_LEFT_UPPER, text, "Arial", 20, clrRed, 0.0, ANCHOR_LEFT_UPPER, false);
}

void OnDeinit(const int reason)
{
    for (int i = 0; i < ArraySize(symbolKeys); i++)
    {
      PerformanceSummary* data;
      perf.TryGetValue(symbolKeys[i], data);
      delete data;
    }
    perf.Clear();
    for(int i=0;i<ArraySize(perfPieChartObjs);i++) delete perfPieChartObjs[i];
    
   helper.DeleteAllMatchingObjects(0, ADString);
}
//+------------------------------------------------------------------+
