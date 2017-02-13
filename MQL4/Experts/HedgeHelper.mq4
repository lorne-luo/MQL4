//+------------------------------------------------------------------+
//|                                                  HedgeHelper.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#import "AutoOrder.dll"
string httpGET(string a0, int& a1[]);
   
#define SellMagic 20110221
#define BuyMagic 20110220

extern bool EAEnabled = true;//是否开启本辅助EA
extern double TakeProfit = 120;//对冲盈利多少点平仓
extern double StopLoss = 100;//对冲止损多少点平仓
extern double TrailingStop = 50;//跟踪止损的步进点数,盈利TrailingStop点则设置平损
extern double Lot = 0.1;
extern int Slip=3;
extern int Interval=120;

double MaxBuyProfit;
double MaxBuyLoss;
double MaxSellProfit;
double MaxSellLoss;
string CommentStr;
double BuyProfit;
double SellProfit;
double TakeProfitPoint;
double TrailingStopLoss;
color BuyColor=Red;
color SellColor=Lime;

string BuyComment = "HedgeBuy";
string SellComment = "HedgeSell";
string SymbolList[7]={"GBPUSD","EURGBP","USDCHF","EURCHF","USDCAD","AUDUSD","EURUSD"};
string Orderid="";
int OrderNum;
int HedgeType;
string OpenUrl="http://leandro.132.china123.net/dghelper/forexorders";
string CheckUrl="http://leandro.132.china123.net/dghelper/forexorders/checkorder/";

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   TakeProfitPoint=TakeProfit;
   TrailingStopLoss=0-StopLoss;
   
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderSymbol()!="EURUSD") continue;
         if(OrderMagicNumber()==BuyMagic)
         {
            Orderid=OrderTicket();
            HedgeType=OP_BUY;
         }else if(OrderMagicNumber()==SellMagic)
         {
            Orderid=OrderTicket();
            HedgeType=OP_SELL;
         }
      }
   }
   
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
   Sleep(Interval*1000);
   if(!EAEnabled) return(0);
   OrderNum=0;
   BuyProfit=0;
   SellProfit=0;
   CommentStr="";
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==BuyMagic)
         {
            BuyProfit=BuyProfit+OrderProfit()/OrderLots()/10;
            HedgeType=OP_BUY;
            OrderNum++;
         }else if(OrderMagicNumber()==SellMagic)
         {
            SellProfit=SellProfit+OrderProfit()/OrderLots()/10;
            HedgeType=OP_SELL;
            OrderNum++;
         }
      }
   }
   int para[2];
   string data;
   if(OrderNum>0&&Orderid!="")//本地有单，检查是否平单
   {
      data=httpGET(CheckUrl+Orderid, para);
      Print("CheckUrl+"+Orderid+"="+data);
      if(data=="00"){
         if(HedgeType==OP_BUY) OrderCloseNow(BuyMagic,HedgeType);
         else OrderCloseNow(SellMagic,HedgeType);
         Orderid="";
         OrderNum=0;
      }
      
   }else if(OrderNum==0 && Orderid==""){//本地无单，检查是否开单
      Orderid="";
      data=httpGET(OpenUrl, para);
      Print("OpenUrl="+data);
      int mid=StringFind(data,"|",0);
      if(data!="1" && mid!=-1){//有单
         string id=StringSubstr(data,0,mid);
         string type=StringSubstr(data,mid+1,StringLen(data)-mid);
         if(type=="1"){
            OpenOrder(OP_BUY);
            Orderid=id;
            HedgeType=OP_BUY;
         }else if(type=="0"){
            OpenOrder(OP_SELL);
            Orderid=id;
            HedgeType=OP_SELL;
         }
         return;
      }
   }
   
   int index=BuyProfit/TrailingStopLoss;
   if(index>0&&TrailingStopLoss<(index-1)*TrailingStopLoss) TrailingStopLoss=(index-1)*TrailingStopLoss;
   if(BuyProfit>MaxBuyProfit) MaxBuyProfit=BuyProfit;
   if(BuyProfit<MaxBuyLoss) MaxBuyLoss=BuyProfit;
   if(SellProfit>MaxSellProfit) MaxSellProfit=SellProfit;
   if(SellProfit<MaxSellLoss) MaxSellLoss=SellProfit;
   /*
   //止损
   if(BuyProfit<0-StopLoss)
   {
      OrderCloseNow(BuyMagic,OP_BUY);
      BuyProfit=0;MaxBuyProfit=0;MaxBuyLoss=0;
   }
   if(SellProfit<0-StopLoss)
   {
      OrderCloseNow(SellMagic,OP_SELL);
      SellProfit=0;MaxSellProfit=0;MaxSellLoss=0;
   }
   
    
   //止盈、跟踪止损
   if(BuyProfit>TakeProfitPoint)
   {
      Alert("BuyProfit:"+DoubleToStr(BuyProfit,2)+" > TakeProfitPoint:"+TakeProfitPoint+",CloseOrder");
      OrderCloseNow(BuyMagic,OP_BUY);
      BuyProfit=0;MaxBuyProfit=0;MaxBuyLoss=0;
   }
   else if(BuyProfit<TrailingStopLoss)
   {
      Alert("BuyProfit:"+DoubleToStr(BuyProfit,2)+" < TrailingStopLoss:"+TrailingStopLoss+",CloseOrder");
      OrderCloseNow(BuyMagic,OP_BUY);
      BuyProfit=0;MaxBuyProfit=0;MaxBuyLoss=0;
   }
   
   if(SellProfit>TakeProfitPoint)
   {
      Alert("SellProfit:"+DoubleToStr(SellProfit,2)+" > TakeProfitPoint:"+TakeProfitPoint+",CloseOrder");
      OrderCloseNow(SellMagic,OP_SELL);
      SellProfit=0;MaxSellProfit=0;MaxSellLoss=0;
   }
   else if(SellProfit<TrailingStopLoss)
   {
      Alert("SellProfit:"+DoubleToStr(SellProfit,2)+" < TrailingStopLoss:"+TrailingStopLoss+",CloseOrder");
      OrderCloseNow(SellMagic,OP_SELL);
      SellProfit=0;MaxSellProfit=0;MaxSellLoss=0;
   }
   */
   //无单
   if(OrderNum==0)
   {
      CommentStr=CommentStr+"No Hedge Order"+"\n";
      MaxBuyProfit=0;
      MaxBuyLoss=0;
      MaxSellProfit=0;
      MaxSellLoss=0;
      TakeProfitPoint=TakeProfit;
      TrailingStopLoss=0-StopLoss;
      Comment(CommentStr);
      return;
   }
   
   CommentStr=CommentStr+"OrderID="+Orderid+" OrderNum="+OrderNum+" HedgeType="+HedgeType+"\n";
   
   //有单
   if(BuyProfit!=0)
   {
      CommentStr=CommentStr+"MaxBuyProfit="+DoubleToStr(MaxBuyProfit,2)+" MaxBuyLoss="+DoubleToStr(MaxBuyLoss,2)+"\n";
      CommentStr=CommentStr+"BuyProfit="+DoubleToStr(BuyProfit,2)+"\n";
      CommentStr=CommentStr+"TakeProfitPoint="+DoubleToStr(TakeProfitPoint,2)+"\n";
      CommentStr=CommentStr+"TrailingStopLoss="+DoubleToStr(TrailingStopLoss,2)+"\n";
   }
   if(SellProfit!=0)
   {
      CommentStr=CommentStr+"MaxSellProfit="+DoubleToStr(MaxSellProfit,2)+" MaxSellLoss="+DoubleToStr(MaxSellLoss,2)+"\n";
      CommentStr=CommentStr+"SellProfit: "+DoubleToStr(SellProfit,2)+"\n";
      CommentStr=CommentStr+"TakeProfitPoint: "+DoubleToStr(TakeProfitPoint,2)+"\n";
      CommentStr=CommentStr+"TrailingStopLoss: "+DoubleToStr(TrailingStopLoss,2)+"\n";
   }
   Comment(CommentStr);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//平单
