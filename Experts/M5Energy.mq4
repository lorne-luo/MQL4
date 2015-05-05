//+------------------------------------------------------------------+
//|                                                     M5Energy.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#define Magic 23521
#define Magic2 23521


/*===================================TimeManager===============================================*/
extern string ______="==================时间参数==================";
extern int MainTimeFrame=PERIOD_M5;
extern int GmtOffset=12;
extern int TradeBeginHour=14;
extern int TradeEndHour=24;
datetime LastOpenOrderTime;//上一次开单时间，基本所有EA都需要
datetime ClearHangOrderTime=300;//挂单指定时间未触发则取消

int OpenOrderPriceShift=5;//挂单的SHIFT点数
extern int StopLoss = 30;  //止损点数
extern double TakeProfit = 0;
extern double Lot=0.1;//正常开单手数
extern int Slip=3;//滑点偏移点数
extern int TrailingStop = 20;//跟踪止损点数

int MainDirection=0;//指示主方向 1多 -1空 1时不做空 -1不做多
int OpenOrderCount=0;//当前已开单数
bool IsEnableTrade=true;


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
   DebugInterval=300;

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
   //检查图表上的时间框架是否和EA推荐的时间框架一致
   if(MainTimeFrame!=Period())
      CommentStr="Warning:Timeframe of chart is not "+MainTimeFrame+" minute!\n";
   CommentStr="CurrentTime="+TimeToStr(TimeCurrent())+"\n";
   CommentStr=CommentStr+"IsEARuning="+IsEARuning+"\n";
   if(!IsEARuning)
   {
      ShowComment();
      return(0);
   }
   DailyStat();
    
//--------------------------------------------------------------------------   
    
   //不在交易时间内不做
   if(!IsInTradeTime(GmtOffset,TradeBeginHour,TradeEndHour))
      CommentStr=CommentStr+"IsInTradeTime=False\n";

   //距离上次交易不到X倍时间框架的时间
   int interal=6;
   bool canOpenOrder=IsInTradeTime(GmtOffset,TradeBeginHour,TradeEndHour) && TimeDistance(LastOpenOrderTime,MainTimeFrame*interal*60);
   if(!TimeDistance(LastOpenOrderTime,MainTimeFrame*interal*60))
      CommentStr=CommentStr+"TimeDistance of LastOpenOrderTime is not enough";
      
//--------------------------------------------------------------------------   
   //处理已有单，跟踪止损、取消过期挂单
   OpenOrderCount=GetExistOrderCount(Magic);
   if(OpenOrderCount>0)
      DealExistOrder(Symbol(),Magic);
   else
   {
   }
   ClearSignal();
   GetSignal(Signal);
   


   //平仓部分
   if(Signal[7]==10)//平空单
   {
      if(OrderCloseNow(Magic,OP_SELL)>0) 
      {
      }
   }
   if(Signal[6]==10)//平多单
   {
      if(OrderCloseNow(Magic,OP_BUY)>0)
      {
      }
   }

   //可能上面有平仓操作，所以判断开仓前再获取一次目前已经开单的数量
   OpenOrderCount=GetExistOrderCount(Magic);
   double lot;
   if(Signal[0]>0 && canOpenOrder)//确认信号 做多  && LastSignalDirection==1
   {
      lot=Lot*0.5;
      int ss=OpenOrderNow(Symbol(),OP_BUYSTOP,lot,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,BuyColor,OpenOrderPriceShift);
      OpenOrderNow(Symbol(),OP_BUYSTOP,lot,Slip,StopLoss,StopLoss,OrderCommentStr+"2",Magic2,BuyColor,OpenOrderPriceShift);
      LastOpenOrderTime=TimeCurrent();
   }

   if(Signal[1]>0 && canOpenOrder)//确认信号 做空  && LastSignalDirection==-1
   {
      lot=Lot*0.5;
      Print(lot);
      OpenOrderNow(Symbol(),OP_SELLSTOP,lot,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,SellColor,OpenOrderPriceShift);
      OpenOrderNow(Symbol(),OP_SELLSTOP,lot,Slip,StopLoss,StopLoss,OrderCommentStr+"2",Magic2,SellColor,OpenOrderPriceShift);
      LastOpenOrderTime=TimeCurrent();
   }
   

//----
   ShowComment();
   return(0);
  }
//+------------------------------------------------------------------+


double CloseOrderPriceGap=18;
int GetSignal(int& Signal[])
{
   double Histogam[];
   int cnt=7;
   GetMACDHistogam(Histogam,Symbol(),MainTimeFrame,12,26,cnt,0);
   int MACDCrossZero=GetArrCorssValue(Histogam,1,0);//是否穿0线
   
   double price[][6];
   double PriceArr[],EMAArr[];
   ArrayResize(price,cnt);
   ArrayResize(PriceArr,cnt);
   ArrayResize(EMAArr,cnt);
   ArrayCopyRates(price,Symbol(),MainTimeFrame);
   for(int i=0;i<cnt;i++)
   {
      PriceArr[i]=price[i][4];
      EMAArr[i]=iMA(Symbol(),MainTimeFrame,20,0,MODE_EMA,PRICE_CLOSE,i);
   }
   int PriceCrossEMA20=GetArrCorssArr(PriceArr,EMAArr,1);

   int PriceSubEMA=Price2Point(Close[0]-iMA(Symbol(),MainTimeFrame,20,0,MODE_EMA,PRICE_CLOSE,1));
   
   //平空
   if(OpenOrderCount>0 && PriceSubEMA>=CloseOrderPriceGap) Signal[7]=10;
   //平多
   if(OpenOrderCount>0 && PriceSubEMA+CloseOrderPriceGap<=0) Signal[6]=10;
      
   //做空
   if(OpenOrderCount==0 && Histogam[1]<0 && Histogam[2]>0 && PriceCrossEMA20==-10)
   {
      MainDirection=-1;
      Signal[1]=10;
      //Print(Histogam[1]+" sell at "+Histogam[0]+" "+OpenOrderCount);
   }
   //做多
   if(OpenOrderCount==0 && Histogam[1]>0 && Histogam[2]<0 && PriceCrossEMA20==10)
   {
      MainDirection=1;
      Signal[0]=10;
      //Print(Histogam[1]+"buy at"+Histogam[0]+" "+OpenOrderCount);
   }
   
   if(IsDebug && IsInTradeTime(GmtOffset,TradeBeginHour,TradeEndHour)
      && TimeDistance(LastPrintDebugTime,DebugInterval))// && HourIsBetween(2,4) 
   {
      Print("MACDCrossZero="+MACDCrossZero+" PriceCrossEMA20="+PriceCrossEMA20+" PriceSubEMA="+PriceSubEMA+
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
               CustomStepTrailingStopOrder(OrderTicket(),StopLoss,50,70,90);
            else if (OrderType()>1)//STOP or LIMIT
               if(TimeDistance(OrderOpenTime(),ClearHangOrderTime)) OrderDelete(OrderTicket());
         }
      }
   }
}