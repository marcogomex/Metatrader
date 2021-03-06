//+------------------------------------------------------------------+
//|                                             PortfolioManager.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <PLManager\PLManager.mqh>
#include <Schedule\ScheduleSet.mqh>
#include <Signals\SignalSet.mqh>
#include <stdlib.mqh>
#include <Signals\BasketSignalScanner.mqh>
#include <BacktestOptimizations\BacktestOptimizations.mqh>
#include <BacktestOptimizations\BacktestOptimizationsConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PortfolioManager
  {
private:
   BacktestOptimizationsConfig backtestConfig;
   bool              deleteLogger;
   bool              _allowExitsToBackslide;
   bool              _closePositionsOnOppositeSignal;
public:
   SymbolSet        *allowedSymbols;
   ScheduleSet      *schedule;
   OrderManager     *orderManager;
   PLManager        *plmanager;
   SignalSet        *signalSet;
   BasketSignalScanner *basketSignalScanner;
   BaseLogger       *logger;
   datetime          time;
   double            lotSize;
   bool              tradeEveryTick;
                     PortfolioManager(double lots,SymbolSet *aAllowedSymbolSet,ScheduleSet *aSchedule,OrderManager *aOrderManager,PLManager *aPlmanager,SignalSet *aSignalSet,BacktestOptimizationsConfig &backtestConfigs,BaseLogger *aLogger);
                    ~PortfolioManager();
   bool              Validate(ValidationResult *validationResult);
   bool              Validate();
   bool              ValidateAndLog();
   void              Initialize();
   void              Execute();
   bool              CanTrade();
   void              AllowExitsToBackslide(bool setTrueToMoveSLbackwardBySignal);
   bool              AllowExitsToBackslide();
   void              ClosePositionsOnOppositeSignal(bool setTrueToCloseOpenOrdersOnOppositeSignal);
   bool              ClosePositionsOnOppositeSignal();
   virtual double    CustomTestResult();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PortfolioManager::PortfolioManager(double lots,SymbolSet *aAllowedSymbolSet,ScheduleSet *aSchedule,OrderManager *aOrderManager,PLManager *aPlmanager,SignalSet *aSignalSet,BacktestOptimizationsConfig &backtestConfigs,BaseLogger *aLogger=NULL)
  {
   this._closePositionsOnOppositeSignal=false;
   this._allowExitsToBackslide=false;
   this.tradeEveryTick=true;
   this.lotSize=lots;
   this.allowedSymbols=aAllowedSymbolSet;
   this.schedule=aSchedule;
   this.orderManager=aOrderManager;
   this.plmanager=aPlmanager;
   this.signalSet=aSignalSet;
   this.basketSignalScanner=new BasketSignalScanner(this.allowedSymbols,this.signalSet,this.lotSize,this._allowExitsToBackslide,this._closePositionsOnOppositeSignal);
   if(aLogger==NULL)
     {
      this.logger=new BaseLogger();
      this.deleteLogger=true;
     }
   this.backtestConfig=backtestConfigs;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PortfolioManager::~PortfolioManager()
  {
   delete this.basketSignalScanner;
   if(this.deleteLogger==true)
     {
      delete this.logger;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PortfolioManager::Validate()
  {
   ValidationResult *validationResult=new ValidationResult();
   return this.Validate(validationResult);
   delete validationResult;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PortfolioManager::Validate(ValidationResult *validationResult)
  {
   validationResult.Result=true;
   Comparators compare;

   bool omv=this.orderManager.Validate(validationResult);
   bool plv=this.plmanager.Validate(validationResult);
   bool sigv=this.signalSet.Validate(validationResult);

   validationResult.Result=(omv && plv && sigv);

   if(!compare.IsGreaterThan(this.lotSize,(double)0))
     {
      validationResult.AddMessage("Lots must be greater than zero.");
      validationResult.Result=false;
     }

   return validationResult.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PortfolioManager::ValidateAndLog()
  {
   string border[]=
     {
      "",
      "!~ !~ !~ !~ !~ User Settings validation failed ~! ~! ~! ~! ~!",
      ""
     };
   ValidationResult *v=new ValidationResult();
   bool out=this.Validate(v);
   if(out==false)
     {
      this.logger.Log(border);
      this.logger.Warn(v.Messages);
      this.logger.Log(border);
     }
   delete v;
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioManager::Initialize()
  {
   if(!this.ValidateAndLog())
     {
      ExpertRemove();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  PortfolioManager::ClosePositionsOnOppositeSignal(bool setTrueToCloseOpenOrdersOnOppositeSignal)
  {
   this._closePositionsOnOppositeSignal=setTrueToCloseOpenOrdersOnOppositeSignal;
   this.basketSignalScanner.closePositionsOnOppositeSignal=setTrueToCloseOpenOrdersOnOppositeSignal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PortfolioManager::ClosePositionsOnOppositeSignal(void)
  {
   return this._closePositionsOnOppositeSignal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  PortfolioManager::AllowExitsToBackslide(bool setTrueToMoveSLbackwardBySignal)
  {
   this._allowExitsToBackslide=setTrueToMoveSLbackwardBySignal;
   this.basketSignalScanner.disableExitsBacksliding=!setTrueToMoveSLbackwardBySignal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PortfolioManager::AllowExitsToBackslide()
  {
   return this._allowExitsToBackslide;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioManager::Execute()
  {
   if(this.plmanager.CanTrade() && this.CanTrade())
     {
      if(this.tradeEveryTick || Time[0]!=this.time)
        {
         this.time=Time[0];
         if(this.schedule.IsActive(TimeCurrent()))
           {
            this.basketSignalScanner.Scan();
           }
        }
     }
   this.plmanager.Execute();
  }
//+------------------------------------------------------------------+
//|Rules to stop the bot from even trying to trade                   |
//+------------------------------------------------------------------+
bool PortfolioManager::CanTrade()
  {
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioManager::CustomTestResult()
  {

   double days=PortfolioStats::HistoryDuration().ToDays();
   
   this.backtestConfig.FactorBy_GainsSlopeUpward_Granularity=((int)MathFloor(days/30.0));
   
   BacktestOptimizations bo(this.backtestConfig);
     
   return bo.GetScore();
  };
//+------------------------------------------------------------------+