int OrderCloseNow(int magic,int ordertype)
{
   int cnt=0;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic)
         {
            RefreshRates();
            if(OrderType()==OP_BUY && ordertype==OP_BUY)//多单
            {
               bool b;
               b=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(), MODE_BID),Slip,BuyColor);
               Sleep(200);
               if(!b)Print("平多单失败");
               cnt++;
            }   
            else if (OrderType()==OP_SELL && ordertype==OP_SELL)//空单
            {
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(), MODE_ASK),Slip,SellColor);
               Sleep(200);
               if(!b)Print("平空单失败");
               cnt++;
            }   
         }
      }
   }
   return(cnt);
}

bool OpenOrder(int cmd)
{
   int mode;
   int magic;
   color c;
   string comment;
   if(cmd==OP_BUY){
      mode=MODE_ASK;
      magic=BuyMagic;
      c=BuyColor;
      comment=BuyComment;
   }else{
      mode=MODE_BID;
      magic=SellMagic;
      c=SellColor;
      comment=SellComment;
   }

   int ticket;
   for (int i = 0; i < ArraySize(SymbolList); i++)
   {
      ticket=-1;
      for (int j = 0; j < 3; j++)
      {
         RefreshRates();
         ticket=OrderSend(SymbolList[i],cmd, Lot, MarketInfo(SymbolList[i],mode), Slip, NULL, NULL, comment, magic, 0, c);Sleep(200);
         if(ticket<0)
            continue;
         else if (j==2)
         {
            Alert("开单操作失败");
            return(false);
         }else break;
      }
   }
   return(true);
}
      /*
      for (int j = OrdersTotal()-1; j >= 0 ; j--)
      {
         if(OrderSelect(j,SELECT_BY_POS))
         {
            if(OrderMagicNumber()==BuyMagic)
            {
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),Slip,CLR_NONE);
               Sleep(500);
            }
         }
      }
      */