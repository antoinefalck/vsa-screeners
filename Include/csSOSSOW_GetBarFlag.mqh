// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// INCLUDED CODE
// =============
// Specify your conditions.
//
// Remember to 'save as...', replacing XXXX by your setup identifier.
//
// Replace 'XXXX' by your setup identifier (in one place in the code below).
//
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <sos.mqh>
#include <sow.mqh>

int csSOSSOW_GetBarFlag(string Pair, int Bar, int timeFrame )
   {
   if(sos(Pair, Bar, timeFrame)) {
      if(sow(Pair, Bar, timeFrame))
         return(2);
      else
         return(1);
   }
   
   else {
      if(sow(Pair, Bar, timeFrame))
         return(-1);
      else
         return(0);
   }

   }
// ~~ end function ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





