//+------------------------------------------------------------------+
//|                                                      RsiBase.mqh |
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
class RsiBase : public AbstractSignal
  {
protected:
   double            _overboughtLevel;
   double            _oversoldLevel;
   bool              _invertedSignal;
   ENUM_APPLIED_PRICE _appliedPrice;
public:
                     RsiBase(int period,ENUM_TIMEFRAMES timeframe,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE,double overboughtLevel=80,double oversoldLevel=20,int shift=0,double minimumSpreadsTpSl=1,bool invertSignal=false,color indicatorColor=clrAquamarine,AbstractSignal *aSubSignal=NULL);
   virtual bool      DoesSignalMeetRequirements();
   virtual bool      Validate(ValidationResult *v);
   void InvertedSignal(bool invertSignal) { this._invertedSignal=invertSignal; }
   bool InvertedSignal() { return this._invertedSignal; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RsiBase::RsiBase(int period,ENUM_TIMEFRAMES timeframe,ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE,double overboughtLevel=80,double oversoldLevel=20,int shift=0,double minimumSpreadsTpSl=1,bool invertSignal=false,color indicatorColor=clrAquamarine,AbstractSignal *aSubSignal=NULL):AbstractSignal(period,timeframe,shift,indicatorColor,minimumSpreadsTpSl,aSubSignal)
  {
   this._overboughtLevel=overboughtLevel;
   this._oversoldLevel=oversoldLevel;
   this._invertedSignal=invertSignal;
   this._appliedPrice=appliedPrice;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RsiBase::Validate(ValidationResult *v)
  {
   AbstractSignal::Validate(v);

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RsiBase::DoesSignalMeetRequirements()
  {
   if(!(AbstractSignal::DoesSignalMeetRequirements()))
     {
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
