//+------------------------------------------------------------------+
//|                                                 MonkeyConfig.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <EA\PortfolioManagerBasedBot\BasePortfolioManagerBotConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct MonkeyConfig : public BasePortfolioManagerBotConfig
  {
public:
   int               lctPeriod;
   ENUM_TIMEFRAMES   lctTimeframe;
   double            lctMinimumTpSlDistance;
   double            lctSkew;
  };
//+------------------------------------------------------------------+
