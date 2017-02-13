//+------------------------------------------------------------------+
//|                                                 TradeContext.mq4 |
//|                                                        komposter |
//|                                             komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "komposter"
#property link      "komposterius@mail.ru"


extern int StopLoss = 20;  //止损点数
extern double TakeProfit = 130;
extern double Lot=0.1;
extern int TrailingStop = 20;//跟踪止损点数
extern int Slip=3;

string comment="DefaultEA";

color buyColor=Red;
color sellColor=Lime;


//+------------------------------开仓条件部分------------------------------------+
//返回现有（特定magic）订单数量
int GetExistOrder(int magic)
{
int result;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic) result++;
      }
   }
   return(result);
}
//+------------------------------//开仓条件部分------------------------------------+

//+------------------------------时间管理部分------------------------------------+



//+------------------------------//时间管理部分------------------------------------+

//+------------------------------下单操作部分------------------------------------+
//先下单再修改止损止盈
int OpenOrderNow(string symbol,int orderType,double lot,int slip,int stopPoint,int profitPoint,string comment,int magic,color c)
{
   int ticket;
   RefreshRates();
   if(orderType==OP_BUY)
      ticket=OrderSend(Symbol(),orderType,lot,Ask,slip,0,0,comment,magic,0,c);
   else if(orderType==1)
      ticket=OrderSend(Symbol(),orderType,lot,Bid,slip,0,0,comment,magic,0,c);

   if (ticket<0)
   {
      Alert("OrderSend failed:"+GetLastError());
      return(0);
   }else if(ticket>0){
      if(OrderSelect(ticket, SELECT_BY_TICKET))
      {
         double point=MarketInfo(OrderSymbol(),MODE_POINT);
         double StopLossPrice;
         double TakeProfitPrice;
         if(stopPoint==0)
            StopLossPrice=0;
         else if(stopPoint>0)
         {
            if(orderType==0)
            {
               StopLossPrice=OrderOpenPrice()-stopPoint*10*point;
            }
            else if(orderType==1)
            {
               StopLossPrice=OrderOpenPrice()+stopPoint*10*point;
            }
         }
         if(profitPoint==0)
            TakeProfitPrice=0;
         else if(profitPoint>0)
         {
            if(orderType==0)
            {
               TakeProfitPrice=OrderOpenPrice()+profitPoint*10*point;
            }else if(orderType==1)
            {
               TakeProfitPrice=OrderOpenPrice()-profitPoint*10*point;
            }
         }
            
         if(!OrderModify(ticket,OrderOpenPrice(),StopLossPrice,TakeProfitPrice,0,c))
            Alert("OrderModify failed:"+GetLastError());
      }
   }
}


//平仓
int OrderCloseNow(int magic,int ordertype)
{
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic)
         {
            if(OrderType()==OP_BUY && ordertype==OP_BUY)//多单
               OrderClose(OrderTicket(),OrderLots(),Bid,Slip,buyColor);
               
            else if (OrderType()==OP_SELL && ordertype==OP_SELL)//空单
               OrderClose(OrderTicket(),OrderLots(),Ask,Slip,sellColor);
         }
      }
   }
}



//+------------------------------//下单操作部分------------------------------------+



//+------------------------------常用指标部分------------------------------------+
 
/*
均线交叉
-10死叉
-7下行加强
-3下行减弱
10金叉
7上行加强
3下行减弱
*/
int CheckMACross(string symbol,int timeframe,int period1,int period2,int mode,int shift)
{
   double Ma1latter=iMA(symbol,timeframe,period1,0,mode,PRICE_CLOSE,1+shift);
   double Ma1former=iMA(symbol,timeframe,period1,0,mode,PRICE_CLOSE,2+shift); 
   double Ma2latter=iMA(symbol,timeframe,period2,0,mode,PRICE_CLOSE,1+shift);
   double Ma2former=iMA(symbol,timeframe,period2,0,mode,PRICE_CLOSE,2+shift);
 
   if (Ma1former>Ma2former && Ma1latter<Ma2latter)//死叉
   {
      return(-10);
   }
   if (Ma1former<Ma2former && Ma1latter>Ma2latter)//金叉
   {
      return(10);
   }
   if (Ma1former>Ma2former && Ma1latter>Ma2latter)//上升趋势
   {
      if(Ma1latter-Ma2latter>Ma1former-Ma2former)
         return(7);
      else
         return(3);
   }
   if (Ma1former<Ma2former && Ma1latter<Ma2latter)//下降趋势
   {
      if(Ma2latter-Ma1latter>Ma2former-Ma1former)
         return(-7);
      else
         return(-3);
   }
   return(0);
}

/*
MACD交叉
-10死叉
-7低位死叉
-5下行增强
-3下行减弱
10金叉
7高位金叉
5上行增强
3上行减弱
*/
int CheckMACDCross(string symbol,int timeframe,int shift)
{
   int fastEMA=12;
   int slowEMA=26;
   int signalSMA=9;
   double     ind_buffer1[];
   double     ind_buffer2[];
   for(int i=0; i<50; i++)
      ind_buffer1[i]=iMA(symbol,timeframe,fastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(symbol,timeframe,slowEMA,0,MODE_EMA,PRICE_CLOSE,i);
   for(i=0; i<50; i++)
      ind_buffer2[i]=iMAOnArray(ind_buffer1,Bars,signalSMA,0,MODE_SMA,i);
   //buffer1快线
   //buffer2慢线
   if(ind_buffer1[0+shift]>ind_buffer2[0+shift] && ind_buffer1[1+shift]<ind_buffer2[1+shift])//MACD金叉
   {
      if(ind_buffer2[0]<0)//慢线处在0下方
         return(10);
      else
         return(7);
   }
   if(ind_buffer1[0+shift]<ind_buffer2[0+shift] && ind_buffer1[1+shift]>ind_buffer2[1+shift])//MACD死叉
   {
      if(ind_buffer2[0]>0)//慢线处在0上方
         return(-10);
      else
         return(-7);
   }
   if(ind_buffer1[0+shift]>ind_buffer2[0+shift] && ind_buffer1[1+shift]>ind_buffer2[1+shift])//上升趋势
   {
      if(ind_buffer1[0+shift]-ind_buffer2[0+shift] > ind_buffer1[1+shift]-ind_buffer2[1+shift])//上升加强
         return(5);
      else//上升减弱
         return(3);
   }
   if(ind_buffer1[0+shift]<ind_buffer2[0+shift] && ind_buffer1[1+shift]<ind_buffer2[1+shift])//下降趋势
   {
      if(ind_buffer2[0+shift]-ind_buffer1[0+shift] > ind_buffer2[1+shift]-ind_buffer1[1+shift])//下降加强
         return(-5);
      else//下降减弱
         return(-3);
   }
   return(0);
}
 
/*
价格穿越均线  
10上穿 
-10下穿
*/
int PriceCrossMA(string symbol,int timeframe,int maperiod,int mode,int shift)
{
   double ma=iMA(symbol,timeframe,maperiod,0,mode,PRICE_CLOSE,1+shift);
   double array1[][6];
   ArrayCopyRates(array1,symbol, timeframe);
   
   double latteropen=array1[0+shift][1];
   double formerclose=array1[1+shift][1];
   
   if((latteropen<ma)&&(formerclose>ma))//下穿均线
      return(-10);
   if((latteropen>ma)&&(formerclose<ma))//上穿均线
      return(10);
   return(0);
}

//+------------------------------//常用指标部分------------------------------------+


