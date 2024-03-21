//+------------------------------------------------------------------+
//|                            Moving Average indicator (MAI) Module |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Macros                                                           |
//+------------------------------------------------------------------+
#define SELL_BUY_OKAY      3
#define SELL_OKAY          2
#define BUY_OKAY           1
#define NO_SELL_BUY        0

#define UP_TREND           4
#define DOWN_TREND         5
#define NO_TREND           6

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int handleFastMa;
int handleMiddleMa;
int handleSlowMa;

//+---------------------------------------------------------------------------------+ 
//|  Init the Moving Average indicator module                                       | 
//+---------------------------------------------------------------------------------+ 
void MAI_init() 
  { 
      handleFastMa = iMA(_Symbol,PERIOD_CURRENT,inFastMaPeriod,0,MODE_SMMA,PRICE_MEDIAN);
      handleMiddleMa = iMA(_Symbol,PERIOD_CURRENT,inMiddleMaPeriod,0,MODE_SMMA,PRICE_CLOSE);
      handleSlowMa = iMA(_Symbol,PERIOD_CURRENT,inSlowMaPeriod,0,MODE_SMMA,PRICE_CLOSE);
  }

//+---------------------------------------------------------------------------------+ 
//|  Return the vote from Moving average conditions are met for buy/sell/nothing    | 
//+---------------------------------------------------------------------------------+ 
int MAI_getMovingAverageVote() 
  { 
   int ret = NO_SELL_BUY;
   
   double maFast[];

   
   double closePriceLastCandle;
   double openPriceLastCandle;

   
   /* Fetch the data from the indicator */
   CopyBuffer(handleFastMa,MAIN_LINE,0,1,maFast);

   closePriceLastCandle = iClose(_Symbol,PERIOD_CURRENT,1);
   openPriceLastCandle = iOpen(_Symbol,PERIOD_CURRENT,1);
   
   int curTrend = getTrend();
   
   if((curTrend == UP_TREND) && (closePriceLastCandle > maFast[0]) )
   {
   /* Up trend detected */
      Print("Up trend detected");
      if (closePriceLastCandle > openPriceLastCandle) // Candle is bull
      {  
         ret = BUY_OKAY;
      }
      
   }
   else if ((curTrend == DOWN_TREND) && (closePriceLastCandle < maFast[0]))
   {
      /* Down trend detected */
      Print("Down trend detected");
      if (closePriceLastCandle < openPriceLastCandle) // Candle is bear
         { 
            ret = SELL_OKAY;
         }
   }
   else
   {
   }


   return (ret); 
  } 
  
//+---------------------------------------------------------------------------------+ 
//|  Return the vote from Moving average conditions are met for buy/sell/nothing    | 
//+---------------------------------------------------------------------------------+ 
double MAI_getMovingAverageSL() 
  { 
   double ret = 0;
   
   double maMiddle[];
   double maSlow[];
   
   
   /* Fetch the data from the indicator */
   CopyBuffer(handleMiddleMa,MAIN_LINE,1,1,maMiddle);
   CopyBuffer(handleSlowMa,MAIN_LINE,1,1,maSlow);


   ret = maMiddle[0];
   

   return (ret); 
  }    

//+---------------------------------------------------------------------------------+ 
//|  Return the current trend                                                       | 
//+---------------------------------------------------------------------------------+
int getTrend()
  {
   int ret = NO_TREND;
   double maFast[];
   double maMiddle[];
   double maSlow[];

   /* Fetch the data from the indicator */
   CopyBuffer(handleFastMa,MAIN_LINE,0,3,maFast);
   CopyBuffer(handleMiddleMa,MAIN_LINE,1,1,maMiddle);
   CopyBuffer(handleSlowMa,MAIN_LINE,1,1,maSlow);
   
   if ((maFast[2] > maFast[1]) && (maFast[1] > maFast[0])) // Make sure fast MA is moving upwards within 3 candles
   {  
      if((maFast[2] > maMiddle[0]) && (maMiddle[0] > maSlow[0]))
      {
         ret = UP_TREND;
      }
   }
   else if ((maFast[2] < maFast[1]) && (maFast[1] < maFast[0])) // Make sure fast MA is moving downwards within 3 candles
   {  
      if((maFast[2] < maMiddle[0]) && (maMiddle[0] < maSlow[0]))
      {
         ret = DOWN_TREND;
      }
   }
   else
   {
   }
   
   
   return ret;

   
  }
//+------------------------------------------------------------------+