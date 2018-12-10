//+----------------------------------------------------------------------------+
//|                                                              FX/Swings.mqh |
//|                                                 Copyright 2018, Sean Estey |
//+----------------------------------------------------------------------------+
#property copyright "Copyright 2018, Sean Estey"
#property strict
#include <FX/Utility.mqh>
#include <FX/Draw.mqh>

//---Enums
enum SwingType {SWING_HIGH, SWING_LOW};
enum SwingLength {THREE_BAR, FIVE_BAR};
enum SwingTerm {NONE,STL,STH,ITL,ITH,LTL,LTH};

//---Globals
string SwingLabels[7] = {"None","STL","STH","ITL","ITH","LTL","LTH"};

//-----------------------------------------------------------------------------+
/* A high/low candle surrounded by 2 lower highs/higher lows.
 * Categorized into: Short-term (ST), Intermediate-term (IT), Long-term (LT) */
//-----------------------------------------------------------------------------+
class Swing {
   public:
      SwingType Type;
      SwingTerm Term;
      SwingLength Length;
      string Name;
      int TF;
      datetime DT;
      int Shift;
      double O;
      double C;
      double H;
      double L;
      bool IsAnnotated;
      
      //-----------------------------------------------------------------------+
      void Swing(string name, int tf, int shift, SwingType type, SwingTerm term, SwingLength len) {
         this.Type=type;
         this.Term=term;
         this.Length=len;
         this.Name=name;
         this.TF=tf;
         this.Shift=shift;
         this.DT=Time[shift];
         this.O=Open[shift];
         this.C=Close[shift];
         this.H=High[shift];
         this.L=Low[shift];
         this.IsAnnotated=false;
      }
      
      //-----------------------------------------------------------------------+
      void ~Swing() {
         ObjectDelete(0,this.Name);
         debuglog("Swing destructor");
      }
      
      //-----------------------------------------------------------------------+
      void Annotate(bool toggle){
         if(toggle==true) {
            if(Term==STL || Term==ITL || Term==LTL)
               CreateText(this.Name, SwingLabels[Term], Shift, ANCHOR_UPPER,0,0,0,
                  "Arial",8,clrBlack);
            else if(Term==STH || Term==ITH || Term==LTH)
               CreateText(this.Name, SwingLabels[Term], Shift, ANCHOR_LOWER,0,0,0,
                  "Arial",8,clrBlack);
            IsAnnotated=true;
         }
         else {
            ObjectDelete(0,this.Name);
            IsAnnotated=false;
         }
      }
      
      //-----------------------------------------------------------------------+
      string ToString(){return "Swing at "+TimeToStr(DT)+", Close:"+(string)C;}
};

//+****************************** METHODS *************************************+


//+---------------------------------------------------------------------------+
//| 
//+---------------------------------------------------------------------------+
void AppendSwing(Swing* c, Swing* &list[]) { 
   ArrayResize(list, ArraySize(list)+1);
   list[ArraySize(list)-1]=c;
}

//+---------------------------------------------------------------------------+
//| 
//+---------------------------------------------------------------------------+
Swing* GetSwing(int shift, Swing* &list[]){
   for(int i=0; i<ArraySize(list); i++) {
      if(list[i].Shift == shift)
         return list[i];
   }
   log("Swing not found! searched "+(string)ArraySize(list)+" items");
   return NULL;
}



