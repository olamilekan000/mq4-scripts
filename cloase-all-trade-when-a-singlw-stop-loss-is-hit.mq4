//+------------------------------------------------------------------+
//|                                                      CancelAll.mq4|
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                         https://www.metaquotes.net|
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialization code
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Deinitialization code
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Check all open trades
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         // Check if the order is an open trade
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
           {
            // Check if the stop loss has been hit
            if((OrderType() == OP_BUY && Bid <= OrderStopLoss()) ||
               (OrderType() == OP_SELL && Ask >= OrderStopLoss()))
              {
               // Close the trade
               if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, clrRed))
                 {
                  Print("Error closing order: ", GetLastError());
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
