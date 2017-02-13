//+------------------------------------------------------------------+
//|                                                      M5EMA55.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include <MyInclude.mqh>

#define Magic 2345
extern int MaValue=55;
extern int Timeframe=PERIOD_H1;
extern int Slip=4;//滑点偏移点数
extern double Lot=0.1;
extern int TakeProfit = 30;  //默认止盈点数 
extern int StopLoss = 20;  //止损点数
extern int TrailingStop = 5;//跟踪止损点数
extern int       MaxOrder=1;

string comment="H1MA55";
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   int con1=PriceCrossMA(Symbol(),Timeframe,MaValue,MODE_SMA,0);
   int con2=CheckMACDCross(Symbol(),Timeframe,0);
   
   if(con1==10&&con2>0)
      OpenOrderNow(Symbol(),OP_BUY,Lot,Slip,StopLoss,TakeProfit,comment,Magic);
   else if(con1==-10&&con2<0)
      OpenOrderNow(Symbol(),OP_SELL,Lot,Slip,StopLoss,TakeProfit,comment,Magic);
  
//----
   return(0);
  }
//+------------------------------------------------------------------+