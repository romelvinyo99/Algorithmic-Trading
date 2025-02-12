#include <Trade/Trade.mqh>

int OnInit(){
   execute_buy() ; 
   return INIT_SUCCEEDED ; 
}
void execute_buy(){
   double entry = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + 100.31 * _Point ; 
   Print(entry) ; 
   
   double tp = entry + 100 * _Point ;
   tp = NormalizeDouble(tp, _Digits) ; 
   Print(tp) ; 
   
   double sl = entry - 100 * _Point ;
   sl = NormalizeDouble(sl, _Digits) ;  
   Print(sl) ; 
   double lots = 23232 ; 
   lots = (int)(lots / SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)) * SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lots = MathMin(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)) ; 
   lots = MathMax(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) ; 
   Print(lots) ; 
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID) ; 
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK) ; 
   ulong spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) ;
   ulong stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) ;  
   
   if(sl > 0 &&entry - sl < (stopLevel + spread)){
      Print(__FUNCTION__, "cannot place buy order invalid sl") ;   
   }
   if(tp > 0 && tp - entry < (stopLevel + spread)){
      Print(__FUNCTION__, "cannot place buy order invalid tp") ; 
   }
   CTrade Trade ; 
   
   if(entry - ask < (spread + stopLevel)){
      Print(__FUNCTION__, "Cannot place buy stop order(Invalid order price)") ; 
   }
   
   if(Trade.BuyStop(lots, entry, _Symbol, sl, tp, ORDER_TIME_GTC)){}
   else{
      Print("Unable to place pending buy order-Error: ", Trade.ResultRetcodeDescription(), "Code: ", Trade.ResultRetcode()) ; 
   }

}