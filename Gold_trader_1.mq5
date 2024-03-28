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
int handleAtr;
int handleAtrThreshold;
CTrade handleTrade;
datetime lastbar_timeopen;
double previousProfit[10] = {0}; // Assuming that maximum number of positions cannot exceed 10
double curTp = 0;

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "Trading Inputs"
input double               lotSizeBuy = 0.02;           // Lot size to open BUY position
input double               lotSizeSell = 0.02;          // Lot size to open SELL position
input bool                 trailingStopLoss = true;     // Enable trailing stop loss

input group "Moving average Indicator and RSI Inputs and ATR"
input int                  RsiPeriod=10;                 // Period of RSI  
input int                  inFastMaPeriod=3;             // Period of fast smoothing average filter
input int                  inMiddleMaPeriod=21;          // Period of Middle smoothing average filter
input int                  inSlowMaPeriod=50;            // Period of slow smoothing average filter
input int                  AtrPeriod=14;                 // Period of ATR
input double               AtrMultiplier=2;              // Multiplier of ATR for setting SL 
input double               TPinPoints = 100;             // Required TP (in points))
input double               ATRthreshold = 1;             // Don't place trades below this ATR value


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   handleRsi = iRSI(_Symbol,PERIOD_CURRENT,RsiPeriod,PRICE_CLOSE);
   handleAtr = iATR(_Symbol,PERIOD_CURRENT,AtrPeriod);
   handleAtrThreshold = iATR(_Symbol,PERIOD_CURRENT,3);
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

   if((isNewBar(false) == true) && (positions == 0) && (getTimeOk()==true)) // Process the bar only once and when there is no enough existing orders
     {
      checkForTradeChance();
     }

   if((positions != 0) && (trailingStopLoss == true))
   {
      OPC_cntrlOpenPositions(); // Perform Trailing stop loss
   }
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   bool breakpoint;

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
  
   double bidPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   int curMAVote = MAI_getMovingAverageVote();   
   
   double atr[];
   CopyBuffer(handleAtr,MAIN_LINE,1,1,atr); // fetch the last RSI value (current one)
   double slInPoints = 100 * AtrMultiplier * (atr[0]); // in points
   double tpInPoints = TPinPoints;
   
   double pricePerPoint =  Point();
   
   
   // TODO: Add a way to detect stagnation and to avoid trade in it
   double atrThreshold[];
   CopyBuffer(handleAtrThreshold,MAIN_LINE,1,1,atrThreshold); // fetch the last RSI value (current one)
   
   // TODO: Add a way to avoid trading with the price is going downwards
  
   if((curMAVote == BUY_OKAY) && (getRsiVote() == BUY_OKAY) && (atrThreshold[0] >= ATRthreshold))
   {
      Print("Buying. RSI,",getRsiValue());
      curTp = askPrice + (tpInPoints * Point());
      double sl = askPrice - (slInPoints * Point()); 
      handleTrade.Buy(lotSizeBuy,_Symbol,askPrice,sl,curTp);
   }

   if((curMAVote == SELL_OKAY) && (getRsiVote() == SELL_OKAY) && (atrThreshold[0] >= ATRthreshold))
   {
      Print("Selling. RSI,",getRsiValue());
      curTp = bidPrice - (tpInPoints * Point());
      double sl = bidPrice + (slInPoints * Point()); 
      handleTrade.Sell(lotSizeSell,_Symbol,bidPrice,sl,curTp);
   }
    
  }

//+-------------------------------------------------------------------------------------+
//|  Return the Okay from the time, to avoid trading during opening or closing hours    |
//+-------------------------------------------------------------------------------------+
bool getTimeOk()
  {
   bool ret = false;

// get the current time
   MqlDateTime strDateTime;
   TimeToStruct(TimeGMT(),strDateTime);

   if((strDateTime.hour >= 7) && (strDateTime.hour <= 20)) // Trade on EU and USA zones
     {
      ret = true;
     }
     
   return true;
  }

//+-------------------------------------------------------------------------------------+
//|  Return the vote of RSI                                                             |
//+-------------------------------------------------------------------------------------+
int getRsiVote()
  {
   int ret = NO_SELL_BUY;
   
   double rsi[];
   CopyBuffer(handleRsi,MAIN_LINE,1,1,rsi); // fetch the last RSI value (current one)
   
   if(rsi[0] < 50)
   {
      ret = SELL_OKAY;
   }
   else if(rsi[0] > 50)
   {
      ret = BUY_OKAY;
   }
   else
   {
   }
   
   return ret;
  }
  
  //+-------------------------------------------------------------------------------------+
//|  Return the vote of RSI                                                             |
//+-------------------------------------------------------------------------------------+
double getRsiValue()
  {
   
   double rsi[];
   CopyBuffer(handleRsi,MAIN_LINE,1,1,rsi); // fetch the last RSI value (current one)   
   return rsi[0];
  }
  
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
