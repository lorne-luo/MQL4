//+------------------------------------------------------------------+
//|                                                    Publisher.mq4 |
//|                                                       Greatshore |
//|                                               greatshore@live.cn |
//+------------------------------------------------------------------+
#property copyright "Greatshore"
#property link      "greatshore@live.cn"

#define GVARUP        "Publisher_UpdateTime"        // 更新时间全局变量名
#define GVARHASH      "Publisher_LastOrdersHash"    // 上一次持仓的Hash
#define DATAPATH      "Publisher\\"                 // 数据文件目录
#define VARPREFIX     "<!!-"                        // 替换变量前缀
#define VARSUFFIX     "--->"                        // 替换变量后缀
#define REALSTR       "$"                           // 显示真实值标记

//---- input parameters
extern int     UpdatePeriod   = 0;                           // 更新周期，分钟，最少5分钟，0表示持仓有变化即更新
extern int     HistoryNum     = 0;                           // 历史交易单周期数目
extern int     HistoryPeriod  = 0;                           // 历史交易单周期单位，0-个，1-天,2-周，3-月
extern bool    ShowPending    = true;                        // 是否显示挂单信息
extern int     TZOffset       = 6;                           // 服务器时区换算
extern string  TZComment      = "Beijing Time:";             // 时间标注
extern string  FTPPath        = "/forexbot";                 // 上传到服务器的目录
extern string  WebFileName    = "state.htm";                 // 上传到服务器的文件名
extern string  TemplateName   = "Publisher.template.htm";    // 发布页面使用的模版文件名
extern string  ShowAccount    = "*****";                     // 显示的账户号，$表示实际账户
extern string  ShowName       = "abui";                      // 显示的账户名，$表示实际账户名
extern string  ShowBroker     = "$";                         // 显示的公司名，$表示实际公司名
extern bool    ShowTicket     = true;                        // 是否显示订单号
extern bool    ShowOpenTime   = true;                        // 是否显示开仓时间
extern bool    ShowSize       = true;                        // 是否显示手数
extern bool    ShowTPSL       = true;                        // 是否显示获利止损价
extern bool    ShowSwap       = true;                        // 是否显示过夜利息
extern int     ShowProfitType = 2;                           // 显示获利方式：0-不显示，1-点数，2-价值
extern bool    ShowComment    = false;                       // 是否显示注释项
extern bool    ShowEquity     = true;                        // 是否显示账户净值
extern bool    ShowFreeMargin = true;                        // 是否显示自由保证金数
extern string  HiddenText     = "---";                       // 隐藏值显示字符

string OpStr[] = {"buy", "sell", "buy limit", "sell limit", "buy stop", "sell stop"};

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
  if (!ShowSize) // 如果不显示持仓手数，则隔夜利息和获利都不能显示
  {
    ShowSwap = false;
    if (ShowProfitType == 2)
      ShowProfitType = 1;
  }
  
  if ((UpdatePeriod < 5) && (UpdatePeriod > 0))
    UpdatePeriod = 5;

  return(0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
  GlobalVariableDel(GVARUP);
  GlobalVariableDel(GVARHASH);

  return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
  datetime LastUpdate, CurrentTime;
  bool NeedUpdate;
  
  CurrentTime = TimeCurrent();
  LastUpdate  = GlobalVariableGet(GVARUP);
  if (UpdatePeriod == 0)
    NeedUpdate = CheckOrderChange();
  else
    NeedUpdate = (CurrentTime - LastUpdate) / 60 >= UpdatePeriod;
  if (NeedUpdate)
  {
    GlobalVariableSet(GVARUP, CurrentTime);
    GeneratePage(DATAPATH + WebFileName);
//    Print("Updating statement finished.");
    SendFTP(DATAPATH + WebFileName, FTPPath);
    FileDelete(DATAPATH + WebFileName);
  }
  
  return(0);
}

//+------------------------------------------------------------------+

// ===== 生成持仓报告页面 =====
void GeneratePage(string FileName)
{
  int fin, fout, i, j;
  string linestr;
  
  fin  = FileOpen(DATAPATH + TemplateName, FILE_READ  | FILE_BIN);
  if (fin < 0)
    Print("Error in reading template file.");
  else
  {
    fout = FileOpen(DATAPATH + WebFileName,  FILE_WRITE | FILE_CSV, ' ');
    while (!FileIsEnding(fin))
    {
      linestr = GetOneLine(fin);
      if (StringLen(linestr) > 0)
      {
        i = StringFind(linestr, VARPREFIX);
        if (i >= 0)
          ReplaceVarStr(fout, linestr, i);
        else
          FileWrite(fout, linestr);
      }
    }
    FileClose(fin);
    FileClose(fout);
  }  
}

