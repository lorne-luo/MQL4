//+------------------------------------------------------------------+
//|                                                  PriceGetter.mq4 |
//|                       Copyright ?2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern int  Interval        = 30; 
extern string  FTPPath        = "/public_html/forex/"; 
extern string  FileName    = "price2.xml";


string SymbolList[] = {"EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};

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
   GenFile(FileName);
   SendFTP(FileName, FTPPath);
   Sleep(Interval*1000);
//----
   return(0);
  }
//+------------------------------------------------------------------+

void GenFile(string fname)
{
   double d;
   string str="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Rates>\n";
   for (int i = 0; i < ArraySize(SymbolList); i++)
   {
      str=str+"\t<Rate Symbol=\""+SymbolList[i]+"\">\n";
      str=str+"\t\t<Ask>"+MarketInfo(SymbolList[i], MODE_ASK)+"</Ask>\n";
      str=str+"\t\t<Bid>"+MarketInfo(SymbolList[i], MODE_BID)+"</Bid>\n";
      str=str+"\t</Rate>\n";
   }//
   str=str+"</Rates>\n";
   int fout = FileOpen(fname,  FILE_WRITE | FILE_CSV, ' ');
   FileWrite(fout, str);
   FileClose(fout);
   
}