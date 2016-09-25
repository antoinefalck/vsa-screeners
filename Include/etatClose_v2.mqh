//+------------------------------------------------------------------+
//|                                                 etatClose_v2.mqh |
//|                                                    Antoine Falck |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antoine Falck"
#property strict

//+------------------------------------------------------------------+
//|                                                    etatClose.mqh |
//|                                                          Antoine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antoine"
#property link      "https://www.mql5.com"
#property strict

int etatClose_v2(int i, string Pair, int timeframe) {
   double position;
   int etatClose;
   double high = iHigh(Pair, timeframe, i);
   double low = iLow(Pair, timeframe, i);
   double close = iClose(Pair, timeframe, i);
   
   if(high - low != 0){
      position = (high-close) / (high-low);
      if (position <= 0.33333) {
         etatClose = 1;
      }
      else if (0.33333 < position && position <= 0.66666) {
         etatClose = 0;
      }
      else {
         etatClose = -1;
      }
   }
   else{
      if(high-close < 0)
         etatClose = 1;
      if(high-close > 0)
         etatClose = -1;
      if(high-close == 0)
         etatClose = 0;
   }
   return etatClose;
}