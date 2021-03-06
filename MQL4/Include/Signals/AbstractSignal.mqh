//+------------------------------------------------------------------+
//|                                               AbstractSignal.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <ChartObjects\ChartObjectsArrows.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsShapes.mqh>
#include <Common\AdxData.mqh>
#include <Common\Comparators.mqh>
#include <Common\ValidationResult.mqh>
#include <Common\PriceRange.mqh>
#include <Common\PriceTrend.mqh>
#include <Common\OrderManager.mqh>
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
   static int        _idCount;
   string            _id;
   ENUM_TIMEFRAMES   _timeframe;
   int               _shift;
   int               _period;
   color             _indicatorColor;
   double            _minimumSpreadsDistance;
   CChartObjectRectangle _indicatorRectangle;
   CChartObjectTrend _indicatorTrend;
   CChartObjectArrow _indicatorArrow;
protected:
   Comparators       _compare;
   virtual bool      IsValid();
   AbstractSignal   *_subSignal;
   virtual void      Timeframe(ENUM_TIMEFRAMES timeframe);
   virtual void      Shift(int shift) { this._shift=shift; };
   virtual void      Period(int period) { this._period=period; };
public:
   virtual ENUM_TIMEFRAMES   Timeframe() { return this._timeframe; }
   virtual int       Shift() { return this._shift; };
   virtual int       Period() { return this._period; };
   virtual color     IndicatorColor() { return this._indicatorColor; };
   virtual double    MinimumSpreadsDistance() { return this._minimumSpreadsDistance; };
   virtual void      IndicatorColor(color clr) { this._indicatorColor=clr; };

   string            ID() { return this._id; }

   SignalResult     *Signal;

   void              AbstractSignal(int period,ENUM_TIMEFRAMES timeframe,int shift,color indicatorColor,double minimumSpreadsTpSl,AbstractSignal *aSubSignal=NULL);
   void             ~AbstractSignal();
   virtual bool      DoesHistoryGoBackFarEnough(string symbol,int requiredBars);
   virtual bool      DoesChartHaveEnoughBars(string symbol,int requiredBars);
   virtual bool      DoesSignalMeetRequirements();
   virtual void      DrawIndicatorRectangle(string symbol,int shift,double priceHigh,double priceLow,string nameSuffix="",int periodOverride=0,color colorOverride=clrNONE);
   virtual void      DrawIndicatorTrend(string symbol,int shift,double priceCurrent,double pricePrevious,string nameSuffix="",int periodOverride=0,color colorOverride=clrNONE);
   virtual void      DrawIndicatorArrow(string symbol,int shift,double price,const char code,const int width=5,string nameSuffix="",color colorOverride=clrNONE);
   virtual bool      DoesSubsignalConfirm(string symbol,int shift);
   virtual AdxData   GetAdx(string symbol,int shift,ENUM_TIMEFRAMES timeframe,int period,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE);
   virtual double    GetRsi(string symbol,int shift,int period,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE);
   virtual double    GetRsi(string symbol,int shift,ENUM_TIMEFRAMES timeframe,int period,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE);
   virtual double    GetRsi(string symbol,int shift,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE);
   virtual double    GetAtr(string symbol,int shift);
   virtual double    GetAtr(string symbol,int shift,int period);
   virtual double    GetMovingAverage(string symbol,int shift,int maShift,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice);
   virtual double    GetBollingerBands(string symbol,int shift,double deviation,int bbShift,ENUM_APPLIED_PRICE appliedPrice,int bbMode);
   virtual double    GetHighestPriceInRange(string symbol,int shift);
   virtual double    GetHighestPriceInRange(string symbol,int shift,int period);
   virtual double    GetHighestPriceInRange(string symbol,int shift,int period,ENUM_TIMEFRAMES timeframe);
   virtual double    GetLowestPriceInRange(string symbol,int shift);
   virtual double    GetLowestPriceInRange(string symbol,int shift,int period);
   virtual double    GetLowestPriceInRange(string symbol,int shift,int period,ENUM_TIMEFRAMES timeframe);
   virtual PriceRange CalculateRangeByPriceLowHigh(string symbol,int shift);
   virtual PriceRange CalculateRangeByPriceLowHigh(string symbol,int shift,int period);
   virtual bool      DetectTouch(string symbol,int shift,int touchPeriod,double thresholdPrice);
   virtual bool      Validate();
   virtual bool      Validate(ValidationResult *validationResult);
   virtual SignalResult *Analyze(string symbol);
   virtual SignalResult *Analyze(string symbol,int shift);
   virtual SignalResult *Analyzer(string symbol,int shift)=0;
  };
