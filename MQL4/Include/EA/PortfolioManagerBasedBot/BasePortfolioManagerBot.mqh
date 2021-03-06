//+------------------------------------------------------------------+
//|                                      BasePortfolioManagerBot.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <PLManager\PLManager.mqh>
#include <Schedule\ScheduleSet.mqh>
#include <Signals\SignalSet.mqh>
#include <PortfolioManager\PortfolioManager.mqh>
#include <EA\PortfolioManagerBasedBot\BasePortfolioManagerBotConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BasePortfolioManagerBot
  {
protected:
   PortfolioManager *portfolioManager;
   SymbolSet        *ss;
   ScheduleSet      *sched;
   OrderManager     *om;
   PLManager        *plman;
   SignalSet        *signalSet;
public:
   void              BasePortfolioManagerBot(BasePortfolioManagerBotConfig &config);
   void             ~BasePortfolioManagerBot();
   virtual void      Initialize();
   virtual double    CustomTestResult()
     {
      return portfolioManager.CustomTestResult();
     }
   virtual void      Execute();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BasePortfolioManagerBot::BasePortfolioManagerBot(BasePortfolioManagerBotConfig &config)
  {
   if(IsTesting())
     {
      config.watchedSymbols=Symbol();
     }
     
   this.ss=new SymbolSet();
   this.ss.AddSymbolsFromCsv(config.watchedSymbols);

   this.sched=new ScheduleSet();
   if(config.scheduleIsDaily==true)
     {
      this.sched.AddWeek(config.startTime,config.endTime,config.startDay,config.endDay);
     }
   else
     {
      this.sched.Add(new Schedule(config.startDay,config.startTime,config.endDay,config.endTime));
     }

   this.om=new OrderManager();
   this.om.Slippage=config.slippage;

   this.plman=new PLManager(ss,om);
   this.plman.ProfitTarget=config.profitTarget;
   this.plman.MaxLoss=config.maxLoss;
   this.plman.MinAge=60;

   this.signalSet=new SignalSet();

   this.portfolioManager=new PortfolioManager(config.lots,this.ss,this.sched,this.om,this.plman,this.signalSet,config.backtestConfig);
   this.portfolioManager.tradeEveryTick=!config.tradeAtBarOpenOnly;
   this.portfolioManager.AllowExitsToBackslide(!config.pinExits);
   this.portfolioManager.ClosePositionsOnOppositeSignal(config.switchDirectionBySignal);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BasePortfolioManagerBot::~BasePortfolioManagerBot()
  {
   delete portfolioManager;
   delete ss;
   delete sched;
   delete om;
   delete plman;
   delete signalSet;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BasePortfolioManagerBot::Initialize()
  {
   this.portfolioManager.Initialize();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BasePortfolioManagerBot::Execute()
  {
   this.portfolioManager.Execute();
  }
//+------------------------------------------------------------------+
