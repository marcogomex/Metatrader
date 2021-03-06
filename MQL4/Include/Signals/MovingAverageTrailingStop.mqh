//+------------------------------------------------------------------+
//|                                    MovingAverageTrailingStop.mqh |
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
class MovingAverageTrailingStop : public MovingAverageBase
  {
private:
   bool              _initializeTo1Atr;
public:
                     MovingAverageTrailingStop(int period,ENUM_TIMEFRAMES timeframe,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice,int maShift,int shift=0,double minimumSpreadsTpSl=1,bool initializeTo1Atr=true);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverageTrailingStop::MovingAverageTrailingStop(int period,ENUM_TIMEFRAMES timeframe,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice,int maShift,int shift=0,double minimumSpreadsTpSl=1,bool initializeTo1Atr=true):MovingAverageBase(period,timeframe,maMethod,maAppliedPrice,maShift,shift,minimumSpreadsTpSl,clrNONE)
  {
   this._initializeTo1Atr=initializeTo1Atr;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *MovingAverageTrailingStop::Analyzer(string symbol,int shift)
  {
   OrderManager om;
   if(om.PairOpenPositionCount(symbol,TimeCurrent())<1)
     {
      return this.Signal;
     }
   double buyPrice=om.PairAveragePrice(symbol,OP_BUY);
   double sellPrice=om.PairAveragePrice(symbol,OP_SELL);
   if(_compare.Xnor((buyPrice>0),(sellPrice>0)))
     {
      return this.Signal;
     }

   double sl=0.0;
   double profit=om.PairProfit(symbol);
   double ma=this.GetMovingAverage(symbol,shift);
   double atr=0.0;
   if(this._initializeTo1Atr==true)
     {
      atr=this.GetAtr(symbol,shift);
     }

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   if(gotTick)
     {
      if(sellPrice>0)
        {
         if(((tick.bid+atr)<sellPrice) && profit>0)
           {
            sl=ma;
           }
         else if(atr>0.0)
           {
            sl=sellPrice+atr;
           }

         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=sl;
         this.Signal.takeProfit=0;
         if(!this.DoesSignalMeetRequirements())
           {
            this.Signal.stopLoss=tick.ask+(MarketInfo(symbol,MODE_SPREAD)*this.MinimumSpreadsDistance()*MarketInfo(symbol,MODE_POINT));
           }
         while(!this.DoesSignalMeetRequirements())
           {
            this.Signal.stopLoss=this.Signal.stopLoss+(1*MarketInfo(symbol,MODE_POINT));
           }
        }
      if(buyPrice>0)
        {
         if(((tick.ask-atr)>buyPrice) && profit>0)
           {
            sl=ma;
           }
         else if(atr>0.0)
           {
            sl=buyPrice-atr;
           }
         this.Signal.isSet=true;
         this.Signal.orderType=OP_BUY;
         this.Signal.price=tick.ask;
         this.Signal.symbol=symbol;
         this.Signal.time=tick.time;
         this.Signal.stopLoss=sl;
         this.Signal.takeProfit=0;
         if(!this.DoesSignalMeetRequirements())
           {
            this.Signal.stopLoss=tick.bid-(MarketInfo(symbol,MODE_SPREAD)*this.MinimumSpreadsDistance()*MarketInfo(symbol,MODE_POINT));
           }
         while(!this.DoesSignalMeetRequirements())
           {
            this.Signal.stopLoss=this.Signal.stopLoss-(1*MarketInfo(symbol,MODE_POINT));
           }
        }
     }
   return this.Signal;
  }
//+------------------------------------------------------------------+
