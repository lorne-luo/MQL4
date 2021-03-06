//+------------------------------------------------------------------+
//|                                             InvestorReminder.mq4 |
//|                                                         by Lorne |
//|                                                   www@luotao.net |
//+------------------------------------------------------------------+
#property copyright "Lorne"
#property link      "www@luotao.net"
#property version   "1.00"
#property strict

#define Magic 20150104

#include <stderror.mqh>
#include <stdlib.mqh>

extern bool OrderMonitorEnable=false;
int OrderTicketListLength=200; // OrderTicketList Array length
int OrderTicketList[200]; // store opening order's ticket

extern bool HLineMonitorEnable=true;
datetime LastHLineMonitrReport=TimeCurrent();

extern bool H4MACD5131Enable=true;
int LastSendMail=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   //EventSetTimer(1);

   if (OrderMonitorEnable)
      OrderMonitorInit();
      
   if (HLineMonitorEnable)
      LastHLineMonitrReport=0;
      
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   //EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   //Print("OnTick");
   // only work day
   if(DayOfWeek()!=0 && DayOfWeek()!=6)
   {
      if (OrderMonitorEnable)
         OrderMonitor();
         
      if (HLineMonitorEnable)
         HLineMonitor();
         
      if (H4MACD5131Enable)
         H4MACD5131();
   }
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   //Print("OnTimer");
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   //Print("OnChartEvent");
  }
//+------------------------------------------------------------------+

void OrderMonitorInit()
{
   // init order list in memory
   for (int i = 0; i < OrderTicketListLength ; i++)
   {
      OrderTicketList[i]=EMPTY_VALUE;
   }
   int j=0;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if (j==OrderTicketListLength)
      {
         Print("OrderTicketListLength not enough, OrdersTotal="+OrdersTotal());
         break;
      }
      if(OrderSelect(i,SELECT_BY_POS))
      {
         OrderTicketList[j]=OrderTicket();
         j++;
         Print("Init add "+ OrderTicket() + " into OrderTicketList");
      }
   }
}

void OrderMonitor()
{
   //report open
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         
         int ticket=OrderTicket();
         int index = IsInOrderList(ticket);
         //Print("index="+index," OrderTicketList[0] = ",OrderTicketList[0]);
         if(index<0)
            ReportOpen(ticket);
      }
   }
   //report close
   for (int i = 0; i < OrderTicketListLength ; i++)
   {
      //&& !OrderSelect(OrderTicketList[i],SELECT_BY_TICKET
      if(OrderTicketList[i]!=EMPTY_VALUE)
      {
         int index = IsCurrentOrder(OrderTicketList[i]);
         if(index<0)
         {
            ReportColse(OrderTicketList[i]);
            OrderTicketList[i]=EMPTY_VALUE;
            Print("Pop ",OrderTicketList[i]," out of OrderTicketList");
         }
      }
   }
}

//check ticket id in OrderTicketList,return index, return -1 if not found
int IsInOrderList(const int ticket)
{
   for (int i = 0; i < OrderTicketListLength ; i++)
   {
      if(OrderTicketList[i]==ticket)
         return(i);
   }
   return(-1);
}

void ReportOpen(const int ticket)
{
   Print("Report Open = "+ticket);
   for (int i = 0; i < OrderTicketListLength ; i++)
   {
      if(OrderTicketList[i]==EMPTY_VALUE)
      {
         if(OrderSelect(ticket,SELECT_BY_TICKET))
         {
            string direction=GetOrderTypeStr(OrderType());
            Print("["+AccountNumber()+"] " + OrderSymbol() +" "+ direction + " Open at  "+OrderOpenPrice());
            SendMail("["+AccountNumber()+"] " + OrderSymbol() +" " + direction + " Open at  "+OrderOpenPrice()+" , "+OrderComment(), 
                     "["+AccountNumber()+"] " + OrderSymbol() +" " + direction + " Open at  "+OrderOpenPrice()+" , "+OrderComment());
            int code=GetLastError();
            if (code==ERR_NO_ERROR || code==ERR_NO_MQLERROR){
               OrderTicketList[i]=ticket;
               Print("Push ",ticket," into OrderTicketList");
            }else{
               Print("[SendMail Failed] "+ErrorDescription(code));
            }
         }
         return;
      }
   }
}

void ReportColse(const int ticket)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY))
   {
      string direction=GetOrderTypeStr(OrderType());
      Print("["+AccountNumber()+"] "+ OrderSymbol() +" " + direction + " Closed "+OrderOpenPrice()+" - "+OrderClosePrice());
      SendMail("["+AccountNumber()+"] "+ OrderSymbol() +" " + direction + " Closed "+OrderOpenPrice()+" - "+OrderClosePrice(), 
               "["+AccountNumber()+"] "+ OrderSymbol() +" " + direction + " Closed "+OrderOpenPrice()+" - "+OrderClosePrice()+" , "+OrderComment());
   }
}

