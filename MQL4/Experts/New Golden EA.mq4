#property copyright "Lorne"
#property link      "www@luotao.net"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define Magic 20140120
//+------------------------------------------------------------------+
//| extern input                                                     |
//+------------------------------------------------------------------+
extern int MagaPeriod = 40;  //趋势线周期
extern int StopLoss = 30;  //止损点数
extern double TakeProfit = 40;
extern double Lot=0.1;//正常开单手数
extern int Slip=3;//滑点偏移点数
extern int TrailingStop = 30;//跟踪止损点数
extern int TrailingStopStep = 20;//紧逼跟踪止损方式时起作用，最高盈利每增加20移动一次止损
extern int TrailingStopLevel0 = 30;//盈利30点后
extern int TrailingStopLevel1 = 50;//盈利50点后开始设置跟踪止损
extern int TrailingStopLevel2 = 70;//盈利80点后再次设置跟踪止损
extern int TrailingStopLevel3 = 90;//盈利100点后将每20点设置一次止损
//+------------------------------------------------------------------+
//| include imports                                                  |
//+------------------------------------------------------------------+
//#include <SystemManager.mqh>
//#include <TimeManager.mqh>
#include <OrderManager.mqh>
#include <IndicatorManager.mqh>
#include <CustomIndicatorManager.mqh>

/*===================================CashManager===============================================
extern string ___="==================资金管理参数==================";
extern int OriginCash=1000;
extern int UsePercent=5;
extern int AbandonPercent=10;
*/
//+------------------------------------------------------------------+
//| global variables                                                 |
//+------------------------------------------------------------------+
/*=================================== Variable ===============================================*/
int MainTimeFrame=PERIOD_H1;
int SmallerTimeFrame=PERIOD_M15;
int LargerTimeFrame=PERIOD_H4;
int LargestTimeFrame=PERIOD_D1;

double LastLots;//当前开单的手数
int OpenOrderCount=0;//当前已开单数
int AddLotProfit=30;//首单盈利超过这个值时才加仓
datetime RunStartInterval=2000;//间隔3秒执行一次START()
datetime LastOpenOrderTime=0;//上一次开单时间
datetime LastTrailingStopTime=0;//上一次跟踪止损时间
datetime ClearHangOrderTime=14400;//挂单X秒后仍未触发则取消
datetime LastSendMail=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   SystemInit();
//----

   BuyColor=Aqua;
   SellColor=Gold;
   RefreshRates();
   Sleep(5000);
   
   //todo 根据上一个本symbol的order初始化LastOpenOrderTime
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
   //Print("Point2Price="+Point2Price(21));
   //输出时间，以及EA是否在运行
   CommentStr="Local="+TimeToStr(TimeCurrent())+" GMT="+TimeToStr(TimeCurrent()-GmtOffset*3600)+" | ";
   if(!IsEARuning) CommentStr=CommentStr+"EA is forbidden running\n";
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
   OpenOrderCount=GetOrderCountBySymbol(Magic,Symbol());
   bool canAddOrder=IsEnableAddOrder && OpenOrderCount<3 
                     && OrderLotsCount(Magic,Symbol())<=2*Lot && TimeDistance(LastOpenOrderTime,MainTimeFrame*1*60);
   bool canSubOrder=IsEnableSubOrder;
   
   int interval=6;//距离上次开单间隔
   bool canOpenOrder = IsTradeAllowed() && IsInTradeTime() && TimeDistance(LastOpenOrderTime,MainTimeFrame*interval*60) && OpenOrderCount < 1;
   
   if(!IsTradeAllowed())
      CommentStr=CommentStr+"TradeAllowed = False\n";
   if(!TimeDistance(LastOpenOrderTime,MainTimeFrame*interval*60))
      CommentStr=CommentStr+"TimeDistance of LastOpenOrderTime is not enough\n";
   if(!IsInTradeTime())//非交易时间内不做
      CommentStr=CommentStr+"IsInTradeTime=False\n";

   
