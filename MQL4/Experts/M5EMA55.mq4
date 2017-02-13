//+------------------------------------------------------------------+
//|                                                      M5EMA55.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#define Magic 54199
extern int MaValue=55;
extern int Timeframe=PERIOD_M5;
extern int Slip=4;//滑点偏移点数
extern double Lot=0.1;
extern int TakeProfit = 11;  //默认止盈点数 
extern int StopLoss = 30;  //止损点数
extern int TrailingStop = 5;//跟踪止损点数
extern int       MaxOrder=2;
extern int       FastEMA=12;
extern int       SlowEMA=26;
extern int       SignalSMA=9;

extern bool       IsDebug=false;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
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
   if(OrdersTotal()>=MaxOrder||!IsTradeAllowed() ) return(0);
   double StopLossPoint=StopLoss*10*Point;
   double TakeProfitPoint=TakeProfit*10*Point;
   
   double Macd=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,0)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,0);//Silver  iMAOnArray(ExtSilverBuffer,Bars,SignalSMA,0,MODE_SMA,i);
   double MaNow=iMA(Symbol(),Timeframe,MaValue,0,MODE_EMA,PRICE_CLOSE,0);
   
   //double openNew=Open[0];
   //double openOld=Open[1];
   double array1[][6];
   ArrayCopyRates(array1,Symbol(), Timeframe);
   
   double openNew=array1[0][4];
   double openOld=array1[0][1];
   
   int Ticket=0;
   if(((openNew>MaNow)&&(openOld<MaNow)&&Macd<0))//做空
   {
      Ticket=OrderSend(Symbol(),OP_SELL,Lot,Bid,Slip,0,0,"M5-EMA55",Magic,0,0);//多单入场
      if (Ticket<0)
      {
         return(0);
      }else if(Ticket>0){
         if(OrderSelect(Ticket, SELECT_BY_TICKET))
         {
            if(OrderModify(Ticket,OrderOpenPrice(),OrderOpenPrice()+StopLossPoint,OrderOpenPrice()-TakeProfitPoint,0,CLR_NONE))
               Print("Modify Order #"+Ticket+" SL "+(OrderOpenPrice()+StopLossPoint)+" TP "+(OrderOpenPrice()-TakeProfitPoint));
         }
         Print("     #"+Ticket+":Sell "+Lot+" "+Symbol()+ " at"+ Bid+" SL "+(Bid+StopLossPoint)+" TP "+(Bid-TakeProfitPoint) );
         Alert("#"+Ticket+":Sell "+Lot+" "+Symbol()+ " at"+ Bid+" SL "+(Bid+StopLossPoint)+" TP "+(Bid-TakeProfitPoint));
      }
     
   }else if((openNew<MaNow)&&(openOld>MaNow)&&Macd>0)//做多
   {
      Ticket=OrderSend(Symbol(),OP_BUY,Lot,Ask,Slip,0,0,"M5-EMA55",Magic,0,0);//多单入场
      if (Ticket<0)
      {
         return(0);
      }else if(Ticket>0){
         if(OrderSelect(Ticket, SELECT_BY_TICKET))
         {
            if(OrderModify(Ticket,OrderOpenPrice(),OrderOpenPrice()-StopLossPoint,OrderOpenPrice()+TakeProfitPoint,0,CLR_NONE))
               Print("Modify Order #"+Ticket+" SL "+(OrderOpenPrice()-StopLossPoint)+" TP "+(OrderOpenPrice()+TakeProfitPoint));
         }
         Print("     #"+Ticket+":Buy "+Lot+" "+Symbol()+ " at"+ Ask+" SL "+(Ask-StopLossPoint)+" TP "+(Ask+TakeProfitPoint) );
         Alert("#"+Ticket+":Buy "+Lot+" "+Symbol()+ " at"+ Ask+" SL "+(Ask-StopLossPoint)+" TP "+(Ask+TakeProfitPoint) );
      }
   }
   if(IsDebug)
   {
      Print(openNew+"|"+MaNow+"|"+openOld+"|"+Macd+"|"+GetLastError());
   }
   

   
//----
   return(0);
  }
//+------------------------------------------------------------------+