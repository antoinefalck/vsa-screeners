//+------------------------------------------------------------------+
//|                                                etatSpread_v2.mqh |
//|                                                    Antoine Falck |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antoine Falck"
#property strict

int etatSpread_v2(int i, int period, double s_1, double s_2, string Pair, int timeframe) {
   
   int etatSpread;
   double spread = iHigh(Pair, timeframe, i)-iClose(Pair, timeframe, i);
   
   double indicator1h = averageSpread(i, period, Pair, timeframe) + s_1*stdSpread(i, period, Pair, timeframe);
   double indicator1b = averageSpread(i, period, Pair, timeframe) - s_1*stdSpread(i, period, Pair, timeframe);
   double indicator2h = averageSpread(i, period, Pair, timeframe) + s_2*stdSpread(i, period, Pair, timeframe);
   double indicator2b = averageSpread(i, period, Pair, timeframe) - s_2*stdSpread(i, period, Pair, timeframe);

   if (spread <= indicator2b)
      etatSpread = -2;
   else if (indicator2b < spread && spread <= indicator1b)
      etatSpread = -1;
   else if (indicator1b < spread && spread <= indicator1h)
      etatSpread = 0;
   else if (indicator1h < spread && spread <= indicator2h)
      etatSpread = 1;
   else
      etatSpread = 2;

   return etatSpread;
}

double averageSpread(int i, int period, string Pair, int timeframe) {
   double sommeSpread = 0.0;
   
   for (int j=0;j<period;j++) {
      sommeSpread += iHigh(Pair, timeframe, i+j)-iLow(Pair, timeframe, i+j);
   }
   
   return sommeSpread / period;
}

double stdSpread(int i, int period, string Pair, int timeframe) {
   double sommeEcarts = 0;
   double averageSpread = averageSpread(i, period, Pair, timeframe);
   
   for (int j=0;j<period;j++)
      sommeEcarts += (iHigh(Pair, timeframe, i+j)-iLow(Pair, timeframe, i+j)-averageSpread)*(iHigh(Pair, timeframe, i+j)-iLow(Pair, timeframe, i+j)-averageSpread);
   
   double variance = sommeEcarts / period;
   double ecartType = sqrt(variance);
   
   return ecartType;
}