//+------------------------------------------------------------------+
//|                          Price boundries indicator (PCBI) Module |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Macros                                                           |
//+------------------------------------------------------------------+
#define PRICE_BOUNDRIES_HOURS  96

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int pBHistroy =(PRICE_BOUNDRIES_HOURS * 60);   // How many ticks the moving average should be aligned 


//+---------------------------------------------------------------------------------+ 
//|  Init the Price boundry indicator module                                        | 
//+---------------------------------------------------------------------------------+ 
void PBI_init(void) 
  {  
      
  }

//+---------------------------------------------------------------------------------+ 
//|  Return the vote from Moving average conditions are met for buy/sell/nothing    | 
//+---------------------------------------------------------------------------------+ 
int PBI_getPriceBoundryVote(double curPrice) 
  { 
   int ret = NO_SELL_BUY;
   
   double highestPrice = 0;
   double lowestPrice = 0;
   
   int highestPriceIndex = iHighest(_Symbol,PERIOD_CURRENT,MODE_HIGH,pBHistroy,1);
   int lowestPriceIndex = iLowest(_Symbol,PERIOD_CURRENT,MODE_LOW,pBHistroy,1);
   
   if(highestPriceIndex!=-1)
   { 
      highestPrice=iHigh(_Symbol,PERIOD_CURRENT,highestPriceIndex);
      ObjectDelete(0,"top price line");
      ObjectCreate(0,"top price line",OBJ_HLINE,0,0,highestPrice);
   }
   
   if(lowestPriceIndex!=-1)
   { 
      lowestPrice=iLow(_Symbol,PERIOD_CURRENT,lowestPriceIndex);
      ObjectDelete(0,"bottom price line");
      ObjectCreate(0,"bottom price line",OBJ_HLINE,0,0,lowestPrice);
   }
   
   if ((curPrice < (highestPrice - 10)) && (curPrice > (lowestPrice + 10)))
   {
      ret = SELL_BUY_OKAY;
   }
   else if (curPrice >= highestPrice)
   {
      ret = SELL_OKAY;
   }
   else if(curPrice <= lowestPrice)
   {  
      ret = BUY_OKAY;
   }
   else
   {  
      ret = NO_SELL_BUY;
   }
   
   return (ret); 
  } 
  
 

//+------------------------------------------------------------------+