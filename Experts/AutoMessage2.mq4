//+------------------------------------------------------------------+
//|                                                  AutoMessage.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#import "AutoOrder.dll"
string httpGET(string a0, int& a1[]);

#property show_inputs
#define Magic 20110419
extern int StopLoss = 15;  //止损点数
extern double TakeProfit = 50;
extern double Lot=0.1;//正常开单手数
extern int Slip=10;//滑点偏移点数
extern int TrailingStop = 20;//跟踪止损点数
extern int TrailingStopStep = 20;//紧逼跟踪止损方式时起作用，最高盈利每增加20移动一次止损
extern int PriceDistance = 15;
extern int ProtectProfit=20;//盈利设置平损
extern int TimeDistance=60;//秒
extern int CloseOrderMin = 60;//分
extern int CancelOrderMin = 6;//分


#include <SystemManager.mqh>
#include <OrderManager.mqh>
#include <TimeManager.mqh>
#include <String.mqh>

extern string __ = "=========Time Configuration==========";
extern int GmtOffset=8;

int OpenOrderCount=0;//当前已开单数
int HangOrderCount=0;//当前挂单数
int DayNum=0;
datetime OpenOrderTime=0;
bool IsOpenOrder=false;
int TimeList[5][2];
string SymbolList[5];

string MessageList[];
datetime CurrentTime;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   SystemInit();
//----
   SymbolList[0]="EURUSD";
   SymbolList[1]="GBPUSD";
   SymbolList[2]="USDCHF";
   SymbolList[3]="AUDUSD";
   SymbolList[4]="USDJPY";
   OrderCommentStr="AutoMessage2";
   GetCalendar();
   //Print("GetFirstWorkDay()="+GetFirstWorkDay());
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
   if(!IsEARuning)
   {
      ShowComment();
      return(0);
   }
   DailyStat();
   
   datetime CurrentTime=TimeCurrent()+GmtOffset*3600;
   if(DayNum!=Day()&&TimeHour(CurrentTime)>7) 
      GetCalendar();
   
   OpenOrderCount=GetExistOrderCount(Magic);
   if(OpenOrderCount==0)
   {
      OpenOrderTime=0;
      IsOpenOrder=false;
   }
   
   string item[];
   for (int i = 0; i < ArraySize(MessageList) ; i++)
   {
      split("|" ,MessageList[i], item);
      CommentStr=CommentStr+item[0]+"|"+item[1]+"|"+item[2]+"\n";
      int j;
      //opened
      if(item[0]=="+") continue;
      
      if(CurrentTime - StrToTime(item[1])>CancelOrderMin*60)
      {
         MessageList[i]="+";
         for (j = 1; j < ArraySize(item) ; j++)
            MessageList[i]=MessageList[i]+"|"+item[j];
         continue;
      }
      //opening
      if(StrToTime(item[1]) - CurrentTime>0&&StrToTime(item[1]) - CurrentTime<TimeDistance&&!IsOpenOrder)
      {
         OpenOrder(item[2]);
         IsOpenOrder=true;
         //opened flag
         MessageList[i]="+";
         for (j = 1; j < ArraySize(item) ; j++)
            MessageList[i]=MessageList[i]+"|"+item[j];
      }
   }
   //5分钟后还没有触发下单则取消订单
   if(!IsinPendingTime())
      DeleteAllHang();
   if(!IsinOpeningTime())
   {
      DeleteAllHang();
      CloseAll();
   }
   Comment(CommentStr);
   Sleep(3000);
//----
   return(0);
  }
//+------------------------------------------------------------------+

//获取信号开多 开空 加多 加空 减多 减空 平多 平空
//         0      1   2    3    4    5    6    7
int GetSignal(int& signal[])
{
   if(IsOpenOrder && TimeDistance(OpenOrderTime,CloseOrderMin*60))
   {
   Print("======signal[6]=10="+TimeToStr(OpenOrderTime));
      signal[6]=10;
   }
   if(IsOpenOrder) return(signal);
   
   datetime currenttime=TimeCurrent()-GmtOffset*3600;
   datetime starttime;
   
   //ISM 每月1号 22：00
   int firstWorkDay=GetFirstWorkDay();
   if(Day()==firstWorkDay)
   {
      starttime=StrToTime(Year()+"."+Month()+"."+Day()+" "+"22:00:00");
      starttime=starttime-GmtOffset*3600-TimeDistance;
      if (TimeCurrent()>starttime && TimeCurrent()-starttime<TimeDistance && !IsOpenOrder)
      {
         signal[0]=1;
      }
   }
   
   //非农 每月第一个周五 20:30
   if(DayOfWeek()==5 && Day()>=2 && Day()<=8)
   {
      starttime=StrToTime(Year()+"."+Month()+"."+Day()+" "+"20:30:00");
      starttime=starttime-GmtOffset*3600-TimeDistance;
      if (TimeCurrent()>starttime && TimeCurrent()-starttime<TimeDistance && !IsOpenOrder)
      {
         signal[0]=1;
      }
   }
}


