//+------------------------------------------------------------------+
//|                                                      H4H1M15.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include <H4H1M15Parameter.mqh>
#include <SystemManager.mqh>
#include <TimeManager.mqh>
#include <OrderManager.mqh>
#include <CashManager.mqh>
#include <IndicatorManager.mqh>
#include <CustomIndicatorManager.mqh>



//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   SystemInit();
//----
   DebugInterval=240;

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   SystemDeinit();
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
   CommentStr="CurrentTime="+TimeToStr(TimeCurrent())+"\n";
   CommentStr=CommentStr+"IsEARuning="+IsEARuning+"\n";
   Sleep(RunStartInterval);
   if(!IsEARuning)
   {
      ShowComment();
      return(0);
   }
   DailyStat();

   
   //检查图表上的时间框架是否和EA推荐的时间框架一致
   if(MainTimeFrame!=Period())
      CommentStr="Warning:Timeframe of chart is not "+MainTimeFrame+" minute!\n";
      
//--------------------------------------------------------------------------   
   //运行时开关变量
   int OpenOrderTimeInterval=8;
   bool canOpenOrder=IsInTradeTime(GmtOffset,TradeBeginHour,TradeEndHour) && TimeDistance(LastOpenOrderTime,PERIOD_H1*OpenOrderTimeInterval*60);

   //不在交易时间内不做
   if(!IsInTradeTime(GmtOffset,TradeBeginHour,TradeEndHour))
      CommentStr=CommentStr+"IsInTradeTime=False\n";
   //距离上次交易不到1.5倍时间框架的时间

//--------------------------------------------------------------------------   
   //处理已有单，跟踪止损、取消过期挂单
   OpenOrderCount=GetExistOrderCount(Magic);
   if(OpenOrderCount>0)
      DealExistOrder(Symbol(),Magic);
   else
   {
      LastLots=0;
      LastOpenPrice=0;
   }
   ClearSignal();
   GetSignal(Signal);
   
   if(!TimeDistance(LastOpenOrderTime,PERIOD_H1*OpenOrderTimeInterval*60))
      CommentStr=CommentStr+"TimeDistance of LastOpenOrderTime is not enough\n";

   //平仓部分
   if(Signal[7]==10)//平空单
   {
      if(OrderCloseNow(Magic,OP_SELL)>0) 
      {
         LastLots=0;
         LastOpenPrice=0;
         LastOpenOrderTime=TimeCurrent();
         OrderTrailingStop=TrailingStop;
      }
   }
   if(Signal[6]==10)//平多单
   {
      if(OrderCloseNow(Magic,OP_BUY)>0)
      {
         LastLots=0;//上次开单手数
         LastOpenPrice=0;//上次开单价位
         LastOpenOrderTime=TimeCurrent();
         OrderTrailingStop=TrailingStop;
      }
   }

   //可能上面有平仓操作，所以判断开仓前再获取一次目前已经开单的数量
   OpenOrderCount=GetExistOrderCount(Magic);
   
   if(Signal[0]>0 && canOpenOrder)//确认信号 做多  && LastSignalDirection==1
   {
      LastLots=Lot*Signal[0]/10;
      LastOpenPrice=Ask;
      int ss=OpenOrderNow(Symbol(),OP_BUY,LastLots,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,BuyColor,0);
      LastOpenOrderTime=TimeCurrent();
      OrderTrailingStop=TrailingStop;
   }

   if(Signal[1]>0 && canOpenOrder)//确认信号 做空  && LastSignalDirection==-1
   {
      LastLots=Lot*Signal[1]/10;
      LastOpenPrice=Bid;
      OpenOrderNow(Symbol(),OP_SELL,LastLots,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,SellColor,0);
      LastOpenOrderTime=TimeCurrent();
      OrderTrailingStop=TrailingStop;
   }
   

//----
   ShowComment();
   return(0);
  }
//+------------------------------------------------------------------+