// ===== 从文件中读取一行 =====
string GetOneLine(int InFile)
{
  int i, j;
  string ret, char;
  
  ret = "";
  while (!FileIsEnding(InFile))
  {
    char = FileReadString(InFile, 1);
    if ((char == "\r") || (char == "\n"))
      break;
    else
      ret = ret + char;
  }
  return(ret);
}

// ===== 替换变量字符串的内容 =====
void ReplaceVarStr(int OutFile, string linestr, int start)
{
  string VarName, LeftStr, RightStr, MidStr;
  int end, i;
  
  end = StringFind(linestr, VARSUFFIX, start);
  i = start + StringLen(VARPREFIX);
  if (start > 0)
    LeftStr  = StringSubstr(linestr, 0, start);
  RightStr = StringSubstr(linestr, end + StringLen(VARSUFFIX));
  MidStr   = "";
  VarName  = StringSubstr(linestr, i, end - i);
  if (VarName == "ACCOUNTNUM")         // 账户号码
  {    
    if (ShowAccount == REALSTR)
      MidStr = AccountNumber();
    else
      MidStr = ShowAccount;
  }
  else if (VarName == "ACCOUNTNAME")   // 账户名称
  {
    if (ShowName == REALSTR)
      MidStr = AccountName();
    else
      MidStr = ShowName;
  }
  else if (VarName == "BROKER")        // 公司名
  {
    if (ShowBroker == REALSTR)
      MidStr = AccountCompany();
    else
      MidStr = ShowBroker;
  }
  else if (VarName == "CURRENCY")      // 账户货币
    MidStr = AccountCurrency();
  else if (VarName == "EQUITY")        // 账户净值
  {
    if (ShowEquity)
      MidStr = DoubleToStr(AccountEquity(), 2);
    else
      MidStr = HiddenText;
  }
  else if (VarName == "FREEMARGIN")    // 可用保证金
  {
    if (ShowFreeMargin)
      MidStr = DoubleToStr(AccountFreeMargin(), 2);
    else
      MidStr = HiddenText;
  }
  else if (VarName == "UPDATETIME")    // 更新时间
  {
    MidStr = TimeToStr(TimeCurrent());
    if ((TZOffset != 0) && (StringLen(TZComment) > 0))
    MidStr = MidStr + " [" + TZComment +  TimeToStr(TimeCurrent() + TZOffset * 3600) + "]";
  }
  else if (VarName == "HOLDINGORDERS")    // 持仓列表
    WriteHoldingOrders(OutFile);
  else if ((VarName == "PENDINGORDERS") && ShowPending)    // 挂单列表
    WritePendingOrders(OutFile);
  else
    MidStr = HiddenText;
  
  FileWrite(OutFile, LeftStr+ MidStr + RightStr);
}

// ===== 写入持仓列表 =====
void WriteHoldingOrders(int OutFile)
{
  int i, j, c, op;
  string symb;
  
  for (i = 0, c = 0; i < OrdersTotal(); i++)
  {
    OrderSelect(i, SELECT_BY_POS);
    op = OrderType();
    if (op < 2)
    {
      symb = OrderSymbol();
      c++;
      WriteLeftColums(OutFile, c, op, symb, MarketInfo(symb, MODE_DIGITS));
      WriteLeftSwapProfit(OutFile, op, symb);
      WriteLeftComment(OutFile);
      FileWrite(OutFile, "</tr>");
    }
  }
}

// ===== 写入挂单列表 =====
void WritePendingOrders(int OutFile)
{
  int i, j, c, op;
  string symb, str = "";
  datetime exp;
  
  for (i = 0, c = 0; i < OrdersTotal(); i++)
  {
    OrderSelect(i, SELECT_BY_POS);
    op = OrderType();
    if (op > 1)
    {
      symb = OrderSymbol();
      c++;
      WriteLeftColums(OutFile, c, op, symb, MarketInfo(symb, MODE_DIGITS));
      exp = OrderExpiration();  // 过期时间
      if (exp > 0)
        str = TimeToStr(exp);
      FileWrite(OutFile, "<td class=msdate nowrap>" + str + "</td>");
      WriteLeftComment(OutFile);
      FileWrite(OutFile, "</tr>");
    }
  }
}

