//+------------------------------------------------------------------+
//|                                                  MarketWatch.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <stdlib.mqh>
#include <Generic\ArrayList.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MarketWatch
  {
public:
   static bool       DoesSymbolExist(string symbol,bool useMarketWatchOnly);
   static bool       IsSymbolWatched(string symbolName);
   static bool       AddSymbolToMarketWatch(string symbolName);
   static bool       RemoveSymbolFromMarketWatch(string symbolName);
   static bool       LoadSymbolHistory(string symbol,ENUM_TIMEFRAMES timeframe,bool force);
   static long       OpenChart(string symbol,ENUM_TIMEFRAMES timeframe);
   static long       OpenChartIfMissing(string symbol,ENUM_TIMEFRAMES timeframe);
   static long       GetChartId(string symbol,ENUM_TIMEFRAMES timeframe);
   static double     SymbolPoints(string symbol);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static double MarketWatch::SymbolPoints(string symbol)
  {
   return MarketInfo(symbol,MODE_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool MarketWatch::DoesSymbolExist(string symbol,bool useMarketWatchOnly=false)
  {
   bool out=false;
   int ct=SymbolsTotal(useMarketWatchOnly);
   for(int i=0; i<ct; i++)
     {
      if(symbol==SymbolName(i,useMarketWatchOnly))
        {
         out=true;
        }
     }
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketWatch::IsSymbolWatched(string symbolName)
  {
   return DoesSymbolExist(symbolName,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketWatch::AddSymbolToMarketWatch(string symbolName)
  {
   bool result=false;
   if(IsSymbolWatched(symbolName))
     {
      result=true;
     }
   else if(DoesSymbolExist(symbolName))
     {
      result=SymbolSelect(symbolName,true);
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketWatch::RemoveSymbolFromMarketWatch(string symbolName)
  {
   bool result=false;
   if(!IsSymbolWatched(symbolName))
     {
      result=true;
     }
   else
     {
      result=SymbolSelect(symbolName,false);
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketWatch::LoadSymbolHistory(string symbol,ENUM_TIMEFRAMES timeframe,bool force)
  {
   MqlRates r[];
   int ct= ArrayCopyRates(r,symbol,timeframe);
   if(ct>=0)
     {
      return true;
     }

   bool out=false;
   int error=GetLastError();
   if(error==4066 && force)
     {
      for(int i=0;i<30; i++)
        {
         Sleep(1000);
         ct=ArrayCopyRates(r,symbol,timeframe);
         if(ct<0)
           {
            //---- check the current bar time
            datetime timestamp=r[0].time;
            if(timestamp>=(TimeCurrent()-(timeframe*60)))
              {
               out=true;
               break;
              }
           }
        }
     }
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long MarketWatch::OpenChart(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   long chartId=ChartOpen(symbol,timeframe);
   if(chartId==0)
     {
      Print("the chart didn't open, error: ",GetLastError());
      Print(ErrorDescription(GetLastError()));
      chartId=(-1);
     }
   return chartId;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long MarketWatch::OpenChartIfMissing(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   long chartId=GetChartId(symbol,timeframe);
   if(chartId==-1)
     {
      chartId=OpenChart(symbol,timeframe);
     }
   return chartId;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long MarketWatch::GetChartId(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   long chartId=ChartFirst();
   while(chartId>=0)
     {
      if(symbol==ChartSymbol(chartId) && timeframe==ChartPeriod(chartId))
        {
         break;
        }
      chartId=ChartNext(chartId);
     }
   return chartId;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