//--------------------------------------------------------------------------   
   //处理已有单，跟踪止损、取消过期挂单
   
   if(OpenOrderCount>0)
      DealExistOrder(Symbol(),Magic);
   else
   {
      LastLots=0;
   }
   
   GetSignal(signal);

   //平仓部分
   if(signal.CloseSell > 0)//平空单
   {
      if(OrderCloseNow(Magic,OP_SELL)>0) 
      {
         LastLots=0;
         Print(CommentStr);
      }
   }
   if(signal.CloseBuy > 0)//平多单
   {
      if(OrderCloseNow(Magic,OP_BUY)>0)
      {
         LastLots=0;//上次开单手数
         Print(CommentStr);
      }
   }

   //可能上面有平仓操作，所以判断开仓前再获取一次目前已经开单的数量
   OpenOrderCount=GetOrderCountBySymbol(Magic,Symbol());
   
//-------------------------------开仓部分-------------------------------------------
   

      
   int ticket;  
   //做多
   if(signal.OpenBuy>0 && canOpenOrder)//确认信号 做多  && ConfirmSignal(1)==1
   {
      LastLots=Lot*signal.OpenBuy/10;
      if(LastLots<MinLot)
         LastLots=MinLot;
      ticket=OpenOrderNow(Symbol(),OP_BUY,LastLots,Slip,StopLoss,TakeProfit,"GoldenBuy="+signal.OpenBuy,Magic,BuyColor,0);

      if(ticket>0)
      {
         LastOpenOrderTime=TimeCurrent();
         SendMail("Golden " + Symbol() + " Buy "+ticket+" = " + DoubleToStr(Ask,Digits), 
                  "Golden " + Symbol() + " Buy "+ticket+" = " + DoubleToStr(Ask,Digits));
         Print(CommentStr);         
      }
   }
   //做空
   if(signal.OpenSell>0 && canOpenOrder)//确认信号 做空  && ConfirmSignal(-1)==1
   {
      LastLots=Lot*signal.OpenSell/10;
      if(LastLots<MinLot)
         LastLots=MinLot;
      ticket=OpenOrderNow(Symbol(),OP_SELL,LastLots,Slip,StopLoss,TakeProfit,"GoldenSell="+signal.OpenSell,Magic,SellColor,0);

      if(ticket>0)
      {
         LastOpenOrderTime=TimeCurrent();
         SendMail("Golden " + Symbol() + " Sell "+ticket+" = " + DoubleToStr(Bid,Digits), 
                  "Golden " + Symbol() + " Sell "+ticket+" = " + DoubleToStr(Bid,Digits));
         Print(CommentStr);         
      }
   }
   
   double lot=LastLots;
   for(int i=0;i<OpenOrderCount;i++)
   {
      lot=lot/2;
   }
   if(signal.AddBuy>0 && canAddOrder)//加多
   {
      lot=lot*signal.AddBuy/10;
      OpenOrderNow(Symbol(),OP_BUY,lot,Slip,StopLoss,TakeProfit,"Golden AddBuy",Magic,BuyColor,0);
      LastOpenOrderTime=TimeCurrent();
   }

   if(signal.AddSell>0 && canAddOrder)//加空
   {
      lot=lot*signal.AddSell/10;
      OpenOrderNow(Symbol(),OP_SELL,lot,Slip,StopLoss,TakeProfit,"Golden AddSell",Magic,SellColor,0);
      LastOpenOrderTime=TimeCurrent();
   }
   CommentStr=CommentStr+"openbuy="+signal.OpenBuy+"  opensell="+signal.OpenSell+"  addbuy="+signal.AddBuy+"  addsell="+signal.AddSell+"  subbuy="+signal.SubBuy+"  subsell="+signal.SubSell+"  closebuy="+signal.CloseBuy+"  closesell="+signal.CloseSell+"\n";