int GetSignal(int& Signal[])
{
   int i=90;
   datetime firstOrderTime=GetOpenOrderFirstTime(Magic,Symbol());
   //if(firstOrderTime!=0) i=(TimeCurrent()-firstOrderTime)/1440*60+2;
   //else i=31;
   double Histogam[];
   double v=0.0003;
   double v2=0.00015;
   GetMACDHistogam(Histogam,Symbol(),LargerTimeFrame,9,26,i,0);
   int MALagerDirection=MADirection(Symbol(),MainTimeFrame,20,MODE_EMA,0);
   
   ArrayResize(Histogam,31);
   int MACDTrend=GetArrayTrend(Histogam);
   
   int MianFIDirection=GetForceIndexReverse(Symbol(),MainTimeFrame,14,0,1);
   
   double r[][3];
   GetArrInflexion(Histogam,r,1);
   int cnt=ArraySize(r)/3;
   
   if(OpenOrderCount>0 && TimeDistance(firstOrderTime,3601*4))
   {
      double max,min;
      max=Histogam[ArrayMaximum(Histogam,WHOLE_ARRAY,0)];
      min=Histogam[ArrayMinimum(Histogam,WHOLE_ARRAY,0)];
      
      //平空
      if(r[0][1]==2&& r[0][0]==1) Signal[7]=10;
      //if(Histogam[1]<0 && Histogam[2]<0) Signal[7]=10;
      //if(MALagerDirection>0) Signal[7]=10;
      //if(M5Shock(Symbol(),20)==10) Signal[7]=10;
      //平多
      if(r[0][1]==2&& r[0][0]==-1) Signal[6]=10;
      //if(Histogam[1]>0 && Histogam[2]>0) Signal[6]=10;
      //if(MALagerDirection<0) Signal[6]=10;
      //if(M5Shock(Symbol(),20)==-10) Signal[6]=10;
      
   }
   //做空 && OpenOrderCount==0
   if(Histogam[2]>0&& Histogam[1]<0&&MACDTrend<-2)
   {
      MainDirection=-1;
      Signal[1]=10;
   }
   //反弹
   if(r[0][1]==2&& r[0][0]==-1 && r[0][2]<0 && r[1][0]==1 && r[1][2]<-0.0015 && MACDTrend<-2)
   {
      MainDirection=-1;
      Signal[1]=10;
      //if(MACDTrend<-5)Signal[1]=Signal[1]+2;
      //Print(Histogam[1]+" sell at "+Histogam[0]+" "+OpenOrderCount);
   }
   //双顶  && MACDTrend<-2
   if(r[0][1]==2&& r[0][0]==-1 && r[0][2]>0.002 && r[1][0]==1 && r[1][2]>0.0015&& r[2][0]==-1 && r[2][2]>r[0][2] && MACDTrend<-2)
   {
      MainDirection=-1;
      Signal[1]=10;
   }
   
   //做多0.00314899 0.00362016 0.00353483Order=1 buy=0 sell=0 abuy=0 asell=0 sbuy=0 ssell=0 cbuy=0 csell=0 
   if(Histogam[2]<0&& Histogam[1]>0&&MACDTrend>2)
   {
      MainDirection=1;
      Signal[0]=10;
   }
   //回调
   if(r[0][1]==2&& r[0][0]==1 && r[0][2]>0 && r[1][0]==-1 && r[1][2]>0.0015 && MACDTrend>2)
   {
      MainDirection=1;
      Signal[0]=10;
      //if(MACDTrend>5)Signal[0]=Signal[0]+2;
      //Print(Histogam[1]+"buy at"+Histogam[0]+" "+OpenOrderCount);
   }
   //双底 && MACDTrend>2
   if(r[0][1]==2&& r[0][0]==1 && r[0][2]<-0.002 && r[1][0]==-1 && r[1][2]<-0.0015&& r[2][0]==1 && r[2][2]<r[0][2] && MACDTrend>2)
   {
      MainDirection=1;
      Signal[0]=10;
   }
   
   if(IsDebug && IsInTradeTime(GmtOffset,TradeBeginHour,TradeEndHour)
      && TimeDistance(LastPrintDebugTime,DebugInterval*60))// && HourIsBetween(2,4) 
   {
      Print(r[0][0]+"="+r[0][2]+" "+r[1][0]+"="+r[1][2]+" "+r[2][0]+"="+r[2][2]+" "+MACDTrend+
      " Order="+OpenOrderCount+
      " buy="+Signal[0]+" sell="+Signal[1]+" abuy="+Signal[2]+" asell="+Signal[3]+" sbuy="+Signal[4]+
      " ssell="+Signal[5]+" cbuy="+Signal[6]+" csell="+Signal[7]+"\n");
      LastPrintDebugTime=TimeCurrent();
   }
}



/*=======================================================================================*/

//处理现有的单 主要是调整移动止损止盈 以及一些异常波动时候平仓
int DealExistOrder(string symbol,int magic)
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic && OrderSymbol()==symbol)
         {
            if(OrderType()<2)//OP_SELL or OP_BUY
               if(StepTrailingStopOrder(OrderTicket(),OrderTrailingStop,TrailingStopStep))
               {
                  //if(OrderTrailingStop>50) OrderTrailingStop=OrderTrailingStop-5;
               }
            else if (OrderType()>1)//STOP or LIMIT
               if(TimeDistance(OrderOpenTime(),ClearHangOrderTime)) OrderDelete(OrderTicket());
         }
      }
   }
}