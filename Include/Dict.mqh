//+------------------------------------------------------------------+
//|                                                       Object.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#include "StdLibErr.mqh"
//+------------------------------------------------------------------+
//| Class CObject.                                                   |
//| Purpose: Base class for storing elements.                        |
//+------------------------------------------------------------------+
class Dict
  {
private:
   
   
public:
   int    keys[];               // previous item of list
   int    values[];               // next item of list
   int count;
   
   Dict(): count(0) 
   {
      //double gap=high-low;
      //count=gap/0.001+1;
      //Print("count="+count);
   }
   
  ~Dict(void){}
   //--- methods to access protected data
   
   void set(double key,double value)                                 
   {
      for(int i=0;i<count;i++)
      {
         if(keys[i]==key)
         {
            values[i]=value;
            return;
         }   
      }
      
      ArrayResize(keys,count+1);
      ArrayResize(values,count+1);
      keys[count]=key;
      values[count]=value;
      count++;
   }
   
   int get(double key)                                 
   {
      for(int i=0;i<count;i++)
      {
         if(keys[i]==key)
            return values[i];
      }
      return 0;
   }
   
   void debug()
   {
      string keystr;
      string vstr;
      for(int i=0;i<count;i++)
      {
         keystr+=keys[i]+" ";
         vstr+=values[i]+" ";
      }
      
      Print(keystr);
      Print(vstr);
   }
   
  };
//+------------------------------------------------------------------+
