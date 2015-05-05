//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Averages Convergence/Divergence"
#property strict

#include <MovingAverages.mqh>

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Red
#property  indicator_color2  Silver
#property  indicator_color3  Lime
#property  indicator_color4  DarkOrange
#property  indicator_width1  1
#property  indicator_width2  1
#property  indicator_width3  1
#property  indicator_width4  1
//--- indicator parameters
extern int InpFastEMA=5;       // Fast EMA Period
extern int InpSlowEMA=13;      // Slow EMA Period
extern int InpSignalSMA=5;     // Signal SMA Period
extern bool IsSendMail=false;  // is send email?
//--- indicator buffers
double    ExtDecreaseBuffer[];
double    ExtSignalBuffer[];
double    ExtIncreaseBuffer[];
double    ExtMacdBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;
int LastSendMail=Day()*100+Hour();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexDrawBegin(1,InpSignalSMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtIncreaseBuffer);
   SetIndexBuffer(1,ExtSignalBuffer);
   SetIndexBuffer(2,ExtDecreaseBuffer);
   SetIndexBuffer(3,ExtMacdBuffer);
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD5131("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")");
   SetIndexLabel(0,"MACD+");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"MACD-");
   SetIndexLabel(3,"MACD-Origin");
//--- check for input parameters
   if(InpFastEMA<=1 || InpSlowEMA<=1 || InpSignalSMA<1 || InpFastEMA>=InpSlowEMA)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
  {
   int i,limit;
//---
   if(rates_total<=InpSignalSMA || !ExtParameters)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++)
      ExtMacdBuffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                    iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//--- signal line counted in the 2-nd buffer
   if (InpSignalSMA > 1)
      SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
//--- done

   for(i=0; i<limit-1; i++)
   {
      ExtIncreaseBuffer[i]=NULL;
      ExtDecreaseBuffer[i]=NULL;
      if(ExtMacdBuffer[i]>ExtMacdBuffer[i+1])
      {
         ExtIncreaseBuffer[i]=ExtMacdBuffer[i];//+
      }else{
         ExtDecreaseBuffer[i]=ExtMacdBuffer[i];//-
      }
   }
   
   // send signal mail 
   int int_time=Day()*100+Hour();
   if(IsSendMail && Period()==PERIOD_H4 && int_time - LastSendMail >= 4)
   {
      
      if(Symbol() == "EURUSD" || Symbol() == "USDJPY" || Symbol() == "NZDUSD" || Symbol() == "GBPUSD" || Symbol() == "AUDUSD" || Symbol() == "XAUUSD" || Symbol() == "USDCAD")
      {
         double current_price=(Ask+Bid)/2;
         //Print(ExtDecreaseBuffer[5] + " | " + ExtDecreaseBuffer[4] + " | " + ExtDecreaseBuffer[3] + " | " + ExtDecreaseBuffer[2] + " | " + ExtDecreaseBuffer[1] + " | " + ExtIncreaseBuffer[0]);
         if(ExtMacdBuffer[1] > ExtMacdBuffer[2] && ExtMacdBuffer[2] < ExtMacdBuffer[3])
         {
            string title = Symbol() + " BUY SIGNAL = " + DoubleToStr(current_price,Digits);
            SendMail(title, DoubleToStr(ExtMacdBuffer[2],Digits) + " -> " + DoubleToStr(ExtMacdBuffer[1],Digits));
            LastSendMail = int_time;
            Print(IntegerToString(LastSendMail) + " : " + title);
         }else if(ExtMacdBuffer[1] < ExtMacdBuffer[2] && ExtMacdBuffer[2] > ExtMacdBuffer[3]){
            string title = Symbol() + " SELL SIGNAL = " + DoubleToStr(current_price,Digits);
            SendMail(title, DoubleToStr(ExtMacdBuffer[2],Digits) + " -> " + DoubleToStr(ExtMacdBuffer[1],Digits));
            LastSendMail = int_time;
            Print(IntegerToString(LastSendMail) + " : " + title);
         }
      }
   }

   return(rates_total);
  }
//+------------------------------------------------------------------+