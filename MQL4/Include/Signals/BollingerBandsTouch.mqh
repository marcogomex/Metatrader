//+------------------------------------------------------------------+
//|                                          BollingerBandsTouch.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\BollingerBandsBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BollingerBandsTouch : public BollingerBandsBase
  {
private:
   int               _touchPeriod;
   int               _touchShift;
   bool              _fadeTouch;
   color             _touchIndicatorColor;
protected:
   virtual void      DrawIndicator(string symbol,int shift,PriceRange &bbPriceRange,PriceRange &touchboxPriceRange,bool touchedHigh,bool touchedLow);
public:
                     BollingerBandsTouch(int period,ENUM_TIMEFRAMES timeframe,bool fadeTouch,int touchPeriod,double bbDeviation,ENUM_APPLIED_PRICE bbAppliedPrice,int touchShift=0,int bbShift=0,int shift=0,double minimumSpreadsTpSl=1,color bbIindicatorColor=clrAquamarine,color touchIindicatorColor=clrAquamarine);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BollingerBandsTouch::BollingerBandsTouch(int period,ENUM_TIMEFRAMES timeframe,bool fadeTouch,int touchPeriod,double bbDeviation,ENUM_APPLIED_PRICE bbAppliedPrice,int touchShift=0,int bbShift=0,int shift=0,double minimumSpreadsTpSl=1,color bbIndicatorColor=clrAquamarine,color touchIndicatorColor=clrAquamarine):BollingerBandsBase(period,timeframe,bbDeviation,bbShift,bbAppliedPrice,shift,minimumSpreadsTpSl,bbIndicatorColor)
  {
   this._touchPeriod=touchPeriod;
   this._touchShift=touchShift;
   this._fadeTouch=fadeTouch;
   this._touchIndicatorColor=touchIndicatorColor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BollingerBandsTouch::DrawIndicator(string symbol,int shift,PriceRange &bbPriceRange,PriceRange &touchboxPriceRange,bool touchedHigh,bool touchedLow)
  {
   this.DrawIndicatorRectangle(symbol,shift,bbPriceRange.high,bbPriceRange.low);
   this.DrawIndicatorRectangle(symbol,shift,touchboxPriceRange.high,touchboxPriceRange.low,"_touch",this._touchPeriod,this._touchIndicatorColor);

   if(touchedHigh && touchedLow)
     {
      this.DrawIndicatorArrow(symbol,this._touchShift,bbPriceRange.low,(char)120,5,NULL,clrRed); // x
     }
   else
     {
      if(touchedHigh)
        {
         if(this._fadeTouch)
           {
            this.DrawIndicatorArrow(symbol,this._touchShift,bbPriceRange.low,(char)218,5,NULL,this._touchIndicatorColor); // down arrow
           }
         else
           {
            this.DrawIndicatorArrow(symbol,this._touchShift,bbPriceRange.high,(char)217,5,NULL,this._touchIndicatorColor); // up arrow
           }
        }

      if(touchedLow)
        {
         if(!this._fadeTouch)
           {
            this.DrawIndicatorArrow(symbol,this._touchShift,bbPriceRange.low,(char)218,5,NULL,this._touchIndicatorColor); // down arrow
           }
         else
           {
            this.DrawIndicatorArrow(symbol,this._touchShift,bbPriceRange.high,(char)217,5,NULL,this._touchIndicatorColor); // up arrow
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *BollingerBandsTouch::Analyzer(string symbol,int shift)
  {
   PriceRange bb=this.CalculateRange(symbol,shift);
   PriceRange touchbox=this.CalculateRangeByPriceLowHigh(symbol,shift,this._touchPeriod);
   bool touchedHigh=this.DetectTouch(symbol,this._touchShift,this._touchPeriod,bb.high);
   bool touchedLow=this.DetectTouch(symbol,this._touchShift,this._touchPeriod,bb.low);

   DrawIndicator(symbol,shift,bb,touchbox,touchedHigh,touchedLow);

   if(touchedHigh && touchedLow)
     {
      return this.Signal;
     }

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   if(gotTick)
     {
      if((this._fadeTouch && touchedHigh) || (!this._fadeTouch && touchedLow))
        {
         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=0;
         this.Signal.takeProfit=0;
        }
      if((!this._fadeTouch && touchedHigh) || (this._fadeTouch && touchedLow))
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
   return this.Signal;
  }
//+------------------------------------------------------------------+
