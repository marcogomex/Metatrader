//+------------------------------------------------------------------+
//|                                                BasicSettings.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

sinput string PortfolioManagerSettings1; // ####
sinput string PortfolioManagerSettings2; // #### Portfolio Manager Settings
sinput string PortfolioManagerSettings3; // ####

input string WatchedSymbols="USDJPYpro,GBPUSDpro,USDCADpro,USDCHFpro,USDSEKpro"; // Currency Basket, csv list or blank for current chart.
input ENUM_TIMEFRAMES PortfolioTimeframe=PERIOD_CURRENT;
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
input bool SwitchDirectionBySignal=true; // Allow signal switching to close orders?

sinput string BacktestCustomSettings1; // ####
sinput string BacktestCustomSettings2; // #### Backtest Custom Optimization Settings
sinput string BacktestCustomSettings3; // ####

input double InitialScore=100; // Backtest Initial Score
input double GainsStdDevLimitMin=0.0; // Minimum value of StdDev of gains
input double GainsStdDevLimitMax=5.0; // Maximum value of StdDev of gains
input int GainsStdDevLimitWeight=2; // Weight of metric Gains StdDev Limit
input double LossesStdDevLimitMin=0.0; // Minimum value of StdDev of losses
input double LossesStdDevLimitMax=2.5; // Maximum value of StdDev of losses
input int LossesStdDevLimitWeight=2; // Weight of metric Losses StdDev Limit
input double NetProfitRangeMin=500.0; // Minimum Net Profit
input double NetProfitRangeMax=50000.0; // Maximum Net Profit
input int NetProfitRangeWeight=10; // Weight of metric NetProfit Range
input double ExpectancyRangeMin=1.0; // Minimum Expected Average Gain
input double ExpectancyRangeMax=5.0; // Maximum Expected Average Gain
input int ExpectancyRangeWeight=30; // Weight of metric Expected Average Gain
input double TradesPerDayRangeMin=0.2; // Minimum amount of Trades Per Day
input double TradesPerDayRangeMax=5.0;  // Maximum number of Trades Per Day
input int TradesPerDayRangeWeight=2; // Weight of metric Trades Per Day
input double LargestLossPerTotalGainLimit=1.0; // Max Percent of Largest Loss Per Total Gain
input int LargestLossPerTotalGainWeight=2; // Weight of metric Max Percent of Largest Loss Per Total Gain
input double MedianLossPerMedianGainPercentLimit=20.0; // Max Percent of Median Loss Per Median Gain
input int MedianLossPerMedianGainPercentWeight=2; // Weight of metric Max Percent of Median Loss Per Median Gain

#include <EA\PortfolioManagerBasedBot\BasePortfolioManagerBotConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetBasicConfigs(BasePortfolioManagerBotConfig &config)
  {
   config.watchedSymbols=WatchedSymbols;
   config.lots=Lots;
   config.profitTarget=ProfitTarget;
   config.maxLoss=MaxLoss;
   config.slippage=Slippage;
   config.startDay=Start_Day;
   config.endDay=End_Day;
   config.startTime=Start_Time;
   config.endTime=End_Time;
   config.scheduleIsDaily=ScheduleIsDaily;
   config.tradeAtBarOpenOnly=TradeAtBarOpenOnly;
   config.pinExits=PinExits;
   config.switchDirectionBySignal=SwitchDirectionBySignal;

   config.backtestConfig.InitialScore=InitialScore;
   config.backtestConfig.GainsStdDevLimitMin=GainsStdDevLimitMin;
   config.backtestConfig.GainsStdDevLimitMax=GainsStdDevLimitMax;
   config.backtestConfig.GainsStdDevLimitWeight=GainsStdDevLimitWeight;
   config.backtestConfig.LossesStdDevLimitMin=LossesStdDevLimitMin;
   config.backtestConfig.LossesStdDevLimitMax=LossesStdDevLimitMax;
   config.backtestConfig.LossesStdDevLimitWeight=LossesStdDevLimitWeight;
   config.backtestConfig.NetProfitRangeMin=NetProfitRangeMin;
   config.backtestConfig.NetProfitRangeMax=NetProfitRangeMax;
   config.backtestConfig.NetProfitRangeWeight=NetProfitRangeWeight;
   config.backtestConfig.ExpectancyRangeMin=ExpectancyRangeMin;
   config.backtestConfig.ExpectancyRangeMax=ExpectancyRangeMax;
   config.backtestConfig.ExpectancyRangeWeight=ExpectancyRangeWeight;
   config.backtestConfig.TradesPerDayRangeMin=TradesPerDayRangeMin;
   config.backtestConfig.TradesPerDayRangeMax=TradesPerDayRangeMax;
   config.backtestConfig.TradesPerDayRangeWeight=TradesPerDayRangeWeight;
   config.backtestConfig.LargestLossPerTotalGainLimit=LargestLossPerTotalGainLimit;
   config.backtestConfig.LargestLossPerTotalGainWeight=LargestLossPerTotalGainWeight;
   config.backtestConfig.MedianLossPerMedianGainPercentLimit=MedianLossPerMedianGainPercentLimit;
   config.backtestConfig.MedianLossPerMedianGainPercentWeight=MedianLossPerMedianGainPercentWeight;

  }


