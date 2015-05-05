#property copyright "Copyright 2012, laoyee"
#property link      "http://www.docin.com/yiwence"

#property indicator_separate_window
int init()
   {
      return(0);
   }
int deinit()
   {
      ObjectsDeleteAll(WindowFind(WindowExpertName()),OBJ_LABEL);
      Comment("");
      return(0);
   }
int start()
   {
      iMain();
      return(0);
   }
void iMain()
   {
      iDisplayInfo("Author","作者: 老易(QQ:921795)",0,120,5,7,"",SeaGreen);
      //帐户信息
      iDisplayInfo("AccountInfo1","公司名称："+AccountCompany(),0,10,20,8,"",SeaGreen);
      iDisplayInfo("AccountInfo2","杠杆比例：1:"+AccountLeverage(),0,10,35,8,"",SeaGreen);
      iDisplayInfo("AccountInfo3","帐户名称："+AccountName(),0,10,50,8,"",SeaGreen);
      iDisplayInfo("AccountInfo4","帐户编号："+AccountNumber(),0,10,65,8,"",SeaGreen);
      iDisplayInfo("AccountInfo5","服务器名："+AccountServer(),0,10,80,8,"",SeaGreen);
      if (IsDemo())
         {
            iDisplayInfo("PlatformRule6","帐户类型：模拟",0,10,95,8,"",SeaGreen);
         }
         else iDisplayInfo("PlatformRule6","帐户类型：真实",0,10,95,8,"",SeaGreen);
      if (MarketInfo(Symbol(),MODE_TRADEALLOWED)==1)
         {
            iDisplayInfo("PlatformRule5","智能交易：允许",0,10,110,8,"",SeaGreen);
         }
         else iDisplayInfo("PlatformRule5","智能交易：禁止",0,10,110,8,"",Red);
      //平台规则
      iDisplayInfo("PlatformRule1","交易点差："+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0),0,200,35,8,"",SeaGreen);
      iDisplayInfo("AccountInfo6","停止水平："+DoubleToStr(MarketInfo(Symbol(),MODE_STOPLEVEL),0),0,200,50,8,"",SeaGreen);
      iDisplayInfo("PlatformRule4","单点价值："+DoubleToStr(MarketInfo(Symbol(),MODE_TICKVALUE),4),0,200,65,8,"",SeaGreen);
      iDisplayInfo("PlatformRule2","最小开仓："+DoubleToStr(MarketInfo(Symbol(),MODE_MINLOT),2),0,200,80,8,"",SeaGreen);
      iDisplayInfo("PlatformRule3","最大开仓："+DoubleToStr(MarketInfo(Symbol(),MODE_MAXLOT),2),0,200,95,8,"",SeaGreen);
      iDisplayInfo("PlatformRule7","1手保证金："+DoubleToStr(MarketInfo(Symbol(),MODE_MARGINREQUIRED),2),0,200,110,8,"",SeaGreen);
   }

/*
函    数：在屏幕上显示文字标签
输入参数：string LableName 标签名称，如果显示多个文本，名称不能相同
          string LableDoc 文本内容
          int Corner 文本显示角
          int LableX 标签X位置坐标
          int LableY 标签Y位置坐标
          int DocSize 文本字号
          string DocStyle 文本字体
          color DocColor 文本颜色
输出参数：在指定的位置（X,Y）按照指定的字号、字体及颜色显示指定的文本
算法说明：
*/
void iDisplayInfo(string LableName,string LableDoc,int Corner,int LableX,int LableY,int DocSize,string DocStyle,color DocColor)
   {
      if (Corner == -1) return(0);
      int myWindowsHandle = WindowFind(WindowExpertName()); //获取当前指标名称所在窗口序号
      LableName=LableName+DoubleToStr(myWindowsHandle,0);
      ObjectCreate(LableName, OBJ_LABEL, myWindowsHandle, 0, 0); //建立标签对象
      ObjectSetText(LableName, LableDoc, DocSize, DocStyle,DocColor); //定义对象属性
      ObjectSet(LableName, OBJPROP_CORNER, Corner); //确定坐标原点，0-左上角，1-右上角，2-左下角，3-右下角，-1-不显示
      ObjectSet(LableName, OBJPROP_XDISTANCE, LableX); //定义横坐标，单位像素
      ObjectSet(LableName, OBJPROP_YDISTANCE, LableY); //定义纵坐标，单位像素
   }

