/*
   Generated by EX4-TO-MQ4 decompiler V4.0.224.1 []
   Website: http://purebeam.biz
   E-mail : purebeam@gmail.com
*/
#property copyright "zx815@126.com"
#property link      "zx815@126.com"

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 1.0
#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Aqua
#property indicator_color4 Gold
#property indicator_color5 Aqua
#property indicator_color6 Gold
#property indicator_color7 Aqua
#property indicator_color8 Gold

extern int FasterMA = 5;
extern int SlowerMA = 15;
extern int MA1_Type = 1;
extern int MA2_Type = 1;
extern int MACD_Fast = 8;
extern int MACD_Slow = 17;
extern int MACD_Signal = 9;
extern int RSI = 14;
extern int Momentum = 14;
extern int DeMarker = 14;
extern int ADX = 14;
extern int ForceIndex = 14;
double g_ibuf_124[];
double g_ibuf_128[];
double g_ibuf_132[];
double g_ibuf_136[];
double g_ibuf_140[];
double g_ibuf_144[];
double g_ibuf_148[];
double g_ibuf_152[];

int init() {
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 119);
   SetIndexBuffer(0, g_ibuf_124);
   SetIndexEmptyValue(0, 0);
   
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 119);
   SetIndexBuffer(1, g_ibuf_128);
   SetIndexEmptyValue(1, 0);
   
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, SYMBOL_STOPSIGN);
   SetIndexBuffer(2, g_ibuf_132);
   SetIndexEmptyValue(2, 0);
   
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, SYMBOL_STOPSIGN);
   SetIndexBuffer(3, g_ibuf_136);
   SetIndexEmptyValue(3, 0);
   
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 110);
   SetIndexBuffer(4, g_ibuf_140);
   SetIndexEmptyValue(4, 0);
   
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(5, 110);
   SetIndexBuffer(5, g_ibuf_144);
   SetIndexEmptyValue(5, 0);
   
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(6, SYMBOL_ARROWUP);
   SetIndexBuffer(6, g_ibuf_148);
   SetIndexEmptyValue(6, 0);
   
   SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(7, SYMBOL_ARROWDOWN);
   SetIndexBuffer(7, g_ibuf_152);
   SetIndexEmptyValue(7, 0);
   
   IndicatorShortName("Golden Varitey");
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double l_ima_12;
   double l_ima_20;
   double l_ima_28;
   double l_ima_36;
   double l_ima_44;
   double l_ima_52;
   double l_imacd_60;
   double l_imacd_68;
   double l_iadx_76;
   double l_iadx_84;
   double l_irsi_92;
   double l_idemarker_100;
   double l_imomentum_108;
   double l_iforce_116;
   int li_0 = IndicatorCounted();
   if (li_0 < 0) return (-1);
   if (li_0 > 0) li_0--;
   int li_8 = Bars - li_0;
   for (int li_4 = li_8 - 1; li_4 >= 0; li_4--) {
      l_ima_12 = iMA(NULL, 0, FasterMA, 0, MA1_Type, PRICE_CLOSE, li_4);
      l_ima_20 = iMA(NULL, 0, FasterMA, 0, MA1_Type, PRICE_CLOSE, li_4 + 1);
      l_ima_28 = iMA(NULL, 0, FasterMA, 0, MA1_Type, PRICE_CLOSE, li_4 - 1);
      l_ima_36 = iMA(NULL, 0, SlowerMA, 0, MA2_Type, PRICE_CLOSE, li_4);
      l_ima_44 = iMA(NULL, 0, SlowerMA, 0, MA2_Type, PRICE_CLOSE, li_4 + 1);
      l_ima_52 = iMA(NULL, 0, SlowerMA, 0, MA2_Type, PRICE_CLOSE, li_4 - 1);
      l_imacd_60 = iMACD(Symbol(), Period(), MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE, MODE_MAIN, li_4);
      l_imacd_68 = iMACD(Symbol(), Period(), MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE, MODE_SIGNAL, li_4);
      l_iadx_76 = iADX(NULL, 0, ADX, PRICE_CLOSE, MODE_PLUSDI, li_4);
      l_iadx_84 = iADX(NULL, 0, ADX, PRICE_CLOSE, MODE_MINUSDI, li_4);
      l_irsi_92 = iRSI(NULL, 0, RSI, PRICE_CLOSE, li_4);
      l_idemarker_100 = iDeMarker(NULL, 0, DeMarker, li_4);
      l_imomentum_108 = iMomentum(NULL, 0, Momentum, PRICE_CLOSE, li_4);
      l_iforce_116 = iForce(NULL, 0, ForceIndex, MODE_EMA, PRICE_CLOSE, li_4);
      if (l_imomentum_108 > 100.0) g_ibuf_124[li_4] = 0.05;//Momentum14>100
      if (l_imomentum_108 <= 100.0) g_ibuf_128[li_4] = 0.05;//Momentum14<100
      if (l_idemarker_100 > 0.5 && l_iforce_116 > 0.0) g_ibuf_140[li_4] = 0.22;//DeMarker14>50 Force14>0
      if (l_idemarker_100 < 0.5 && l_iforce_116 < 0.0) g_ibuf_144[li_4] = 0.22;//DeMarker14<50 Force14<0
      if (l_irsi_92 > 50.0 && l_imacd_60 > l_imacd_68 && l_iadx_76 > l_iadx_84) g_ibuf_132[li_4] = 0.47;//RSI14>50 MACD8179 histogram>signal ADX +DI>-DI
      if (l_irsi_92 < 50.0 && l_imacd_60 < l_imacd_68 && l_iadx_76 < l_iadx_84) g_ibuf_136[li_4] = 0.47;//RSI14<50 MACD8179 histogram<signal ADX +DI<-DI
      if (l_ima_12 > l_ima_36 && l_ima_20 < l_ima_44 && l_ima_28 > l_ima_52) g_ibuf_148[li_4] = 0.8;//EMA5 up cross EMA15
      if (l_ima_12 < l_ima_36 && l_ima_20 > l_ima_44 && l_ima_28 < l_ima_52) g_ibuf_152[li_4] = 0.8;//EMA5 down cross EMA15
   }
   return (0);
}