//+------------------------------------------------------------------+
//|                                            Basic    StochRSI.mq4 |
//|                                 Copyright � 2007, Petr Doroshenko|
//|                                            i7hornet@yahoo.com    |
//+------------------------------------------------------------------+

#include <utility.mqh>


#property copyright "Copyright � 2007, Petr Doroshenko"
#property link      "i7hornet@yahoo.com"

#property indicator_separate_window
#property indicator_height 350
#property indicator_minimum -15
#property indicator_maximum 115
#property indicator_level1 10
#property indicator_level2 20
#property indicator_level3 80
#property indicator_level4 90

#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//---- input parameters
extern int RSIPeriod=10;
extern int KPeriod=10;
extern int DPeriod=2;
extern int Slowing=2;
extern int StochOverbought=80;
extern int StochOversold=20;

//---- buffers
double MainBuffer[];
double SignalBuffer[];
double HighesBuffer[];
double LowesBuffer[];
double rsi[];

int draw_begin1=0;
int draw_begin2=0;
int RPrice=5;
int subwindow_idx=NULL;

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int deinit() {
   //Print("deinit StochRSI Indicator objects...");
   //ObjectsDeleteAll(ChartID(), subwindow_idx, EMPTY); 
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   int id=0;//ChartID();
   if(IsVisualMode())
      id=0;
      
   string short_name = "StochRSI("+RSIPeriod+","+KPeriod+","+DPeriod+","+Slowing+")";
   string os_name = "StochRSI Oversold Line";
   string ob_name = "StochRSI Overbought Line";
   
   //---- 3 additional buffers are used for counting.
   IndicatorBuffers(5);
   SetIndexBuffer(2, HighesBuffer);
   SetIndexBuffer(3, LowesBuffer);
   SetIndexBuffer(4, rsi);
   //---- indicator lines
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0, MainBuffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(1, SignalBuffer);
   //---- name for DataWindow and indicator subwindow label
   short_name="StochRSI("+RSIPeriod+","+KPeriod+","+DPeriod+","+Slowing+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Signal");
   draw_begin1=KPeriod+Slowing;
   draw_begin2=draw_begin1+DPeriod;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin2);
  
   // Overbought/Oversold lines
   subwindow_idx=ChartWindowFind(id, short_name);
   int res = ObjectCreate(id, os_name, OBJ_HLINE, subwindow_idx, Time[0], StochOversold);
   ObjectSetInteger(id, os_name, OBJPROP_COLOR, clrGreen); 
   ObjectSetInteger(id, os_name, OBJPROP_STYLE, STYLE_DOT); 
   ObjectSetInteger(id, os_name, OBJPROP_WIDTH, 2); 
   ObjectSetInteger(id, os_name, OBJPROP_BACK, false); 
   ObjectSetInteger(id, os_name, OBJPROP_SELECTABLE, true); 
   ObjectSetInteger(id, os_name, OBJPROP_SELECTED, true); 
   ObjectSetInteger(id, os_name, OBJPROP_HIDDEN, false); 
   ObjectSetInteger(id, os_name, OBJPROP_ZORDER, 0); 
   res = ObjectCreate(id, ob_name, OBJ_HLINE, subwindow_idx, Time[0], StochOverbought);
   ObjectSetInteger(id, ob_name, OBJPROP_COLOR, clrGreen); 
   ObjectSetInteger(id, ob_name, OBJPROP_STYLE, STYLE_DOT); 
   ObjectSetInteger(id, ob_name, OBJPROP_WIDTH, 2); 
   ObjectSetInteger(id, ob_name, OBJPROP_BACK, false); 
   ObjectSetInteger(id, ob_name, OBJPROP_SELECTABLE, true); 
   ObjectSetInteger(id, ob_name, OBJPROP_SELECTED, true); 
   ObjectSetInteger(id, ob_name, OBJPROP_HIDDEN, false); 
   ObjectSetInteger(id, ob_name, OBJPROP_ZORDER, 0); 
   
   if(!res)
      Print("ERROR creating Fisher line: ",err_msg(GetLastError()));
   Print("StochRSI init() done. ChartID: ", id);
   //EventSetMillisecondTimer(1); //right before return
   return(0);
}
  
//+------------------------------------------------------------------+
//| Stochastics formula applied to RSI                               |
//+------------------------------------------------------------------+
int start() {  
   int    i,k;
   int    counted_bars=IndicatorCounted();
   
   //---- check Slowing 
   if (Slowing<=0)
      Slowing=1;
   if(Bars<=draw_begin2)
      return(0);
      
   //---- initial zero
   if(counted_bars<1) {
      for(i=1;i<=draw_begin1;i++) MainBuffer[Bars-i]=0;
      for(i=1;i<=draw_begin2;i++) SignalBuffer[Bars-i]=0;
   }
   
   //---- initial RSI      
   i=Bars-RSIPeriod;
   
   if(counted_bars>RSIPeriod)
      i=Bars-counted_bars-1;
   
   while(i>=0){
      rsi[i]=iRSI(NULL,0,RSIPeriod,RPrice,i); i--;
   }
   
   //---- minimums & maximums counting
   i=Bars-KPeriod;
   if(counted_bars>KPeriod)
      i=Bars-counted_bars-1;
      
   while(i>=0) {
     double min=1000000, max=-1000000;
      k=i+KPeriod-1;
      while(k>=i)
        {
         min=MathMin(min,rsi[k]);
         max=MathMax(max,rsi[k]);
         k--;
        }
      LowesBuffer[i]=min;
      HighesBuffer[i]=max;
      i--;
   }
      
   //---- %K line of RSI
   i=Bars-draw_begin1;
   if(counted_bars>draw_begin1)
      i=Bars-counted_bars-1;
      
   while(i>=0) {
      double sumlow=0.0;
      double sumhigh=0.0;
      for(k=(i+Slowing-1);k>=i;k--)
        {
         sumlow+=rsi[k]-LowesBuffer[k];
         sumhigh+=HighesBuffer[k]-LowesBuffer[k];
        }
      if(sumhigh==0.0) MainBuffer[i]=100.0;
      else MainBuffer[i]=sumlow/sumhigh*100;
      i--;
   }
      
   //---- last counted bar will be recounted
   if(counted_bars>0)
      counted_bars--;
   int limit=Bars-counted_bars;
   
   //---- signal line is simple movimg average
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(MainBuffer,Bars,DPeriod,0,MODE_SMA,i);
   
   return(0);
}