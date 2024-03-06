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


//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int handleFastMa;
int handleMiddleMa;
int handleSlowMa;


int fastMaPeriod = 3;        // Period of fast smoothing average filter 
int middleMaPeriod = 21;     // Period of Middle smoothing average filter   
int slowMaPeriod = 50;       // Period of slow smoothing average filter
int movingAvgHistroy =5;     // How many ticks the moving average should be aligned 


//+---------------------------------------------------------------------------------+ 
//|  Init the Moving Average indicator module                                       | 
//+---------------------------------------------------------------------------------+ 
void MAI_init(int inputFMaPrd, int inputMMaPrd, int inputSMaPrd, int inputMaHistroy) 
  { 
      fastMaPeriod = inputFMaPrd;
      middleMaPeriod = inputMMaPrd;
      slowMaPeriod = inputSMaPrd;
      movingAvgHistroy = inputMaHistroy;
      
      handleFastMa = iMA(_Symbol,PERIOD_CURRENT,fastMaPeriod,0,MODE_SMMA,PRICE_MEDIAN);
      handleMiddleMa = iMA(_Symbol,PERIOD_CURRENT,middleMaPeriod,0,MODE_SMMA,PRICE_CLOSE);
      handleSlowMa = iMA(_Symbol,PERIOD_CURRENT,slowMaPeriod,0,MODE_SMMA,PRICE_CLOSE);
  }

//+---------------------------------------------------------------------------------+ 
//|  Return the vote from Moving average conditions are met for buy/sell/nothing    | 
//+---------------------------------------------------------------------------------+ 
int MAI_getMovingAverageVote(double curPrice) 
  { 
   int ret = NO_SELL_BUY;
   
   double maFast[];
   double maMiddle[];
   double maSlow[];
   
   double closePriceLastCandle;
   double openPriceLastCandle;

   
   /* Fetch the data from the indicator */
   CopyBuffer(handleFastMa,MAIN_LINE,0,1,maFast);
   CopyBuffer(handleMiddleMa,MAIN_LINE,1,1,maMiddle);
   CopyBuffer(handleSlowMa,MAIN_LINE,1,1,maSlow);


   closePriceLastCandle = iClose(_Symbol,PERIOD_CURRENT,1);
   openPriceLastCandle = iOpen(_Symbol,PERIOD_CURRENT,1);
   
   
   
   if((maFast[0] > maMiddle[0]) && (maMiddle[0] > maSlow[0]) && (closePriceLastCandle > maFast[0]) )
   {
   /* Up trend detected */
   
      if (closePriceLastCandle > openPriceLastCandle) // Candle is bull
      {  
         ret = BUY_OKAY;
      }
      
   }
   else if ((maFast[0] < maMiddle[0]) && (maMiddle[0] < maSlow[0]) && (closePriceLastCandle < maFast[0]))
   {
   /* Up trend detected */
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
//|  Return the vote from Moving average level vs price    | 
//+---------------------------------------------------------------------------------+ 
int MAI_getPriceDiffVote(double curPrice) 
  { 
   int ret = NO_SELL_BUY;
   
   double maFast[];

   
   
   /* Fetch the data from the indicator */
   CopyBuffer(handleFastMa,MAIN_LINE,1,10,maFast);
   
   double ratioOfPriceDiff = MathAbs(((maFast[0] - curPrice) / maFast[0]) * 100);
   
   if (ratioOfPriceDiff < 0.2) 
   {  
      // Moving Average is giving good to go to sell
       ret = SELL_OKAY;
   }
         else
   {  
      // Do nothing
   }
   
   
   return (ret); 
  }  

//+------------------------------------------------------------------+