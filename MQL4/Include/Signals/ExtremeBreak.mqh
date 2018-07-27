//+------------------------------------------------------------------+
//|                                                 ExtremeBreak.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\AbstractSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ExtremeBreak : public AbstractSignal
  {
public:
   ExtremeBreak(int period,ENUM_TIMEFRAMES timeframe,int shift=2,color indicatorColor=clrAquamarine);
   SignalResult     *Analyze(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ExtremeBreak::ExtremeBreak(int period,ENUM_TIMEFRAMES timeframe,int shift=2,color indicatorColor=clrAquamarine):AbstractSignal(period,timeframe,shift,indicatorColor)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *ExtremeBreak::Analyze(string symbol,int shift)
  {
   this.Signal.Reset();

   if(!this.DoesHistoryGoBackFarEnough(symbol,(shift+this.Period())))
     {
      return this.Signal;
     }

   double low =(iLow(symbol,this.Timeframe(),iLowest(symbol,this.Timeframe(),MODE_LOW,this.Period(),shift)));
   double high = (iHigh(symbol,this.Timeframe(),iHighest(symbol,this.Timeframe(),MODE_HIGH,this.Period(),shift)));

   this.DrawIndicatorRectangle(symbol,shift,high,low);

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   if(gotTick)
     {
      if(tick.bid<low)
        {
         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=0;
         this.Signal.takeProfit=0;
        }
      else if(tick.ask>high)
        {
         this.Signal.isSet=true;
         this.Signal.orderType=OP_BUY;
         this.Signal.price=tick.ask;
         this.Signal.symbol=symbol;
         this.Signal.time=tick.time;
         this.Signal.stopLoss=0;
         this.Signal.takeProfit=0;
        }

      if(this.Signal.isSet && !this.DoesSignalMeetRequirements())
        {
         this.Signal.Reset();
        }
     }
   return this.Signal;
  }
//+------------------------------------------------------------------+
