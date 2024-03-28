//+------------------------------------------------------------------+
//|                            Open position control (OPC) Module |
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
CPositionInfo position;

//+------------------------------------------------------------------+
//| Interfaces                                                       |
//+------------------------------------------------------------------+

//+---------------------------------------------------------------------------------+
//|  Init the Open position controller module                                       |
//+---------------------------------------------------------------------------------+
void OPC_init(void)
  {
    
  }
 

//+---------------------------------------------------------------------------------+
//|  Control current open positions  (Trailing stopLoss)                            |
//+---------------------------------------------------------------------------------+
void OPC_cntrlOpenPositions(void)
  {
      double atr[];
      CopyBuffer(handleAtr,MAIN_LINE,1,1,atr); // fetch the last RSI value (current one)
      
      double bidPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double askPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   
      double updatedSl;
      double slInPoints = 100 * AtrMultiplier * atr[0]; // in points
      
      position.SelectByIndex(0); // Select the current position
      
      double previousSl = PositionGetDouble(POSITION_SL);
      
      // If we are buying of selling
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {    
         updatedSl = askPrice - (slInPoints * Point());        
         if(updatedSl > previousSl)
         {
            // Update SL
            handleTrade.PositionModify(_Symbol,updatedSl,curTp);
         }
      }
      
      else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
      {          
         updatedSl = bidPrice + (slInPoints * Point());    
         if(updatedSl < previousSl)
         {
            // Update SL
            handleTrade.PositionModify(_Symbol,updatedSl,curTp);
         }
      }
      else
      {
      }
           
      //Comment(StringFormat("id = %G\ncurProfit = %G\nmaxProfit = %G\ncurSpread = %G",strCurrentPositions[0].positionID,strCurrentPositions[0].positionCurProfit,strCurrentPositions[0].positionMaxProfit),currentSpreadPoints);


  }  
 
 
//+------------------------------------------------------------------+
//| Local function                                                   |
//+------------------------------------------------------------------+  
 
