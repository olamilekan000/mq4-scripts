//+------------------------------------------------------------------+
//|                                                 stoplosscalc.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int getPipsForCurrentCurrency()
{
   if(Symbol() == "XAUUSD"){
      printf("stop loss is: 250");
      return(200);
   }
   printf("stop loss is: 200");
  return(200);
}

int InpStopLossPoints = getPipsForCurrentCurrency();  // Stop loss in points

int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
  datetime checkTime = TimeCurrent()-10;
  
  int cnt = OrdersTotal();
  
  printf(IntegerToString(InpStopLossPoints));
  
  for (int i=cnt-1; i>=0; i--) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber()==0 && OrderStopLoss()==0
               && (OrderType()==ORDER_TYPE_BUY || OrderType()==ORDER_TYPE_SELL)) {
            if (OrderOpenTime()>checkTime) {
               double   stopLoss       =  InpStopLossPoints*SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT);
               double   stopLossPrice  =  (OrderType()==ORDER_TYPE_BUY) ?
                                          OrderOpenPrice()-stopLoss :
                                          OrderOpenPrice()+stopLoss;
               stopLossPrice = NormalizeDouble(stopLossPrice, (int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS));
               if (OrderModify(OrderTicket(), OrderOpenPrice(), stopLossPrice, OrderTakeProfit(), OrderExpiration())) {}
            }
         }
      }
   }
  }