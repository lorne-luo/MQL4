//+------------------------------------------------------------------+
//|                                                          RSI.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Relative Strength Index"
#property strict

#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    3
#property indicator_color1     White
#property indicator_color2     Red
#property indicator_color3     Lime
#property indicator_level1     30.0
#property indicator_level2     70.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- input parameters
input int InpRSIPeriod=14; // RSI Period
//--- buffers
double ExtRSIBuffer[];
double ExtPosBuffer[];
double ExtNegBuffer[];
double ExtIncreseBuffer[];
double ExtDecreseBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   string short_name;
//--- 2 additional buffers are used for counting.
   IndicatorBuffers(5);
   SetIndexBuffer(0,ExtRSIBuffer);
   SetIndexBuffer(1,ExtIncreseBuffer);
   SetIndexBuffer(2,ExtDecreseBuffer);
   SetIndexBuffer(3,ExtPosBuffer);
   SetIndexBuffer(4,ExtNegBuffer);
//--- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
//--- name for DataWindow and indicator subwindow label
   short_name="RSI_COLOR("+string(InpRSIPeriod)+") ";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//--- check for input
   if(InpRSIPeriod<2)
     {
      Print("Incorrect value for input variable InpRSIPeriod = ",InpRSIPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpRSIPeriod);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int    i,pos;
   double diff;
//---
   if(Bars<=InpRSIPeriod || InpRSIPeriod<2)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtRSIBuffer,false);
   ArraySetAsSeries(ExtPosBuffer,false);
   ArraySetAsSeries(ExtNegBuffer,false);
   ArraySetAsSeries(ExtIncreseBuffer,false);
   ArraySetAsSeries(ExtDecreseBuffer,false);
   ArraySetAsSeries(close,false);
//--- preliminary calculations
   pos=prev_calculated-1;
   if(pos<=InpRSIPeriod)
     {
      //--- first RSIPeriod values of the indicator are not calculated
      ExtRSIBuffer[0]=0.0;
      ExtPosBuffer[0]=0.0;
      ExtNegBuffer[0]=0.0;
      ExtIncreseBuffer[0]=0.0;
      ExtDecreseBuffer[0]=0.0;
      double sump=0.0;
      double sumn=0.0;
      for(i=1; i<=InpRSIPeriod; i++)
        {
         ExtRSIBuffer[i]=0.0;
         ExtPosBuffer[i]=0.0;
         ExtNegBuffer[i]=0.0;
         ExtIncreseBuffer[i]=0.0;
         ExtDecreseBuffer[i]=0.0;
         diff=close[i]-close[i-1];
         if(diff>0)
            sump+=diff;
         else
            sumn-=diff;
        }
      //--- calculate first visible value
      ExtPosBuffer[InpRSIPeriod]=sump/InpRSIPeriod;
      ExtNegBuffer[InpRSIPeriod]=sumn/InpRSIPeriod;
      if(ExtNegBuffer[InpRSIPeriod]!=0.0)
      {
         ExtRSIBuffer[InpRSIPeriod]=100.0-(100.0/(1.0+ExtPosBuffer[InpRSIPeriod]/ExtNegBuffer[InpRSIPeriod]));
         //ExtIncreseBuffer[InpRSIPeriod]=ExtRSIBuffer[InpRSIPeriod]+10;
         //ExtDecreseBuffer[InpRSIPeriod]=ExtRSIBuffer[InpRSIPeriod]-10;
      }else
      {
         if(ExtPosBuffer[InpRSIPeriod]!=0.0)
            ExtRSIBuffer[InpRSIPeriod]=100.0;
         else
            ExtRSIBuffer[InpRSIPeriod]=50.0;
      }
      //--- prepare the position value for main calculation
      pos=InpRSIPeriod+1;
     }
//--- the main loop of calculations
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      diff=close[i]-close[i-1];
      ExtPosBuffer[i]=(ExtPosBuffer[i-1]*(InpRSIPeriod-1)+(diff>0.0?diff:0.0))/InpRSIPeriod;
      ExtNegBuffer[i]=(ExtNegBuffer[i-1]*(InpRSIPeriod-1)+(diff<0.0?-diff:0.0))/InpRSIPeriod;
      if(ExtNegBuffer[i]!=0.0)
      {
         ExtRSIBuffer[i]=100.0-100.0/(1+ExtPosBuffer[i]/ExtNegBuffer[i]);
         if(i>1)
         {
            if(ExtRSIBuffer[i] > ExtRSIBuffer[i-1])
            {
               ExtIncreseBuffer[i]=ExtRSIBuffer[i];
               ExtIncreseBuffer[i-1]=ExtRSIBuffer[i-1];
            }else if(ExtRSIBuffer[i-1] > ExtRSIBuffer[i]){
               ExtDecreseBuffer[i]=ExtRSIBuffer[i];
               ExtDecreseBuffer[i-1]=ExtRSIBuffer[i-1];
            }
         }
         //ExtIncreseBuffer[i]=ExtRSIBuffer[i]+10;
         //ExtDecreseBuffer[i]=ExtRSIBuffer[i]-10;
      }
      else
        {
         if(ExtPosBuffer[i]!=0.0)
            ExtRSIBuffer[i]=100.0;
         else
            ExtRSIBuffer[i]=50.0;
        }
        
            
     }
     
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
