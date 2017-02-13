//+------------------------------------------------------------------+
//| MaCross.mq4 |
//| Copyright ?2007, 520FX Corp. |
//| http://www.520fx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2007, 520FX Corp."
#property link "http://www.520fx.com"
#define Magic 124345
extern int Ma1=10;
extern int Ma2=30;
extern int Slip=3;
int HoldingOrderType;
int Ser;
int start()
{
   //----
   int Cnt=GetHoldingOrderCnt();
   if (Cnt<=0)//空仓
   {
      if (YesOrNo(OP_SELL))//多单入场条件
      {
         int Ticket=OrderSend(Symbol(),OP_BUY,0.1,Ask,Slip,0,0,"",Magic,0,0);//开多头新单
         if (Ticket<0)
         {
            Print(GetLastError());
            return(0);
         } 
      }else if (YesOrNo(OP_BUY))// 空单入场条件
      {
         Ticket=OrderSend(Symbol(),OP_SELL,0.1,Bid,Slip,0,0,"",Magic,0,0);//开空头新单
         if (Ticket<0)
         {
            Print(GetLastError());
            return(0);
         } 
      }else return(0);
   }else//持仓
   {
      switch(HoldingOrderType)
      {
         case OP_BUY:
         if (YesOrNo(OP_BUY))
         {
            if (OrderClose(Ser,OrderLots(),Bid,Slip,CLR_NONE))
            {
               return(0);
            }else
            {
               Print(GetLastError());
               return(0);
            }
         }
         break;
      case OP_SELL:
            if (YesOrNo(OP_SELL))
            {
               if (OrderClose(Ser,OrderLots(),Ask,Slip,CLR_NONE))
               {
               return(0);
               }else
               {
                  Print(GetLastError());
                  return(0);
               }
            }
            break;
         }
      }
   //----
   return(0);
}
//+------------------------------------------------------------------+
int GetHoldingOrderCnt()
{
   int j=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
      {
         j=j+1;
         HoldingOrderType=OrderType();
         Ser=OrderTicket();
      }
   } 
   return(j);
}
//========================
bool YesOrNo(int Type)
{
   double Ma1Data=iMA(NULL,0,Ma1,0,MODE_SMA,PRICE_CLOSE,1);
   double Ma1Data1=iMA(NULL,0,Ma1,0,MODE_SMA,PRICE_CLOSE,2); 
   double Ma2Data=iMA(NULL,0,Ma2,0,MODE_SMA,PRICE_CLOSE,1);
   double Ma2Data1=iMA(NULL,0,Ma2,0,MODE_SMA,PRICE_CLOSE,2);
   switch(Type)
   {
      case OP_BUY:
         if (Ma1Data1>Ma2Data1 && Ma1Data<Ma2Data)
         {
            return(true);
         }else return(false);
      break;
      case OP_SELL:
         if (Ma1Data1<Ma2Data1 && Ma1Data>Ma2Data)
         {
            return(true);
         }else return(false);
      break;
   } 
}

