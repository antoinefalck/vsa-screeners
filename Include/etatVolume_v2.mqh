//+------------------------------------------------------------------+
//|                                                etatVolume_v2.mqh |
//|                                                          Antoine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antoine"
#property strict

int etatVolume_v2(int Bar, int period, double v_1, double v_2, double v_3, string Pair, int timeframe) {

   double volume = iVolume(Pair, timeframe, Bar);
   int etatVolume;
   
   double indicator1h = averageVolume(Bar, period, Pair, timeframe) + v_1*stdVolume(Bar, period, Pair, timeframe);
   double indicator1b = averageVolume(Bar, period, Pair, timeframe) - v_1*stdVolume(Bar, period, Pair, timeframe);
   double indicator2h = averageVolume(Bar, period, Pair, timeframe) + v_2*stdVolume(Bar, period, Pair, timeframe);
   double indicator2b = averageVolume(Bar, period, Pair, timeframe) - v_2*stdVolume(Bar, period, Pair, timeframe);
   double indicator3h = averageVolume(Bar, period, Pair, timeframe) + v_3*stdVolume(Bar, period, Pair, timeframe);
   double indicator3b = averageVolume(Bar, period, Pair, timeframe) - v_3*stdVolume(Bar, period, Pair, timeframe);

   if (volume <= indicator3b)
      etatVolume = -3;
   else if (indicator3b < volume && volume <= indicator2b)
      etatVolume = -2;
   else if (indicator2b < volume && volume <= indicator1b)
      etatVolume = -1;
   else if (indicator1b < volume && volume <= indicator1h)
      etatVolume = 0;
   else if (indicator1h < volume && volume <= indicator2h)
      etatVolume = 1;
   else if (indicator2h < volume && volume <= indicator3h)
      etatVolume = 2;
   else
      etatVolume = 3;
      
   return etatVolume;
}

// Calcule la moyenne des mm derniers volumes
double averageVolume(int j, double period, string Pair, int timeframe) {
   double volumeTotal = 0.0;
   
   for (int i=0;i<period;i++)
      volumeTotal += iVolume(Pair, timeframe, i+j);

   return volumeTotal / (period);
}

// Calcule l'ecart-type des mm derniers volumes
double stdVolume(int j, double period, string Pair, int timeframe) {
   double sommeEcarts = 0;
   double averageVolume = averageVolume(j, period, Pair, timeframe);
   
   for (int i=0;i<period;i++)
      sommeEcarts += (iVolume(Pair, timeframe, i+j)-averageVolume)*(iVolume(Pair, timeframe, i+j)-averageVolume);
   
   double variance = sommeEcarts / period;
   double ecartType = sqrt(variance);
   
   return ecartType;
}