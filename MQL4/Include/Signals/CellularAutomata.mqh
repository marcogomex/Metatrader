//+------------------------------------------------------------------+
//|                                             CellularAutomata.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\CellularAutomataBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CellularAutomata : public CellularAutomataBase
  {
public:
                     CellularAutomata(int period,ENUM_TIMEFRAMES timeframe,double minimumSpreadsTpSl,double skew,AbstractSignal *aSubSignal=NULL);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CellularAutomata::CellularAutomata(int period,ENUM_TIMEFRAMES timeframe,double minimumSpreadsTpSl,double skew,AbstractSignal *aSubSignal=NULL):CellularAutomataBase(period,timeframe,0,minimumSpreadsTpSl,skew,aSubSignal)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *CellularAutomata::Analyzer(string symbol,int shift)
  {
   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);
// and there's a fresh tick on the symbol's chart
   if(gotTick)
     {

      bool isRangeMode=this.IsRangeMode(symbol,shift,10,tick);
      if(isRangeMode)
        {
         this._atrMultiplier=0.675;
         this._skew=0.18;
        }
      else
        {
         this._atrMultiplier=1;
         this._skew=0.0;
        }

      PriceRange pr=this.CalculateRangeByPriceLowHigh(symbol,shift+1,14);
      pr.high=this.GetHighestPriceInRange(symbol,1,14,PERIOD_H1);
      pr.low=this.GetLowestPriceInRange(symbol,1,14,PERIOD_H1);

      bool sell=(tick.ask<pr.mid) && (tick.ask<pr.low);
      bool buy=(tick.bid>pr.mid) && (tick.bid>pr.high);

      bool sellSignal=(_compare.Ternary(isRangeMode,buy,sell));
      bool buySignal=(_compare.Ternary(isRangeMode,sell,buy));

      if(_compare.Xor(sellSignal,buySignal))
        {
         if(sellSignal)
           {
            this.SetSellSignal(symbol,shift,tick,isRangeMode);
           }

         if(buySignal)
           {
            this.SetBuySignal(symbol,shift,tick,isRangeMode);
           }

         // signal confirmation
         if(!this.DoesSubsignalConfirm(symbol,shift))
           {
            this.Signal.Reset();
           }
        }
      else
        {
         this.Signal.Reset();
        }

      // if there is an order open...
      if(1<=OrderManager::PairOpenPositionCount(symbol,TimeCurrent()))
        {
         this.SetExits(symbol,shift,tick);
        }

     }

   return this.Signal;
  }
//+------------------------------------------------------------------+
