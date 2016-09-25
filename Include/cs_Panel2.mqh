#property copyright     "Martin Systems, Copyright © 2014"
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// INCLUDED CODE
// =============
/*
This code is intended for inclusion within Indicator Code csXXXX_Panel.mq4
(where XXXX is the identifier for the condition under consideration).
It should not need to be modified.

It displays a panel showing the results of your condition testing on your
chosen pairs and timeframes.

Your test is applied to bar[0] after it is 90% formed, else to bar[1].
Wingdings show whether condition is tested on bar[0] or bar[1].
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
#property indicator_chart_window
#property indicator_buffers 1        // used for de-bugging

// User input
// ==========
extern string  XTimeframes = "M5,M15,M30,H1,H4,D1";
extern string	Pair = "EURUSD";
extern string	XBars = "15,14,13,12,11,10,9,8,7,6,5,4,3,2,1";       // omits M1,W1,MN

// Panel construction variables
// ============================
string	FontName  =  "Courier New"; // A fixed-width font lines up nicely
int		FontSize  =    10;         
color    FontColor =  MediumBlue;    
int      x_width   =  22;         //pixels width for each timeframe column
int      x_offset;                //pixels from the RHS
int      y_depth   =  12;         //pixels depth for each display line

// Timeframes
// ==========
int		countTimeframes;         // Number of timeframes  
int      iT;                      // Indexer for timeframes
string	TimeframeDescs[];        // Timeframe array ("M1","M5" etc)
int		Timeframes[];	          // Timeframe array (in minutes)
datetime TimesDue[];    

// Bars
// ==========
int		countBars;         // Number of timeframes  
int      iB;                      // Indexer for timeframes
int	BarsDescs[];        // Timeframe array ("M1","M5" etc)
//int		Timeframes[];	          // Timeframe array (in minutes)
//datetime TimesDue[];              // Array for TimesDue as to when the next process should occur.
                                  // TimeDue is expressed as the number of seconds elapsed in a period.

// Objects
// =======
string objId ;       // Used to hold the full id of an object.
string objPrefix;

// For testing
// ===========
//bool alerted=false;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialise 
// ==========
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void init()
   {
   objPrefix = "cs" + csName + "_";
   RemoveObjects(objPrefix);   // NB objPrefix is defined in the "includer" program.
                               // RemoveObjects() is an 'included' utility function.

   // Disply the Panel Heading
   // ========================
	x_offset = 0;
	objId = objPrefix + "PanelHead";
   ObjectCreate(objId, OBJ_LABEL, 0, 0, 0);
   ObjectSet(objId, OBJPROP_CORNER, 0);
   ObjectSet(objId, OBJPROP_XDISTANCE, x_offset);
   ObjectSet(objId, OBJPROP_YDISTANCE, y_depth);

   // Sortir un tableau de la chaine de caractere
   int lenXBars, start, intBar;
   string Bar;
   XBars = XBars + ",";
   lenXBars = StringLen(XBars);
   iB = 0;
   for(start=0 ; start<lenXBars;) {
      Bar = StringSubstr(XBars, start, StringFind(XBars,",",start)-start);    // On cherche le numero de la bar
      intBar = StrToInteger(Bar);                                             // On sort le int correspondant au string
      start = start+StringLen(Bar)+1;                                         // On met le start au prohain
      ArrayResize(BarsDescs,iB+1);       // Make room to add a timeframe description...             
      BarsDescs[iB]    =  intBar; // Stack timeframe description in array
      iB++;
   }
   countBars = iB;


   // Display Timeframe column headings
   // =================================
   for(iB = 0; iB < countBars; iB++)
      {
      Bar = BarsDescs[iB];
      x_offset = 60 + iB*x_width + 2;

      objId = objPrefix + Bar + "_Hd";
      ObjectCreate(objId,OBJ_LABEL,0,0,0,0,0);
      ObjectSet(objId,OBJPROP_CORNER,0);
      ObjectSet(objId,OBJPROP_XDISTANCE,x_offset);
      ObjectSet(objId,OBJPROP_YDISTANCE,2*y_depth);
      ObjectSetText(objId,Bar,FontSize-2,FontName,FontColor);
      }
      
   
   
   // Check, store & display Pair symbols
   // ===================================
   int    Timeframe, Len_XTimeframes;
   string TimeframeDesc;
   x_offset = 0;
   XTimeframes = XTimeframes + ","; //ensure trailing comma
   Len_XTimeframes = StringLen(XTimeframes);
   iT=0;
   for(start=0; start<Len_XTimeframes;)
      {
      TimeframeDesc = StringSubstr(XTimeframes,start,StringFind(XTimeframes,",",start)-start); //Extract pair from csv string
      start = start+StringLen(TimeframeDesc)+1;   // point to next char past the current pair and the comma
      
      Timeframe = TimeframeDescToMinutes(TimeframeDesc);    //Get the 'minutes' for this timeframe    
      if( Timeframe != -1 )
         {    // If this is a valid timeframe
         if( (iT != 0)   &&   (Timeframe <= Timeframes[iT-1]) )
            {
            Alert("Timeframes must be in ascending order");
            break;
            }
         else
            {
            ArrayResize(TimeframeDescs,iT+1);       // Make room to add a timeframe description...             
            ArrayResize(Timeframes,iT+1);           // ... and its 'minutes'
            ArrayResize(TimesDue,iT+1);             // ... and its TimeDue
            TimeframeDescs[iT]    =  TimeframeDesc; // Stack timeframe description in array
            Timeframes[iT]        =  Timeframe;     // Stack timeframe minutes in array
            TimesDue[iT]          = 0;              // Initialise to zero (redundant??)
            objId = objPrefix + Timeframe;
            ObjectCreate(objId,OBJ_LABEL,0,0,0,0,0);
		      ObjectSet(objId,OBJPROP_CORNER,0);
		      ObjectSet(objId,OBJPROP_XDISTANCE,x_offset);
		      ObjectSet(objId,OBJPROP_YDISTANCE,(iT+3)*y_depth);
		      ObjectSetText(objId,TimeframeDesc,FontSize,FontName,FontColor);
            iT++;
            }
         }
      }
   countTimeframes = iT; 


   // Create one object for each pair within each timeframe
   // =====================================================
   for(iB=0; iB<countBars; iB++)
      {
      Bar   = BarsDescs[iB];
      
      for(iT=0; iT<countTimeframes; iT++)
         {
         TimeframeDesc = TimeframeDescs[iT];
   	   x_offset = 60 + iB*x_width + 2;
			objId = objPrefix + TimeframeDesc + Bar;
			ObjectCreate(objId,OBJ_LABEL,0,0,0,0,0);
 			ObjectSet(objId,OBJPROP_CORNER,0);
   		ObjectSet(objId,OBJPROP_XDISTANCE,x_offset);
			ObjectSet(objId,OBJPROP_YDISTANCE,(iT+3)*y_depth);
         }
      }
   }

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Finish 
// ======
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void deinit()
   {
   RemoveObjects(objPrefix);
   }

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Main Program 
// ============
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void start()
   {
   // Cycle thru timeframes
   // =====================
   for(iB=0; iB<countBars; iB++)
      {
         // For each timeframe, I want to do the processing ONCE, on the penultimate bar (bar[1]),
         // whenever the latest bar is less than 90% elapsed (the Changeover Time).
         //
         // Then, as the latest bar reaches 90% elapsed, I switch to the latest bar (bar[0]) and 
         // do the processing some more times in the last 10% of the timeframe.
         //
         // That is, I am always working on a bar that is at least 90% formed.
         //
         // Note that stuff can be affected by type casting rules (but it don't matter).

      int   Bar;           // Minutes per period 
      
      Bar        = StrToInteger(BarsDescs[iB]);

      objId = objPrefix + "PanelHead";          // Time stamp the processing  
      ObjectSetText(objId,csName + ": " + TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), FontSize, FontName, FontColor);
      
      // Cycle thru pairs (within each timeframe)
      // ========================================
      for(iT=0; iT<countTimeframes; iT++)
         {
         int Timeframe = Timeframes[iT];
         string TimeframeDesc = TimeframeDescs[iT];
         
         
         
              // Function returns 1,0,-1 depending on Long, neutral, short
         int Result = GetBarFlag(Pair, Bar, Timeframe) ;
               // NB - the code for GetBarFlag() is in the 'includer' program
         
            
         
         string ShowFont   = "WingDings";
         color  ShowColor;
         string ShowCode;
         
         // Examine result and display as appropriate
         if( Result == 0 )
            {
            ShowColor  = DarkGray;
            ShowCode   = CharToStr(161); // WingDing 0
            }         
         
         else if( Result == 1 )
            {
            ShowColor   =  Green;
            ShowCode    = CharToStr(217);
            }
         
         
         else if( Result == -1 )
            {
            ShowColor   = Red;
            ShowCode    = CharToStr(218);
            }
         
         else if( Result == 2 )
            {
            ShowColor   = Blue;
            ShowCode    = CharToStr(116);
            }


            
   		objId = objPrefix + TimeframeDesc + Bar;      // Change WingdingCode object
   		ObjectSetText(objId,ShowCode,FontSize,ShowFont,ShowColor);
   		
         }//next iP
         
      }//next iT
   

   }//Endfunction

