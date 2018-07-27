//+------------------------------------------------------------------+
//|                                                  AtrBreakout.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\AtrBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AtrBreakout : public AtrBase
  {
public:
                     AtrBreakout(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,int shift=0,int minimumPointsTpSl=50,color indicatorColor=clrAquamarine);
   SignalResult     *Analyze(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AtrBreakout::AtrBreakout(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,int shift=0,int minimumPointsTpSl=50,color indicatorColor=clrAquamarine):AtrBase(period,atrMultiplier,timeframe,shift,minimumPointsTpSl,indicatorColor)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *AtrBreakout::Analyze(string symbol,int shift)
  {
   this.Signal.Reset();

   if(!this.DoesHistoryGoBackFarEnough(symbol,(shift+this.Period())))
     {
      return this.Signal;
     }

   double atr=iATR(symbol,this.Timeframe(),this.Period(),shift);

   double low=(iLow(symbol,this.Timeframe(),iLowest(symbol,this.Timeframe(),MODE_LOW,this.Period(),shift)));
   double high=(iHigh(symbol,this.Timeframe(),iHighest(symbol,this.Timeframe(),MODE_HIGH,this.Period(),shift)));

   double mid=((low+high)/2);

   low=(mid -(atr*this._atrMultiplier));
   high=(mid+(atr*this._atrMultiplier));

   this.DrawIndicatorRectangle(symbol,shift,high,low);

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   if(gotTick)
     {
      if(tick.ask<=mid)
        {
         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=(tick.bid+MathAbs(high-mid));
         this.Signal.takeProfit=(tick.bid-MathAbs(low-mid));
        }
      if(tick.bid>=mid)
        {
         this.Signal.isSet=true;
         this.Signal.orderType=OP_BUY;
         this.Signal.price=tick.ask;
         this.Signal.symbol=symbol;
         this.Signal.time=tick.time;
         this.Signal.stopLoss=(tick.ask-MathAbs(mid-low));
         this.Signal.takeProfit=(tick.ask+MathAbs(mid-high));
        }

      if(this.Signal.isSet && !this.DoesSignalMeetRequirements())
        {
         this.Signal.Reset();
        }
     }
   return this.Signal;
  }
//+------------------------------------------------------------------+