static int AbstractSignal::_idCount=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::AbstractSignal(int period,ENUM_TIMEFRAMES timeframe,int shift,color indicatorColor,double minimumSpreadsTpSl,AbstractSignal *aSubSignal=NULL)
  {
   this._id=StringConcatenate("Signal",AbstractSignal::_idCount);
   AbstractSignal::_idCount+=1;

   this.Period(period);
   this.Timeframe(timeframe);
   this.Shift(shift);
   this.IndicatorColor(indicatorColor);
   this._minimumSpreadsDistance=minimumSpreadsTpSl;
   if(aSubSignal!=NULL)
     {
      this._subSignal=aSubSignal;
     }

   this.Signal=new SignalResult();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::~AbstractSignal()
  {
   if(this._subSignal!=NULL)
     {
      delete this._subSignal;
     }
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

   if(!this._compare.IsNotBelow(this._minimumSpreadsDistance,0.0))
     {
      v.Result=false;
      v.AddMessage("Minimum spreads distance must be 0 or greater.");
     }

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *AbstractSignal::Analyze(string symbol)
  {
   MarketWatch::LoadSymbolHistory(symbol,this._timeframe,true);
   if(!IsTesting())
     {
      MarketWatch::OpenChartIfMissing(symbol,this._timeframe);
     }
   this.Analyze(symbol,this._shift);
   return this.Signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *AbstractSignal::Analyze(string symbol,int shift)
  {
   this.Signal.Reset();

   if(!this.DoesHistoryGoBackFarEnough(symbol,(shift+(this.Period()*2))))
     {
      return this.Signal;
     }

   this.Analyzer(symbol,shift);

   if(this.Signal.isSet && !this.DoesSignalMeetRequirements())
     {
      this.Signal.Reset();
     }

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
   return OrderManager::ValidateStopLevels(this.Signal) && this.Signal.IsValid(this._minimumSpreadsDistance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::DrawIndicatorRectangle(string symbol,int shift,double priceHigh,double priceLow,string nameSuffix="",int periodOverride=0,color colorOverride=clrNONE)
  {
   if(IsTesting() && this.Timeframe()!=ChartPeriod() && symbol!=Symbol())
     {
      return;
     }
   int period=this._period;
   if(periodOverride>0)
     {
      period=periodOverride;
     }

   color indicatorColor=this.IndicatorColor();
   if(colorOverride!=clrNONE)
     {
      indicatorColor=colorOverride;
     }

   if(!this.DoesChartHaveEnoughBars(symbol,(shift+period*2)))
     {
      return;
     }

   string indicatorName=StringConcatenate(this.ID(),"_rectangle",nameSuffix);

   long chartId=MarketWatch::GetChartId(symbol,this.Timeframe());
   if(this._indicatorRectangle.Attach(chartId,indicatorName,0,2))
     {
      this._indicatorRectangle.SetPoint(0,iTime(symbol,this.Timeframe(),shift+period),priceHigh);
      this._indicatorRectangle.SetPoint(1,iTime(symbol,this.Timeframe(),shift),priceLow);
      this._indicatorRectangle.Color(indicatorColor);
     }
   else
     {
      this._indicatorRectangle.Create(chartId,indicatorName,0,iTime(symbol,this.Timeframe(),shift+period),priceHigh,iTime(symbol,this.Timeframe(),shift),priceLow);
      this._indicatorRectangle.Color(indicatorColor);
      this._indicatorRectangle.Background(false);
     }

   ChartRedraw(chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::DrawIndicatorTrend(string symbol,int shift,double priceCurrent,double pricePrevious,string nameSuffix="",int periodOverride=0,color colorOverride=clrNONE)
  {
   if(IsTesting() && this.Timeframe()!=ChartPeriod() && symbol!=Symbol())
     {
      return;
     }
   int period=this._period;
   if(periodOverride>0)
     {
      period=periodOverride;
     }
   color indicatorColor=this.IndicatorColor();
   if(colorOverride!=clrNONE)
     {
      indicatorColor=colorOverride;
     }

   if(!this.DoesChartHaveEnoughBars(symbol,(shift+period*2)))
     {
      return;
     }

   string indicatorName=StringConcatenate(this.ID(),"_trend",nameSuffix);

   long chartId=MarketWatch::GetChartId(symbol,this.Timeframe());
   if(this._indicatorTrend.Attach(chartId,indicatorName,0,2))
     {
      this._indicatorTrend.SetPoint(0,iTime(symbol,this.Timeframe(),shift+period),pricePrevious);
      this._indicatorTrend.SetPoint(1,iTime(symbol,this.Timeframe(),shift),priceCurrent);
      this._indicatorTrend.Color(indicatorColor);
     }
   else
     {
      this._indicatorTrend.Create(chartId,indicatorName,0,iTime(symbol,this.Timeframe(),shift+period),pricePrevious,iTime(symbol,this.Timeframe(),shift),priceCurrent);
      this._indicatorTrend.Color(indicatorColor);
      this._indicatorTrend.Background(false);
     }

   ChartRedraw(chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AbstractSignal::DrawIndicatorArrow(string symbol,int shift,double price,const char wingdingCode,const int width=5,string nameSuffix="",color colorOverride=clrNONE)
  {
   if(IsTesting() && this.Timeframe()!=ChartPeriod() && symbol!=Symbol())
     {
      return;
     }
   if(!this.DoesChartHaveEnoughBars(symbol,shift))
     {
      return;
     }

   color indicatorColor=this.IndicatorColor();
   if(colorOverride!=clrNONE)
     {
      indicatorColor=colorOverride;
     }

   string indicatorName=StringConcatenate(this.ID(),"_arrow",nameSuffix);

   long chartId=MarketWatch::GetChartId(symbol,this.Timeframe());
   if(this._indicatorArrow.Attach(chartId,indicatorName,0,1))
     {
      this._indicatorArrow.Color(indicatorColor);
      this._indicatorArrow.ArrowCode(wingdingCode);
      this._indicatorArrow.SetPoint(0,iTime(symbol,this.Timeframe(),shift),price);
     }
   else
     {
      this._indicatorArrow.Create(chartId,indicatorName,0,iTime(symbol,this.Timeframe(),shift),price,wingdingCode);
      this._indicatorArrow.Color(indicatorColor);
      this._indicatorArrow.Background(false);
      this._indicatorArrow.Width(width);
     }

   ChartRedraw(chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AdxData AbstractSignal::GetAdx(string symbol,int shift,ENUM_TIMEFRAMES timeframe,int period,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE)
  {
   AdxData d;
   d.Main = iADX(symbol,timeframe,period,appliedPrice,MODE_MAIN,shift);
   d.PlusDirection = iADX(symbol,timeframe,period,appliedPrice,MODE_PLUSDI,shift);
   d.MinusDirection = iADX(symbol,timeframe,period,appliedPrice,MODE_MINUSDI,shift);
   return d;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetRsi(string symbol,int shift,ENUM_TIMEFRAMES timeframe,int period,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE)
  {
   return iRSI(symbol,timeframe,period,appliedPrice,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetRsi(string symbol,int shift,int period,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE)
  {
   return this.GetRsi(symbol,shift,this.Timeframe(),period,appliedPrice);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetRsi(string symbol,int shift,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE)
  {
   return this.GetRsi(symbol,shift,this.Timeframe(),this.Period(),appliedPrice);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetAtr(string symbol,int shift)
  {
   return this.GetAtr(symbol,shift,this.Period());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetAtr(string symbol,int shift,int period)
  {
   return iATR(symbol,this.Timeframe(),period,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetMovingAverage(string symbol,int shift,int maShift,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice)
  {
   return iMA(symbol,this.Timeframe(),this.Period(),maShift,maMethod,maAppliedPrice,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetBollingerBands(string symbol,int shift,double deviation,int bbShift,ENUM_APPLIED_PRICE appliedPrice,int bbMode)
  {
   return iBands(symbol,this.Timeframe(),this.Period(),deviation,bbShift,appliedPrice,bbMode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetHighestPriceInRange(string symbol,int shift,int period,ENUM_TIMEFRAMES timeframe)
  {
   return (iHigh(symbol,timeframe,iHighest(symbol,timeframe,MODE_HIGH,period,shift)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetHighestPriceInRange(string symbol,int shift,int period)
  {
   return this.GetHighestPriceInRange(symbol,shift,period,this.Timeframe());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetHighestPriceInRange(string symbol,int shift)
  {
   return this.GetHighestPriceInRange(symbol,shift,this.Period(),this.Timeframe());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetLowestPriceInRange(string symbol,int shift,int period,ENUM_TIMEFRAMES timeframe)
  {
   return (iLow(symbol,timeframe,iLowest(symbol,timeframe,MODE_LOW,period,shift)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetLowestPriceInRange(string symbol,int shift,int period)
  {
   return this.GetLowestPriceInRange(symbol,shift,period,this.Timeframe());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AbstractSignal::GetLowestPriceInRange(string symbol,int shift)
  {
   return this.GetLowestPriceInRange(symbol,shift,this.Period(),this.Timeframe());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceRange AbstractSignal::CalculateRangeByPriceLowHigh(string symbol,int shift,int period)
  {
   PriceRange pr;
   pr.low=this.GetLowestPriceInRange(symbol,shift,period);
   pr.high=this.GetHighestPriceInRange(symbol,shift,period);
   pr.mid=((pr.low+pr.high)/2);
   return pr;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceRange AbstractSignal::CalculateRangeByPriceLowHigh(string symbol,int shift)
  {
   PriceRange pr;
   pr.low=this.GetLowestPriceInRange(symbol,shift);
   pr.high=this.GetHighestPriceInRange(symbol,shift);
   pr.mid=((pr.low+pr.high)/2);
   return pr;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AbstractSignal::DetectTouch(string symbol,int shift,int touchPeriod,double thresholdPrice)
  {
   PriceRange lh=this.CalculateRangeByPriceLowHigh(symbol,shift,touchPeriod);
   return this._compare.IsBetween(thresholdPrice,lh.low,lh.high);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AbstractSignal::DoesSubsignalConfirm(string symbol,int shift)
  {
// if the signal is not set, there is nothing to confirm.
   if(!this.Signal.isSet)
     {
      return false;
     }
// by default, a set signal is self confirming.
   bool out=true;
// if there is no subsignal then the signal is confirmed.
   if(this._subSignal!=NULL)
     {
      SignalResult *sig=this._subSignal.Analyze(symbol,shift+this._subSignal.Shift());
      // when there is a subSignal defined for this Signal,
      // the subSignal must be set AND the subSignal OrderType
      // must match the Signal OrderType.
      if(this._compare.Nand(sig.isSet,(sig.orderType==this.Signal.orderType)))
        {
         // either the subSignal was not set
         // or the OrderType did not match
         // the OrderType of the Signal
         out=false;
        }
     }
   return out;
  }
//+------------------------------------------------------------------+