// ===== 写入前半部分 =====
void WriteLeftColums(int OutFile, int c, int op, string symb, int d)
{
  string str, str2, fmt;
  int i;

  // 第一行，行背景色
  if (c % 2 == 1)
    str = ">";
  else
    str = " bgcolor=#E0E0E0>";
  FileWrite(OutFile, "<tr align=right" + str);
      
  // Ticket
  if (ShowTicket)
    str = OrderTicket();
  else
    str = HiddenText;
  FileWrite(OutFile, "<td>" + str + "</td>");
     
  // 开仓时间
  if (ShowOpenTime)
    str = TimeToStr(OrderOpenTime());
  else
    str = HiddenText;
  FileWrite(OutFile, "<td class=msdate nowrap>" + str + "</td>");

  // 开仓方向
  FileWrite(OutFile, "<td>" + OpStr[op] + "</td>");

  // 开仓手数
  if (ShowSize)
    str = DoubleToStr(OrderLots(), 2);
  else
    str = HiddenText;
  FileWrite(OutFile, "<td class=mspt>" + str + "</td>");

  // 交易货币对和开仓价
  FileWrite(OutFile, "<td>" + symb + "</td>");
  fmt = "<td style=\"mso-number-format:0\.";
  for (i = 0; i < d; i++)
    fmt = fmt + "0";
  FileWrite(OutFile, fmt + ";\">" + DoubleToStr(OrderOpenPrice(), d) + "</td>");

  // 获利止损价
  if (ShowTPSL)
  {
    str  = DoubleToStr(OrderTakeProfit(), d);
    str2 = DoubleToStr(OrderStopLoss(), d);
  }
  else
  {
    str  = HiddenText;
    str2 = HiddenText;
  }
  FileWrite(OutFile, fmt + ";\">" + str  + "</td>");
  FileWrite(OutFile, fmt + ";\">" + str2 + "</td>");
}

// ===== 写入利息和获利 =====
void WriteLeftSwapProfit(int OutFile, int op, string symb)
{
  double cp;
  string str;
  
  // 隔夜利息
  if (ShowSwap)
    str = DoubleToStr(OrderSwap(), 2);
  else
    str = HiddenText;
  FileWrite(OutFile, "<td class=mspt>" + str + "</td>");
  
  // 获利
  switch (ShowProfitType)
  {
    case 0 :
         str =  ">" + HiddenText;
         break;
    case 1 :
         if (op == OP_BUY)
           cp = MarketInfo(symb, MODE_BID);
         else
           cp = MarketInfo(symb, MODE_ASK);
         str = ">" + DoubleToStr((cp - OrderOpenPrice()) / MarketInfo(symb, MODE_POINT), 0) + "p";
         break;
    case 2 :
         str = " class=mspt>" + DoubleToStr(OrderProfit(), 2);
  }
  FileWrite(OutFile, "<td" + str + "</td>");
}

// ===== 写入注释 =====
void WriteLeftComment(int OutFile)
{
  string str;

  str = OrderComment();
  if (!ShowComment && (StringLen(str) > 0))
    str = HiddenText;
  FileWrite(OutFile, "<td>" + str  + "</td>");
}

// ===== 检查持仓有没有变化 =====
bool CheckOrderChange()
{
  int LastOrdersHash, CurrnetOrdersHash;
  
  LastOrdersHash    = GlobalVariableGet(GVARHASH);
  CurrnetOrdersHash = GetOrdersHash(OrdersTotal());
  if (CurrnetOrdersHash != LastOrdersHash)
  {
    GlobalVariableSet(GVARHASH, CurrnetOrdersHash);
    return(true);
  }
  else
    return(false);
}

// ===== 计算当前持仓的Hash =====
int GetOrdersHash(int OrdersCount)
{
  int Orders[][6], i, j, k, Hash;
  string OrderSymb, str;

  ArrayResize(Orders, OrdersCount);
  
  // 将持仓转化成整数
  for (i = 0; i < OrdersCount; i++)
  {
    OrderSelect(i, SELECT_BY_POS);
    OrderSymb = OrderSymbol();
    
    Orders[i][0] = OrderTicket();
    Orders[i][1] = SymbolToInt(OrderSymb);
    Orders[i][2] = OrderType();
    Orders[i][3] = OrderLots() * 100;
    Orders[i][4] = OrderOpenPrice() / MarketInfo(OrderSymb, MODE_POINT);
    Orders[i][5] = OrderSwap() * 100;
  }
  if (OrdersCount > 0)
  {
    ArraySort(Orders);
    // 计算Hash值
    for (Hash = 0, i = 0; i < OrdersCount; i++)
      for (j = 0; j < 6; j++)
      {
        str = IntToStr(Orders[i][j]);
        for (k = 0; k < 4; k++)
          Hash += (Hash << 5) + StringGetChar(str, k);
      }
  }
  
  return(Hash);
}

// ===== 把货币对转换成整形 =====
int SymbolToInt(string Symb)
{
  int i, r;
  
  for (r = 0, i = 0; i < StringLen(Symb); i++)
    r += r << 5 + StringGetChar(Symb, i);
  return(r);
}

// ===== 将整数转化场字符串 =====
string IntToStr(int num)
{
  string r = "    ";
  int i, b;
  
  for (i = 3; i >= 0; i--)
  {
    b = num & 0xFF;
    if (b == 0)
      b = 95;
    StringSetChar(r, i, b);
    num = num >> 8;
  }
  return(r);
}