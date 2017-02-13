//+------------------------------------------------------------------+
//|                                             PauseBeforeTrade.mq4 |
//|                       Copyright ?2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern int PauseBeforeTrade = 10; // 交易之间的停顿(以秒为单位)
 
/////////////////////////////////////////////////////////////////////////////////
// int _PauseBeforeTrade()
//
// 对于整体变量LastTradeTime函数设定地方时间值 .
// 如果此刻开启的地方时间值小于LastTradeTime + 
// PauseBeforeTrade 值,函数将进行等待。
// 如果根本没有整体变量LastTradeTime, 函数将进行创建.
// 返回代码:
//  1 - 成功编译
// -1 - 智能交易被用户打断(智能交易从图表中删除, 
//      终端关闭, 图表货币对或时间周期改变，等等。)
/////////////////////////////////////////////////////////////////////////////////
int _PauseBeforeTrade()
 {
  // 在测试执行期间没有停顿 - 只是终端函数
  if(IsTesting()) 
    return(1); 
  int _GetLastError = 0;
  int _LastTradeTime, RealPauseBeforeTrade;
 
  //+------------------------------------------------------------------+
  //| 检测整体变量是否存在。如果不存在，进行创建                       |
  //+------------------------------------------------------------------+
  while(true)
   {
    // 如果智能交易被用户打断，停止运行
    if(IsStopped()) 
     { 
      Print("智能交易被用户终止!"); 
      return(-1); 
     }
    // 检测整体变量是否存在
    // 如果存在，循环等待
    if(GlobalVariableCheck("LastTradeTime")) 
      break;
    else
     // 如果GlobalVariableCheck返回FALSE, 说明没有任何整体变量存在，
     // 或是在检测过程中出现了错误
     {
      _GetLastError = GetLastError();
      // 如果仍然存在错误，显示信息，等待0.1秒， 
      // 开始重新检测
      if(_GetLastError != 0)
       {
        Print("_PauseBeforeTrade()-GlobalVariableCheck(\"LastTradeTime\")-Error #",
              _GetLastError );
        Sleep(100);
        continue;
       }
     }
    // 如果没有错误生成,说明没有整体变量，尝试创建
    // 如果GlobalVariableSet > 0, 说明整体变量成功创建. 
    // 退出函数
    if(GlobalVariableSet("LastTradeTime", LocalTime() ) > 0) 
      return(1);
    else
     // 如果GlobalVariableSet 返回值<= 0, 说明在变量创建期间生成错误
     {
      _GetLastError = GetLastError();
      // 显示信息,等待0.1秒，重新开始尝试 
      if(_GetLastError != 0)
       {
        Print("_PauseBeforeTrade()-GlobalVariableSet(\"LastTradeTime\", ", 
              LocalTime(), ") - Error #", _GetLastError );
        Sleep(100);
        continue;
       }
     }
   }
  //+--------------------------------------------------------------------------------+
  //| 如果函数执行达到此点,所名整体变量存在                                          |
  //|                                                                                |
  //| 等待LocalTime() 值> LastTradeTime + PauseBeforeTrade                           |
  //+--------------------------------------------------------------------------------+
  while(true)
   {
    // 如果智能交易被用户打断，停止运作
    if(IsStopped()) 
     { 
      Print("智能交易被用户终止!"); 
      return(-1); 
     }
    // 获取整体变量值 
    _LastTradeTime = GlobalVariableGet("LastTradeTime");
    // 如果此时生成错误，显示信息，等待0.1秒， 
    // 并且在此尝试
    _GetLastError = GetLastError();
    if(_GetLastError != 0)
     {
      Print("_PauseBeforeTrade()-GlobalVariableGet(\"LastTradeTime\")-Error #", 
            _GetLastError );
      continue;
     }
    // 以秒为单位计算自最后交易结束过去的时间
    RealPauseBeforeTrade = LocalTime() - _LastTradeTime;
    // 如果少于PauseBeforeTrade秒数的时间过去，
    if(RealPauseBeforeTrade < PauseBeforeTrade)
     {
      // 显示信息，等待一秒，重新检验
      Comment("Pause between trades. Remaining time: ", 
               PauseBeforeTrade - RealPauseBeforeTrade, " sec" );
      Sleep(1000);
      continue;
     }
    // 如果过去时间超过PauseBeforeTrade秒数，停止循环
    else
      break;
   }
  //+--------------------------------------------------------------------------------+
  //| 如果函数执行到达此点，说明整体变量存在并且地方时间超过                         |
  //|LastTradeTime + PauseBeforeTrade                                                |
  //|                                                                                |
  //| 给整体变量LastTradeTime 设置地方时间值                                         |
  //+--------------------------------------------------------------------------------+
  while(true)
   {
    // 如果智能交易被用户打断，停止运作
    if(IsStopped()) 
     { 
      Print("智能交易被用户终止!"); 
      return(-1);
     }

    // 给整体变量LastTradeTime设置地方时间值。
    // 成功的情况下退出
    if(GlobalVariableSet( "LastTradeTime", LocalTime() ) > 0) 
     { 
      Comment(""); 
      return(1); 
     }
    else
    // 如果GlobalVariableSet 返回值<= 0, 说明错误生成
     {
      _GetLastError = GetLastError();
      // 显示信息，等待0.1 秒，并且重新开始尝试
      if(_GetLastError != 0)
       {
        Print("_PauseBeforeTrade()-GlobalVariableSet(\"LastTradeTime\", ", 
              LocalTime(), " ) - Error #", _GetLastError );
        Sleep(100);
        continue;
       }
     }
   }
 }