// whether stored ticket is opending, yes return order position,no return -1
int IsCurrentOrder(const int ticket)
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(ticket==OrderTicket())
            return i;
      }
   }
   return -1;
}
string GetOrderTypeStr(int type)
{
   if(type==OP_BUY)
   {
      return "BUY";
   }else if(type==OP_SELL)
   {
      return "SELL";
   }else if(type==OP_BUYLIMIT)
   {
      return "BUYLIMIT";
   }else if(type==OP_SELLLIMIT)
   {
      return "SELLLIMIT";
   }else if(type==OP_BUYSTOP)
   {
      return "BUYSTOP";
   }else
   {
      return "SELLSTOP";
   }
}

void HLineMonitor()
{
   // 1hr later form last report
   if ((TimeCurrent()-LastHLineMonitrReport)<3600) return;

   double open=iOpen(Symbol(),PERIOD_M5,1);
   double close=iClose(Symbol(),PERIOD_M5,1);

   int obj_total=ObjectsTotal();
   //Print("ObjectsTotal="+obj_total);
   string name;
   for(int i=0;i<obj_total;i++)
   {
      name=ObjectName(i);
      if(ObjectType(name)==OBJ_HLINE)
      {
         double price=ObjectGet(name, OBJPROP_PRICE1);
         
         string msg="";
         if(price>open && price<close)
         {
            msg=Symbol()+" up cross "+DoubleToStr(price,Digits);
            SendMail(msg, msg);
            Print(msg);
            LastHLineMonitrReport=TimeCurrent();
         }else if(price<open && price>close){
            msg=Symbol()+" down cross "+DoubleToStr(price,Digits);
            SendMail(msg, msg);
            Print(msg);
            LastHLineMonitrReport=TimeCurrent();
         }
      }
   }
}


#include <MovingAverages.mqh>

void H4MACD5131()
{
   int currentHour=Year()*1000000+Month()*10000+Day()*100+TimeHour(iTime(Symbol(), PERIOD_H4,0));
   if(currentHour - LastSendMail >= 4)
   {
      double rsi14 = iCustom(Symbol(), PERIOD_H4, "RSI",14, 0, 0);
      double ma89_0=iMA(Symbol(),PERIOD_H4,89,0,MODE_EMA,PRICE_CLOSE,0);
      double ma89_1=iMA(Symbol(),PERIOD_H4,89,0,MODE_EMA,PRICE_CLOSE,1);
      double macd1 = iMACD(Symbol(),PERIOD_H4,5,13,1,PRICE_CLOSE,MODE_MAIN,1);
      double macd2 = iMACD(Symbol(),PERIOD_H4,5,13,1,PRICE_CLOSE,MODE_MAIN,2);
      double macd3 = iMACD(Symbol(),PERIOD_H4,5,13,1,PRICE_CLOSE,MODE_MAIN,3);
      double current_price=(Ask+Bid)/2;
      
      if (ma89_0<ma89_1 && rsi14>50)
      {
         if(macd1 < macd2 && macd2 > macd3){
            string title = "H4:" + Symbol() + " SELL = " + DoubleToStr(current_price,Digits);
            SendMail(title, DoubleToStr(macd2,Digits) + " -> " + DoubleToStr(macd1,Digits)+" RSI14="+DoubleToStr(rsi14,2));
            Print(IntegerToString(LastSendMail) + " : " + title);
         }
      }else if (ma89_0>ma89_1 && rsi14<50){
         if(macd1 > macd2 && macd2 < macd3)
         {
            string title = "H4:" + Symbol() + " BUY = " + DoubleToStr(current_price,Digits);
            SendMail(title, DoubleToStr(macd2,Digits) + " -> " + DoubleToStr(macd1,Digits)+" RSI14="+DoubleToStr(rsi14,2));
            Print(IntegerToString(LastSendMail) + " : " + title);
         }
      }
      //Comment(macd1+" | "+macd2+" | "+macd3+" | "+rsi14+" | "+ma89_0+" | "+ma89_1);
      LastSendMail = currentHour;
      Comment("LastRun = "+LastSendMail+"\n"+DoubleToStr(macd1,6)+" | "+DoubleToStr(macd2,6)+" | "+DoubleToStr(macd3,6)+" | "+DoubleToStr(rsi14,2)+" | "+DoubleToStr(ma89_0,Digits)+" | "+DoubleToStr(ma89_1,Digits));
      Print(Symbol()+" LastRun = "+LastSendMail+"\n"+DoubleToStr(macd1,6)+" | "+DoubleToStr(macd2,6)+" | "+DoubleToStr(macd3,6)+" | "+DoubleToStr(rsi14,2)+" | "+DoubleToStr(ma89_0,Digits)+" | "+DoubleToStr(ma89_1,Digits));
   }
}

