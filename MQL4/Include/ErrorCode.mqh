#property copyright "Lorne"
#property link      "www@luotao.net"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


string ErrorInfo(int code){
   string error;
   switch(code){
      // Error codes returned from a trade server or client terminal
      case 0://ERR_NO_ERROR
          error="No error returned";
          break;
      case 1://ERR_NO_RESULT
          error="No error returned, but the result is unknown";
          break;
      case 2://ERR_COMMON_ERROR
          error="Common error";
          break;
      case 3://ERR_INVALID_TRADE_PARAMETERS
          error="Invalid trade parameters";
          break;
      case 4://ERR_SERVER_BUSY
          error="Trade server is busy";
          break;
      case 5://ERR_OLD_VERSION
          error="Old version of the client terminal";
          break;
      case 6://ERR_NO_CONNECTION
          error="No connection with trade server";
          break;
      case 7://ERR_NOT_ENOUGH_RIGHTS
          error="Not enough rights";
          break;
      case 8://ERR_TOO_FREQUENT_REQUESTS
          error="Too frequent requests";
          break;
      case 9://ERR_MALFUNCTIONAL_TRADE
          error="Malfunctional trade operation";
          break;
      case 64://ERR_ACCOUNT_DISABLED
          error="Account disabled";
          break;
      case 65://ERR_INVALID_ACCOUNT
          error="Invalid account";
          break;
      case 128://ERR_TRADE_TIMEOUT
          error="Trade timeout";
          break;
      case 129://ERR_INVALID_PRICE
          error="Invalid price";
          break;
      case 130://ERR_INVALID_STOPS
          error="Invalid stops";
          break;
      case 131://ERR_INVALID_TRADE_VOLUME
          error="Invalid trade volume";
          break;
      case 132://ERR_MARKET_CLOSED
          error="Market is closed";
          break;
      case 133://ERR_TRADE_DISABLED
          error="Trade is disabled";
          break;
      case 134://ERR_NOT_ENOUGH_MONEY
          error="Not enough money";
          break;
      case 135://ERR_PRICE_CHANGED
          error="Price changed";
          break;
      case 136://ERR_OFF_QUOTES
          error="Off quotes";
          break;
      case 137://ERR_BROKER_BUSY
          error="Broker is busy";
          break;
      case 138://ERR_REQUOTE
          error="Requote";
          break;
      case 139://ERR_ORDER_LOCKED
          error="Order is locked";
          break;
      case 140://ERR_LONG_POSITIONS_ONLY_ALLOWED
          error="Buy orders only allowed";
          break;
      case 141://ERR_TOO_MANY_REQUESTS
          error="Too many requests";
          break;
      case 145://ERR_TRADE_MODIFY_DENIED
          error="Modification denied because order is too close to market";
          break;
      case 146://ERR_TRADE_CONTEXT_BUSY
          error="Trade context is busy";
          break;
      case 147://ERR_TRADE_EXPIRATION_DENIED
          error="Expirations are denied by broker";
          break;
      case 148://ERR_TRADE_TOO_MANY_ORDERS
          error="The amount of open and pending orders has reached the limit set by the broker";
          break;
      case 149://ERR_TRADE_HEDGE_PROHIBITED
          error="An attempt to open an order opposite to the existing one when hedging is disabled";
          break;
      case 150://ERR_TRADE_PROHIBITED_BY_FIFO
          error="An attempt to close an order contravening the FIFO rule";
      
      // MQL4 run time error codes:
          break;
      case 4000://ERR_NO_MQLERROR
          error="No error returned";
          break;
      case 4001://ERR_WRONG_FUNCTION_POINTER
          error="Wrong function pointer";
          break;
      case 4002://ERR_ARRAY_INDEX_OUT_OF_RANGE
          error="Array index is out of range";
          break;
      case 4003://ERR_NO_MEMORY_FOR_CALL_STACK
          error="No memory for function call stack";
          break;
      case 4004://ERR_RECURSIVE_STACK_OVERFLOW
          error="Recursive stack overflow";
          break;
      case 4005://ERR_NOT_ENOUGH_STACK_FOR_PARAM
          error="Not enough stack for parameter";
          break;
      case 4006://ERR_NO_MEMORY_FOR_PARAM_STRING
          error="No memory for parameter string";
          break;
      case 4007://ERR_NO_MEMORY_FOR_TEMP_STRING
          error="No memory for temp string";
          break;
      case 4008://ERR_NOT_INITIALIZED_STRING
          error="Not initialized string";
          break;
      case 4009://ERR_NOT_INITIALIZED_ARRAYSTRING
          error="Not initialized string in array";
          break;
      case 4010://ERR_NO_MEMORY_FOR_ARRAYSTRING
          error="No memory for array string";
          break;
      case 4011://ERR_TOO_LONG_STRING
          error="Too long string";
          break;
      case 4012://ERR_REMAINDER_FROM_ZERO_DIVIDE
          error="Remainder from zero divide";
          break;
      case 4013://ERR_ZERO_DIVIDE
          error="Zero divide";
          break;
      case 4014://ERR_UNKNOWN_COMMAND
          error="Unknown command";
          break;
      case 4015://ERR_WRONG_JUMP
          error="Wrong jump (never generated error)";
          break;
      case 4016://ERR_NOT_INITIALIZED_ARRAY
          error="Not initialized array";
          break;
      case 4017://ERR_DLL_CALLS_NOT_ALLOWED
          error="DLL calls are not allowed";
          break;
      case 4018://ERR_CANNOT_LOAD_LIBRARY
          error="Cannot load library";
          break;
      case 4019://ERR_CANNOT_CALL_FUNCTION
          error="Cannot call function";
          break;
      case 4020://ERR_EXTERNAL_CALLS_NOT_ALLOWED
          error="Expert function calls are not allowed";
          break;
      case 4021://ERR_NO_MEMORY_FOR_RETURNED_STR
          error="Not enough memory for temp string returned from function";
          break;
      case 4022://ERR_SYSTEM_BUSY
          error="System is busy (never generated error)";
          break;
      case 4023://ERR_DLLFUNC_CRITICALERROR
          error="DLL-function call critical error";
          break;
      case 4024://ERR_INTERNAL_ERROR
          error="Internal error";
          break;
      case 4025://ERR_OUT_OF_MEMORY
          error="Out of memory";
          break;
      case 4026://ERR_INVALID_POINTER
          error="Invalid pointer";
          break;
      case 4027://ERR_FORMAT_TOO_MANY_FORMATTERS
          error="Too many formatters in the format function";
          break;
      case 4028://ERR_FORMAT_TOO_MANY_PARAMETERS
          error="Parameters count exceeds formatters count";
          break;
      case 4029://ERR_ARRAY_INVALID
          error="Invalid array";
          break;
      case 4030://ERR_CHART_NOREPLY
          error="No reply from chart";
          break;
      case 4050://ERR_INVALID_FUNCTION_PARAMSCNT
          error="Invalid function parameters count";
          break;
      case 4051://ERR_INVALID_FUNCTION_PARAMVALUE
          error="Invalid function parameter value";
          break;
      case 4052://ERR_STRING_FUNCTION_INTERNAL
          error="String function internal error";
          break;
      case 4053://ERR_SOME_ARRAY_ERROR
          error="Some array error";
          break;
      case 4054://ERR_INCORRECT_SERIESARRAY_USING
          error="Incorrect series array using";
          break;
      case 4055://ERR_CUSTOM_INDICATOR_ERROR
          error="Custom indicator error";
          break;
      case 4056://ERR_INCOMPATIBLE_ARRAYS
          error="Arrays are incompatible";
          break;
      case 4057://ERR_GLOBAL_VARIABLES_PROCESSING
          error="Global variables processing error";
          break;
      case 4058://ERR_GLOBAL_VARIABLE_NOT_FOUND
          error="Global variable not found";
          break;
      case 4059://ERR_FUNC_NOT_ALLOWED_IN_TESTING
          error="Function is not allowed in testing mode";
          break;
      case 4060://ERR_FUNCTION_NOT_CONFIRMED
          error="Function is not allowed for call";
          break;
      case 4061://ERR_SEND_MAIL_ERROR
          error="Send mail error";
          break;
      case 4062://ERR_STRING_PARAMETER_EXPECTED
          error="String parameter expected";
          break;
      case 4063://ERR_INTEGER_PARAMETER_EXPECTED
          error="Integer parameter expected";
          break;
      case 4064://ERR_DOUBLE_PARAMETER_EXPECTED
          error="Double parameter expected";
          break;
      case 4065://ERR_ARRAY_AS_PARAMETER_EXPECTED
          error="Array as parameter expected";
          break;
      case 4066://ERR_HISTORY_WILL_UPDATED
          error="Requested history data is in updating state";
          break;
      case 4067://ERR_TRADE_ERROR
          error="Internal trade error";
          break;
      case 4068://ERR_RESOURCE_NOT_FOUND
          error="Resource not found";
          break;
      case 4069://ERR_RESOURCE_NOT_SUPPORTED
          error="Resource not supported";
          break;
      case 4070://ERR_RESOURCE_DUPLICATED
          error="Duplicate resource";
          break;
      case 4071://ERR_INDICATOR_CANNOT_INIT
          error="Custom indicator cannot initialize";
          break;
      case 4072://ERR_INDICATOR_CANNOT_LOAD
          error="Cannot load custom indicator";
          break;
      case 4099://ERR_END_OF_FILE
          error="End of file";
          break;
      case 4100://ERR_SOME_FILE_ERROR
          error="Some file error";
          break;
      case 4101://ERR_WRONG_FILE_NAME
          error="Wrong file name";
          break;
      case 4102://ERR_TOO_MANY_OPENED_FILES
          error="Too many opened files";
          break;
      case 4103://ERR_CANNOT_OPEN_FILE
          error="Cannot open file";
          break;
      case 4104://ERR_INCOMPATIBLE_FILEACCESS
          error="Incompatible access to a file";
          break;
      case 4105://ERR_NO_ORDER_SELECTED
          error="No order selected";
          break;
      case 4106://ERR_UNKNOWN_SYMBOL
          error="Unknown symbol";
          break;
      case 4107://ERR_INVALID_PRICE_PARAM
          error="Invalid price";
          break;
      case 4108://ERR_INVALID_TICKET
          error="Invalid ticket";
          break;
      case 4109://ERR_TRADE_NOT_ALLOWED
          error="Trade is not allowed. Enable checkbox 'Allow live trading' in the Expert Advisor properties";
          break;
      case 4110://ERR_LONGS_NOT_ALLOWED
          error="Longs are not allowed. Check the Expert Advisor properties";
          break;
      case 4111://ERR_SHORTS_NOT_ALLOWED
          error="Shorts are not allowed. Check the Expert Advisor properties";
          break;
      case 4112://ERR_TRADE_EXPERT_DISABLED_BY_SERVER 
          error="Automated trading by Expert Advisors/Scripts disabled by trade server";
          break;
      case 4200://ERR_OBJECT_ALREADY_EXISTS
          error="Object already exists";
          break;
      case 4201://ERR_UNKNOWN_OBJECT_PROPERTY
          error="Unknown object property";
          break;
      case 4202://ERR_OBJECT_DOES_NOT_EXIST
          error="Object does not exist";
          break;
      case 4203://ERR_UNKNOWN_OBJECT_TYPE
          error="Unknown object type";
          break;
      case 4204://ERR_NO_OBJECT_NAME
          error="No object name";
          break;
      case 4205://ERR_OBJECT_COORDINATES_ERROR
          error="Object coordinates error";
          break;
      case 4206://ERR_NO_SPECIFIED_SUBWINDOW
          error="No specified subwindow";
          break;
      case 4207://ERR_SOME_OBJECT_ERROR
          error="Graphical object error";
          break;
      case 4210://ERR_CHART_PROP_INVALID
          error="Unknown chart property";
          break;
      case 4211://ERR_CHART_NOT_FOUND
          error="Chart not found";
          break;
      case 4212://ERR_CHARTWINDOW_NOT_FOUND
          error="Chart subwindow not found";
          break;
      case 4213://ERR_CHARTINDICATOR_NOT_FOUND
          error="Chart indicator not found";
          break;
      case 4220://ERR_SYMBOL_SELECT
          error="Symbol select error";
          break;
      case 4250://ERR_NOTIFICATION_ERROR
          error="Notification error";
          break;
      case 4251://ERR_NOTIFICATION_PARAMETER
          error="Notification parameter error";
          break;
      case 4252://ERR_NOTIFICATION_SETTINGS
          error="Notifications disabled";
          break;
      case 4253://ERR_NOTIFICATION_TOO_FREQUENT
          error="Notification send too frequent";
          break;
      case 5001://ERR_FILE_TOO_MANY_OPENED
          error="Too many opened files";
          break;
      case 5002://ERR_FILE_WRONG_FILENAME
          error="Wrong file name";
          break;
      case 5003://ERR_FILE_TOO_LONG_FILENAME
          error="Too long file name";
          break;
      case 5004://ERR_FILE_CANNOT_OPEN
          error="Cannot open file";
          break;
      case 5005://ERR_FILE_BUFFER_ALLOCATION_ERROR
          error="Text file buffer allocation error";
          break;
      case 5006://ERR_FILE_CANNOT_DELETE
          error="Cannot delete file";
          break;
      case 5007://ERR_FILE_INVALID_HANDLE
          error="Invalid file handle (file closed or was not opened)";
          break;
      case 5008://ERR_FILE_WRONG_HANDLE
          error="Wrong file handle (handle index is out of handle table)";
          break;
      case 5009://ERR_FILE_NOT_TOWRITE
          error="File must be opened with FILE_WRITE flag";
          break;
      case 5010://ERR_FILE_NOT_TOREAD
          error="File must be opened with FILE_READ flag";
          break;
      case 5011://ERR_FILE_NOT_BIN
          error="File must be opened with FILE_BIN flag";
          break;
      case 5012://ERR_FILE_NOT_TXT
          error="File must be opened with FILE_TXT flag";
          break;
      case 5013://ERR_FILE_NOT_TXTORCSV
          error="File must be opened with FILE_TXT or FILE_CSV flag";
          break;
      case 5014://ERR_FILE_NOT_CSV
          error="File must be opened with FILE_CSV flag";
          break;
      case 5015://ERR_FILE_READ_ERROR
          error="File read error";
          break;
      case 5016://ERR_FILE_WRITE_ERROR
          error="File write error";
          break;
      case 5017://ERR_FILE_BIN_STRINGSIZE
          error="String size must be specified for binary file";
          break;
      case 5018://ERR_FILE_INCOMPATIBLE
          error="Incompatible file (for string arrays-TXT, for others-BIN)";
          break;
      case 5019://ERR_FILE_IS_DIRECTORY
          error="File is directory not file";
          break;
      case 5020://ERR_FILE_NOT_EXIST
          error="File does not exist";
          break;
      case 5021://ERR_FILE_CANNOT_REWRITE
          error="File cannot be rewritten";
          break;
      case 5022://ERR_FILE_WRONG_DIRECTORYNAME
          error="Wrong directory name";
          break;
      case 5023://ERR_FILE_DIRECTORY_NOT_EXIST
          error="Directory does not exist";
          break;
      case 5024://ERR_FILE_NOT_DIRECTORY
          error="Specified file is not directory";
          break;
      case 5025://ERR_FILE_CANNOT_DELETE_DIRECTORY
          error="Cannot delete directory";
          break;
      case 5026://ERR_FILE_CANNOT_CLEAN_DIRECTORY
          error="Cannot clean directory";
          break;
      case 5027://ERR_FILE_ARRAYRESIZE_ERROR
          error="Array resize error";
          break;
      case 5028://ERR_FILE_STRINGRESIZE_ERROR
          error="String resize error";
          break;
      case 5029://ERR_FILE_STRUCT_WITH_OBJECTS
          error="Structure contains strings or dynamic arrays";
          break;
      case 5200://ERR_WEBREQUEST_INVALID_ADDRESS
          error="Invalid URL";
          break;
      case 5201://ERR_WEBREQUEST_CONNECT_FAILED
          error="Failed to connect to specified URL";
          break;
      case 5202://ERR_WEBREQUEST_TIMEOUT
          error="Timeout exceeded";
          break;
      case 5203://ERR_WEBREQUEST_REQUEST_FAILED
          error="HTTP request failed";
          break;
      default:
         error="unknown error "+code;
   }
   return(error);
}

