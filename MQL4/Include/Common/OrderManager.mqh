//+------------------------------------------------------------------+
//|                                                 OrderManager.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <stdlib.mqh>
#include <Generic\ArrayList.mqh>
#include <Common\ValidationResult.mqh>
#include <Common\SimpleParsers.mqh>
#include <Common\BaseLogger.mqh>
#include <Common\Comparators.mqh>
#include <Signals\SignalResult.mqh>
#include <Common\Strings.mqh>
#include <Stats\Stats.mqh>
#include <Stopwatch\Stopwatch.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderManager
  {
private:
   SimpleParsers     simpleParsers;
public:
   int               Slippage;
   BaseLogger        Logger;
   
   void              OrderManager();
   
   double            CalculateEffectiveLeverage(string symbol,ENUM_ORDER_TYPE orderType);
   double            CalculateEffectiveLeverage(string symbol,double lots);
   double            CalculatePositionValue(string symbol,double lots);
   void              CloseOrders(string symbol,datetime minimumAge);
   bool              ModifyOrder(int ticket,double orderPrice,double stopLoss,double takeProfit,datetime expiration,bool pinExits=false);
   void              NormalizeExits(string symbol,ENUM_ORDER_TYPE orderType,double stopLoss,double takeProfit,bool pinExits=true);
   int               SendOrder(SignalResult *s,double lotSize);
   bool              Validate();
   bool              Validate(ValidationResult *validationResult);
   
   static bool       CanTrade();
   static bool       CanTrade(string symbol,datetime time);
   static double     CalculateLotValue(string symbol);
   static void       GetClosedOrderTicketsArray(int &array[],string symbol="");
   static int        GetLastClosedOrderTicket(string symbol="");
   static bool       IsOrderTypeBuying(ENUM_ORDER_TYPE t);
   static bool       IsOrderTypeSelling(ENUM_ORDER_TYPE t);
   static double     PairAveragePrice(string symbol,ENUM_ORDER_TYPE orderType);
   static double     PairAveragePriceWithAdditonalOrder(string symbol,ENUM_ORDER_TYPE orderType,double size);
   static double     PairHighestPricePaid(string symbol,ENUM_ORDER_TYPE orderType);
   static double     PairHighestStopLoss(string symbol,ENUM_ORDER_TYPE orderType);
   static double     PairHighestTakeProfit(string symbol,ENUM_ORDER_TYPE orderType);
   static double     PairLotsTotal(string symbol,ENUM_ORDER_TYPE orderType);
   static double     PairLowestPricePaid(string symbol,ENUM_ORDER_TYPE orderType);
   static double     PairLowestStopLoss(string symbol,ENUM_ORDER_TYPE orderType);
   static double     PairLowestTakeProfit(string symbol,ENUM_ORDER_TYPE orderType);
   static double     PairOpenPositionCount(string symbol,datetime minimumAge);
   static double     PairOpenPositionCount(ENUM_ORDER_TYPE orderType,string symbol,datetime minimumAge);
   static double     PairProfit(string symbol);
   static bool       ValidateStopLevels(string symbol,ENUM_ORDER_TYPE orderType,double orderPrice,double stopLoss,double takeProfit);
   static bool       ValidateStopLevels(SignalResult *s);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool OrderManager::IsOrderTypeBuying(ENUM_ORDER_TYPE t)
  {
   if((t==OP_BUY)
      || (t == OP_BUYLIMIT)
      || (t == OP_BUYSTOP))
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool OrderManager::IsOrderTypeSelling(ENUM_ORDER_TYPE t)
  {
   if((t==OP_SELL)
      || (t == OP_SELLLIMIT)
      || (t == OP_SELLSTOP))
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|Gets the total size on the given currency pair.                   |
//+------------------------------------------------------------------+
double OrderManager::PairLotsTotal(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         num=num+OrderLots();
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the highest take profit for any order on the given pair.     |
//+------------------------------------------------------------------+
double OrderManager::PairHighestTakeProfit(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderTakeProfit()>num)
           {
            num=OrderTakeProfit();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the lowest take profit for any order on the given pair.      |
//+------------------------------------------------------------------+
double OrderManager::PairLowestTakeProfit(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || (OrderTakeProfit()>0 && OrderTakeProfit()<num))
           {
            num=OrderTakeProfit();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the highest price paid for any order on the given pair.      |
//+------------------------------------------------------------------+
double OrderManager::PairHighestPricePaid(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderOpenPrice()>num)
           {
            num=OrderOpenPrice();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the lowest price paid for any order on the given pair.       |
//+------------------------------------------------------------------+
double OrderManager::PairLowestPricePaid(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderOpenPrice()<num)
           {
            num=OrderOpenPrice();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the current average price paid for the given currency pair.  |
//+------------------------------------------------------------------+
double OrderManager::PairAveragePrice(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   double sum=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         sum=sum+OrderOpenPrice() * OrderLots();
         num=num+OrderLots();
        }
     }
   if(num>0 && sum>0)
     {
      return (sum / num);
     }
   else
     {
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|Gets the current average price paid for the given currency pair.  |
//+------------------------------------------------------------------+
double OrderManager::PairAveragePriceWithAdditonalOrder(string symbol,ENUM_ORDER_TYPE orderType,double size)
  {
   double num=0;
   double sum=0;
   if(orderType==OP_BUY)
     {
      num=size * 100000;
      sum=MarketInfo(symbol,MODE_ASK) * size * 100000;
     }
   if(orderType==OP_SELL)
     {
      num=size * 100000;
      sum=MarketInfo(symbol,MODE_BID) * size * 100000;
     }

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         sum=sum+OrderOpenPrice() * (OrderLots() * 100000);
         num=num+(OrderLots() * 100000);
        }
     }

   if(num>0 && sum>0)
     {
      return (sum / num);
     }
   else
     {
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|Gets the lowest stop loss for any order on the given pair.        |
//+------------------------------------------------------------------+
double OrderManager::PairLowestStopLoss(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || (OrderStopLoss()>0 && OrderStopLoss()<num))
           {
            num=OrderStopLoss();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the highest stop loss for any order on the given pair.       |
//+------------------------------------------------------------------+
double OrderManager::PairHighestStopLoss(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderStopLoss()>num)
           {
            num=OrderStopLoss();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderManager::CalculateLotValue(string symbol)
  {
   double symbolLotSize=MarketInfo(symbol,MODE_LOTSIZE);
   double symbolPointSize=MarketInfo(symbol,MODE_POINT);
   double symbolDigits=MarketInfo(symbol,MODE_DIGITS);
   double pointShiftFactor=MathPow(10,symbolDigits-5);
   double symbolAskPrice=MarketInfo(symbol,MODE_ASK);
   double symbolTickValue=MarketInfo(symbol,MODE_TICKVALUE);
   double symbolTickSize=MarketInfo(symbol,MODE_TICKSIZE);
   double symbolPointValue=symbolTickValue/symbolTickSize;

   return (symbolLotSize * pointShiftFactor * symbolAskPrice * symbolPointValue * symbolPointSize);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderManager::CalculatePositionValue(string symbol,double lots)
  {
   return this.CalculateLotValue(symbol) * lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderManager::CalculateEffectiveLeverage(string symbol,double lots)
  {
   double positionValue=0;
   double num=0;
   if(lots>0 && AccountEquity()>0)
     {
      positionValue=this.CalculatePositionValue(symbol,lots);
      num=(positionValue/AccountEquity());
     }
   return num;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderManager::CalculateEffectiveLeverage(string symbol,ENUM_ORDER_TYPE orderType)
  {
   return this.CalculateEffectiveLeverage(symbol,PairLotsTotal(symbol,orderType));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManager::OrderManager()
  {
   this.Slippage=10;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::Validate()
  {
   ValidationResult *v=new ValidationResult();
   bool out=this.Validate(v);
   delete v;
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::Validate(ValidationResult *validationResult)
  {
   Comparators compare;
   validationResult.Result=true;

   if(compare.IsLessThan(this.Slippage,(int)0))
     {
      validationResult.AddMessage("The Slippage must be greater than or equal to zero.");
      validationResult.Result=false;
     }

   return validationResult.Result;
  }
//+------------------------------------------------------------------+
//| Basic check on whether trading is allowed and enabled for the    |
//| current symbol at the current time.                              |
//+------------------------------------------------------------------+
bool OrderManager::CanTrade()
  {
   return IsTesting() || IsTradeAllowed();
  }
//+------------------------------------------------------------------+
//| Basic check on whether trading is allowed and enabled.           |
//+------------------------------------------------------------------+
bool OrderManager::CanTrade(string symbol,datetime time)
  {
   return IsTesting() || IsTradeAllowed(symbol,time);
  }
//+------------------------------------------------------------------+
//| Gets the quantity of orders older than the                       |
//| minimum age, on the given pair.                                  |
//+------------------------------------------------------------------+
double OrderManager::PairOpenPositionCount(string symbol,datetime minimumAge)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)
         && (OrderType()==OP_BUY || OrderType()==OP_SELL)
         && OrderSymbol()==symbol
         && (OrderOpenTime()<=minimumAge))
        {
         num=num+1;
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//| Gets the quantity of orders on the given                         |
//| pair, filtered by order type.                                    |
//+------------------------------------------------------------------+
double OrderManager::PairOpenPositionCount(ENUM_ORDER_TYPE orderType,string symbol,datetime minimumAge)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)
         && (OrderType()==orderType)
         && OrderSymbol()==symbol
         && (OrderOpenTime()<=minimumAge))
        {
         num=num+1;
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the current net profit of open positions on the given        |
//|currency pair.                                                    |
//+------------------------------------------------------------------+
double OrderManager::PairProfit(string symbol)
  {
   double sum=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && (OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderSymbol()==symbol)
        {
         sum=sum+OrderProfit();
        }
     }
   return sum;
  }
//+------------------------------------------------------------------+
//| Closes all orders for the specified symbol that are older than   |
//| the minimum age.                                                 |
//+------------------------------------------------------------------+
void OrderManager::CloseOrders(string symbol,datetime minimumAge)
  {
   int ticket,i;
//----
   while(PairOpenPositionCount(symbol,minimumAge)>0)
     {
      for(i=0;i<OrdersTotal();i++)
        {
         ticket=OrderSelect(i,SELECT_BY_POS);
         if(OrderType()==OP_BUY && OrderSymbol()==symbol && (OrderOpenTime()<=minimumAge))
           {
            double bid=NormalizeDouble(MarketInfo(symbol,MODE_BID),(int)MarketInfo(symbol,MODE_DIGITS));
            if(OrderClose(OrderTicket(),OrderLots(),bid,this.Slippage)==false)
              {
               this.Logger.Error((string)GetLastError());
              }
           }
         if(OrderType()==OP_SELL && OrderSymbol()==symbol && (OrderOpenTime()<=minimumAge))
           {
            double ask=NormalizeDouble(MarketInfo(symbol,MODE_ASK),(int)MarketInfo(symbol,MODE_DIGITS));
            if(OrderClose(OrderTicket(),OrderLots(),ask,this.Slippage)==false)
              {
               this.Logger.Error((string)GetLastError());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::SendOrder(SignalResult *r,double lotSize)
  {
   int ticket=(-1);
   int d=(int)SymbolInfoInteger(r.symbol,SYMBOL_DIGITS);

   if(!(this.ValidateStopLevels(r.symbol,r.orderType,r.price,r.stopLoss,r.takeProfit)))
     {
      this.Logger.Warn("OrderSend not sent, stop levels are invalid.");
      this.Logger.Warn(StringConcatenate(
                       "symbol= ",r.symbol,
                       ", type= ",EnumToString((ENUM_ORDER_TYPE)r.orderType),
                       ", lots= ",NormalizeDouble(lotSize,2),
                       ", price= ",NormalizeDouble(r.price,d),
                       ", slippage= ",this.Slippage,
                       ", stop loss= ",NormalizeDouble(r.stopLoss,d),
                       ", take profit=  ",NormalizeDouble(r.takeProfit,d)));
      return ticket;
     }

   ticket=OrderSend(
                    (string)r.symbol,
                    (ENUM_ORDER_TYPE)r.orderType,
                    NormalizeDouble(lotSize,2),
                    NormalizeDouble(r.price,d),
                    (int)this.Slippage,
                    NormalizeDouble(r.stopLoss,d),
                    NormalizeDouble(r.takeProfit,d));

   if(ticket>0)
     {
      Stopwatch s;
      s.Start();
      while(s.ElapsedSeconds()<10 && OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==false)
        {
         Sleep(10);
        }
      s.Stop();
     }

   if(ticket<0)
     {
      this.Logger.Error("OrderSend Error : "+ ErrorDescription(GetLastError()));
      this.Logger.Error(StringConcatenate(
                        "Order Sent : symbol= ",r.symbol,
                        ", type= ",EnumToString((ENUM_ORDER_TYPE)r.orderType),
                        ", lots= ",NormalizeDouble(lotSize,2),
                        ", price= ",NormalizeDouble(r.price,d),
                        ", slippage= ",this.Slippage,
                        ", stop loss= ",NormalizeDouble(r.stopLoss,d),
                        ", take profit=  ",NormalizeDouble(r.takeProfit,d)));
      if(IsTesting())
        {
         ExpertRemove();
        }
      return ticket;
     }
   return ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::ValidateStopLevels(SignalResult *s)
  {
   return OrderManager::ValidateStopLevels(s.symbol,s.orderType,s.price,s.stopLoss,s.takeProfit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::ValidateStopLevels(string symbol,ENUM_ORDER_TYPE orderType,double orderPrice,double stopLoss,double takeProfit)
  {
   if(!(OrderManager::IsOrderTypeBuying(orderType) || OrderManager::IsOrderTypeSelling(orderType)))
     {
      return false;
     }

   double minStops=(MarketInfo(symbol,MODE_STOPLEVEL))*MarketInfo(symbol,MODE_POINT);
   double prc=orderPrice;
   if(orderType==OP_BUY)
     {
      prc=MarketInfo(symbol,MODE_BID);
     }
   if(orderType==OP_SELL)
     {
      prc=MarketInfo(symbol,MODE_ASK);
     }
   if(OrderManager::IsOrderTypeBuying(orderType) && takeProfit>0)
     {
      if(prc>takeProfit)
        {
         return false;
        }
     }
   if(OrderManager::IsOrderTypeBuying(orderType) && stopLoss>0)
     {
      if(prc<stopLoss)
        {
         return false;
        }
     }
   if(OrderManager::IsOrderTypeSelling(orderType) && takeProfit>0)
     {
      if(prc<takeProfit)
        {
         return false;
        }
     }
   if(OrderManager::IsOrderTypeSelling(orderType) && stopLoss>0)
     {
      if(prc>stopLoss)
        {
         return false;
        }
     }
   double tpd=MathAbs(prc - takeProfit);
   double sld=MathAbs(prc - stopLoss);
   if((stopLoss==0 || sld>minStops) && (takeProfit==0 || tpd>minStops))
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::ModifyOrder(int ticket,double orderPrice,double stopLoss,double takeProfit,datetime expiration,bool pinExits=false)
  {
   if(!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      this.Logger.Error(StringConcatenate("Could not select the order with ticket number : ", ticket));
      this.Logger.Error(StringConcatenate((string)GetLastError(), " : ",ErrorDescription(GetLastError())));
      return false;
     }

   double tp=0;
   double sl=0;
   if(!pinExits)
     {
      tp=takeProfit;
      sl=stopLoss;
     }
   else
     {
      tp=OrderTakeProfit();
      sl=OrderStopLoss();

      if(this.IsOrderTypeBuying((ENUM_ORDER_TYPE)OrderType()))
        {
         if(takeProfit>0 && (takeProfit>tp || tp==0))
           {
            tp=takeProfit;
           }
         if(stopLoss>0 && (stopLoss>sl || sl==0))
           {
            sl=stopLoss;
           }
        }
      if(this.IsOrderTypeSelling((ENUM_ORDER_TYPE)OrderType()))
        {
         if(takeProfit>0 && (takeProfit<tp || tp==0))
           {
            tp=takeProfit;
           }
         if(stopLoss>0 && (stopLoss<sl || sl==0))
           {
            sl=stopLoss;
           }
        }
     }

   string symbol=OrderSymbol();
   int d=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   if(NormalizeDouble(OrderOpenPrice(),d)==NormalizeDouble(orderPrice,d)
      &&  NormalizeDouble(OrderStopLoss(),d)==NormalizeDouble(sl,d)
      && NormalizeDouble(OrderTakeProfit(),d)==NormalizeDouble(tp,d)
      && OrderExpiration()==expiration)
     {
      // when asked to change values to what they already are, we're successful without trying.
      return true;
     }

   if(!(this.ValidateStopLevels(symbol,(ENUM_ORDER_TYPE)OrderType(),orderPrice,sl,tp)))
     {
      this.Logger.Warn("OrderModify not sent, stop levels are invalid.");
      this.Logger.Warn(StringConcatenate(
                       "symbol= ",symbol,
                       ", type= ",EnumToString((ENUM_ORDER_TYPE)OrderType()),
                       ", price= ",NormalizeDouble(orderPrice,d),
                       ", stop loss= ",NormalizeDouble(sl,d),
                       ", take profit=  ",NormalizeDouble(tp,d)));
      return false;
     }
   bool success=OrderModify(
                            ticket,
                            NormalizeDouble(orderPrice,d),
                            NormalizeDouble(sl,d),
                            NormalizeDouble(tp,d),
                            expiration);
   if(!success)
     {
      this.Logger.Error("OrderModify Error : "+ ErrorDescription(GetLastError()));
      this.Logger.Error(StringConcatenate(
                        "Order Sent : symbol= ",symbol,
                        ", ticket= ",ticket,
                        ", price= ",NormalizeDouble(orderPrice,d),
                        ", stop loss= ",NormalizeDouble(sl,d),
                        ", take profit=  ",NormalizeDouble(tp,d),
                        ", expiration= ",expiration));
      if(IsTesting())
        {
         ExpertRemove();
        }
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManager::NormalizeExits(string symbol,ENUM_ORDER_TYPE orderType,double stopLoss,double takeProfit,bool pinExits=true)
  {
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         this.ModifyOrder(OrderTicket(),OrderOpenPrice(),stopLoss,takeProfit,OrderExpiration(),pinExits);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManager::GetClosedOrderTicketsArray(int &array[],string symbol="")
  {
   int total=OrdersHistoryTotal();
   int i=0;
   int found=0;
   for(i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if((OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderSymbol()==symbol || Strings::IsNullOrBlank(symbol)))
           {
            if(0<ArrayResize(array,found+1,0))
              {
               array[found]=OrderTicket();
              }
            found++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::GetLastClosedOrderTicket(string symbol="")
  {
   int arr[];
   OrderManager::GetClosedOrderTicketsArray(arr,symbol);
   if(Stats::Count(arr)<=0)
     {
      return 0;
     }
   return Stats::Max(arr);
  }
//+------------------------------------------------------------------+
