//+------------------------------------------------------------------+
//|                                          BasketSignalScanner.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\BaseSymbolScanner.mqh>
#include <Common\OrderManager.mqh>
#include <Signals\SignalSet.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BasketSignalScanner : public BaseSymbolScanner
  {
private:
   OrderManager      orderManager;
   SignalSet        *signalSet;
   double            lotSize;
public:
   bool              disableExitsBacksliding;
   bool              closePositionsOnOppositeSignal;
   void              BasketSignalScanner(
                                         SymbolSet *aSymbolSet,SignalSet *aSignalSet,
                                         double lotSize,bool allowExitsToBackslide,
                                         bool closePositionsOnOppositeSignal);
   void              PerSymbolAction(string symbol);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BasketSignalScanner::BasketSignalScanner(
                                              SymbolSet *aSymbolSet,SignalSet *aSignalSet,double aLotSize,
                                              bool allowExitsToBackslide,
                                              bool closeOrdersOnOppositeSignal):BaseSymbolScanner(aSymbolSet)
  {
   this.signalSet=aSignalSet;
   this.lotSize=aLotSize;
   this.disableExitsBacksliding=!allowExitsToBackslide;
   this.closePositionsOnOppositeSignal=closeOrdersOnOppositeSignal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BasketSignalScanner::PerSymbolAction(string symbol)
  {
   this.signalSet.Analyze(symbol,this.closePositionsOnOppositeSignal);
   if(this.signalSet.Signal!=NULL)
     {
      SignalResult *r=this.signalSet.Signal;
      if(r.isSet==true)
        {
         if(this.orderManager.PairOpenPositionCount(r.symbol,TimeCurrent())<1)
           {
            this.orderManager.SendOrder(r,this.lotSize);
           }
         else
           {
            if(0==this.orderManager.PairOpenPositionCount(r.orderType,r.symbol,TimeCurrent()))
              {
               if(closePositionsOnOppositeSignal)
                 {
                  this.orderManager.CloseOrders(r.symbol,TimeCurrent());
                  this.orderManager.SendOrder(r,this.lotSize);
                 }
              }
            else
              {
               // modifies the sl and tp according to the signal given.
               this.orderManager.NormalizeExits(
                                                r.symbol,r.orderType,r.stopLoss,
                                                r.takeProfit,this.disableExitsBacksliding);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
