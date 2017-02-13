//+------------------------------------------------------------------+
//|                                                 AutostopLoss.mq4 |
//|                                                 Power by Leandro |
//|                               有BUG或有更好想法请联系 QQ:99451121|
//+------------------------------------------------------------------+

#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>

extern bool EAEnabled = true;//是否开启本辅助EA
/*
盈利达到ProfitProtectLevel_x_Pips即在当前盈利百分之ProfitProtectLevel_x_Percen的位置设置止损
例如
ProfitProtectLevel_0_Pips   = 20;
ProfitProtectLevel_0_Percen = 0;
意思即盈利达到20点时将止损点位移到开仓价
*/
extern double       ProfitProtectLevel_0_Pips   = 20;
extern double       ProfitProtectLevel_0_Percen = 0;
extern double       ProfitProtectLevel_1_Pips   = 40;
extern double       ProfitProtectLevel_1_Percen = 30;
extern double       ProfitProtectLevel_2_Pips   = 60;
extern double       ProfitProtectLevel_2_Percen = 50;
extern double       ProfitProtectLevel_3_Pips   = 80;
extern double       ProfitProtectLevel_3_Percen = 65;
extern double       ProfitProtectLevel_4_Pips   = 100;
extern double       ProfitProtectLevel_4_Percen = 75;

