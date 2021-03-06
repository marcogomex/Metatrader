//+------------------------------------------------------------------+
//|                                BasePortfolioManagerBotConfig.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <EA\Common\EAConfig.mqh>
#include <BacktestOptimizations\BacktestOptimizationsConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct BasePortfolioManagerBotConfig : public EAConfig
  {
public:
   string            watchedSymbols;
   double            lots;
   double            profitTarget;
   double            maxLoss;
   int               slippage;
   ENUM_DAY_OF_WEEK  startDay;
   ENUM_DAY_OF_WEEK  endDay;
   string            startTime;
   string            endTime;
   bool              scheduleIsDaily;
   bool              tradeAtBarOpenOnly;
   bool              pinExits;
   bool              switchDirectionBySignal;
   BacktestOptimizationsConfig backtestConfig;
  };
//+------------------------------------------------------------------+
