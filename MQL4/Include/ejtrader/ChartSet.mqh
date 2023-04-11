input string SectionColor="============== Layout Config ====================";//===================================================
enum ColorSelectd
  {
  COLOR__REDBLUE,// Blue / Red
   COLOR_REDGREEN,// Green / Red
   
  };
//--
input ColorSelectd ColorsCharts=COLOR__REDBLUE;// Color
color COLOR_DOWN=clrNONE;
color COLOR_UP=clrNONE;
color _INPcolorDefault=Black;
color _INPcolorDefaultB=White;
void ColorChartss()
{


 //-- Initialize Colors
   if(ColorsCharts!=COLOR_REDGREEN)
     {
      COLOR_DOWN=clrRed;
      COLOR_UP=DodgerBlue;
     }
   else
     {
      COLOR_DOWN=clrRed;
      COLOR_UP=clrLimeGreen;
     }
      ResetLastError();
      if(!ChartSetInteger(0,CHART_SHOW_DATE_SCALE,0,true))
         Print(__FUNCTION__+", Error Code = ",GetLastError());
      if(!ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,0,true))
         Print(__FUNCTION__+", Error Code = ",GetLastError());
         
         
     if(!ChartSetInteger(0,CHART_AUTOSCROLL,0,false))
         Print(__FUNCTION__+", Error Code = ",GetLastError());
// CHART COLOR AND DESIGN
          ChartSetInteger(0,CHART_FOREGROUND,false);
           if(!ChartSetInteger(0,CHART_COLOR_BACKGROUND,0,_INPcolorDefault)) 
         Print(__FUNCTION__+",BACKGROUD Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_FOREGROUND,0,_INPcolorDefaultB)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_GRID,0,C'36,43,47')) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_ASK,0,Yellow)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_BID,0,Red)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CHART_DOWN,0,COLOR_DOWN)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CHART_LINE,0,White)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CHART_UP,0,COLOR_UP)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,0,Red)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_VOLUME,0,Green)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
         
         
         ChartSetInteger(0,CHART_SHOW_GRID,true); // Hide the Grid.
         ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,false);// Hide Periodo
         ChartSetInteger(0,CHART_SHOW_ASK_LINE,false);
         ChartSetInteger(0,CHART_AUTOSCROLL,false);
         ChartSetInteger(0,CHART_BRING_TO_TOP,false);
         ChartSetInteger(0,CHART_SHIFT,true);
         ChartSetInteger(0,CHART_SHOW_ONE_CLICK,false);
         ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
          ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,true);
          ChartSetInteger(0,CHART_SHOW_BID_LINE,true);
        
}        




void PriceScale()
{
//CHART PRICE AND TIME SCALE 
   
   ResetLastError();
      if(!ChartSetInteger(0,CHART_SHOW_DATE_SCALE,0,false))
         Print(__FUNCTION__+", Error Code = ",GetLastError());
      if(!ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,0,false))
         Print(__FUNCTION__+", Error Code = ",GetLastError());
         
         // CHART COLOR AND DESIGN
           if(!ChartSetInteger(0,CHART_COLOR_BACKGROUND,0,_INPcolorDefault)) 
         Print(__FUNCTION__+",BACKGROUD Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_FOREGROUND,0,_INPcolorDefaultB)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_GRID,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_ASK,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_BID,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CHART_DOWN,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CHART_LINE,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_CHART_UP,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
      if(!ChartSetInteger(0,CHART_COLOR_VOLUME,0,clrNONE)) 
         Print(__FUNCTION__+", Código de erro = ",GetLastError());
         ChartSetInteger(0,CHART_SHOW_GRID,false); // Hide the Grid.
         
         
         ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,false);// Hide Periodo
         ChartSetInteger(0,CHART_SHOW_ASK_LINE,false);
         ChartSetInteger(0,CHART_AUTOSCROLL,false);
         ChartSetInteger(0,CHART_BRING_TO_TOP,false);
         ChartSetInteger(0,CHART_SHIFT,true);
         ChartSetInteger(0,CHART_SHOW_ONE_CLICK,false);
         ChartSetInteger(0,CHART_SHOW_DATE_SCALE,false);
         ChartSetInteger(0,CHART_SHOW_BID_LINE,false);
         ChartSetInteger(0,CHART_SHOW_OHLC,false);
         ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,false);
         ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,false);
         ChartSetInteger(0,CHART_SHOW_VOLUMES,false);
         ChartSetInteger(0,CHART_MODE,CHART_LINE);
         
         }
