//+------------------------------------------------------------------+
//|                                              FX/ChartObjects.mqh |
//|                                       Copyright 2018, Sean Estey |
//+------------------------------------------------------------------+

#property copyright "Copyright 2018, Sean Estey"
#property strict

#include <FX/Logging.mqh>
#include <FX/Utility.mqh>

struct Rectangle {
   color clr;
   datetime dt1;
   double p1;
   datetime dt2;
   double p2;
};

//+---------------------------------------------------------------------------+
//| Create vertical line object
//+---------------------------------------------------------------------------+
void CreateVLine(int bar, string& objlist[]) {
   int id=0;
   string name = "vline_"+(string)bar;
   
   if(!ObjectCreate(id, name, OBJ_VLINE, 0, Time[bar-1], 0))
      return;   
   ObjectSetInteger(id, name, OBJPROP_COLOR, clrBlack); 
   ObjectSetInteger(id, name, OBJPROP_STYLE, STYLE_DASH); 
   ObjectSetInteger(id, name, OBJPROP_WIDTH, 1); 
   ObjectSetInteger(id, name, OBJPROP_BACK, false); 
   ObjectSetInteger(id, name, OBJPROP_SELECTABLE, false); 
   ObjectSetInteger(id, name, OBJPROP_SELECTED, false); 
   ObjectSetInteger(id, name, OBJPROP_HIDDEN, false); 
   ObjectSetInteger(id, name, OBJPROP_ZORDER, 0);
   appendStrArray(objlist, name);
}

//+---------------------------------------------------------------------------+
//| Create line object between 2 given points
//+---------------------------------------------------------------------------+
void CreateLine(string name, datetime dt1, double p1, datetime dt2, double p2, string& objlist[],
   const long chart_ID=0,             
   const color clr=clrBlack,
   const int width=2) {
   
   if(!ObjectCreate(chart_ID, name, OBJ_TREND, 0, dt1, p1, dt2, p2))
      return;   
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr); 
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, STYLE_SOLID); 
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width); 
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, true); 
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, false); 
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, false); 
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, false); 
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, 0);
   ObjectSetInteger(chart_ID, name, OBJPROP_RAY_RIGHT, false);
   appendStrArray(objlist, name);
}

//+----------------------------------------------------------------------------+
//| Create ArrowUp or ArrowDown chart object.
//+----------------------------------------------------------------------------+
void CreateArrow(string name, string symbol, int obj, int shift, color clr){ //string& objlist[]) { 
   double price, ypos=0;
   int width=7;
   datetime time=iTime(symbol,0,shift);   // anchor point time 
   ENUM_ARROW_ANCHOR anchor=0;             
   
   if(obj == OBJ_ARROW_UP) {
      anchor=ANCHOR_TOP;
      price=iLow(symbol,0,shift);     // anchor point price 
      ypos=price*0.9999;
   }
   else if(obj == OBJ_ARROW_DOWN) {
      anchor=ANCHOR_BOTTOM;
      price=iHigh(symbol,0,shift);
      ypos=price*1.0001;
   }
   else if(obj==OBJ_ARROW_STOP || obj==OBJ_ARROW_CHECK) {
      anchor=ANCHOR_TOP;
       price=iLow(symbol,0,shift);
      ypos=price*0.9999;
   }
   else {
      anchor=ANCHOR_BOTTOM;
      price=iHigh(symbol,0,shift);
      ypos=price*1.0001;
   }
   
   if(!ObjectCreate(0,name,obj,0,time,ypos)) {
      log("Error creating arrow '"+name+"'. Reason:"+(string)err_msg());
      return; 
   }
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor); 
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr); 
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID); 
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width); 
   ObjectSetInteger(0, name, OBJPROP_BACK, false); 
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false); 
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false); 
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false); 
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, name);
   //appendStrArray(objlist, name);
} 

