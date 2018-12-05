//+------------------------------------------------------------------+
//|                                                   FX/Utility.mqh |
//|                                       Copyright 2018, Sean Estey |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Sean Estey"
#property strict


//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
bool NewBar() {
    static datetime lastbar;
    datetime curbar = Time[0];  
    if(lastbar != curbar) {
       lastbar=curbar;
       return true;
    }
    else
      return false;
}

//*****************************************************************************/
//+***************************** STATISTICS ***********************************+
//*****************************************************************************/

//+----------------------------------------------------------------------------+
//| Variance                                                                   |
//+----------------------------------------------------------------------------+
double Variance(double &arr[],double mx) {
   int size=ArraySize(arr);
   if(size<=1) {
      Print(__FUNCTION__+": array size error");
      return(EMPTY_VALUE);
   }
   double sum=0.0;
   for(int i=0;i<size;i++)
      sum+=MathPow(arr[i]-mx,2);
   return(sum/(size-1));
}

//+----------------------------------------------------------------------------+
//| Arithmetical mean of entire sampling                                       |
//+----------------------------------------------------------------------------+
double Average(double &arr[]) {
   int size=ArraySize(arr);
   if(size<=0) {
      Print(__FUNCTION__+": array size error");
      return(EMPTY_VALUE);
   }
   double sum=0.0;
   for(int i=0;i<size;i++)
      sum+=arr[i];
   return(sum/size);
}

//-----------------------------------------------------------------------------+
//+********************************** UNITS ***********************************+
//-----------------------------------------------------------------------------+

double ToPips(double price) {
   double dig=MarketInfo(Symbol(),MODE_DIGITS);
   double pts=MarketInfo(Symbol(),MODE_POINT);
   return price/pts;
}  

string ToPipsStr(double price, int decimals=0) {
   double dig=MarketInfo(Symbol(),MODE_DIGITS);
   double pts=MarketInfo(Symbol(),MODE_POINT);
   return DoubleToStr(price/pts,decimals);
}

//-----------------------------------------------------------------------------+
//+********************************** DATATYPES *******************************+
//-----------------------------------------------------------------------------+

string intArrayToStr(int& anArray[]) {
   string s="[";
   for(int i=0;i<ArraySize(anArray); i++) {
      if(anArray[i] != 0)
         s+=(string)anArray[i]+",";
   }
   s+="]";
   return s;
}

void appendIntArray(int& array[], int x){
   ArrayResize(array, ArraySize(array)+1);
   array[ArraySize(array)-1]=x;
}

void appendStrArray(string& array[], string x){
   ArrayResize(array, ArraySize(array)+1);
   array[ArraySize(array)-1]=x;
}

string strArrayToStr(string& anArray[]) {
   string s="[";
   for(int i=0;i<ArraySize(anArray); i++) {
      //if(anArray[i])
      s+=anArray[i]+",";
   }
   s+="]";
   return s;
}

void appendDtArray(datetime& dtarray[], datetime dt){
   ArrayResize(dtarray, ArraySize(dtarray)+1);
   dtarray[ArraySize(dtarray)-1]=dt;
}

string dtArrayToStr(datetime& anArray[], int n) {
   string s="[";
   
   for(int i=0;i<n && i<ArraySize(anArray); i++) {
      if(anArray[i])
         s+=TimeToString(anArray[i],TIME_DATE|TIME_MINUTES)+", ";
   }
   s+="]";
   return s;
}