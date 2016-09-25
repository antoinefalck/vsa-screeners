//+------------------------------------------------------------------+
//|                                                          sos.mqh |
//|                                                    Antoine Falck |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| sos1 sos34 sos36 sos53 sos57 sos91 sos99 sos101                  |
//+------------------------------------------------------------------+

#include <etatVolume_v2.mqh>
#include <etatSpread_v2.mqh>
#include <etatClose_v2.mqh>

#property copyright "Antoine Falck"

bool sos(string Pair, int Bar, int timeFrame) {
   bool resultat = false;
   
   // Variables statiques qui servent au calcul
   int            ext_mm = 23;
   double         ext_s1 = 0.4;
   double         ext_s2 = 1.0;
   double         ext_v1 = 0.4;
   double         ext_v2 = 1.0;
   double         ext_v3 = 2.0;
   int            ext_p =  5;
   int            ext_LB = 5;


   // Variables qui servent dans les conditions
   int vol        = etatVolume_v2(Bar, ext_mm, ext_v1, ext_v2, ext_v3, Pair, timeFrame);
   int volBar1    = etatVolume_v2(Bar+1, ext_mm, ext_v1, ext_v2, ext_v3, Pair, timeFrame);
   int spr        = etatSpread_v2(Bar, ext_mm, ext_s1, ext_s2, Pair, timeFrame);
   int clo        = etatClose_v2(Bar, Pair, timeFrame);
   int cloBar1    = etatClose_v2(Bar+1, Pair, timeFrame);

   double low = iLow(Pair, timeFrame, Bar);
   double low1 = iLow(Pair, timeFrame, Bar+1);
   double close = iClose(Pair, timeFrame, Bar);
   double close1 = iClose(Pair, timeFrame, Bar+1);
   double close2 = iClose(Pair, timeFrame, Bar+2);
   double volume = iVolume(Pair, timeFrame, Bar);
   double volume1 = iVolume(Pair, timeFrame, Bar+1);
      
      
   // Cloture up
   bool CUp = (close > close1);
         
   // Cloture down
   bool CDown = (close < close1);

   // Cloture down prec
   bool CDownBar1 = (close1 < close2);      
         
   // Fresh new Low ground
   bool CLowest = (Bar == iLowest(Pair, timeFrame, MODE_LOW, ext_p, Bar));
      
   // Fresh new Low ground bar prec
   bool CLowestBar1 = (Bar+1 == iLowest(Pair, timeFrame, MODE_LOW, ext_p, Bar+1));
      
   // Low Down
   bool CLow = (low < low1);
         
   // Showing an increase in volume
   bool CVolHausse = (volume > volume1);

   // Volumes plus importants que les quelques precedents (ici que les VB precedents)
   bool CVolHaussiers = true;
   for (int j=0;j<=ext_LB;j++) {
      if (volume < iVolume(Pair, timeFrame, Bar+j)) {
         CVolHaussiers = false;
         break;
      }
   }
   
   // There should be an up-move behind you
   bool CBaisse = true;
   for (int j=0;j<=ext_LB;j++) {
      if(iMA(Pair, timeFrame, 23, 0, MODE_SMA, PRICE_CLOSE, Bar+j+1) < 
         iMA(Pair, timeFrame, 23, 0, MODE_SMA, PRICE_CLOSE, Bar+j)) {
         CBaisse = false;
         break;
      }
   }
      

   //--- Sortie de resultat
     
   // SOS1
   if(CDown && CVolHaussiers && (clo>=0) && CBaisse && CLowest)
      resultat = true;

   // SOS34
   if(CLow && (spr>=1) && (clo==1))
      resultat = true;
   
   // SOS6
   if (CDown && (spr<0) && (vol>=2) && CLowest)
      resultat = true;
      
   // SOS54
   if (CLow && (spr>=1) && (clo==1) )
      resultat = true;

   // SOS57
   if (CDownBar1 && (cloBar1==-1) && CUp && (clo==1) && CBaisse)
      resultat = true;

   // SOS91
   if (CDown && (vol>=2) && CBaisse)
      resultat = true;
   
   // SOS99
   if(CDownBar1 && CLowestBar1 && CUp && (spr>=1) && (iMA(Pair, timeFrame, 23, 0, MODE_SMA, PRICE_CLOSE, Bar+1) > 
         iMA(Pair, timeFrame, 23, 0, MODE_SMA, PRICE_CLOSE, Bar)) )  
      // on a cette condition sur les mm23 pour filtrer un peu mais pas trop 
      resultat = true;
      
   // SOS101            
   if (CDownBar1 && (volBar1>=2) && (cloBar1==-1) && CUp && CLowestBar1 && CBaisse)
      resultat = true;
   

return(resultat);
}