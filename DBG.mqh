//+------------------------------------------------------------------+
//|                                               Debug (DBG) Module |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Macros                                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
//--- input parameters of the script 
string            InpName="Label";         // Label name 
int               InpX=150;                // X-axis distance 
int               InpY=150;                // Y-axis distance 
string            InpFont="Arial";         // Font 
int               InpFontSize=10;          // Font size 
color             InpColor=clrRed;         // Color 
double            InpAngle=0.0;            // Slope angle in degrees 
ENUM_ANCHOR_POINT InpAnchor=ANCHOR_CENTER; // Anchor type 
bool              InpBack=false;           // Background object 
bool              InpSelection=true;       // Highlight to move 
bool              InpHidden=true;          // Hidden in the object list 
long              InpZOrder=0;             // Priority for mouse click 

//+------------------------------------------------------------------+
//| Interfaces                                                       |
//+------------------------------------------------------------------+

//+---------------------------------------------------------------------------------+
//|  Init the Open position controller module                                       |
//+---------------------------------------------------------------------------------+
void DBG_init(void)
  {
    //--- prepare initial text for the label 
   string text; 
   StringConcatenate(text,"Upper left corner: ",0,",",0); 
  //--- create a text label on the chart 
   if(!labelCreate(0,InpName,0,InpX,InpY,CORNER_LEFT_UPPER,text,InpFont,InpFontSize, 
      InpColor,InpAngle,InpAnchor,InpBack,InpSelection,InpHidden,InpZOrder)) 
     { 
      return; 
     } 
  }
  
  
//+---------------------------------------------------------------------------------+
//|  DeInit the Open position controller module                                     |
//+---------------------------------------------------------------------------------+
void DBG_deinit(void)
  {
      labelDelete(0,InpName);
  }
 

//+---------------------------------------------------------------------------------+
//|  Update the data of the current open positions                                  |
//+---------------------------------------------------------------------------------+
void DBG_updateTrades(void)
  {
      string strLabelText = "Trade #1 ID: '\n' Trade #2 ID:";
      labelTextChange(0,InpName,strLabelText);

  }
 

//+---------------------------------------------------------------------------------+
//|  Update the data of the current open positions                                  |
//+---------------------------------------------------------------------------------+
bool labelCreate(const long              chart_ID=0,               // chart's ID 
                 const string            name="Label",             // label name 
                 const int               sub_window=0,             // subwindow index 
                 const int               x=0,                      // X coordinate 
                 const int               y=0,                      // Y coordinate 
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                 const string            text="Label",             // text 
                 const string            font="Arial",             // font 
                 const int               font_size=10,             // font size 
                 const color             clr=clrRed,               // color 
                 const double            angle=0.0,                // text slope 
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                 const bool              back=false,               // in the background 
                 const bool              selection=false,          // highlight to move 
                 const bool              hidden=true,              // hidden in the object list 
                 const long              z_order=0)                // priority for mouse click 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- create a text label 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create text label! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- set the slope angle of the text 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
  
//+---------------------------------------------------------------------------------+
//|  Change the label text                                                          |
//+---------------------------------------------------------------------------------+

bool labelTextChange(const long   chart_ID=0,   // chart's ID 
                     const string name="Label", // object name 
                     const string text="Text")  // text 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- change object text 
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text)) 
     { 
      Print(__FUNCTION__, 
            ": failed to change the text! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  }
  
  
  
//+---------------------------------------------------------------------------------+
//|  Delete the label text                                                          |
//+---------------------------------------------------------------------------------+
bool labelDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="Label") // label name 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- delete the label 
   if(!ObjectDelete(chart_ID,name)) 
     { 
      Print(__FUNCTION__, 
            ": failed to delete a text label! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 