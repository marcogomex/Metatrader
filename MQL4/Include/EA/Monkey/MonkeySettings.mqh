//+------------------------------------------------------------------+
//|                                               MonkeySettings.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

sinput string MonkeySettings1; // ####
sinput string MonkeySettings2; // #### Signal Settings
sinput string MonkeySettings3; // ####

input int LctPeriod=30; // Period for calculating exits.
input double LctMinimumTpSlDistance=5; // Tp/Sl minimum distance, in spreads.
input double LctSkew=0.0; // Skew sl/tp spread

#include <EA\PortfolioManagerBasedBot\BasicSettings.mqh>
