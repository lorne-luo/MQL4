//+------------------------------------------------------------------+
//|                                             InvestorReminder.mq4 |
//|                                                         by Lorne |
//|                                                   www@luotao.net |
//+------------------------------------------------------------------+
#property copyright "Lorne"
#property link      "www@luotao.net"
#property version   "1.00"
#property strict

#define Magic 20141209


int TracingOrderCount=100;
int OrderTicketList[100];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   //EventSetTimer(1);
   
   // init order list in memory
   for (int i = 0; i < TracingOrderCount ; i++)
   {
      OrderTicketList[i]=EMPTY_VALUE;
   }
   int j=0;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if (j==TracingOrderCount)
      {
         Print("OrderTicketListLength not enough, OrdersTotal="+OrdersTotal());
         break;
      }
      if(OrderSelect(i,SELECT_BY_POS))
      {
         OrderTicketList[j]=OrderTicket();
         j++;
         Print("Init add "+ OrderTicket() + " into OrderTicketList");
      }
   }
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   //EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   //Print("OnTick");
   //report open
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         int ticket=OrderTicket();
         int index = IsInOrderList(ticket);
         //Print("index="+index," OrderTicketList[0] = ",OrderTicketList[0]);
         if(index<0)
            ReportOpen(ticket);
      }
   }
   //report close
   for (int i = 0; i < TracingOrderCount ; i++)
   {
      //&& !OrderSelect(OrderTicketList[i],SELECT_BY_TICKET
      if(OrderTicketList[i]!=EMPTY_VALUE)
      {
         int index = IsCurrentOrder(OrderTicketList[i]);
         if(index<0)
         {
            Print("Pop ",OrderTicketList[i]," out of OrderTicketList");
            ReportColse(OrderTicketList[i]);
            OrderTicketList[i]=EMPTY_VALUE;
         }
      }
   }
   
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   //Print("OnTimer");
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   //Print("OnChartEvent");
  }
//+------------------------------------------------------------------+

//check ticket id in OrderTicketList,return index, return -1 if not found
int IsInOrderList(const int ticket)
{
   for (int i = 0; i < TracingOrderCount ; i++)
   {
      if(OrderTicketList[i]==ticket)
     {
         return(i);
     }
   }
   return(-1);
}

void ReportOpen(const int ticket)
{
   Print("Report Open = "+ticket);
   for (int i = 0; i < TracingOrderCount ; i++)
   {
      if(OrderTicketList[i]==EMPTY_VALUE)
      {
         if(OrderSelect(ticket,SELECT_BY_TICKET))
         {
            string direction=GetOrderTypeStr(OrderType());
            Print("["+AccountNumber()+"] " + OrderSymbol() +" "+ direction + " Open at  "+OrderOpenPrice());
            SendMail("["+AccountNumber()+"] " + OrderSymbol() +" " + direction + " Open at  "+OrderOpenPrice(), 
                     "["+AccountNumber()+"] " + OrderSymbol() +" " + direction + " Open at  "+OrderOpenPrice());
            int code=GetLastError();
            if (code==ERR_NO_ERROR || code==ERR_NO_MQLERROR){
               OrderTicketList[i]=ticket;
               Print("Push ",ticket," into OrderTicketList");
            }else{
               Print("SendMail Failed : "+ErrorInfo(code));
            }
         }
         return;
      }
   }
}

void ReportColse(const int ticket)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY))
   {
      string direction=GetOrderTypeStr(OrderType());
      Print("["+AccountNumber()+"] "+ OrderSymbol() +" " + direction + " Closed "+OrderOpenPrice()+" - "+OrderClosePrice());
      SendMail("["+AccountNumber()+"] "+ OrderSymbol() +" " + direction + " Closed "+OrderOpenPrice()+" - "+OrderClosePrice(), 
               "["+AccountNumber()+"] "+ OrderSymbol() +" " + direction + " Closed "+OrderOpenPrice()+" - "+OrderClosePrice());
   }
}

