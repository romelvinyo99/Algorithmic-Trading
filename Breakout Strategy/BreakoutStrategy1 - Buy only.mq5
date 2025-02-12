// Defining the properties
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.2"
// Importing the trade module
#include <Trade/Trade.mqh>
// Initialization of the Trade class
CTrade Trade ; 

// Event-Handling functions

// Initiliazer function
ulong magic_number = 42 ; 
int OnInit(){
  // Setting the magic number 
  Trade.SetExpertMagicNumber(magic_number) ;
  // Printing the initialization message
  Print("Opening program...") ;
  return INIT_SUCCEEDED ;   
}

// Deinitializer function
void OnDeinit(const int reason){
  Print("...Closing program") ; 
  Print("Reason: ", reason) ; 
}

// Tick-Event function
// Period - days
input ENUM_TIMEFRAMES period = PERIOD_D1 ;
// Count - How many x-bars/candles back
input int count = 10 ; 
// Tp and Sl - in form of pips
input int tp_points = 100 ; 
input int sl_points = 100 ; 
void OnTick(){
  // Getting the ask price (Buy price)
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK) ; 
  // Getting the highest bar index - shift parameter
  int high_index = iHighest(_Symbol, period, MODE_HIGH, count, 0) ; 
  // Getting the highest value of the high bar index
  double high = iHigh(_Symbol, period, high_index) ; 
  // Checking for open positions
  bool isOpen = loopPositions() ; 
  //Opening a buy position - if the market is moving upwards
  if (ask > high && !isOpen){
      Print("Ask: ",ask) ;
      Print("High: ", high) ; 
      
     // Calculating the spread
     ulong spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) ; 
     // Calculating the stop level
     ulong stop_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) ; 
     // Calculating the take profit and stop loss - enough to cover the spread
     double sl = NormalizeDouble((ask - ((sl_points+spread+stop_level) * _Point)), _Digits) ;
     double tp = NormalizeDouble((ask + ((sl_points+spread+stop_level) * _Point)), _Digits) ;
     // Checking for invalid stop level
     if (sl > 0 && ask - sl < (stop_level+spread)*_Point){
         Print("Invalid stop loss") ;
         return ;  
     }
     if (sl > 0 && tp - ask < (stop_level+spread)*_Point){
         Print("Invalid stop loss") ; 
         return ; 
     }
     // Calculating the lot size
     double lots = 0.012 ; 
     // Removing excess precision - rounding up
     lots = (int)(lots / SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)) * SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP) ; 
     // When extremely low - below required level
     lots = MathMax(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) ;
     // When extremely high - above required level 
     lots = MathMin(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)) ; 
     
     // Opening a buy position
     if (Trade.Buy(lots, _Symbol, 0, sl, tp, "This is a buy positions")){
        Print("Trade successful: ", Trade.ResultOrder()) ; 
     }
     else{
        Print("Trade Failed: ", Trade.ResultRetcodeDescription()) ; 
     }
  }
}
// Loop open positons functions - with trailing stop loss capabilities
input bool lsTsl = true ; 
input int tslBufferPips = 10 ; 
bool loopPositions(){
   bool checkOpen = false ; 
   for (int i = PositionsTotal()-1 ; i>=0 ; i--){
       // Getting the position ticket
       ulong position_ticket = PositionGetTicket(i) ;
       // Getting the position magic number and symbol 
       ulong position_magic = PositionGetInteger(POSITION_MAGIC) ;
       string position_symbol = PositionGetString(POSITION_SYMBOL) ;
       // Checking if position is open
       if (magic_number != position_magic) continue ; 
       if (_Symbol != position_symbol) continue ; 
       // If the above conditions are false means the position is open 
       checkOpen = true ;
       // Trailing Stop loss
       if (lsTsl){
          // Getting the position stop loss and take profit
          double position_sl = PositionGetDouble(POSITION_SL) ; 
          double position_tp = PositionGetDouble(POSITION_TP) ; 
          // Getting the slbuffer
          double sl_buffer = tslBufferPips * _Point ; 
          // Getting the lowest value of the last bar - some pips - to prevent close tracking
          double last_candle_sl = NormalizeDouble((iLow(_Symbol, period, 1) - sl_buffer), _Digits) ; 
          if (last_candle_sl > position_sl && last_candle_sl > 0){
             // Position modification
             Trade.PositionModify(position_ticket, last_candle_sl, position_tp) ;
          }
       }   
   
   }
   return checkOpen ; 
}

