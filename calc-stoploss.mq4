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

int getPipsForCurrentCurrency(){
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
int MaxOrderCount = 10;  // max order that can be placed

int OnInit(){
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){}

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
  
  // Runs when total orders are more than MaxOrderCount
  if (total > MaxOrderCount){
    Alert("Total orders are: ", total);

    bool currOrder = OrderSelect(total - 1, SELECT_BY_POS, MODE_TRADES);
    int ticketID = OrderTicket();

    if (currOrder && OrderClose(ticketID, OrderLots(), OrderClosePrice(), OrderType())) {
      Alert("Order with ticket ID: " , ticketID, " Closed!!");
      return;
    }
    
    Alert("Order with ticket ID: " , ticketID, " Was not closed");
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
        double stopLoss       =  InpStopLossPoints*SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT);
        double stopLossPrice  =  (OrderType()==ORDER_TYPE_BUY) ? OrderOpenPrice()-stopLoss : OrderOpenPrice()+stopLoss;

        stopLossPrice = NormalizeDouble(stopLossPrice, (int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS));
        if (OrderModify(OrderTicket(), OrderOpenPrice(), stopLossPrice, OrderTakeProfit(), OrderExpiration())) {}
      }
    }
  }
}

void MoveStopLoss(){
  int acctProfit = AccountProfit();
  int cnt = OrdersTotal(); // Gets the order total count
  int STOP_WHEN = 50;
  int INCR_SL = 1;
 
  if(cnt == 0){
   STOP_WHEN = 50;
  }
  
  if (acctProfit > STOP_WHEN){ // move stoploss to breakeven when in profit
    for (int x=0;x<=cnt; x++) {
        //Alert("Balance now +20 ", x);
      if (OrderSelect(x, SELECT_BY_POS, MODE_TRADES)) {
        double stopLoss       =  INCR_SL*SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT);
        double stopLossPrice  =  (OrderType() == ORDER_TYPE_BUY) ? OrderOpenPrice() + stopLoss : OrderOpenPrice() - stopLoss;
        stopLossPrice = NormalizeDouble(stopLossPrice, (int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS));

        if (!OrderModify(OrderTicket(), OrderOpenPrice(), stopLossPrice, OrderTakeProfit(), OrderExpiration())) {
          Print("order not modified ", GetLastError());
        }
      }
    }

    INCR_SL = INCR_SL +2; // move stoploss by 2 pips
  }
   //sleep for 1 minute
   //Sleep(60000);
}

  