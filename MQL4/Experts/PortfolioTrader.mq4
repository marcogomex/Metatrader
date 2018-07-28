//+------------------------------------------------------------------+
//|                                              PortfolioTrader.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Does Magic."
#property strict

#include <EA\PortfolioTrader.mqh>

input string WatchedSymbols="USDJPYpro,GBPUSDpro,USDCADpro,USDCHFpro,USDSEKpro"; // Currency Basket, csv list or blank for current chart.
input ENUM_TIMEFRAMES ExtremeBreakTimeframe=PERIOD_CURRENT;
input int ExtremeBreakPeriod=30; // Breakout period, highest and lowest price threshold.
input int ExtremeBreakShift=1; // How many bars are in a breakout?
input color ExtremeBreakColor=clrAquamarine; // Color the breakout box
input int AtrPeriod=3; // Atr period for calculating Tp/Sl
input double AtrMultiplier=3; // Atr multiplier.
input double AtrMinimumTpSlDistance=5; // Tp/Sl minimum distance, in spreads.
input color AtrColor=clrHotPink; // Color the Atr box.
input int ParallelSignals=3; // Quantity of parallel signals to use.
input double Lots=0.01; // Lots to trade.
input double ProfitTarget=25; // Profit target in account currency.
input double MaxLoss=25; // Maximum allowed loss in account currency.
input int Slippage=10; // Allowed slippage.
extern ENUM_DAY_OF_WEEK Start_Day=0; // Start Day
extern ENUM_DAY_OF_WEEK End_Day=6; // End Day
extern string   Start_Time="00:00"; // Start Time
extern string   End_Time="24:00"; // End Time
input bool ScheduleIsDaily=false; // Use start and stop times daily?
input bool TradeAtBarOpenOnly=false; // Trade only at opening of new bar?
input bool PinExits=true; // Disable signals from moving exits backward?

PortfolioTrader *portfolioTrader;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   delete portfolioTrader;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   string symbols=WatchedSymbols;
   ENUM_TIMEFRAMES timeframe=ExtremeBreakTimeframe;
   if(IsTesting())
     {
      symbols=Symbol();
      timeframe=PERIOD_CURRENT;
     }
   portfolioTrader=new PortfolioTrader(
                                       symbols,
                                       ExtremeBreakPeriod,ExtremeBreakShift,ExtremeBreakColor,
                                       AtrMinimumTpSlDistance,timeframe,
                                       AtrPeriod,AtrMultiplier,AtrColor,
                                       ParallelSignals,Lots,ProfitTarget,MaxLoss,Slippage,
                                       Start_Day,End_Day,Start_Time,End_Time,ScheduleIsDaily,
                                       TradeAtBarOpenOnly,PinExits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   portfolioTrader.Execute();
  }
//+------------------------------------------------------------------+
