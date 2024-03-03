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

int fastMaPeriod = 21;       // Period of fast smoothing average filter 
int middleMaPeriod = 50;     // Period of Middle smoothing average filter   
int slowMaPeriod = 200;       // Period of slow smoothing average filter
int movingAvgHistroy =5;   // How many ticks the moving average should be aligned 


//+---------------------------------------------------------------------------------+ 
//|  Init the Moving Average indicator module                                       | 
//+---------------------------------------------------------------------------------+ 
void MAI_init(int inputFMaPrd, int inputMMaPrd, int inputSMaPrd, int inputMaHistroy) 
  { 
      fastMaPeriod = inputFMaPrd;
      middleMaPeriod = inputMMaPrd;
      slowMaPeriod = inputSMaPrd;
      movingAvgHistroy = inputMaHistroy;
      
      handleFastMa = iMA(_Symbol,PERIOD_CURRENT,fastMaPeriod,0,MODE_SMMA,PRICE_CLOSE);
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
   
   double slopeValueDiff = 0.0019;
   
   /* Fetch the data from the indicator */
   CopyBuffer(handleFastMa,MAIN_LINE,1,10,maFast);
   CopyBuffer(handleMiddleMa,MAIN_LINE,1,10,maMiddle);
   CopyBuffer(handleSlowMa,MAIN_LINE,1,10,maSlow);
   
   Print(maFast[0]- maFast[movingAvgHistroy]);
   
   if ( ((maFast[0] > maMiddle[0]) && (maMiddle[0] > maSlow[0])) && 
        ((maFast[movingAvgHistroy]- maFast[0]) > slopeValueDiff) && 
        ((maFast[movingAvgHistroy] > maMiddle[movingAvgHistroy]) && (maMiddle[movingAvgHistroy] > maSlow[movingAvgHistroy])) ) // If the Moving averages are lined up for the histroy period
   {
      if (curPrice > maFast[0]) // Second condition: the price has to be above the fastest moving average
      {  
         // Moving Average is giving good to go to buy
         ret = BUY_OKAY;
      }
      else
      {  
         // Do nothing
      }
   }
   
   else if ( ((maFast[0] < maMiddle[0]) && (maMiddle[0] < maSlow[0])) &&
             ((maFast[0]- maFast[movingAvgHistroy]) > slopeValueDiff) &&  
             ((maFast[movingAvgHistroy] < maMiddle[movingAvgHistroy]) && (maMiddle[movingAvgHistroy] < maSlow[movingAvgHistroy]))  ) // If the Moving averages are lined up
   {
      if (curPrice < maFast[0]) // Second condition: the price has to be below the fastest moving average
      {  
         // Moving Average is giving good to go to sell
          ret = SELL_OKAY;
      }
            else
      {  
         // Do nothing
      }
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