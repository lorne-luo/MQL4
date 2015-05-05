//+------------------------------------------------------------------+
//|                                                 MACD Alerter.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Silver
#property  indicator_color2  Red

//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
extern bool EmailON=false;
//---- indicator buffers
double     MacdBuffer[];
double     SignalBuffer[];
string mailStr;
string mailTitleStr;
datetime lastAlertHour;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  lastAlertHour=Time[0]+Period()*60;
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,SignalSMA);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer);
   SetIndexBuffer(1,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+FastEMA+","+SlowEMA+","+SignalSMA+") NextTime="+TimeToStr(lastAlertHour,TIME_MINUTES)+" IsMail="+EmailON);
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++)
      MacdBuffer[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
//---- alert
   if(CurTime() < lastAlertHour)return(0);
   if(MacdBuffer[2]>MacdBuffer[1] && MacdBuffer[3]>MacdBuffer[2])//ÏÂÐÐ
   {
      if(MacdBuffer[1]>0) mailTitleStr="MACDÏÂÐÐ>0";
      else mailTitleStr="MACDÏÂÐÐ<0";
   }
   if(MacdBuffer[2]<MacdBuffer[1] && MacdBuffer[3]<MacdBuffer[2])//ÉÏÐÐ
   {
      if(MacdBuffer[1]>0) mailTitleStr="MACDÉÏÐÐ>0";
      else mailTitleStr="MACDÉÏÐÐ<0";
   }
   if(MacdBuffer[2]>MacdBuffer[1] && MacdBuffer[3]<MacdBuffer[2])//¶¥µã -1
   {
      if(MacdBuffer[1]>0) mailTitleStr="MACD¶¥µã>0";
      else mailTitleStr="MACD¶¥µã<0";
   }
   if(MacdBuffer[2]<MacdBuffer[1] && MacdBuffer[3]>MacdBuffer[2])//µ×µã 1
   {
      if(MacdBuffer[1]>0) mailTitleStr="MACDµ×µã>0";
      else mailTitleStr="MACDµ×µã<0";
   }
   mailStr=""+TimeToStr(CurTime())+" "+Symbol()+" "+Period()+"m\n"+
                  "MACD="+DoubleToStr(MacdBuffer[3],Digits+2)+"->"+DoubleToStr(MacdBuffer[2],Digits+2)+"->"+DoubleToStr(MacdBuffer[1],Digits+2)+"\n"+
                  "Price="+DoubleToStr(Close[2],Digits+1)+"->"+DoubleToStr(Close[1],Digits+1);
   lastAlertHour=Time[0]+Period()*60;
   if(EmailON) SendMail(mailTitleStr,mailStr);
   
//---- done
   
   return(0);
  }
//+------------------------------------------------------------------+