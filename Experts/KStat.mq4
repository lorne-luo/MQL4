//+------------------------------------------------------------------+
//|                                                        KStat.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
extern double n=365;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   double up;
   double down;
   double high;
   double low;
   double updown;
   double closeopen;
   double profit;
   double tail;
   double count=0;
   
   int in10;
   int in1020;
   int in2030;
   int in3040;
   int in4050;
   int in5060;
   int in6070;
   int in7080;
   int in8090;
   int in90100;
   int in100110;int in110;
   int tailbelow;
   
   int trend;int reverse;
   
   for (int i = 1; i < n ; i++)
   {
      
      
      if(Open[i]>Close[i])//Пежљ
      {
         high=Open[i];
         low=Close[i];
         profit=Open[i]-Low[i];
         tail+=High[i]-Open[i];
         if(Open[i+1]>Close[i+1])
            trend++;
         else 
            reverse++;
      }
      else
      {
         high=Close[i];
         low=Open[i];
         profit=High[i]-Open[i];
         tail+=Open[i]-Low[i];
         if(Open[i+1]<Close[i+1])
            trend++;
         else 
            reverse++;
      }
      
      
      profit=profit*10000;
      
      if(profit<10)
         in10++;
      else if(profit>10&&profit<20)
         in1020++;
      else if(profit>20&&profit<30)
         in2030++;
      else if(profit>30&&profit<40)
         in3040++;
      else if(profit>40&&profit<50)
         in4050++;
      else if(profit>50&&profit<60)
         in5060++;
      else if(profit>60&&profit<70)
         in6070++;
      else if(profit>70&&profit<80)
         in7080++;
      else if(profit>80&&profit<90)
         in8090++;
      else if(profit>90&&profit<100)
         in90100++;
      else if(profit>100&&profit<110)
         in100110++;
      else if(profit>110)
         in110++;

      up+=High[i]-high;
      down+=low-Low[i];
      updown+=High[i]-Low[i];
      closeopen+=MathAbs(Close[i]-Open[i]);
      count++;
   }
   Comment("Up:"+up/count+"\nDown:"+down/count+"\nupdown:"+updown/count+"\ncloseopen:"+closeopen/count);
   Print("10-:"+in10+"|10+:"+in1020*0+"|20+:"+in2030+"|30+:"+in3040+"|40+:"+in4050+"|50+:"+in5060+"|60+:"+in6070+"|70+:"+in7080+"|80+:"+in8090+"|90+:"+in90100+"|100+:"+in100110+"|110+:"+in110);
   Print("tail:"+tail/count);
   
   int stop=30;
   count=count-in10;
   Print("10:"+count*10+"|"+(count*10-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=count-in1020;
   Print("20:"+count*20+"|"+(count*20-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=count-in2030;
   Print("30:"+count*30+"|"+(count*30-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=count-in3040;
   Print("40:"+count*40+"|"+(count*40-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=count-in4050;
   Print("50:"+count*50+"|"+(count*50-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=count-in5060;
   Print("60:"+count*60+"|"+(count*60-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=count-in6070;
   Print("70:"+count*70+"|"+(count*70-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=count-in7080;
   Print("80:"+count*80+"|"+(count*80-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=count-in8090;
   Print("90:"+count*90+"|"+(count*90-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=count-in90100;
   Print("100:"+count*100+"|"+(count*100-(n-count)*stop)+"       |"+(n-count)+"|"+NormalizeDouble((count)*100/n,4));
   count=in110;
   Print("110:"+count*110+"|"+(count*110-(n-in110)*stop)+"       |"+(n-in110)+"|"+NormalizeDouble((in110)*100/n,4));
   
   
   Print("trend:reverse  "+trend+":"+reverse);
   
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
   
//----
   return(0);
  }
//+------------------------------------------------------------------+