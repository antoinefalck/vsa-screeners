//+------------------------------------------------------------------+
//|                                                          sow.mqh |
//|                                                    Antoine Falck |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antoine Falck"

#include <etatVolume_v2.mqh>
#include <etatSpread_v2.mqh>
#include <etatClose_v2.mqh>

bool sow(string Pair, int Bar, int timeFrame) {
   bool resultat = false;
   
   // Variables statiques qui servent au calcul
   int            ext_mm = 23;
   double         ext_s1 = 0.4;
   double         ext_s2 = 1.0;
   double         ext_v1 = 0.4;
   double         ext_v2 = 1.0;
   double         ext_v3 = 2.0;
   int            ext_p =  5;
   int            ext_LH = 5;

   // Variables qui servent dans les conditions
   int vol        = etatVolume_v2(Bar, ext_mm, ext_v1, ext_v2, ext_v3, Pair, timeFrame);
   int volBar1    = etatVolume_v2(Bar+1, ext_mm, ext_v1, ext_v2, ext_v3, Pair, timeFrame);
   int spr        = etatSpread_v2(Bar, ext_mm, ext_s1, ext_s2, Pair, timeFrame);
   int clo        = etatClose_v2(Bar, Pair, timeFrame);
   int cloBar1    = etatClose_v2(Bar+1, Pair, timeFrame);

   double high = iHigh(Pair, timeFrame, Bar);
   double high1 = iHigh(Pair, timeFrame, Bar+1);
   double low = iLow(Pair, timeFrame, Bar);
   double low1 = iLow(Pair, timeFrame, Bar+1);
   double close = iClose(Pair, timeFrame, Bar);
   double close1 = iClose(Pair, timeFrame, Bar+1);
   double close2 = iClose(Pair, timeFrame, Bar+2);
   double volume = iVolume(Pair, timeFrame, Bar);
   double volume1 = iVolume(Pair, timeFrame, Bar+1);
   double volume2 = iVolume(Pair, timeFrame, Bar+2);

   // Cloture up
   bool CUp = (close > close1);

   // Cloture up prec
   bool CUpBar1 = (close1 > close2);      

   // Cloture down
   bool CDown = (close < close1);

   // Fresh new high ground
   bool CHighest = (Bar == iHighest(Pair, timeFrame, MODE_LOW, ext_p, Bar));

   // High Up
   bool CHigh = (high > high1);
      
   // Showing an increase in volume
   bool CVolHausse = (volume > volume1);

   // Increase volume bar prec
   bool CVolHausseBar1 = (volume1 > volume2);
      
   // There should be an up-move behind you
   bool CHausse = true;
   for (int j=0;j<=ext_LH;j++) {
      if(iMA(Pair, timeFrame, 23, 0, MODE_SMA, PRICE_CLOSE, Bar+j+1) > 
         iMA(Pair, timeFrame, 23, 0, MODE_SMA, PRICE_CLOSE, Bar+j)) {
         CHausse = false;
         break;
      }
   }
  
   //giving the apperance of a top reversal
   bool CtopHigh = ((high>(0.75*high1+0.25*low1)) && (high<(1.25*high1-0.25*low1)));
   bool CtopLow = ((low<(0.75*low1+0.25*high1)) && (low>(1.25*low1-0.25*high1)));
   bool CTop = (CtopHigh && CtopLow);


   //--- Sortie de resultat

   // SOW1
   if(CUp && (vol>=2) && (clo==0) && CHighest && CHausse)
      resultat = true;

   // SOW2
   if(CHigh && (clo==-1) && (spr>=0) && (vol!=0))
      resultat = true;
      
   // SOW5
   if((spr<=0) && CUp && (vol>=2) && (clo<=0) && CHighest)
      resultat = true;

   // SOW54
   if((vol>=2) && CUp && (clo<=0) && CHausse)
      resultat = true;

   // SOW58
   if(CUpBar1 && (spr>=1) && CDown && (clo==-1) && CHigh)
      resultat = true;

   // SOW78
   if((spr==2) && CDown && (clo==-1))
      resultat = true;

   // SOW89
   if(CUpBar1 && CVolHausseBar1 && (clo<=0) && (vol>=1) && (high>low1 && CHausse))
      resultat = true;
         
   // SOW108
   if(CUpBar1 && (cloBar1==1) && CDown && (clo==-1) && CHausse && CTop)
      resultat = true;
 
   return(resultat);
}