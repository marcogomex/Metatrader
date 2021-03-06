//+------------------------------------------------------------------+
//|                                                GetAllHistory.mq4 |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property version   "1.00"
#property strict

#include <MarketWatch\MarketWatch.mqh>
#include <Stopwatch\Stopwatch.mqh>
#include <Common\EnumLists.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   MarketWatch mw;
   Stopwatch swGlobal;
   Stopwatch swEach;
   Stopwatch swLocal;

   swGlobal.Start();

   int symbolCt=SymbolsTotal(true);
   int tfCount=ArraySize(EnumLists::TimeframesOnline);
   int i,j;
   string symbol;
   ENUM_TIMEFRAMES timeframe;
   for(i=0; i<symbolCt; i++)
     {
      symbol=SymbolName(i,true);
      for(j=0;j<tfCount;j++)
        {
         swEach.Start();
         timeframe=EnumLists::TimeframesOnline[j];
         mw.AddSymbolToMarketWatch(symbol);
         long chartId=mw.OpenChartIfMissing(symbol,timeframe);
         Sleep(1000);
         ChartSetInteger(chartId,CHART_AUTOSCROLL,false);
         Sleep(100);
         ChartSetInteger(chartId,CHART_SHIFT,false);
         Sleep(100);
         ChartSetInteger(chartId,CHART_SCALEFIX,0,false);
         Sleep(100);
         ChartSetInteger(chartId,CHART_SCALE,0,0);
         Sleep(100);
         ChartSetInteger(chartId,CHART_MODE,0,CHART_CANDLES);
         Sleep(100);
         ChartSetInteger(chartId,CHART_BRING_TO_TOP,0,true);
         Sleep(100);

         MqlRates r[];
         int sz=0;
         int sz2=1;
         int sc;
         swLocal.Start();
         ChartNavigate(chartId,CHART_END);
         Sleep(100);
         while(sz < sz2)
           {
            sz=sz2;
            while(ChartNavigate(chartId,CHART_CURRENT_POS,-100000) && swLocal.ElapsedSeconds()<1)
              {
               sc = swLocal.ElapsedSeconds();
               Sleep(1);
              }
            swLocal.Reset();
            while(ChartNavigate(chartId,CHART_CURRENT_POS,-10000) && swLocal.ElapsedSeconds()<1)
              {
               Sleep(1);
              }
            swLocal.Reset();
            while(ChartNavigate(chartId,CHART_CURRENT_POS,-1000) && swLocal.ElapsedSeconds()<1)
              {
               Sleep(1);
              }
            swLocal.Reset();
            while(ChartNavigate(chartId,CHART_CURRENT_POS,-100) && swLocal.ElapsedSeconds()<1)
              {
               Sleep(1);
              }
            swLocal.Reset();
            while(ChartNavigate(chartId,CHART_CURRENT_POS,-10) && swLocal.ElapsedSeconds()<1)
              {
               Sleep(1);
              }
            swLocal.Reset();
            while(ChartNavigate(chartId,CHART_CURRENT_POS,-1) && swLocal.ElapsedSeconds()<1)
              {
               Sleep(1);
              }
            swLocal.Reset();
            sz2=ArrayCopyRates(r,symbol,timeframe);
           }
         swLocal.Stop();

         if(chartId!=ChartID())
           {
            Sleep(1000);
            ChartClose(chartId);
           }
         swEach.Stop();
         Print(StringConcatenate(symbol," ",EnumToString(timeframe)," history download took ",swEach.ElapsedSeconds()," seconds"));
        }
     }
   swGlobal.Stop();
   Print(StringConcatenate("history download took ",swGlobal.ElapsedSeconds()," seconds"));
  }
//+------------------------------------------------------------------+
