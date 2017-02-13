//+------------------------------------------------------------------+
//|                                                      Template.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#define Magic 34643245

#include <TemplateParameter.mqh>
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
   DebugInterval=5;

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
   bool canRunStart=(TimeDistance(LastRunStartTime,RunStartInterval) && IsEARuning);
   if(!canRunStart)
   {
      return(0);
   }
   LastRunStartTime=TimeCurrent();
   
   DailyStat();

   
   //检查图表上的时间框架是否和EA推荐的时间框架一致
   if(MainTimeFrame!=Period())
      CommentStr="Warning:Timeframe of chart is not "+MainTimeFrame+" minute!\n";
      
//--------------------------------------------------------------------------   
   //距离上次交易不到X倍时间框架的时间
   int interal=6;
   bool canOpenOrder=IsInTradeTime() && TimeDistance(LastOpenOrderTime,MainTimeFrame*interal*60);
   if(!TimeDistance(LastOpenOrderTime,MainTimeFrame*interal*60))
      CommentStr=CommentStr+"TimeDistance of LastOpenOrderTime is not enough";
      
   //不在交易时间内不做
   if(!IsInTradeTime())
      CommentStr=CommentStr+"IsInTradeTime=False\n";

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
   
   if(!TimeDistance(LastOpenOrderTime,MainTimeFrame*4*60))
      CommentStr=CommentStr+"TimeDistance of LastOpenOrderTime is not enough";

   //平仓部分
   if(Signal[7]==10)//平空单
   {
      if(OrderCloseNow(Magic,OP_SELL)>0) 
      {
         LastLots=0;
         LastOpenPrice=0;
      }
   }
   if(Signal[6]==10)//平多单
   {
      if(OrderCloseNow(Magic,OP_BUY)>0)
      {
         LastLots=0;//上次开单手数
         LastOpenPrice=0;//上次开单价位
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
   }

   if(Signal[1]>0 && canOpenOrder)//确认信号 做空  && LastSignalDirection==-1
   {
      LastLots=Lot*Signal[1]/10;
      LastOpenPrice=Bid;
      OpenOrderNow(Symbol(),OP_SELL,LastLots,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,SellColor,0);
      LastOpenOrderTime=TimeCurrent();
   }
   

//----
   ShowComment();
   return(0);
  }
//+------------------------------------------------------------------+



int GetSignal(int& Signal[])
{


   //平空
   if(OpenOrderCount>0 && ) Signal[7]=10;
   //平多
   if(OpenOrderCount>0 &&) Signal[6]=10;
      
   //做空
   if(OpenOrderCount==0 && )
   {
      MainDirection=-1;
      Signal[1]=10;
      //Print(Histogam[1]+" sell at "+Histogam[0]+" "+OpenOrderCount);
   }
   //做多
   if(OpenOrderCount==0 && )
   {
      MainDirection=1;
      Signal[0]=10;
      //Print(Histogam[1]+"buy at"+Histogam[0]+" "+OpenOrderCount);
   }
   
   if(IsDebug && IsInTradeTime()
      && TimeDistance(LastPrintDebugTime,DebugInterval*60))// && HourIsBetween(2,4) 
   {
      Print(
      "Order="+OpenOrderCount+
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
               StepTrailingStopOrder(OrderTicket(),TrailingStop,TrailingStopStep);
            else if (OrderType()>1)//STOP or LIMIT
               if(TimeDistance(OrderOpenTime(),ClearHangOrderTime)) OrderDelete(OrderTicket());
         }
      }
   }
}