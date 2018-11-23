//+------------------------------------------------------------------+
//|                      Fisher Transform                            |
//|                        original Fisher routine by Yura Prokofiev |
//+------------------------------------------------------------------+
#include <utility.mqh>

#property copyright "Copyright © 2017, Macdulio"
#property link      "http://macdulio.blogspot.co.uk"

#property indicator_separate_window
#property indicator_minimum -2
#property indicator_maximum 2
#property indicator_height 350
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//---- input parameters
extern int FisherPeriod   = 10;
extern double FisherRange = 0.9;

//---- indicator buffers
double FishSigBuf[];
double FishTrigBuf[];

int subwindow_idx=NULL;

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int deinit() {
   //Print("deinit Fisher Indicator objects...");
   //ObjectsDeleteAll(ChartID(), subwindow_idx, EMPTY); 
   return(0);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int init()  {
   int id=0; //ChartID();
   if(IsVisualMode())
      id=0;
   
   string short_name = "Fisher Transform";
   string ob="Fisher OB Line";
   string os="Fisher OS Line";  
   
   // Indicator lines
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0, FishSigBuf);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(1, FishTrigBuf);
   ArrayInitialize(FishSigBuf, 0);
   ArrayInitialize(FishTrigBuf, 0);
   IndicatorShortName(short_name);
   IndicatorDigits(3);
   SetIndexLabel(0, "Fisher Signal");
   SetIndexLabel(1, "Fisher Trigger"); 
   SetIndexDrawBegin(0, FisherPeriod);
   SetIndexDrawBegin(1, FisherPeriod);
   
     
   // Overbought/Oversold lines.
   subwindow_idx=ChartWindowFind(id, short_name);
   int res = ObjectCreate(id, os, OBJ_HLINE, subwindow_idx, Time[0], FisherRange*-1);
   ObjectSetInteger(id, os, OBJPROP_COLOR, clrGreen); 
   ObjectSetInteger(id, os, OBJPROP_STYLE, STYLE_SOLID); 
   ObjectSetInteger(id, os, OBJPROP_WIDTH, 2); 
   ObjectSetInteger(id, os, OBJPROP_BACK, false); 
   ObjectSetInteger(id, os, OBJPROP_SELECTABLE, true); 
   ObjectSetInteger(id, os, OBJPROP_SELECTED, true); 
   ObjectSetInteger(id, os, OBJPROP_HIDDEN, false); 
   ObjectSetInteger(id, os, OBJPROP_ZORDER, 0); 
   res = ObjectCreate(id, ob, OBJ_HLINE, subwindow_idx, Time[0], FisherRange);
   ObjectSetInteger(id, ob, OBJPROP_COLOR, clrGreen); 
   ObjectSetInteger(id, ob, OBJPROP_STYLE, STYLE_SOLID); 
   ObjectSetInteger(id, ob, OBJPROP_WIDTH, 2); 
   ObjectSetInteger(id, ob, OBJPROP_BACK, false); 
   ObjectSetInteger(id, ob, OBJPROP_SELECTABLE, true); 
   ObjectSetInteger(id, ob, OBJPROP_SELECTED, true); 
   ObjectSetInteger(id, ob, OBJPROP_HIDDEN, false); 
   ObjectSetInteger(id, ob, OBJPROP_ZORDER, 0); 
   
   if(!res)
      log("ERROR creating Fisher line: ",err_msg(GetLastError()), ", subwindow_idx: ", subwindow_idx);
   log("Fisher init() done. ChartID: ", id);
   return(0);
}

//+------------------------------------------------------------------+
// The amount of bars not changed after the indicator had been launched last. 
// Pine script:
//     Length = input(10, minval=1)
//     xHL2 = hl2
//     xMaxH = highest(xHL2, Length)
//     xMinL = lowest(xHL2,Length)
//     nValue1 = 0.33 * 2 * ((xHL2 - xMinL) / (xMaxH - xMinL) - 0.5) + 0.67 * nz(nValue1[1])
//     nValue2 = iff(nValue1 > .99,  .999, iff(nValue1 < -.99, -.999, nValue1))
//     nFish = 0.5 * log((1 + nValue2) / (1 - nValue2)) + 0.5 * nz(nFish[1])
//     plot(nFish, color=green, title="Fisher")
//     plot(nz(nFish[1]), color=red, title="Trigger")
//+------------------------------------------------------------------+
int start() {
   double MinL=0, MaxH=0, nVal1=0, nVal1_prev=0, nVal2=0, hl2=0;
   
   //int i=Bars-FisherPeriod;
   int counted_bars=IndicatorCounted();
   
   if(counted_bars <1) {
      for(int j=1; j<=FisherPeriod; j++) {
         FishSigBuf[Bars-j] = 0;
         FishTrigBuf[Bars-j] = 0;
      }
   }
   //else {
   int i=Bars-FisherPeriod;
   if(counted_bars > FisherPeriod)
      i = Bars - counted_bars - 1;
   //}
   
   while(i>=0) {
      MaxH = High[iHighest(NULL,0,MODE_HIGH,FisherPeriod,i)];
      MinL = Low[iLowest(NULL,0,MODE_LOW,FisherPeriod,i)];
      
      //if(Low[i] == 0 || MaxH-MinL==0 || 1-nVal2==0) {
      //   log("DIVIDE BY ZERO! Low["+i+"]="+(string)Low[i]+", MaxH="+MaxH+", MinL="+MinL+", nVal2="+nVal2);
         //FishSigBuf[i] = 0;
         //FishTrigBuf[i] = 0;
         //i--;
      //   break;
      //}
      
      hl2 = (High[i]+Low[i])/2;
      nVal1 = 0.33*2* ((hl2 - MinL) / (MaxH - MinL) - 0.5) + 0.67*nVal1_prev;    
      //nVal2 = nVal1 > 0.99 ? 0.999 : nVal1 < -0.99 ? -0.999 : nVal1;
      nVal2 = MathMin(MathMax(nVal1,-0.999),0.999);
      FishSigBuf[i] = 0.5*MathLog((1+nVal2)/(1-nVal2)) + 0.5*FishSigBuf[i+1];
      FishTrigBuf[i] = FishSigBuf[i+1];
      i--;
      nVal1_prev=nVal1;
   }
   
   //dump(10);
   return(0);   
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void dump(int n) {
   string values="[";
   // Test for array bounds access
   //int max = ArraySize(FishSigBuf) > 10 ? 10 : ArraySize(FishSigBuf);
   
   for(int k=0; k<n; k++) {
      values+= DoubleToString(FishSigBuf[k],3) + ", ";
   }
   values+="]";
   log("Bars:"+Bars+", Counted:"+IndicatorCounted()+", Fisher.reverse().tail("+(string)n+"):"+values);
}