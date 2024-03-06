//+------------------------------------------------------------------+
//|                                                Gold_Trader_1.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include "MAI.mqh"
#include "OPC.mqh"
#include "DBG.mqh"


//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int handleRsi;
CTrade handleTrade;
datetime lastbar_timeopen;
double previousProfit[10] = {0}; // Assuming that maximum number of positions cannot exceed 10

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "Trading Inputs"
input double               lotSizeBuy = 0.02;           // Lot size to open BUY position
input double               lotSizeSell = 0.01;          // Lot size to open SELL position
input int                  maxNuOfPositions = 5;        // Maximum number of positions can exist together
input double               requiredProfit = 3;         // The minimum profit required from the position
input bool                 trailingStopLoss = true;     // Enable trailing stop loss
input double               TrailingStopProfit = 0.5;    // How much the price should drop to close the position above the profit

input group "Moving average Indicator and RSI Inputs"
input int                  RsiPeriod=10;                 // Period of RSI  
input int                  inFastMaPeriod=3;             // Period of fast smoothing average filter
input int                  inMiddleMaPeriod=21;          // Period of Middle smoothing average filter
input int                  inSlowMaPeriod=50;            // Period of slow smoothing average filter


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   handleRsi = iRSI(_Symbol,PERIOD_CURRENT,RsiPeriod,PRICE_CLOSE);
   MAI_init();
   OPC_init();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   int nuOfBars = iBars(_Symbol,PERIOD_CURRENT);

   int positions = PositionsTotal();

   if((isNewBar(false) == true) && (positions < maxNuOfPositions) && (getTimeOk()==true)) // Process the bar only once and when there is no enough existing orders
     {
      checkForTradeChance();
     }

   OPC_fillPositionsData();
   OPC_cntrlOpenPositions();
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }


//+------------------------------------------------------------------+
//|  Return 'true' when a new bar appears                            |
//+------------------------------------------------------------------+
bool isNewBar(const bool print_log=true)
  {
   static datetime bartime=0; // store open time of the current bar
//--- get open time of the zero bar
   datetime currbar_time=iTime(_Symbol,_Period,0);
//--- if open time changes, a new bar has arrived
   if(bartime!=currbar_time)
     {
      bartime=currbar_time;
      lastbar_timeopen=bartime;
      //--- display data on open time of a new bar in the log
      if(print_log && !(MQLInfoInteger(MQL_OPTIMIZATION)||MQLInfoInteger(MQL_TESTER)))
        {
         //--- display a message with a new bar open time
         PrintFormat("%s: new bar on %s %s opened at %s",__FUNCTION__,_Symbol,
                     StringSubstr(EnumToString(_Period),7),
                     TimeToString(TimeCurrent(),TIME_SECONDS));
         //--- get data on the last tick
         MqlTick last_tick;
         if(!SymbolInfoTick(Symbol(),last_tick))
            Print("SymbolInfoTick() failed, error = ",GetLastError());
         //--- display the last tick time up to milliseconds
         PrintFormat("Last tick was at %s.%03d",
                     TimeToString(last_tick.time,TIME_SECONDS),last_tick.time_msc%1000);
        }
      //--- we have a new bar
      return (true);
     }
//--- no new bar
   return (false);
  }


//+------------------------------------------------------------------+
//|  check if we can perform a trade if good conditions are met      |
//+------------------------------------------------------------------+
void checkForTradeChance()
  {

   uint PositionsCount = 0;
   long PositionId = 0;

   double bidPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   if (getRsiRangeOk() == true)
   {
      if(MAI_getMovingAverageVote(askPrice) == BUY_OKAY)
      {
         Print("Buying ...");
         handleTrade.Buy(lotSizeBuy,_Symbol,askPrice,0,0);
         PositionsCount = PositionsTotal();
         position.SelectByIndex(PositionsCount-1);
         PositionId = position.Identifier(); // now we know the ticket of the opened position
      }

      
      if(MAI_getMovingAverageVote(bidPrice) == SELL_OKAY)
      {
         Print("Selling ...");
         handleTrade.Sell(lotSizeSell,_Symbol,bidPrice,0,0);
         PositionsCount = PositionsTotal();
         position.SelectByIndex(PositionsCount-1);
         PositionId = position.Identifier(); // now we know the ticket of the opened position
      }

   }
        
  }

//+-------------------------------------------------------------------------------------+
//|  Return the Okay from the time, to avoid trading during opening or closing hours    |
//+-------------------------------------------------------------------------------------+
bool getTimeOk()
  {
   bool ret = true;



// get the current time
   MqlDateTime strDateTime;
   TimeToStruct(TimeGMT(),strDateTime);

   if(strDateTime.hour == 22) // Start of Sydeny session
     {
      ret = false;
     }

   if(strDateTime.hour == 7) // End of Sydeny session
     {
      ret = false;
     }

   if(strDateTime.hour == 0) // Start of Tokoyo session
     {
      ret = false;
     }

   if(strDateTime.hour == 9) // End of Tokoyo session
     {
      ret = false;
     }

   if(strDateTime.hour == 8) // Start of London session
     {
      ret = false;
     }

   if(strDateTime.hour == 17) // End of London session
     {
      ret = false;
     }

   if(strDateTime.hour == 13) // Start of New york session
     {
      ret = false;
     }

   if(strDateTime.hour == 21) // End of New York session
     {
      ret = false;
     }





   return (true);
  }

//+-------------------------------------------------------------------------------------+
//|  Return the Okay from RSI range prespective                                         |
//+-------------------------------------------------------------------------------------+
bool getRsiRangeOk()
  {
   bool ret = false;
   
   double rsi[];
   CopyBuffer(handleRsi,MAIN_LINE,1,1,rsi); // fetch the last RSI value (current one)
   
   if((rsi[0] < 80) && (rsi[0] > 20))
   {
      ret = true;
   }
   else
   {
      ret = false;
   }
   
   return ret;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
