//+------------------------------------------------------------------+
//|                                               AbstractSignal.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsShapes.mqh>
#include <Common\Comparators.mqh>
#include <Common\ValidationResult.mqh>
#include <Signals\SignalResult.mqh>
#include <MarketWatch\MarketWatch.mqh>
#include <Generic\LinkedList.mqh>
#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AbstractSignal
  {
private:
   Comparators       _compare;
   static int        _idCount;
   string            _id;
   ENUM_TIMEFRAMES   _timeframe;
   int               _shift;
   int               _period;
   color             _indicatorColor;
   CChartObjectRectangle _indicatorRectangle;
   CChartObjectTrend _indicatorTrend;
protected:
   virtual void      Timeframe(ENUM_TIMEFRAMES timeframe);
   virtual void      Shift(int shift) { this._shift=shift; };
   virtual void      Period(int period) { this._period=period; };
public:
   virtual ENUM_TIMEFRAMES   Timeframe() { return this._timeframe; }
   virtual int       Shift() { return this._shift; };
   virtual int       Period() { return this._period; };
   virtual color     IndicatorColor() { return this._indicatorColor; };
   virtual void      IndicatorColor(color clr) { this._indicatorColor=clr; };

   string            ID() { return this._id; }

   SignalResult     *Signal;

   void              AbstractSignal(int period,ENUM_TIMEFRAMES timeframe,int shift,color indicatorColor);
   void             ~AbstractSignal();
   virtual bool      DoesHistoryGoBackFarEnough(string symbol,int requiredBars);
   virtual bool      DoesChartHaveEnoughBars(string symbol,int requiredBars);
   virtual bool      DoesSignalMeetRequirements();
   virtual void      DrawIndicatorRectangle(string symbol,int shift,double priceHigh,double priceLow);
   virtual void      DrawIndicatorTrend(string symbol,int shift,double priceCurrent,double pricePrevious);
   virtual bool      Validate();
   virtual bool      Validate(ValidationResult *validationResult);
   virtual SignalResult *Analyze(string symbol);
   virtual SignalResult *Analyze(string symbol,int shift)=0;
  };
static int AbstractSignal::_idCount=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::AbstractSignal(int period,ENUM_TIMEFRAMES timeframe,int shift,color indicatorColor)
  {
   this._id=StringConcatenate("Signal",AbstractSignal::_idCount);
   AbstractSignal::_idCount+=1;

   this.Period(period);
   this.Timeframe(timeframe);
   this.Shift(shift);
   this.IndicatorColor(indicatorColor);

   this.Signal=new SignalResult();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::~AbstractSignal()
  {
   delete this.Signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::Timeframe(ENUM_TIMEFRAMES timeframe)
  {
   if(timeframe==PERIOD_CURRENT)
     {
      this._timeframe=ChartPeriod();
     }
   else
     {
      this._timeframe=timeframe;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AbstractSignal::Validate()
  {
   ValidationResult *v=new ValidationResult();
   v.Result=true;
   bool out=this.Validate(v);
   delete v;
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AbstractSignal::Validate(ValidationResult *v)
  {
   if(!this._compare.IsNotBelow(this.Period(),1))
     {
      v.Result=false;
      v.AddMessage("Period must be 1 or greater.");
     }

   if(!this._compare.IsNotBelow(this.Shift(),0))
     {
      v.Result=false;
      v.AddMessage("Shift must be 0 or greater.");
     }

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *AbstractSignal::Analyze(string symbol)
  {
   MarketWatch::LoadSymbolHistory(symbol,this._timeframe,true);
   MarketWatch::OpenChartIfMissing(symbol,this._timeframe);
   this.Analyze(symbol,this._shift);
   return this.Signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AbstractSignal::DoesHistoryGoBackFarEnough(string symbol,int requiredBars)
  {
   int barsInHistoryCt=Bars(symbol,this.Timeframe());

   int barsNeededInHistoryCt=((int)MathCeil(1.01 *(requiredBars)));
   if(barsInHistoryCt<barsNeededInHistoryCt)
     {
      // There isn't enough history to analyze.
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AbstractSignal::DoesChartHaveEnoughBars(string symbol,int requiredBars)
  {
   int barsOnChartCt=iBars(symbol,this.Timeframe());

   int barsNeededOnChartCt=((int)MathCeil(1.01 *(requiredBars)));
   if(barsOnChartCt<barsNeededOnChartCt)
     {
      // There isn't a bar to draw on.
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AbstractSignal::DoesSignalMeetRequirements()
  {
   if(this.Signal==NULL)
     {
      return false;
     }
   return this.Signal.IsValid();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::DrawIndicatorRectangle(string symbol,int shift,double priceHigh,double priceLow)
  {
   if(!this.DoesChartHaveEnoughBars(symbol,(shift+this._period*2)))
     {
      return;
     }

   long chartId=MarketWatch::GetChartId(symbol,this.Timeframe());
   if(this._indicatorRectangle.Attach(chartId,this.ID(),0,2))
     {
      this._indicatorRectangle.SetPoint(0,Time[shift+this._period],priceHigh);
      this._indicatorRectangle.SetPoint(1,Time[shift],priceLow);
     }
   else
     {
      this._indicatorRectangle.Create(chartId,this.ID(),0,Time[shift+this._period],priceHigh,Time[shift],priceLow);
      this._indicatorRectangle.Color(this.IndicatorColor());
      this._indicatorRectangle.Background(false);
     }

   ChartRedraw(chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::DrawIndicatorTrend(string symbol,int shift,double priceCurrent,double pricePrevious)
  {
   if(!this.DoesChartHaveEnoughBars(symbol,(shift+this.Period()*2)))
     {
      return;
     }

   long chartId=MarketWatch::GetChartId(symbol,this.Timeframe());
   if(this._indicatorTrend.Attach(chartId,this.ID(),0,2))
     {
      this._indicatorTrend.SetPoint(0,Time[shift+this.Period()],pricePrevious);
      this._indicatorTrend.SetPoint(1,Time[shift],priceCurrent);
     }
   else
     {
      this._indicatorTrend.Create(chartId,this.ID(),0,Time[shift+this.Period()],pricePrevious,Time[shift],priceCurrent);
      this._indicatorTrend.Color(this.IndicatorColor());
      this._indicatorTrend.Background(false);
     }

   ChartRedraw(chartId);
  }
//+------------------------------------------------------------------+