/*=======================================================================================*/

//+------------------------------------------------------------------+
void GetCalendar()
{
   int para[2];
   string data=httpGET("http://leandro.132.china123.net/forex/automessage.php", para);
   Print("GetTodayCalendar Count="+split("\n" ,data, MessageList));
   DayNum=Day();
}

//处理现有的单 主要是调整移动止损止盈 以及一些异常波动时候平仓
int DealExistOrder(int magic)
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic)
         {
            if(OrderType()<2)//OP_SELL or OP_BUY
            {
               //StepTrailingStopOrder(OrderTicket(),TrailingStop,TrailingStopStep);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
void OpenOrder(string symbol)
{  
   double DistancePoint=PriceDistance*10*Point;
   double StopLossPoint=StopLoss*10*Point;
   double TakeProfitPoint=TakeProfit*10*Point;
   
   OrderSend(symbol, OP_BUYSTOP, Lot, Ask+DistancePoint,Slip,Ask+DistancePoint-StopLossPoint,Ask+DistancePoint+TakeProfitPoint,OrderCommentStr,Magic,0,Green);
   Sleep(1000);
   OrderSend(symbol, OP_SELLSTOP, Lot, Bid-DistancePoint,Slip,Bid-DistancePoint+StopLossPoint,Bid-DistancePoint-TakeProfitPoint,OrderCommentStr,Magic,0,Green);
}

//+------------------------------------------------------------------+
void DeleteAll()
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()!=Magic) continue;
         OrderDelete(OrderTicket());
      }
   }
}

void DeleteAllHang()
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()!=Magic) continue;
         if(OrderType()>1) OrderDelete(OrderTicket());
      }
   }
}

//+------------------------------------------------------------------+
void CloseAll()
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()!=Magic) continue;
         if(OrderType()==OP_BUY)
            OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),Slip,Green);
         else if(OrderType()==OP_SELL)
            OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),Slip,Green);
         else if(OrderType()>1)
            OrderDelete(OrderTicket());
      }
   }
}

bool IsinPendingTime()
{
   string item[];
   for (int i = 0; i < ArraySize(MessageList) ; i++)
   {
      split("|" ,MessageList[i], item);
      if(TimeCurrent()-StrToTime(item[1])<CancelOrderMin*60 && StrToTime(item[1])>TimeCurrent()<TimeDistance)
      {
         return(true);
      }
   }
   return(false);
}

bool IsinOpeningTime()
{
   string item[];
   for (int i = 0; i < ArraySize(MessageList) ; i++)
   {
      split("|" ,MessageList[i], item);
      if(TimeCurrent()-StrToTime(item[1])<CloseOrderMin*60 && StrToTime(item[1])>TimeCurrent()<TimeDistance)
      {
         return(true);
      }
   }
   return(false);
}
/*


   ClearSignal();
   GetSignal(Signal);

   //平仓部分
   if(Signal[6]>0)//平空单
   {
      OrderCloseNow(Magic,OP_SELL);
      OrderCloseNow(Magic,OP_BUY);
      DeleteAllHangOrder();
      IsOpenOrder=false;
      OpenOrderTime=0;
   }
   
   OpenOrderCount=GetExistOrderCount(Magic);
   
   if(Signal[0]>0  && !IsOpenOrder)//确认信号 做多  && LastSignalDirection==1
   {
      //for(int i=0;i<ArraySize(SymbolList);i++)
      //{
         OpenOrderNow(SymbolList[0],OP_BUYSTOP,Lot,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,BuyColor,PriceDistance);
         OpenOrderNow(SymbolList[0],OP_SELLSTOP,Lot,Slip,StopLoss,TakeProfit,OrderCommentStr,Magic,SellColor,PriceDistance);
      //}

      IsOpenOrder=true;
      OpenOrderTime=TimeCurrent();
   } 
*/


