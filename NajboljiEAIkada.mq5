

#include <Trade\Trade.mqh>;
CTrade trade;

input ENUM_TIMEFRAMES lowerTF = PERIOD_M1;
input ENUM_TIMEFRAMES higherTF = PERIOD_H1;
input int periodRSI = 14;
input double ATREntryMultiplier = 1.5;
input double ATRMultiplier = 2;
input double RRMultiplier = 2;

input bool allowBuy = true;
input bool allowSell = true;


bool CheckForNewCandle(int CandleNum)
{
   static int LastCandleNum;
   
   if(CandleNum > LastCandleNum)
   {
      LastCandleNum = CandleNum;
      return true;
   }
   return false;
}



void OnTick()
{

      int CandleNum = Bars(Symbol(), lowerTF);
      bool newCandle = CheckForNewCandle(CandleNum);
      
      if(newCandle)
      {
         // RSI, ATR, EMA
         
         double myRSIArray[];
         double myATRArray[];
         double myEMAArray[];
         
         int rsiHandle = iRSI(Symbol(), lowerTF, periodRSI, PRICE_CLOSE);
         int atrHandle = iATR(Symbol(), lowerTF, 14);
         int emaHandle = iMA(Symbol(), higherTF, 50, 0, MODE_EMA, PRICE_CLOSE);
         
         ArraySetAsSeries(myATRArray, true);
         ArraySetAsSeries(myRSIArray, true);
         ArraySetAsSeries(myEMAArray, true);
         
         CopyBuffer(rsiHandle, 0, 0, 3, myRSIArray);
         CopyBuffer(atrHandle, 0, 0, 3, myATRArray);
         CopyBuffer(emaHandle, 0, 0, 3, myEMAArray);
         
         double RSI1 = NormalizeDouble(myRSIArray[1],2);
         double ATR1 = NormalizeDouble(myATRArray[1],_Digits);
         double EMA  = NormalizeDouble(myEMAArray[1],_Digits);
         
         if(RSI1 < 30 && allowBuy)
         {
            // rsi is below 30
            
            // bullish engufing
            
            double open2 = iOpen(Symbol(), lowerTF, 2);
            double close2 = iClose(Symbol(), lowerTF, 2);
            double high2 = iHigh(Symbol(), lowerTF, 2);
            
            double close1 = iClose(Symbol(), lowerTF, 1);
            
            if(close2 < open2 && close1 > high2)
            {
               // bullish engulfing pattern
               
               // range prosle svece
               double range = iHigh(Symbol(), lowerTF, 1) - iLow(Symbol(), lowerTF, 1);
               if(range > ATREntryMultiplier * ATR1)
               {
               
                  // valid buy trade
                  //if(iClose(Symbol(), higherTF, 1) > EMA)
                  //{
                  double entryPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
                  double stoploss = entryPrice - ATR1 * ATRMultiplier;
                  double takeprofit = entryPrice + ATR1 * ATRMultiplier * RRMultiplier;
                  
                  
                  // position size
                  double sldistance = entryPrice - stoploss;
                  double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
                  double tickCount = sldistance/tickSize;
                  double tickValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
                  double valueToRisk = AccountInfoDouble(ACCOUNT_BALANCE) * 0.02;
                  
                  double positionSize = (tickCount * tickValue) != 0 ? valueToRisk/(tickCount * tickValue) : 0;
                  positionSize = NormalizeDouble(positionSize, 2);
                  
                  if(!trade.Buy(positionSize, Symbol(), entryPrice, stoploss, takeprofit, NULL))
                  {
                     Print("Doslo je do greske");
                  }
                  //}
               }
            }
         }
         if(RSI1 > 70 && allowSell)
         {
            // rsi is above 70
            
            // bearish engufing
            
            double open2 = iOpen(Symbol(), lowerTF, 2);
            double close2 = iClose(Symbol(), lowerTF, 2);
            double low2 = iLow(Symbol(), lowerTF, 2);
            
            double close1 = iClose(Symbol(), lowerTF, 1);
            
            if(close2 > open2 && close1 < low2)
            {
               // bullish engulfing pattern
               
               // range prosle svece
               double range = iHigh(Symbol(), lowerTF, 1) - iLow(Symbol(), lowerTF, 1);
               if(range > ATREntryMultiplier * ATR1)
               {
               
                  // valid sell trade
                  if(iClose(Symbol(), higherTF, 1) < EMA)
                  {
                  double entryPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
                  double stoploss = entryPrice + ATR1 * ATRMultiplier;
                  double takeprofit = entryPrice - ATR1 * ATRMultiplier * RRMultiplier;
                  
                  
                  // position size
                  double sldistance = stoploss - entryPrice;
                  double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
                  double tickCount = sldistance/tickSize;
                  double tickValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
                  double valueToRisk = AccountInfoDouble(ACCOUNT_BALANCE) * 0.02;
                  
                  double positionSize = (tickCount * tickValue) != 0 ? valueToRisk/(tickCount * tickValue) : 0;
                  positionSize = NormalizeDouble(positionSize, 2);
                  
                  if(!trade.Sell(positionSize, Symbol(), entryPrice, stoploss, takeprofit, NULL))
                  {
                     Print("Doslo je do greske");
                  }
                  }
               }
            }
         }
         
      }
}