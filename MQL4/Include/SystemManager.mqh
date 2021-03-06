#property copyright "Lorne"
#property link      "www@luotao.net"

#include <stderror.mqh>
#include <stdlib.mqh>
//#include <ErrorCode.mqh>

extern string _="==================系统参数==================";
extern bool IsEARuning=true;
extern bool IsDebug=false;
extern bool IsLog=false;
extern bool IsShowComment=true;//在图表上输出相关信息

extern string __="==================时间参数==================";
extern int GmtOffset=2;
extern int TradeBeginHour=1;
extern int TradeEndHour=21;

int LotDigits=1;//手数支持到小数点后几位
double ThisPoint=0.0001;//1点对应的价格
double MinLot=0.01;

int ThisDay;
int ThisMonth;
double YesterdayProfit;
double ThisMonthProfit;
double LastMonthProfit;
double YesterdayPoint;
double ThisMonthPoint;
double LastMonthPoint;

datetime LastPrintDebugTime;//若开启了ISDEBUG，上一次PRINT出主要信号的时间
datetime LastLogDebugTime;//若开启了ISLOG，上一次LOG出主要信号的时间

string CommentStr;//输出Comment
int LogFileHandler;

//获取信号0-10
struct Signal
{
   int OpenBuy;
   int OpenSell;
   int AddBuy;
   int AddSell;
   int SubBuy;
   int SubSell;
   int CloseBuy;
   int CloseSell;
};
Signal signal;


/*================================================================================*/
//系统初始化，获取最小LOT数，点数
void SystemInit()
{
   ThisDay=TimeDay(TimeCurrent());
   ThisMonth=TimeMonth(TimeCurrent());
   GetYesterdayProfit(Magic);
   GetThisMonthProfit(Magic);
   GetLastMonthProfit(Magic);
   //计算一点是多少价格，各个平台Point位数不同
   // todo 有待完善
   int intcnt= IntPartCount(Ask);
   if(intcnt==1)
      ThisPoint=0.0001;
   else if(intcnt>1&&intcnt<4)
      ThisPoint=0.01;
   else if(intcnt==4)
      ThisPoint=0.1;
   else if(intcnt>4)
      ThisPoint=1;
   
   MinLot=MarketInfo(Symbol(), MODE_MINLOT);
   double tempMinLot=MinLot;
   for(int j=0;;j++)
   {
      if(1<=tempMinLot)
      {
         LotDigits=j;
         break;
      }else{
         tempMinLot=tempMinLot*10;
      }
   }
   Print(" ======= MinPip="+ThisPoint+", LotDecimalPoint="+LotDigits+", MINLOT="+MinLot+", ThisPoint="+ThisPoint+" ======= ");
   //打开Log文件句柄
   if(IsLog) LogFileHandler = FileOpen(WindowExpertName() + "_" + Symbol() + "_" + Magic + ".log", FILE_WRITE);
}



//系统关闭反初始化
void SystemDeinit()
{
   if(LogFileHandler!=0)
      FileClose(LogFileHandler);
}

void ClearSignal()
{
   signal.OpenBuy=0;
   signal.OpenSell=0;
   signal.AddBuy=0;
   signal.AddSell=0;
   signal.SubBuy=0;
   signal.SubSell=0;
   signal.CloseBuy=0;
   signal.CloseSell=0;
}

//输出注释到图表
void ShowComment()
{
   CommentStr=CommentStr+"=======================================\nToday:"
   +TodayClosedOrderProfit(Magic)+" "+TodayOpendOrderProfit(Magic)+"\n"
   +"YesterdayProfit="+DoubleToStr(YesterdayProfit,1)+" "+DoubleToStr(YesterdayPoint,0)+" P"
   +"\nThisMonthProfit="+DoubleToStr(ThisMonthProfit,1)+" "+DoubleToStr(ThisMonthPoint,0)+" P\nLastMonthProfit="
   +DoubleToStr(LastMonthProfit,1)+" "+DoubleToStr(LastMonthPoint,0)+" P\n";
   if(IsShowComment) Comment(CommentStr);
}

void DailyStat()
{
   if(ThisDay!=TimeDay(TimeCurrent()))//过了一天，统计盈利信息
   {
      GetYesterdayProfit(Magic);
      GetThisMonthProfit(Magic);
      GetLastMonthProfit(Magic);
      ThisDay=TimeDay(TimeCurrent());
      Print("YesterdayProfit="+DoubleToStr(YesterdayProfit,1)+" "+DoubleToStr(YesterdayProfit,0)+" Point");
   }
}

//打印Debug信息
void PrintDebugInfo(string debugStr)
{
   Print(debugStr);
   LastPrintDebugTime=TimeCurrent();
}

//记录Log
void Log(string logStr) {
   if (LogFileHandler >= 0)
      FileWrite(LogFileHandler, TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + ": " + logStr);
   LastLogDebugTime=TimeCurrent();
}

//今日正在交易订单盈利点数
double TodayOpendOrderProfit(int magic)
{
   double profit=0;
   double lots=0;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic && OrderSymbol()==Symbol())
            profit = profit + OrderProfit();
      }
   }
   return(profit);
}

