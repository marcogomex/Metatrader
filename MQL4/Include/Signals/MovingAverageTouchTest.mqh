//+------------------------------------------------------------------+
//|                                       MovingAverageTouchTest.mqh |
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
class MovingAverageTouchTest : public MovingAverageBase
  {
private:
   int               _tests;
public:
                     MovingAverageTouchTest(int period,ENUM_TIMEFRAMES timeframe,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice,int maShift,AbstractSignal *aSubSignal, int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrHotPink,int tests=2);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverageTouchTest::MovingAverageTouchTest(int period,ENUM_TIMEFRAMES timeframe,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice,int maShift,AbstractSignal *aSubSignal,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrHotPink,int tests=2):MovingAverageBase(period,timeframe,maMethod,maAppliedPrice,maShift,shift,minimumSpreadsTpSl,indicatorColor,aSubSignal)
  {
   this._tests=tests;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *MovingAverageTouchTest::Analyzer(string symbol,int shift)
  {
   PriceTrend ma=this.GetMovingAverageTrend(symbol,shift);

   bool hasTestedLevelSufficiently=true;
   int i,sht;
   PriceTrend t_ma=ma;
   PriceTrend l_ma;
   for(i=0;i<this._tests;i++)
     {
      sht=shift+(this.Period()*i);
      t_ma=this.GetMovingAverageTrend(symbol,sht);

      this.DrawIndicatorRectangle(symbol,sht,t_ma.current,t_ma.previous,StringConcatenate("_rectangle_",i),0,this.IndicatorColor());
      // must have touched the last value of the moving average window
      if(!(this.DetectTouch(symbol,sht,this.Period(),t_ma.current)
         // and the moving average window must have the same directional slope as the current moving average window
         && (((ma.current>ma.previous) && (t_ma.current>t_ma.previous)) || ((ma.current<ma.previous) && (t_ma.current<t_ma.previous)))
         ))
        {
         hasTestedLevelSufficiently=false;
        }
      else
        {
         this.DrawIndicatorArrow(symbol,sht,((t_ma.current+t_ma.previous)/2),(char)77,5,StringConcatenate("_touch_",i),this.IndicatorColor());
        }
     }

   if(!hasTestedLevelSufficiently)
     {
      this.Signal.Reset();
      return this.Signal;
     }

   this.Signal=this._subSignal.Analyze(symbol,shift);
   return this.Signal;
  }
//+------------------------------------------------------------------+
