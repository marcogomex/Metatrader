//+------------------------------------------------------------------+
//|                                                MovingAverage.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\MovingAverageBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MovingAverage : public MovingAverageBase
  {
public:
                     MovingAverage(int period,ENUM_TIMEFRAMES timeframe,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice,int maShift,int shift=0,color indicatorColor=clrHotPink);
   SignalResult     *Analyze(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverage::MovingAverage(int period,ENUM_TIMEFRAMES timeframe,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice,int maShift,int shift=0,color indicatorColor=clrHotPink):MovingAverageBase(period,timeframe,maMethod,maAppliedPrice,maShift,shift,indicatorColor)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *MovingAverage::Analyze(string symbol,int shift)
  {
   this.Signal.Reset();

   if(!this.DoesHistoryGoBackFarEnough(symbol,(shift+this.Period()*2)))
     {
      return this.Signal;
     }

   double movingAverage=iMA(symbol,this.Timeframe(),this.Period(),this._maShift,this._maMethod,this._maAppliedPrice,shift);
   double movingAveragePrevious=iMA(symbol,this.Timeframe(),this.Period(),this._maShift,this._maMethod,this._maAppliedPrice,this.Period()+shift);

   this.DrawIndicatorTrend(symbol,shift,movingAverage,movingAveragePrevious);

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   if(gotTick)
     {
      if(movingAverage<movingAveragePrevious)
        {
         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=0;
         this.Signal.takeProfit=0;
        }
      if(movingAverage>movingAveragePrevious)
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