//今日已平仓盈利点数
double TodayClosedOrderProfit(int magic)
{
   int y=TimeYear(TimeCurrent());
   int m=TimeMonth(TimeCurrent());
   int d=TimeDay(TimeCurrent());
   int yy;
   int mm;
   int dd;
   double profit=0;
   
   for (int i = HistoryTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
      {
         if(OrderMagicNumber()!=magic || OrderSymbol()!=Symbol()) continue;
         yy=TimeYear(OrderCloseTime());
         mm=TimeMonth(OrderCloseTime());
         dd=TimeDay(OrderCloseTime());
         if(yy==y && m==mm && d==dd)
         {
            profit = profit + OrderProfit();
         }
      }
   }
   return(profit);
}

//昨日EA盈利点数
void GetYesterdayProfit(int magic)
{
   YesterdayProfit=0;
   YesterdayPoint=0;
   datetime yesterday=TimeCurrent()-86400;
   int y=TimeYear(yesterday);
   int m=TimeMonth(yesterday);
   int d=TimeDay(yesterday);
   int yy;
   int mm;
   int dd;
   for (int i = HistoryTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
      {
         if(OrderMagicNumber()!=magic || OrderSymbol()!=Symbol()) continue;
         yy=TimeYear(OrderCloseTime());
         mm=TimeMonth(OrderCloseTime());
         dd=TimeDay(OrderCloseTime());
         if(yy==y && m==mm && d==dd)
         {
            YesterdayProfit = YesterdayProfit + OrderProfit();
            YesterdayPoint=YesterdayPoint + OrderProfit()/OrderLots()/10;
         }
      }
   }
}

//上个月EA盈利点数
void GetLastMonthProfit(int magic)
{
   LastMonthProfit=0;
   LastMonthPoint=0;
   datetime yesterday=TimeCurrent()-86400;
   int y=TimeYear(TimeCurrent());
   int m=TimeMonth(TimeCurrent());
   if(m-1==0)
   {
      m=12;
      y=y-1;
   }else{
      m=m-1;
   }   
   int yy;
   int mm;

   for (int i = HistoryTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
      {
         if(OrderMagicNumber()!=magic || OrderSymbol()!=Symbol()) continue;
         yy=TimeYear(OrderCloseTime());
         mm=TimeMonth(OrderCloseTime());
         if(yy==y && m==mm)
         {
            LastMonthProfit = LastMonthProfit + OrderProfit();
            LastMonthPoint = LastMonthPoint + OrderProfit()/OrderLots()/10;
         }
      }
   }
}

//本月EA盈利点数
void GetThisMonthProfit(int magic)
{
   ThisMonthProfit=0;
   ThisMonthPoint=0;
   datetime yesterday=TimeCurrent()-86400;
   int y=TimeYear(TimeCurrent());
   int m=TimeMonth(TimeCurrent());
   int yy;
   int mm;
   for (int i = HistoryTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
      {
         if(OrderMagicNumber()!=magic || OrderSymbol()!=Symbol()) continue;
         yy=TimeYear(OrderCloseTime());
         mm=TimeMonth(OrderCloseTime());
         if(yy==y && m==mm)
         {
            ThisMonthProfit = ThisMonthProfit + OrderProfit();
            ThisMonthPoint = ThisMonthPoint + OrderProfit()/OrderLots()/10;
         }
      }
   }
}
//+------------------------------系统函数------------------------------------+
//点数 to 报价
double Point2Price(int point)
{
   return(point*ThisPoint);
}
//报价 to 点数
double Price2Point(double price)
{
   return(price/ThisPoint);
}

//返回一个数整数部分的位数
int IntPartCount(double d)
{
   int c=d;
   int result=0;
   while(c>0)
   {
       result++;
       c=c/10; 
   }
   
   return(result);
}

//+----------------------------------------------------------------------------+
//|  Error functions                                                       
//+----------------------------------------------------------------------------+

//============================================= TIME MANAGE ============================================

//是否在交易时间内
bool IsInTradeTime()
{
   int dd=DayOfWeek();
   if(DayOfWeek()==0 || DayOfWeek()==6)//周六日不参加
      return(false);
   int gmt=TimeHour(TimeCurrent()-GmtOffset*3600);
   //Print(gmt);
   if(TradeBeginHour<=TradeEndHour)
   {
      if(gmt<=TradeEndHour&&gmt>=TradeBeginHour) return(true);
   }
   else
   {
      if(gmt<=TradeEndHour || gmt>=TradeBeginHour) return(true);
   }
   
   return(false);
}

//是否满足距离上一次开单时间达到distance 超过返回true 不足返回false
bool TimeDistance(datetime lastTime,datetime distance)
{
   if((TimeCurrent()-lastTime)>distance)
      return(true);
   else
      return(false);
}

//是否在时间区间内
bool HourIsBetween(int start,int end )
{
   int now=TimeHour(TimeCurrent());
   if(start<=end)
   {
      if(now<=end && now>=start) return(true);
   }
   else
   {
      if(now<=end || now>=start) return(true);
   }
   
   return(false);
}

//返回本月第一个工作日
int GetFirstWorkDay()
{
   datetime time1=StrToTime(Year()+"."+Month()+".1 12:00:00");
   datetime time2=StrToTime(Year()+"."+Month()+".2 12:00:00");
   datetime time3=StrToTime(Year()+"."+Month()+".3 12:00:00");
   if(TimeDayOfWeek(time1)!=0 && TimeDayOfWeek(time1)!=6)
      return(1);
   else if(TimeDayOfWeek(time2)!=0 && TimeDayOfWeek(time2)!=6)
      return(2);
   else
      return(3);
}

