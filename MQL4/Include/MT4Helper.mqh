//+------------------------------------------------------------------+
//|                                                 TradeContext.mq4 |
//|                                                        komposter |
//|                                             komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "komposter"
#property link      "komposterius@mail.ru"

//¿˚»Û±£ª§
bool ProfitProtect(string  myType)
{
   if(OrderCount < BeginProtectPositions) 
     return(false);
     
//  profit protect level 5
   if(MaxOrderProfitPips >= ProfitProtectLevel_5_Pips) 
   { if(OrderProfitPips < NormalizeDouble(MaxOrderProfitPips * (ProfitProtectLevel_5_Percen /100),0))
     {
        CloseOrders(OP_SELL,myType);
        CloseOrders(OP_BUY,myType);
        Print("Order protected ",ProfitProtectLevel_5_Percen," MaxOrderProfitPips ",MaxOrderProfitPips," now " ,OrderProfitPips);
        return(true);
     } else return(false);
   } else

//  profit protect level 4
   if(MaxOrderProfitPips >= ProfitProtectLevel_4_Pips) 
   { if(OrderProfitPips < NormalizeDouble(MaxOrderProfitPips * (ProfitProtectLevel_4_Percen /100),0))
     {
        CloseOrders(OP_SELL,myType);
        CloseOrders(OP_BUY,myType);
        Print("Order protected ",ProfitProtectLevel_4_Percen," MaxOrderProfitPips ",MaxOrderProfitPips," now " ,OrderProfitPips);
        return(true);
     } else return(false);
   } else

//  profit protect level 3
   if(MaxOrderProfitPips >= ProfitProtectLevel_3_Pips) 
   { if(OrderProfitPips < NormalizeDouble(MaxOrderProfitPips * (ProfitProtectLevel_3_Percen /100),0))
     {
        CloseOrders(OP_SELL,myType);
        CloseOrders(OP_BUY,myType);
        Print("Order protected ",ProfitProtectLevel_3_Percen," MaxOrderProfitPips ",MaxOrderProfitPips," now " ,OrderProfitPips);
        return(true);
     } else return(false);
   }  else

//  profit protect level 2
   if(MaxOrderProfitPips >= ProfitProtectLevel_2_Pips) 
   { if(OrderProfitPips < NormalizeDouble(MaxOrderProfitPips * (ProfitProtectLevel_2_Percen /100),0))
     {
        CloseOrders(OP_SELL,myType);
        CloseOrders(OP_BUY,myType);
        Print("Order protected ",ProfitProtectLevel_2_Percen," MaxOrderProfitPips ",MaxOrderProfitPips," now " ,OrderProfitPips);
        return(true);
     } else return(false);
   }  else

//  profit protect level 1
   if(MaxOrderProfitPips >= ProfitProtectLevel_1_Pips) 
   { if(OrderProfitPips < NormalizeDouble(MaxOrderProfitPips * (ProfitProtectLevel_1_Percen /100),0))
     {
        CloseOrders(OP_SELL,myType);
        CloseOrders(OP_BUY,myType);
        Print("Order protected ",ProfitProtectLevel_1_Percen," MaxOrderProfitPips ",MaxOrderProfitPips," now " ,OrderProfitPips);
        return(true);
     } 
   }  else

//  profit protect level 0   
   if(MaxOrderProfitPips >= ProfitProtectLevel_0_Pips) 
   { if(OrderProfitPips < NormalizeDouble(MaxOrderProfitPips * (ProfitProtectLevel_0_Percen /100),0))
     {
        CloseOrders(OP_SELL,myType);
        CloseOrders(OP_BUY,myType);
        Print("Order protected ",ProfitProtectLevel_0_Percen," MaxOrderProfitPips ",MaxOrderProfitPips," now " ,OrderProfitPips);
        return(true);
     } else return(false);
   }  

  return(false);

}  // end PositionsProtection