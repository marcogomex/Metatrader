//+------------------------------------------------------------------+
//|                                                    RsiLevels.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\RsiBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RsiLevels : public RsiBase
  {
public:
                     RsiLevels(int period,ENUM_TIMEFRAMES timeframe,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE,double overboughtLevel=80,double oversoldLevel=20,int shift=0,double minimumSpreadsTpSl=1,bool invertSignal=false,color indicatorColor=clrAquamarine,AbstractSignal *aSubSignal=NULL);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RsiLevels::RsiLevels(int period,ENUM_TIMEFRAMES timeframe,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE,double overboughtLevel=80,double oversoldLevel=20,int shift=0,double minimumSpreadsTpSl=1,bool invertSignal=false,color indicatorColor=clrAquamarine,AbstractSignal *aSubSignal=NULL):RsiBase(period,timeframe,appliedPrice,overboughtLevel,oversoldLevel,shift,minimumSpreadsTpSl,invertSignal,indicatorColor,aSubSignal)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *RsiLevels::Analyzer(string symbol,int shift)
  {
   double rsi=this.GetRsi(symbol,shift,this._appliedPrice);

   PriceRange pr=this.CalculateRangeByPriceLowHigh(symbol,shift);

   this.DrawIndicatorRectangle(symbol,shift,pr.high,pr.low);

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);
   bool sell=(rsi>this._overboughtLevel);
   bool buy=(rsi<this._oversoldLevel);
   bool sellSignal=(this._compare.Ternary(this.InvertedSignal(),buy,sell));
   bool buySignal=(this._compare.Ternary(this.InvertedSignal(),sell,buy));

   if(gotTick && sellSignal!=buySignal)
     {
      if(sellSignal)
        {
         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=0;
         this.Signal.takeProfit=0;
        }
      else if(buySignal)
        {
         this.Signal.isSet=true;
         this.Signal.orderType=OP_BUY;
         this.Signal.price=tick.ask;
         this.Signal.symbol=symbol;
         this.Signal.time=tick.time;
         this.Signal.stopLoss=0;
         this.Signal.takeProfit=0;
        }
     }

// signal confirmation
   if(!this.DoesSubsignalConfirm(symbol,shift))
     {
      this.Signal.Reset();
     }

   return this.Signal;
  }
//+------------------------------------------------------------------+