//----
   ShowComment();
   return(0);
  }
  
//每种信号量0-10
void GetSignal(Signal& tempsignal)
{
   // clear singal
   tempsignal.AddBuy=0;
   tempsignal.AddSell=0;
   tempsignal.OpenBuy=0;
   tempsignal.OpenSell=0;
   tempsignal.SubBuy=0;
   tempsignal.SubSell=0;
   tempsignal.CloseBuy=0;
   tempsignal.CloseSell=0;
   //多重时间趋势
   int trendLine=GetTrendLine(MainTimeFrame,1,Symbol(),MagaPeriod);
   
   TrendVariable trendVariableCount;
   GetTrendVariableCount(MainTimeFrame,1,Symbol(),trendVariableCount);
   int goldenArrow=GetGoldenArrow(Symbol(),MainTimeFrame);
   int goldenFinger=GetGoldenFinger(Symbol(),MainTimeFrame);
      
   int MACDTrend=GetMACDTrend(MainTimeFrame,Symbol());
   double currentMACDValue=iCustom(Symbol(), MainTimeFrame, "Golden MACD",5,34,5, 4, 0);
/*=======================================开仓=============================================*/
   //近5个K线趋势线变蓝且有向上箭头，多头信号至少2个,MACD大于0 做多
   if(trendLine>0 && trendLine<=5 && goldenArrow>0 && goldenArrow<=10 && goldenFinger>0 && goldenFinger<=10 &&
      trendVariableCount.Buy>1 && currentMACDValue>0 && MACDTrend>0)
   {
      tempsignal.OpenBuy=10;
      tempsignal.OpenSell=0;
      tempsignal.CloseSell=10;
   }
   else if(trendLine>0 && trendLine<=5 && ((goldenArrow>0 && goldenArrow<=10) || (goldenFinger>0 && goldenFinger<=10)) &&
      trendVariableCount.Buy>2 && currentMACDValue>0 && MACDTrend>0)
   {
      tempsignal.OpenBuy=10;
      tempsignal.OpenSell=0;
      tempsignal.CloseSell=10;
   }
   if (trendLine>0 && trendLine<=5 && goldenArrow>0 && goldenArrow<=5 && goldenFinger>0 && goldenFinger<=5)
   {
      if(TimeDistance(LastSendMail,5*3600))
      {
         SendMail(Symbol()+" Trend,Aroow,Finger = Buy",Symbol()+" Trend,Aroow,Finger = Buy");
         LastSendMail=TimeCurrent();
      }
   }
   
   //近5个K线趋势线变黄且有向下箭头，空头信号至少2个,MACD小于0 做空
   if(trendLine<0 && trendLine>=-5 && goldenArrow<0 && goldenArrow>=-10 && goldenFinger<0 && goldenFinger>=-10 &&
      trendVariableCount.Sell<-1 && currentMACDValue<0 && MACDTrend<0)
   {
      tempsignal.OpenSell=10;
      tempsignal.OpenBuy=0;
      tempsignal.CloseBuy=10;
   }
   else if(trendLine<0 && trendLine>=-5 && ((goldenArrow<0 && goldenArrow>=-10) || (goldenFinger<0 && goldenFinger>=-10)) &&
      trendVariableCount.Sell<-2 && currentMACDValue<0 && MACDTrend<0)
   {
      tempsignal.OpenSell=10;
      tempsignal.OpenBuy=0;
      tempsignal.CloseBuy=10;
   }
   if (trendLine<0 && trendLine>=-5 && goldenArrow<0 && goldenArrow>=-5 && goldenFinger<0 && goldenFinger>=-5)
   {
      if(TimeDistance(LastSendMail,5*3600))
      {
         SendMail(Symbol()+" Trend,Aroow,Finger = Sell",Symbol()+" Trend,Aroow,Finger = Sell");
         LastSendMail=TimeCurrent();
      }
   }
   
/*=======================================平仓=============================================*/
   if(trendLine >= 0 || trendVariableCount.Buy>1 || (goldenArrow>0 && goldenFinger>0) || MACDTrend>0)//平空单
   {
      tempsignal.CloseSell=10;
   }
   if(trendLine <= 0 || trendVariableCount.Sell<-1 || (goldenArrow<0 && goldenFinger<0) || MACDTrend<0)//平多单
   {
      tempsignal.CloseBuy=10;
   }

/*=======================================加仓=============================================*/
   //加多 满信号 一直蓝线且有单  && blue0>blue1 && blue1>0 
   //加仓后判断一下是否是近期最高价
   if(trendLine==5 && trendVariableCount.Buy>1 && OpenOrderCount > 0)
   {
      //tempsignal.AddBuy=10;
   }

   //Print(lastOpenPrice+" "+Price2Point(Ask-lastOpenPrice)+">"+AddLotProfit);
   //加空 !!是否加入多重时间框架？看M15图 && red0<red1 && red1<0
   if(trendLine==-5 && trendVariableCount.Sell<-1  && OpenOrderCount > 0)
   {
      //tempsignal.AddSell=10;
   }

/*=======================================减仓=============================================*/
   //减多
   if(OpenOrderCount>0)
   {
      //tempsignal.SubBuy=10;
   }
   if(OpenOrderCount>0)//减空
   {
      //tempsignal.SubSell=10;
   }
   
   CommentStr=CommentStr+"trendLine="+trendLine+" variableCount="+trendVariableCount.Buy+"|"+trendVariableCount.Sell+" arrow="+goldenArrow+" finger="+goldenFinger+" macd="+MACDTrend+" macdvalue="+DoubleToStr(currentMACDValue,6)+" OpenedOrderCount="+OpenOrderCount+"\n";
   
   string s="trendLine="+trendLine+" trendCount="+trendVariableCount.Buy+"|"+trendVariableCount.Sell+" macd="+MACDTrend
      +" Order="+OpenOrderCount+
      " openbuy="+tempsignal.OpenBuy+" opensell="+tempsignal.OpenSell+" abuy="+tempsignal.AddBuy+" addsell="+tempsignal.AddSell+" sbuy="+tempsignal.SubBuy+
      " ssell="+tempsignal.SubSell+" closebuy="+tempsignal.CloseBuy+" closesell="+tempsignal.CloseSell+"\n";
      
   //每15m Print一次调试信息
   if(IsDebug && IsInTradeTime() && TimeDistance(LastPrintDebugTime,15*60))
      PrintDebugInfo(s);
   if(IsLog && IsInTradeTime() && TimeDistance(LastLogDebugTime,15*60))
      Log(s); 
   //return(signal);
}




/*=======================================================================================*/

//处理现有的单 主要是调整移动止损止盈 以及一些异常波动时候平仓
void DealExistOrder(string symbol,int magic)
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic && OrderSymbol()==symbol)
         {
            if(OrderType()<2)//OP_SELL or OP_BUY
            {
               //StepTrailStop(OrderTicket(),TrailingStop,TrailingStopStep);
               CustomStepTrailingStopOrder(OrderTicket(),TrailingStop,TrailingStopLevel0,TrailingStopLevel1,TrailingStopLevel2,TrailingStopLevel3);
            }else if (OrderType()>1)//STOP or LIMIT
            {
               if(TimeDistance(OrderOpenTime(),ClearHangOrderTime))
               {
                  bool result = OrderDelete(OrderTicket());
                  if(result == false)
                  {
                     string errorStr=ErrorDescription(GetLastError());
                     Alert("[Order ", OrderTicket(), " close failed] ", errorStr);
                     Print("[Order ", OrderTicket(), " close failed] ", errorStr);
                     Sleep(500);
                  }
               }
            }
         }
      }
   }
}
 


