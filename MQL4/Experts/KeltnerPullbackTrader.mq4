//+------------------------------------------------------------------+
//|                                        KeltnerPullbackTrader.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Does Magic."
#property strict

#include <EA\KeltnerPullbackTrader.mqh>

input string WatchedSymbols="USDJPYpro,GBPUSDpro,USDCADpro,USDCHFpro,USDSEKpro"; // Currency Basket, csv list or blank for current chart.
input ENUM_TIMEFRAMES KeltnerPullbackTimeframe=PERIOD_D1;
input int KeltnerPullbackMaPeriod=30;
input int KeltnerPullbackMaShift=0;
input ENUM_MA_METHOD KeltnerPullbackMaMethod=MODE_EMA;
input ENUM_APPLIED_PRICE KeltnerPullbackMaAppliedPrice=PRICE_TYPICAL;
input color KeltnerPullbackMaColor=clrHotPink;
input int KeltnerPullbackAtrPeriod=30;
input double KeltnerPullbackAtrMultiplier=3;
input color KeltnerPullbackAtrColor=clrAquamarine;
input int KeltnerPullbackShift=0;
input double KeltnerPullbackMinimumTpSlDistance=5; // Tp/Sl minimum distance, in spreads.
input int KeltnerPullbackParallelSignals=2; // Quantity of parallel signals to use.
input double Lots=0.5;
input double ProfitTarget=0; // Profit target in account currency
input double MaxLoss=0; // Maximum allowed loss in account currency
input int Slippage=10; // Allowed slippage
extern ENUM_DAY_OF_WEEK Start_Day=0;//Start Day
extern ENUM_DAY_OF_WEEK End_Day=6;//End Day
extern string   Start_Time="00:00";//Start Time
extern string   End_Time="24:00";//End Time
input bool ScheduleIsDaily=false;// Use start and stop times daily?
input bool TradeAtBarOpenOnly=false;// Trade only at opening of new bar?
input bool PinExits=true; // Disable signals from moving exits backward?

KeltnerPullbackTrader *keltnerPullbackTrader;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   delete keltnerPullbackTrader;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   string symbols=WatchedSymbols;
   ENUM_TIMEFRAMES timeframe=KeltnerPullbackTimeframe;
   if(IsTesting())
     {
      symbols=Symbol();
      timeframe=PERIOD_CURRENT;
     }
   keltnerPullbackTrader=new KeltnerPullbackTrader(
                                                   symbols,
                                                   KeltnerPullbackMaPeriod,
                                                   KeltnerPullbackMaShift,
                                                   KeltnerPullbackMaMethod,
                                                   KeltnerPullbackMaAppliedPrice,
                                                   KeltnerPullbackMaColor,
                                                   KeltnerPullbackAtrPeriod,
                                                   KeltnerPullbackAtrMultiplier,
                                                   KeltnerPullbackShift,
                                                   KeltnerPullbackAtrColor,
                                                   KeltnerPullbackMinimumTpSlDistance,
                                                   timeframe,
                                                   KeltnerPullbackParallelSignals,
                                                   Lots,ProfitTarget,MaxLoss,Slippage,
                                                   Start_Day,End_Day,Start_Time,End_Time,ScheduleIsDaily,
                                                   TradeAtBarOpenOnly,PinExits);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   keltnerPullbackTrader.Execute();
  }
//+------------------------------------------------------------------+