//+---------------------------------------------------------------------------+
//| Find Short-term, Intermediate-term, and Long-term Highs/Lows (swings)
//+---------------------------------------------------------------------------+
void UpdateSwings(string symbol, ENUM_TIMEFRAMES tf, int shift1, int shift2, color clr,
                     const double &lows[], const double &highs[],
                     Swing* &sl[], Swing* &sh[], string& objs[]) {   
   
   if(ArraySize(sh) > 1 || ArraySize(sl) > 1) {
      log("SwingLabels already created. Call destructor on existing pointer arrays before recreating.");
      return;
   }
   
   // First pass: find Short-Term swings. Iterate Bars left-to-right 
   for(int i=shift1; i>=shift2; i--) {      
      if(isSwing(i, SWING_HIGH, THREE_BAR, highs)) {
         Swing* c=new Swing("sh_"+(string)i+"_3bar", tf,i,SWING_HIGH,STH,THREE_BAR);
         AppendSwing(c, sh);
      }
      else if(isSwing(i, SWING_LOW, THREE_BAR, lows)) {
         Swing* c=new Swing("sl_"+(string)i+"_3bar", tf,i,SWING_LOW,STL,THREE_BAR);
         AppendSwing(c, sl);
      }   
   }

   // Second pass: find Intermediate-Term Swings
   // Iterate left-to-right on swing arrays
    for(int i=1; i<ArraySize(sh)-1; i++) {
      Swing* c=sh[i];
      if(c.H <= sh[i-1].H || c.H <= sh[i+1].H)
         continue;
      c.Annotate(false);
      c.Term=ITH;
      c.Annotate(true);
   }
   for(int i=1; i<ArraySize(sl)-1; i++) {
      Swing* c=sl[i];
      if(c.L >= sl[i-1].L || c.L >= sl[i+1].L)
         continue;
      c.Annotate(false);
      c.Term=ITL;
      c.Annotate(true);
   }  
   
   // Final pass: find Long-Term Swings
   for(int i=1; i<ArraySize(sh); i++) {
      bool lmatch=false, rmatch=false;
      
      // Iterate to left of i and test first ITH
      for(int j=i-1; j>=0; j--) {
         if(sh[j].Term==LTH)
            break;
         if(sh[j].Term!=ITH)
            continue;
         if(sh[j].H<sh[i].H)
            lmatch=true;
         break;
      }
      // Iterate to right of i and test first ITH
      for(int j=i+1; j<ArraySize(sh); j++) {
         if(sh[j].Term==LTH)
            break;
         if(sh[j].Term!=ITH)
            continue;
         if(sh[j].H<sh[i].H)
            rmatch=true;
         break;
      }
      if(lmatch==true && rmatch==true){
         sh[i].Annotate(false);
         sh[i].Term=LTH;
         sh[i].Annotate(true);
      }
   }
   for(int i=1; i<ArraySize(sl); i++) {
      bool lmatch=false, rmatch=false;
      
      for(int j=i-1; j>=0; j--) {
         if(sl[j].Term==LTL)
            break;
         if(sl[j].Term!=ITL)
            continue;
         if(sl[j].L>sl[i].L){
            lmatch=true;
            break;
         }
      }
      for(int j=i+1; j<ArraySize(sl); j++) {
         if(sl[j].Term==LTL)
            break;
         if(sl[j].Term!=ITL)
            continue;
         if(sl[j].L>sl[i].L)
            rmatch=true;
         break;
      }
      if(lmatch==true && rmatch==true){
         sl[i].Annotate(false);
         sl[i].Term=LTL;
         sl[i].Annotate(true);
      }
   }
}

//+---------------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
bool isSwing(int offset, SwingType type, SwingLength len, const double &list[]) {
   int min_offset= len==THREE_BAR ? 1 : 2;
   int max_offset= len==THREE_BAR ? ArraySize(list)-2 : ArraySize(list)-3;
  
   if(offset < min_offset || offset > max_offset)
      return false;
  
   if(len==THREE_BAR) {
      if(type==SWING_HIGH)
         if(list[offset] > list[offset+1] && list[offset] > list[offset-1])
            return true;
         else
            return false;
      else if(type==SWING_LOW)
         if(list[offset] < list[offset+1] && list[offset] < list[offset-1])
            return true;
         else
            return false;
   }
   else if(len==FIVE_BAR) {
      if(type==SWING_HIGH)
         if(list[offset]>list[offset-1] && list[offset-1]>list[offset-2] && list[offset]>list[offset+1] && list[offset+1]>list[offset+2])
            return true;
         else
            return false;
      else if(type==SWING_LOW)
         if(list[offset]<list[offset-1] && list[offset-1]<list[offset-2] && list[offset]<list[offset+1] && list[offset+1]<list[offset+2])
            return true;
         else
            return false;
   }
   return -1;
}

