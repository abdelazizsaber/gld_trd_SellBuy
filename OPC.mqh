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
#define MAX_ALLOWED_TRADES 10


//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

struct PositionData
  {
   bool              empty; // To mark if the current index is empty or not
   long              positionID; // Ticket or ID of the position
   double            positionCurProfit;
   double            positionMaxProfit;
   double            takeProfit;
   double            swap;
  };
 
PositionData strCurrentPositions[MAX_ALLOWED_TRADES];
CPositionInfo position;

//+------------------------------------------------------------------+
//| Interfaces                                                       |
//+------------------------------------------------------------------+

//+---------------------------------------------------------------------------------+
//|  Init the Open position controller module                                       |
//+---------------------------------------------------------------------------------+
void OPC_init(void)
  {
      for(int i = 0; i<MAX_ALLOWED_TRADES; i++)
      {  
         strCurrentPositions[i].empty = true;
         strCurrentPositions[i].positionID = 0;
         strCurrentPositions[i].positionCurProfit = 0;
         strCurrentPositions[i].positionMaxProfit = 0;
         strCurrentPositions[i].takeProfit = 0;
         strCurrentPositions[i].swap = 0;
      }     
  }
 

//+---------------------------------------------------------------------------------+
//|  Fill the data of the current open positions                                    |
//+---------------------------------------------------------------------------------+
void OPC_fillPositionsData(void)
  {
       uint curPositionsCount = PositionsTotal();
       
       // loop on the current positions
        for(int i = (int)curPositionsCount-1; i >= 0; i--)
        {
         if(position.SelectByIndex(i) && position.Symbol() == Symbol())
           {
               long posId = PositionGetInteger(POSITION_TICKET);
               if(posIdExist(posId) == false) // Check if we have this ID stored already
               {
               
                  fillNewID(posId); // Fill new ID for the selected position by index
               }
           }
        }
       
        UpdatePosData();      
  }
 
 
//+---------------------------------------------------------------------------------+
//|  Control current open positions                                                 |
//+---------------------------------------------------------------------------------+
void OPC_cntrlOpenPositions(void)
  {
      for(int i = 0; i<MAX_ALLOWED_TRADES; i++)
      {  
         if(strCurrentPositions[i].empty == false)
         {
            double deltaProfit = strCurrentPositions[i].positionMaxProfit - strCurrentPositions[i].positionCurProfit; // Delta of the price between maximum profit and current profit
            double actualCurProfit = strCurrentPositions[i].positionCurProfit - MathAbs(strCurrentPositions[i].swap);
            
            if((actualCurProfit > requiredProfit) && (deltaProfit >= TrailingStopProfit))
            {
               long curTicket = strCurrentPositions[i].positionID;
               
               position.SelectByTicket(curTicket);
               if(handleTrade.PositionClose(curTicket) == true)
               {  
                  Print("Closing trade Successfull");
               }
               else
               {
                  Print("Closing trade failed");
                  uint errorCode = handleTrade.ResultRetcode();
                  Print(errorCode);
               }
                 
                 deletePosByIndex(i);
            }
            else
            {
               // Do nothing, just wait
            }
         }
         else  
         {
         }
      } 
     
      Comment(StringFormat("id = %G\ncurProfit = %G\nmaxProfit = %d",strCurrentPositions[0].positionID,strCurrentPositions[0].positionCurProfit,strCurrentPositions[0].positionMaxProfit));


  }  
 
 
//+------------------------------------------------------------------+
//| Local function                                                   |
//+------------------------------------------------------------------+  
 
//+---------------------------------------------------------------------------------+
//|  Check if the position ID currently exist                                       |
//+---------------------------------------------------------------------------------+
bool posIdExist(long id)
  {
      bool idFound = false;
     
      for(int i = 0; i<MAX_ALLOWED_TRADES; i++)
      {  
         if(strCurrentPositions[i].positionID == id)
         {
            idFound = true;
         }
         else  
         {
         }
      }
      return idFound;
  }
 
//+---------------------------------------------------------------------------------+
//|  Fill new ID for the selected position by index                                 |
//+---------------------------------------------------------------------------------+
void fillNewID(long id)
  {        
      bool emptySlotFound = false;
      int curPositionIndex = 0;
     
      while((emptySlotFound == false) && (curPositionIndex < MAX_ALLOWED_TRADES))
      {
         if(strCurrentPositions[curPositionIndex].empty == true)
         {  
            // Found empty slot
            emptySlotFound = true;
         }
         else
         {
            curPositionIndex++; // Empty slot not found, look for another slot
         }
         
      }
     
      if ((emptySlotFound == true) && (curPositionIndex < MAX_ALLOWED_TRADES))
      {
         double curSwap = PositionGetDouble(POSITION_SWAP);
         
         strCurrentPositions[curPositionIndex].positionID = id;
         strCurrentPositions[curPositionIndex].positionCurProfit = position.Profit();
         strCurrentPositions[curPositionIndex].swap = curSwap;
         strCurrentPositions[curPositionIndex].empty = false;
      }
      else
      {
         // Nothing to do
      }
  }
 
 
//+---------------------------------------------------------------------------------+
//|  Delete position from list                                                      |
//+---------------------------------------------------------------------------------+
void deletePosByIndex(long index)
  {
      strCurrentPositions[index].positionID = 0;
      strCurrentPositions[index].positionCurProfit = 0;
      strCurrentPositions[index].empty = true;
      strCurrentPositions[index].positionMaxProfit = 0;
      strCurrentPositions[index].takeProfit = 0;
      strCurrentPositions[index].swap = 0;         
  }
 
 
//+---------------------------------------------------------------------------------+
//|  Update Positions data (profit and maximum profit)                              |
//+---------------------------------------------------------------------------------+
void UpdatePosData(void)
  {
   
      for(int i = 0; i<MAX_ALLOWED_TRADES; i++)
      {  
         if(strCurrentPositions[i].empty == false)
         { 
            if (position.SelectByTicket(strCurrentPositions[i].positionID) == false)
            {
               Print("Selection of position: ",strCurrentPositions[i].positionID," Failed");
            }
            else
            {
               strCurrentPositions[i].positionCurProfit = position.Profit();
               
               double curSwap = PositionGetDouble(POSITION_SWAP);
               strCurrentPositions[i].swap = curSwap;
              
               if(strCurrentPositions[i].positionCurProfit > strCurrentPositions[i].positionMaxProfit)
               {
                  // New maximum profit recorded
                  strCurrentPositions[i].positionMaxProfit = strCurrentPositions[i].positionCurProfit;
               }
            }
         }
         else  
         {
         }
      }
  }