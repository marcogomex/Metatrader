//+------------------------------------------------------------------+
//|                                                        Monkey.mq4 |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Does Magic."
#property strict

#include <EA\Monkey\Monkey.mqh>
#include <EA\Monkey\MonkeySettings.mqh>
#include <EA\Monkey\MonkeyConfig.mqh>

Monkey *bot;
#include <EA\PortfolioManagerBasedBot\BasicEATemplate.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   MonkeyConfig config;

   GetBasicConfigs(config);

   config.lctPeriod=LctPeriod;
   config.lctTimeframe=PortfolioTimeframe;
   config.lctMinimumTpSlDistance=LctMinimumTpSlDistance;
   config.lctSkew=LctSkew;
   
   bot=new Monkey(config);
  }
//+------------------------------------------------------------------+