datetime LastRunTime=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if(ProfitProtectLevel_0_Percen>100)ProfitProtectLevel_0_Percen=100;
   if(ProfitProtectLevel_1_Percen>100)ProfitProtectLevel_1_Percen=100;
   if(ProfitProtectLevel_2_Percen>100)ProfitProtectLevel_2_Percen=100;
   if(ProfitProtectLevel_3_Percen>100)ProfitProtectLevel_3_Percen=100;
   if(ProfitProtectLevel_4_Percen>100)ProfitProtectLevel_4_Percen=100;
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
   if (!EAEnabled)
   {
     return(0);
   }
   
   if (TimeCurrent()-LastRunTime<3)
   {
     return(0);
   }
   
   double ProfitNow;
   double StopLossNow;
   
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      
      if(OrderSelect(i,SELECT_BY_POS))
      {       
         
         double ask=MarketInfo(OrderSymbol(),MODE_ASK);
         double bid=MarketInfo(OrderSymbol(),MODE_BID);
         double point=MarketInfo(OrderSymbol(),MODE_POINT);
         
         double ProfitProtectLevel_0_PipsPoint=ProfitProtectLevel_0_Pips*10*MarketInfo(OrderSymbol(),MODE_POINT);
         double ProfitProtectLevel_1_PipsPoint=ProfitProtectLevel_1_Pips*10*MarketInfo(OrderSymbol(),MODE_POINT);
         double ProfitProtectLevel_2_PipsPoint=ProfitProtectLevel_2_Pips*10*MarketInfo(OrderSymbol(),MODE_POINT);
         double ProfitProtectLevel_3_PipsPoint=ProfitProtectLevel_3_Pips*10*MarketInfo(OrderSymbol(),MODE_POINT);
         double ProfitProtectLevel_4_PipsPoint=ProfitProtectLevel_4_Pips*10*MarketInfo(OrderSymbol(),MODE_POINT);
         
         if(OrderType() == OP_BUY)
         {
            ProfitNow=MarketInfo(OrderSymbol(), MODE_BID)-OrderOpenPrice();
            StopLossNow=OrderOpenPrice()-OrderStopLoss();
         }else if(OrderType() == OP_SELL)
         {
            ProfitNow=OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK);
            if(OrderStopLoss()==0)
               StopLossNow=OrderOpenPrice();
            else
               StopLossNow=OrderStopLoss()-OrderOpenPrice();
         }
         /*
         Print(OrderSymbol()+"|"+MarketInfo(OrderSymbol(),MODE_POINT));continue;
         StopLossNow=OrderProfit();
         Print(OrderSymbol()+"|"+MarketInfo(OrderSymbol(),MODE_POINT)
            +"|ProfitNow: "+DoubleToStr(ProfitNow,5)
            +"|OpenAsLossPoint: "+DoubleToStr(OpenAsLossPoint,5)
            +"|StopLossNow: "+DoubleToStr(StopLossNow,5)
            +"|OrderOpenPrice: "+DoubleToStr(OrderOpenPrice(),5)
            +"|OrderStopLoss: "+DoubleToStr(OrderStopLoss(),5)
            );
         */
         //OrderPrint();
         //5个档次的止损
         double ProtectStopLoss;
         if(ProfitNow > ProfitProtectLevel_4_PipsPoint)
         {
            //Print(OrderSymbol()+"|"+ProfitNow+">"+ProfitProtectLevel_4_PipsPoint);
            ProtectStopLoss = ProfitProtectLevel_4_Pips*ProfitProtectLevel_4_Percen/10*MarketInfo(OrderSymbol(),MODE_POINT);
            if(OrderType() == OP_BUY)
            {
               if(OrderStopLoss()<OrderOpenPrice()+ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }else if(OrderType() == OP_SELL)
            {
               if(OrderStopLoss()==0||OrderStopLoss()>OrderOpenPrice()-ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }
         }else if(ProfitNow > ProfitProtectLevel_3_PipsPoint){
            //Print(OrderSymbol()+"|"+ProfitNow+">"+ProfitProtectLevel_3_PipsPoint);
            ProtectStopLoss = ProfitProtectLevel_3_Pips*ProfitProtectLevel_3_Percen/10*MarketInfo(OrderSymbol(),MODE_POINT);
            if(OrderType() == OP_BUY)
            {
               if(OrderStopLoss()<OrderOpenPrice()+ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }else if(OrderType() == OP_SELL)
            {
               if(OrderStopLoss()==0||OrderStopLoss()>OrderOpenPrice()-ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }
         }else if(ProfitNow > ProfitProtectLevel_2_PipsPoint){
            //Print(OrderSymbol()+"|"+ProfitNow+">"+ProfitProtectLevel_2_PipsPoint);
            ProtectStopLoss = ProfitProtectLevel_2_Pips*ProfitProtectLevel_2_Percen/10*MarketInfo(OrderSymbol(),MODE_POINT);
            if(OrderType() == OP_BUY)
            {
               if(OrderStopLoss()<OrderOpenPrice()+ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }else if(OrderType() == OP_SELL)
            {
               if(OrderStopLoss()==0||OrderStopLoss()>OrderOpenPrice()-ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }
            Print(GetLastError());
         }else if(ProfitNow > ProfitProtectLevel_1_PipsPoint){
            //Print(OrderSymbol()+"|"+ProfitNow+">"+ProfitProtectLevel_1_PipsPoint);
            ProtectStopLoss = ProfitProtectLevel_1_Pips*ProfitProtectLevel_1_Percen/10*MarketInfo(OrderSymbol(),MODE_POINT);
            if(OrderType() == OP_BUY)
            {
               if(OrderStopLoss()<OrderOpenPrice()+ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }else if(OrderType() == OP_SELL)
            {
               if(OrderStopLoss()==0||OrderStopLoss()>OrderOpenPrice()-ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }
            Print(GetLastError());
         }else if(ProfitNow > ProfitProtectLevel_0_PipsPoint){
            //Print(OrderSymbol()+"|"+ProfitNow+">"+ProfitProtectLevel_0_PipsPoint);
            ProtectStopLoss = ProfitProtectLevel_0_Pips*ProfitProtectLevel_0_Percen/10*MarketInfo(OrderSymbol(),MODE_POINT);
            if(OrderType() == OP_BUY)
            {
               if(OrderStopLoss()<OrderOpenPrice()+ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }else if(OrderType() == OP_SELL)
            {
               if(OrderStopLoss()==0||OrderStopLoss()>OrderOpenPrice()-ProtectStopLoss)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-ProtectStopLoss,OrderTakeProfit(),0,CLR_NONE);
               }
            }
         }else{
            
         }
         //if(OrderSymbol()=="GBPUSD") Print(OrderSymbol()+"|"+ProfitNow+"|"+ProfitProtectLevel_0_PipsPoint+"|"+ProfitProtectLevel_1_PipsPoint+"|"+ProfitProtectLevel_2_PipsPoint+"|"+ProfitProtectLevel_3_PipsPoint+"|"+ProfitProtectLevel_4_PipsPoint);
         
      }else{
         
      }
      
   }
   LastRunTime=TimeCurrent();
//----
   return(0);
  }
//+------------------------------------------------------------------+