//+---------------------------------------------------------------------------+
//| Connect each significant swing (>short-term) by a line labelled with the
//| difference in YPOS.
//+---------------------------------------------------------------------------+
int ShowSwingVariances(string symbol, ENUM_TIMEFRAMES tf, Swing* &list[], string& objs[]) {
   if(ArraySize(list) < 1) {
      log("ShowSwingVariance(): Swing array is empty.");
      return -1;
   }
   
   // Filter out Short-Term and Unlabelled swings
   Swing* filtered[];
   for(int i=0; i<ArraySize(list)-1; i++) {
      if(list[i].Term==NONE || list[i].Term==STH || list[i].Term==STL)
         continue;
      AppendSwing(list[i],filtered);
   }
   
   debuglog("Filtered Swing list from "+(string)ArraySize(list)+" to "+(string)ArraySize(filtered));
   
   Swing* a;
   Swing* b;

   for(int i=0; i<ArraySize(filtered)-1; i++) {
      a=filtered[i];
      b=filtered[i+1];
      
      double a_p=a.Type==SWING_HIGH ? a.H : a.L;
      double b_p=b.Type==SWING_HIGH ? b.H : b.L;
      // Connect both  points with a trendline      
      CreateLine("diff_"+(string)a.Shift,a.DT,a_p,b.DT,b_p,objs,0,clrRed,1);
      
      // Annotate the center of the line with the height diff
      int center_bar=a.Shift-MathFloor((a.Shift-b.Shift)/2);
      double y_diff = MathAbs(a_p-b_p);
      string txt_name="diff_"+(string)a.Shift+"_txt";
      
      CreateText(txt_name,DoubleToStr(y_diff,3),center_bar,
         a.Type==SWING_HIGH? ANCHOR_LOWER : ANCHOR_UPPER,
         a_p<b_p ? a_p+(y_diff/2) : b_p+(y_diff/2),
         0,0,"Arial",8, clrRed);
      appendStrArray(objs, txt_name);
      
      debuglog("Connected Swings "+(string)a.Shift+"-"+(string)b.Shift+", YDiff:"+DoubleToStr(y_diff,3));
   }
   return 1;
}

//+---------------------------------------------------------------------------+
//| Given a significant SL and SH, find the pivot close to the mean which has
//| the highest amount of swings around it.
//+---------------------------------------------------------------------------+
int FindPivot(Swing* s1, Swing* s2){
   if(s1.DT>=s2.DT) {
      log("FindPivot Error: s1.DT must be less than s2.DT");
      return -1;
   }
     
   double high=s1.H>s2.H ? s1.H : s2.H;
   double low=s2.L<s1.L ? s2.L : s1.L;
   double mean=(high+low)/2;
   //double v=mean/1000;
   
   double piv2=mean-(mean-low)/25;
   double piv3=mean+(high-mean)/25;
   
   debuglog("FindPivot inputs: Bars "+(string)s2.Shift+"-"+(string)s1.Shift+", Range:"+DoubleToStr(low,4)+"-"+DoubleToStr(high,4));
   
   int piv1_res = Intersects(mean,s1.DT, s2.DT);
   int piv2_res = Intersects(piv2,s1.DT, s2.DT);
   int piv3_res = Intersects(piv3,s1.DT, s2.DT);
   
   debuglog("FindPivot output: pivot #1 (mean):"+DoubleToStr(mean,2)+", touches:"+(string)piv1_res);
   debuglog("FindPivot output: pivot #2:"+DoubleToStr(piv2,2)+", touches:"+(string)piv2_res);
   debuglog("FindPivot output: pivot #3:"+DoubleToStr(piv3,2)+", touches:"+(string)piv3_res);
   
   return 1;
}

//+---------------------------------------------------------------------------+
//| dt1: datetime of left chart bar (lower)
//| dt2: datetime of right chart bar (higher)
//+---------------------------------------------------------------------------+
int Intersects(double price, datetime dt1, datetime dt2) {
   if(dt1>=dt2){
      log("Intersects() dt1 must have lower datetime value than dt2");
      return -1;
   }
   int n_touches=0;
   int n_bars=Bars(Symbol(),0,dt1,dt2);
   datetime dt = dt1;
   
   debuglog("Intersects() P:"+DoubleToStr(price,3));
   
   for(int i=0; i<n_bars; i++){
      int shift=iBarShift(Symbol(),0,dt);
      if(price<=iHigh(Symbol(),0,shift) && price>=iLow(Symbol(),0,shift)) {
         n_touches++;
         debuglog("Bar "+(string)shift+": found intersection. Touches:"+(string)n_touches);
      }
      dt+=PeriodSeconds();
   }
   return n_touches;
}