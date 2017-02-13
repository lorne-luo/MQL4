//+------------------------------------------------------------------+
//|                                                  AutoMessage.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property show_inputs
#define Magic 262589380

extern bool EAEnabled = true;//是否开启本辅助EA
extern string _ = "=========Time Configuration==========";
extern int MessageMonth = 0;
extern int MessageDay = 0;
extern int MessageHour = 0;
extern int MessageMin = 0;
extern int GmtOffset=7;
extern int TimeDistance=60;//秒
extern int CloseOrderMin = 120;
extern int CancelOrderMin = 7;
extern string __ = "=========Price Configuration==========";
extern int PriceDistance = 15;
extern int StopLoss = 15;  //止损点数
extern int TakeProfit = 60;  //止损点数
extern int ProtectProfit = 20;  //止损点数
extern double Lot = 0.1;
extern int Slip=10;//滑点偏移点数
extern string comment = "AutoMessage";

bool IsOrdered=false;
datetime starttime2;
datetime starttime3;
datetime starttime4;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   //若不指定月、日则默认为当天
   if(MessageMonth==0) MessageMonth=Month();
   if(MessageDay==0) MessageDay=Day();

   starttime2=StrToTime(Year()+"."+MessageMonth+"."+MessageDay+" "+MessageHour+":"+MessageMin+":"+"00");
   starttime3=starttime2-GmtOffset*3600;
   starttime4=starttime2+CloseOrderMin*60;
   Comment("MessageLocalTime"+TimeToStr(starttime2)+"\n"
            +"ServerCurrentTime:"+TimeToStr(TimeCurrent())+"\n"
            +"MessageServerTime"+TimeToStr(starttime3)+"\n"
            +"CloseServerTime"+TimeToStr(starttime4)+"\n");
            
   //Print("StartTime:"+TimeToStr(starttime2));
   //Print("TimeCurrent:"+TimeToStr(TimeCurrent()));
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
   if(!EAEnabled) return(0);
   
   datetime starttime=StrToTime(Year()+"."+MessageMonth+"."+MessageDay+" "+MessageHour+":"+MessageMin+":"+"00");
   starttime=starttime-GmtOffset*3600;
   //Comment(starttime - TimeCurrent());
   string s;
   
   if (TimeCurrent()>starttime)
      s="-";
   else
      s="";
            
   Comment("MessageLocalTime"+TimeToStr(starttime2)+"\n"
            +"MessageServerTime"+TimeToStr(starttime3)+"\n"
            +"CloseServerTime"+TimeToStr(starttime4-GmtOffset*3600)+"\n"
            +"CountDown:"+s+TimeToStr(MathAbs(TimeCurrent()-starttime),TIME_SECONDS)+"\n"

            );
            
   if(starttime - TimeCurrent()>0&&starttime - TimeCurrent()<TimeDistance&&!IsOrdered)
   {
      OpenOrder();
      IsOrdered=true;
   }
   
   if(starttime - TimeCurrent()<0&&TimeCurrent()-starttime<CloseOrderMin*60)
   {
      int OpenedOrder=0; 
      //统计订单数量
      for (int i = OrdersTotal()-1; i >= 0 ; i--)
      {
         if(OrderSelect(i,SELECT_BY_POS))
         {
            if(OrderMagicNumber()!=Magic) continue;
            if(OrderType()<2) //持单中
            {
               if(OrderProfit()/10/Lot>ProtectProfit)//盈利达到保护位置，设置平损
               {
                  double openasloss=OrderStopLoss();
                  if(OrderType()==0&&OrderOpenPrice()+1*10*Point>openasloss)
                     openasloss=OrderOpenPrice()+1*10*Point;
                  else if(OrderType()==1&&OrderOpenPrice()-1*10*Point<openasloss)
                     openasloss=OrderOpenPrice()-1*10*Point;
                     
                  if(OrderStopLoss()!=openasloss)
                  {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),openasloss,OrderTakeProfit(),0,Green))
                        Alert("OrderModify failed:"+GetLastError());
                  }
               }
               OpenedOrder++;
            }
         }
      }
      //取消多余订单
      if(OpenedOrder>0)
      {
         for (i = OrdersTotal()-1; i >= 0 ; i--)
         {
            if(OrderSelect(i,SELECT_BY_POS))
            {
               if(OrderMagicNumber()!=Magic) continue;
               if(OrderType()>1)
               {
                  OrderDelete(OrderTicket());
               }
            }
         }
      }
      
      //5分钟后还没有触发下单则取消订单
      if(TimeCurrent()-starttime>CancelOrderMin*60 && OpenedOrder==0)
      {
         DeleteAll();
         EAEnabled=false;
         Comment("EAEnabled: "+EAEnabled+" DeleteAll");
      }
   }else if(TimeCurrent()-starttime>CloseOrderMin*60)//时间到后
   {
      CloseAll();
      EAEnabled=false;
      Comment("EAEnabled: "+EAEnabled+" CloseAll");
   }

//----
   return(0);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
void OpenOrder()
{  
   double DistancePoint=PriceDistance*10*Point;
   double StopLossPoint=StopLoss*10*Point;
   double TakeProfitPoint=TakeProfit*10*Point;
   
   OrderSend(Symbol(), OP_BUYSTOP, Lot, Ask+DistancePoint,Slip,Ask+DistancePoint-StopLossPoint,Ask+DistancePoint+TakeProfitPoint,comment,Magic,0,Green);
   Sleep(2000);
   OrderSend(Symbol(), OP_SELLSTOP, Lot, Bid-DistancePoint,Slip,Bid-DistancePoint+StopLossPoint,Bid-DistancePoint-TakeProfitPoint,comment,Magic,0,Green);
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