// whether opening order, yes return pos,no return -1
int IsCurrentOrder(const int ticket)
{
   int result=-1;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(ticket==OrderTicket())
            return i;
      }
   }
   return -1;
}
string GetOrderTypeStr(int type)
{
   if(type==OP_BUY)
   {
      return "BUY";
   }else if(type==OP_SELL)
   {
      return "SELL";
   }else if(type==OP_BUYLIMIT)
   {
      return "BUYLIMIT";
   }else if(type==OP_SELLLIMIT)
   {
      return "SELLLIMIT";
   }else if(type==OP_BUYSTOP)
   {
      return "BUYSTOP";
   }else
   {
      return "SELLSTOP";
   }
}


string ErrorInfo(int code){
   string error;
   switch(code){
      // Error codes returned from a trade server or client terminal
      case 0://ERR_NO_ERROR
          error="No error returned";
      case 1://ERR_NO_RESULT
          error="No error returned, but the result is unknown";
      case 2://ERR_COMMON_ERROR
          error="Common error";
      case 3://ERR_INVALID_TRADE_PARAMETERS
          error="Invalid trade parameters";
      case 4://ERR_SERVER_BUSY
          error="Trade server is busy";
      case 5://ERR_OLD_VERSION
          error="Old version of the client terminal";
      case 6://ERR_NO_CONNECTION
          error="No connection with trade server";
      case 7://ERR_NOT_ENOUGH_RIGHTS
          error="Not enough rights";
      case 8://ERR_TOO_FREQUENT_REQUESTS
          error="Too frequent requests";
      case 9://ERR_MALFUNCTIONAL_TRADE
          error="Malfunctional trade operation";
      case 64://ERR_ACCOUNT_DISABLED
          error="Account disabled";
      case 65://ERR_INVALID_ACCOUNT
          error="Invalid account";
      case 128://ERR_TRADE_TIMEOUT
          error="Trade timeout";
      case 129://ERR_INVALID_PRICE
          error="Invalid price";
      case 130://ERR_INVALID_STOPS
          error="Invalid stops";
      case 131://ERR_INVALID_TRADE_VOLUME
          error="Invalid trade volume";
      case 132://ERR_MARKET_CLOSED
          error="Market is closed";
      case 133://ERR_TRADE_DISABLED
          error="Trade is disabled";
      case 134://ERR_NOT_ENOUGH_MONEY
          error="Not enough money";
      case 135://ERR_PRICE_CHANGED
          error="Price changed";
      case 136://ERR_OFF_QUOTES
          error="Off quotes";
      case 137://ERR_BROKER_BUSY
          error="Broker is busy";
      case 138://ERR_REQUOTE
          error="Requote";
      case 139://ERR_ORDER_LOCKED
          error="Order is locked";
      case 140://ERR_LONG_POSITIONS_ONLY_ALLOWED
          error="Buy orders only allowed";
      case 141://ERR_TOO_MANY_REQUESTS
          error="Too many requests";
      case 145://ERR_TRADE_MODIFY_DENIED
          error="Modification denied because order is too close to market";
      case 146://ERR_TRADE_CONTEXT_BUSY
          error="Trade context is busy";
      case 147://ERR_TRADE_EXPIRATION_DENIED
          error="Expirations are denied by broker";
      case 148://ERR_TRADE_TOO_MANY_ORDERS
          error="The amount of open and pending orders has reached the limit set by the broker";
      case 149://ERR_TRADE_HEDGE_PROHIBITED
          error="An attempt to open an order opposite to the existing one when hedging is disabled";
      case 150://ERR_TRADE_PROHIBITED_BY_FIFO
          error="An attempt to close an order contravening the FIFO rule";
      
      // MQL4 run time error codes:
      case 4000://ERR_NO_MQLERROR
          error="No error returned";
      case 4001://ERR_WRONG_FUNCTION_POINTER
          error="Wrong function pointer";
      case 4002://ERR_ARRAY_INDEX_OUT_OF_RANGE
          error="Array index is out of range";
      case 4003://ERR_NO_MEMORY_FOR_CALL_STACK
          error="No memory for function call stack";
      case 4004://ERR_RECURSIVE_STACK_OVERFLOW
          error="Recursive stack overflow";
      case 4005://ERR_NOT_ENOUGH_STACK_FOR_PARAM
          error="Not enough stack for parameter";
      case 4006://ERR_NO_MEMORY_FOR_PARAM_STRING
          error="No memory for parameter string";
      case 4007://ERR_NO_MEMORY_FOR_TEMP_STRING
          error="No memory for temp string";
      case 4008://ERR_NOT_INITIALIZED_STRING
          error="Not initialized string";
      case 4009://ERR_NOT_INITIALIZED_ARRAYSTRING
          error="Not initialized string in array";
      case 4010://ERR_NO_MEMORY_FOR_ARRAYSTRING
          error="No memory for array string";
      case 4011://ERR_TOO_LONG_STRING
          error="Too long string";
      case 4012://ERR_REMAINDER_FROM_ZERO_DIVIDE
          error="Remainder from zero divide";
      case 4013://ERR_ZERO_DIVIDE
          error="Zero divide";
      case 4014://ERR_UNKNOWN_COMMAND
          error="Unknown command";
      case 4015://ERR_WRONG_JUMP
          error="Wrong jump (never generated error)";
      case 4016://ERR_NOT_INITIALIZED_ARRAY
          error="Not initialized array";
      case 4017://ERR_DLL_CALLS_NOT_ALLOWED
          error="DLL calls are not allowed";
      case 4018://ERR_CANNOT_LOAD_LIBRARY
          error="Cannot load library";
      case 4019://ERR_CANNOT_CALL_FUNCTION
          error="Cannot call function";
      case 4020://ERR_EXTERNAL_CALLS_NOT_ALLOWED
          error="Expert function calls are not allowed";
      case 4021://ERR_NO_MEMORY_FOR_RETURNED_STR
          error="Not enough memory for temp string returned from function";
      case 4022://ERR_SYSTEM_BUSY
          error="System is busy (never generated error)";
      case 4023://ERR_DLLFUNC_CRITICALERROR
          error="DLL-function call critical error";
      case 4024://ERR_INTERNAL_ERROR
          error="Internal error";
      case 4025://ERR_OUT_OF_MEMORY
          error="Out of memory";
      case 4026://ERR_INVALID_POINTER
          error="Invalid pointer";
      case 4027://ERR_FORMAT_TOO_MANY_FORMATTERS
          error="Too many formatters in the format function";
      case 4028://ERR_FORMAT_TOO_MANY_PARAMETERS
          error="Parameters count exceeds formatters count";
      case 4029://ERR_ARRAY_INVALID
          error="Invalid array";
      case 4030://ERR_CHART_NOREPLY
          error="No reply from chart";
      case 4050://ERR_INVALID_FUNCTION_PARAMSCNT
          error="Invalid function parameters count";
      case 4051://ERR_INVALID_FUNCTION_PARAMVALUE
          error="Invalid function parameter value";
      case 4052://ERR_STRING_FUNCTION_INTERNAL
          error="String function internal error";
      case 4053://ERR_SOME_ARRAY_ERROR
          error="Some array error";
      case 4054://ERR_INCORRECT_SERIESARRAY_USING
          error="Incorrect series array using";
      case 4055://ERR_CUSTOM_INDICATOR_ERROR
          error="Custom indicator error";
      case 4056://ERR_INCOMPATIBLE_ARRAYS
          error="Arrays are incompatible";
      case 4057://ERR_GLOBAL_VARIABLES_PROCESSING
          error="Global variables processing error";
      case 4058://ERR_GLOBAL_VARIABLE_NOT_FOUND
          error="Global variable not found";
      case 4059://ERR_FUNC_NOT_ALLOWED_IN_TESTING
          error="Function is not allowed in testing mode";
      case 4060://ERR_FUNCTION_NOT_CONFIRMED
          error="Function is not allowed for call";
      case 4061://ERR_SEND_MAIL_ERROR
          error="Send mail error";
      case 4062://ERR_STRING_PARAMETER_EXPECTED
          error="String parameter expected";
      case 4063://ERR_INTEGER_PARAMETER_EXPECTED
          error="Integer parameter expected";
      case 4064://ERR_DOUBLE_PARAMETER_EXPECTED
          error="Double parameter expected";
      case 4065://ERR_ARRAY_AS_PARAMETER_EXPECTED
          error="Array as parameter expected";
      case 4066://ERR_HISTORY_WILL_UPDATED
          error="Requested history data is in updating state";
      case 4067://ERR_TRADE_ERROR
          error="Internal trade error";
      case 4068://ERR_RESOURCE_NOT_FOUND
          error="Resource not found";
      case 4069://ERR_RESOURCE_NOT_SUPPORTED
          error="Resource not supported";
      case 4070://ERR_RESOURCE_DUPLICATED
          error="Duplicate resource";
      case 4071://ERR_INDICATOR_CANNOT_INIT
          error="Custom indicator cannot initialize";
      case 4072://ERR_INDICATOR_CANNOT_LOAD
          error="Cannot load custom indicator";
      case 4099://ERR_END_OF_FILE
          error="End of file";
      case 4100://ERR_SOME_FILE_ERROR
          error="Some file error";
      case 4101://ERR_WRONG_FILE_NAME
          error="Wrong file name";
      case 4102://ERR_TOO_MANY_OPENED_FILES
          error="Too many opened files";
      case 4103://ERR_CANNOT_OPEN_FILE
          error="Cannot open file";
      case 4104://ERR_INCOMPATIBLE_FILEACCESS
          error="Incompatible access to a file";
      case 4105://ERR_NO_ORDER_SELECTED
          error="No order selected";
      case 4106://ERR_UNKNOWN_SYMBOL
          error="Unknown symbol";
      case 4107://ERR_INVALID_PRICE_PARAM
          error="Invalid price";
      case 4108://ERR_INVALID_TICKET
          error="Invalid ticket";
      case 4109://ERR_TRADE_NOT_ALLOWED
          error="Trade is not allowed. Enable checkbox &quot;Allow live trading&quot; in the Expert Advisor properties";
      case 4110://ERR_LONGS_NOT_ALLOWED
          error="Longs are not allowed. Check the Expert Advisor properties";
      case 4111://ERR_SHORTS_NOT_ALLOWED
          error="Shorts are not allowed. Check the Expert Advisor properties";
      case 4112://ERR_TRADE_EXPERT_DISABLED_BY_SERVER 
          error="Automated trading by Expert Advisors/Scripts disabled by trade server";
      case 4200://ERR_OBJECT_ALREADY_EXISTS
          error="Object already exists";
      case 4201://ERR_UNKNOWN_OBJECT_PROPERTY
          error="Unknown object property";
      case 4202://ERR_OBJECT_DOES_NOT_EXIST
          error="Object does not exist";
      case 4203://ERR_UNKNOWN_OBJECT_TYPE
          error="Unknown object type";
      case 4204://ERR_NO_OBJECT_NAME
          error="No object name";
      case 4205://ERR_OBJECT_COORDINATES_ERROR
          error="Object coordinates error";
      case 4206://ERR_NO_SPECIFIED_SUBWINDOW
          error="No specified subwindow";
      case 4207://ERR_SOME_OBJECT_ERROR
          error="Graphical object error";
      case 4210://ERR_CHART_PROP_INVALID
          error="Unknown chart property";
      case 4211://ERR_CHART_NOT_FOUND
          error="Chart not found";
      case 4212://ERR_CHARTWINDOW_NOT_FOUND
          error="Chart subwindow not found";
      case 4213://ERR_CHARTINDICATOR_NOT_FOUND
          error="Chart indicator not found";
      case 4220://ERR_SYMBOL_SELECT
          error="Symbol select error";
      case 4250://ERR_NOTIFICATION_ERROR
          error="Notification error";
      case 4251://ERR_NOTIFICATION_PARAMETER
          error="Notification parameter error";
      case 4252://ERR_NOTIFICATION_SETTINGS
          error="Notifications disabled";
      case 4253://ERR_NOTIFICATION_TOO_FREQUENT
          error="Notification send too frequent";
      case 5001://ERR_FILE_TOO_MANY_OPENED
          error="Too many opened files";
      case 5002://ERR_FILE_WRONG_FILENAME
          error="Wrong file name";
      case 5003://ERR_FILE_TOO_LONG_FILENAME
          error="Too long file name";
      case 5004://ERR_FILE_CANNOT_OPEN
          error="Cannot open file";
      case 5005://ERR_FILE_BUFFER_ALLOCATION_ERROR
          error="Text file buffer allocation error";
      case 5006://ERR_FILE_CANNOT_DELETE
          error="Cannot delete file";
      case 5007://ERR_FILE_INVALID_HANDLE
          error="Invalid file handle (file closed or was not opened)";
      case 5008://ERR_FILE_WRONG_HANDLE
          error="Wrong file handle (handle index is out of handle table)";
      case 5009://ERR_FILE_NOT_TOWRITE
          error="File must be opened with FILE_WRITE flag";
      case 5010://ERR_FILE_NOT_TOREAD
          error="File must be opened with FILE_READ flag";
      case 5011://ERR_FILE_NOT_BIN
          error="File must be opened with FILE_BIN flag";
      case 5012://ERR_FILE_NOT_TXT
          error="File must be opened with FILE_TXT flag";
      case 5013://ERR_FILE_NOT_TXTORCSV
          error="File must be opened with FILE_TXT or FILE_CSV flag";
      case 5014://ERR_FILE_NOT_CSV
          error="File must be opened with FILE_CSV flag";
      case 5015://ERR_FILE_READ_ERROR
          error="File read error";
      case 5016://ERR_FILE_WRITE_ERROR
          error="File write error";
      case 5017://ERR_FILE_BIN_STRINGSIZE
          error="String size must be specified for binary file";
      case 5018://ERR_FILE_INCOMPATIBLE
          error="Incompatible file (for string arrays-TXT, for others-BIN)";
      case 5019://ERR_FILE_IS_DIRECTORY
          error="File is directory not file";
      case 5020://ERR_FILE_NOT_EXIST
          error="File does not exist";
      case 5021://ERR_FILE_CANNOT_REWRITE
          error="File cannot be rewritten";
      case 5022://ERR_FILE_WRONG_DIRECTORYNAME
          error="Wrong directory name";
      case 5023://ERR_FILE_DIRECTORY_NOT_EXIST
          error="Directory does not exist";
      case 5024://ERR_FILE_NOT_DIRECTORY
          error="Specified file is not directory";
      case 5025://ERR_FILE_CANNOT_DELETE_DIRECTORY
          error="Cannot delete directory";
      case 5026://ERR_FILE_CANNOT_CLEAN_DIRECTORY
          error="Cannot clean directory";
      case 5027://ERR_FILE_ARRAYRESIZE_ERROR
          error="Array resize error";
      case 5028://ERR_FILE_STRINGRESIZE_ERROR
          error="String resize error";
      case 5029://ERR_FILE_STRUCT_WITH_OBJECTS
          error="Structure contains strings or dynamic arrays";
      case 5200://ERR_WEBREQUEST_INVALID_ADDRESS
          error="Invalid URL";
      case 5201://ERR_WEBREQUEST_CONNECT_FAILED
          error="Failed to connect to specified URL";
      case 5202://ERR_WEBREQUEST_TIMEOUT
          error="Timeout exceeded";
      case 5203://ERR_WEBREQUEST_REQUEST_FAILED
          error="HTTP request failed";
      default:error="unknown error "+code;
   }
   return(error);
}