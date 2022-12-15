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
   printf(Symbol(), " is the symbol");
   if(Symbol() == "XAUUSD"){
      return(250);
   }
   if(Symbol() == "BTCUSD"){
      return(20000);
   }
    if(Symbol() == "US30"){
      printf("stop loss is: 250");
      return(2000);
   }
  return(100);
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
void OnTick() {
  CloseExcessOrders();
  CalculateStopLoss();
  MoveStopLoss();
 }
  
void CloseExcessOrders() {
  int total = OrdersTotal();
  
  // Runs when total orders are more than 10
  if (total > 10){
       Alert("Total orders are: ",total);
  
       bool currOrder = OrderSelect(total - 1, SELECT_BY_POS, MODE_TRADES);
       int needleTicket = OrderTicket();
       if (currOrder && OrderClose(needleTicket,OrderLots(), OrderClosePrice(), OrderType())) {
         Alert("Order with ticket ID: " , needleTicket, " Closed!!");
         return;
       }
       Alert("Order with ticket ID: " , needleTicket, " Was not closed");
  }
}

void CalculateStopLoss(){
  datetime checkTime = TimeCurrent()-10;
  
  int cnt = OrdersTotal();

  // printf(IntegerToString(InpStopLossPoints));
  
  for (int x=0;x<=cnt; x++) {
     if (OrderSelect(x, SELECT_BY_POS, MODE_TRADES)) {
          if (OrderStopLoss()==0 && (OrderType()==ORDER_TYPE_BUY || OrderType()==ORDER_TYPE_SELL)) {
            // if (OrderOpenTime()>checkTime) {}
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

void MoveStopLoss(){
  int acctProfit = AccountProfit();
  int cnt = OrdersTotal();
  int STOP_WHEN = 20;
 
  if(cnt = 0){
   STOP_WHEN = 20;
  }
  
   if (acctProfit > STOP_WHEN){
      Alert("Balance now +20");
       for (int x=0;x<=cnt; x++) {
          if (OrderSelect(x, SELECT_BY_POS, MODE_TRADES)) {
            double   stopLoss       =  10*SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT);
            double   stopLossPrice  =  (OrderType()==ORDER_TYPE_BUY) ?
                                       OrderOpenPrice()+stopLoss :
                                       OrderOpenPrice()-stopLoss;
            stopLossPrice = NormalizeDouble(stopLossPrice, (int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS));
            if (OrderModify(OrderTicket(), OrderOpenPrice(), stopLossPrice, OrderTakeProfit(), OrderExpiration())) {}
         }
         //sleep for 1 minute
         Sleep(60000); 
       }
    }
}

  