//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
bool CreateText(string name, string text, int shift, ENUM_ANCHOR_POINT anchor,
   long price=0,
   const long chart_ID=0,             
   const int sub_window=0,
   const string font="Arial",
   const int font_size=10,
   const color clr=clrBlack,
   const double angle=0.0,
   const bool back=true,
   const bool selection=false,
   const bool hidden=true,
   const long z_order=0) { 
   
   double _price, offset;
   datetime time=iTime(Symbol(),0,shift);
    
   if(anchor==ANCHOR_UPPER) {
      offset=0.9999;
      price=price==0 ? iLow(Symbol(),0,shift)*offset : price*offset;
   }
   else if(anchor==ANCHOR_LOWER) {
      offset=1.0001;
      price=price==0 ? iHigh(Symbol(),0,shift)*offset : price*offset;
   }
      
   ResetLastError(); 
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price)){ 
      debuglog(__FUNCTION__+": Failed to create text obj! Desc:"+err_msg()); 
      return(false); 
   } 
   debuglog("Text obj created at bar "+(string)shift+", price:"+DoubleToStr(price,3));
   
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   // Anchors: ANCHOR_LOWER, ANCHOR_UPPER, ANCHOR_CENTER, etc
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);    
   return(true); 
} 

//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
bool CreateLabel(string text, string name,
   long x=150,
   long y=150, 
   ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, 
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER,
   const long chart_ID=0,             
   const int sub_window=0,
   const string font="Arial",
   const int font_size=12,
   const color clr=clrBlack,
   const double angle=0.0,
   const bool back=false,
   const bool selection=false,
   const bool hidden=true,
   const long z_order=0) { 
   
   if(StringLen(name) < 1)
      name=text;
   ResetLastError(); 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)){ 
      //Print(__FUNCTION__+": Failed to create text obj! Desc:"+err_msg()); 
      return(false); 
   } 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   /* ENUM_BASE_CORNER: [CORNER_LEFT_UPPER, CORNER_LEFT_LOWER, CORNER_RIGHT_LOWER, CORNER_RIGHT_UPPER] */
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
   /* NUM_ANCHOR_POINT: [ANCHOR_LEFT_UPPER, ANCHOR_LEFT, ANCHOR_LEFT_LOWER, ANCHOR_LOWER,
      ANCHOR_RIGHT_LOWER, ANCHOR_RIGHT, ANCHOR_RIGHT_UPPER, ANCHOR_UPPER, ANCHOR_CENTER] */
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);    
   return(true); 
} 

//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
bool CreateRect(datetime dt1,double p1,datetime dt2,double p2,string& objlist[],
   const long chart_ID=0,   
   const int sub_window=0,  
   const color           clr=clrLavender,   
   const ENUM_LINE_STYLE style=STYLE_SOLID,
   const int             width=1,          
   const bool            fill=true,       
   const bool            back=true,       
   const bool            selection=true,   
   const bool            hidden=true,      
   const long            z_order=0)        
  { 
  
   ResetLastError(); 
   string name="Rect_"+(string)dt1;
      
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,dt1,p1,dt2,p2)) { 
      //Print(__FUNCTION__+": failed to create a rectangle! Desc:"+err_msg());
      return(false); 
   } 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
   return(true); 
}

//+----------------------------------------------------------------------------+
//| Create rectangle label                                                     | 
//+----------------------------------------------------------------------------+
bool CreateLabelRect(const long             chart_ID=0,               
                     const string           name="RectLabel",         
                     const int              sub_window=0,             
                     const int              x=0,                      
                     const int              y=0,                      
                     const int              width=50,                 
                     const int              height=18,                
                     const color            back_clr=C'236,233,216',  
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, 
                     const color            clr=clrRed,               // flat border color (Flat) 
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style 
                     const int              line_width=1,             // flat border width 
                     const bool             back=false,               // in the background 
                     const bool             selection=false,          // highlight to move 
                     const bool             hidden=false,              // hidden in the object list 
                     const long             z_order=0)                // priority for mouse click 
  { 
   ResetLastError(); 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)) { 
      Print(__FUNCTION__, 
            ": failed to create a rectangle label! Error code = ",GetLastError()); 
      return(false); 
   } 
   //--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
   //--- set label size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
   //--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
   //--- set border type 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border); 
   //--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
   //--- set flat border color (in Flat mode) 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   //--- set flat border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
   //--- set flat border width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width); 
   //--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
   //--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
   //--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
   //--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
   //--- successful execution 
   return(true); 
} 