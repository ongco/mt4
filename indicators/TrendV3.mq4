//+------------------------------------------------------------------+
//|                                                      TrendV2.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   10
//--- plot MA10
#property indicator_label1  "MA10"
#property indicator_type1   DRAW_NONE
#property indicator_color1  clrWhite
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BullTrend
#property indicator_label2  "BullTrend"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot WeakBullTrend
#property indicator_label3  "WeakBullTrend"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrViolet
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot BearTrend
#property indicator_label4  "BearTrend"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrForestGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot WeakBearTrend
#property indicator_label5  "WeakBearTrend"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrLightGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Swing
#property indicator_label6  "Swing"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrWhite
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

#property indicator_color7 clrRed
#property indicator_color8 clrRed
#property indicator_width7 3
#property indicator_width8 3

#property indicator_color9 clrYellow
#property indicator_color10 clrYellow
#property indicator_width9 3
#property indicator_width10 3


double WarningBodyHigh[],WarningBodyLow[];
double IncBodyHigh[],IncBodyLow[];
//--- indicator buffers
double         MA10Buffer[];
double         BullTrendBuffer[];
double         WeakBullTrendBuffer[];
double         BearTrendBuffer[];
double         WeakBearTrendBuffer[];
double         SwingBuffer[];


input int InpFastEMA=10;   // Fast EMA Period
input int InpSlowEMA=20;   // Slow EMA Period


int getShift()
{
   int curMin = Minute();
   int shift = 0;
   if(curMin < 15) {
      shift = 1;
   } else if(curMin >=15 && curMin < 30) {
      shift = 2;
   } else if(curMin >=30 && curMin < 45) {
      shift = 3;
   }
   
   return shift;
}


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MA10Buffer);
   SetIndexBuffer(1,BullTrendBuffer);
   SetIndexBuffer(2,WeakBullTrendBuffer);
   SetIndexBuffer(3,BearTrendBuffer);
   SetIndexBuffer(4,WeakBearTrendBuffer);
   SetIndexBuffer(5,SwingBuffer);
   
   SetIndexBuffer(6, WarningBodyHigh);
   SetIndexBuffer(7, WarningBodyLow);
   
   SetIndexBuffer(8, IncBodyHigh);
   SetIndexBuffer(9, IncBodyLow);
   
   SetIndexStyle(6, DRAW_HISTOGRAM);
   SetIndexStyle(7, DRAW_HISTOGRAM);
   
   SetIndexStyle(8, DRAW_HISTOGRAM);
   SetIndexStyle(9, DRAW_HISTOGRAM);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

      int i, limit;
      
      // 最少需要72小时的数据
      if(rates_total<=72)
         return 0;
      
     
         
      
         
      //--- last counted bar will be recounted
      limit=rates_total-prev_calculated;
      if(prev_calculated>0)
         limit++; 
      
     for(i=0; i< limit; i++) 
     {
         // 计算EMA10 20
         MA10Buffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i);
         
         
         SwingBuffer[i] = iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
         WeakBullTrendBuffer[i] = BullTrendBuffer[i] = SwingBuffer[i];
         BearTrendBuffer[i] = WeakBearTrendBuffer[i] =  SwingBuffer[i];

     }
     
     
     
     for(i=rates_total - InpSlowEMA; i >=  0; i--) 
     {
     
         
       // 计算Sto
       double stochastic = iStochastic(NULL,NULL,8,3,3,MODE_EMA,0,MODE_MAIN,i);
       double stochastic_prev = iStochastic(NULL,NULL,8,3,3,MODE_EMA,0,MODE_MAIN,i+1);
       
       if(stochastic_prev < 20 && stochastic >= 20) 
       {
         WarningBodyHigh[i] = MathMax(close[i], open[i]);
         WarningBodyLow[i] = MathMin(close[i], open[i]);
       } else if(stochastic_prev >= 80 && stochastic < 80)
       {
         WarningBodyHigh[i] = MathMax(close[i], open[i]);
         WarningBodyLow[i] = MathMin(close[i], open[i]);
         
       }
       
       // 计算基准线Kijun-sen
       double kijun_sen = iIchimoku(NULL, 0, 7, 22, 44, MODE_KIJUNSEN, i);
       double tenkan_sen = iIchimoku(NULL, 0, 7, 22, 44, MODE_TENKANSEN, i);
       
       // 判断上升趋势
       if(close[i] >= kijun_sen && tenkan_sen >= kijun_sen) 
       {
         if(close[i] >= MA10Buffer[i] && close[i] >= BullTrendBuffer[i]) 
         {
            
            WeakBullTrendBuffer[i] = BearTrendBuffer[i] = WeakBearTrendBuffer[i] = SwingBuffer[i] = EMPTY_VALUE;
            
           
                       
            continue;
         } 
            
           
            
                      
            
         
         if(close[i] >= MA10Buffer[i] && close[i] <= BullTrendBuffer[i] )
         {
            
            BullTrendBuffer[i] = BearTrendBuffer[i] = WeakBearTrendBuffer[i] = SwingBuffer[i] = EMPTY_VALUE;
            continue;
         }
                  
       }
       
       // 判断下降趋势
       if(close[i] <= kijun_sen && tenkan_sen <= kijun_sen) 
       { 
         if(close[i] <= MA10Buffer[i] && close[i] <= BullTrendBuffer[i]) 
         {
            
           
            
            WeakBullTrendBuffer[i] = BullTrendBuffer[i] = WeakBearTrendBuffer[i] = SwingBuffer[i] = EMPTY_VALUE;
            continue;
         } 
         
         
         if(close[i] >= MA10Buffer[i] && close[i] <= BullTrendBuffer[i] )
         {
            
            BullTrendBuffer[i] = WeakBullTrendBuffer[i] = BearTrendBuffer[i] = SwingBuffer[i] = EMPTY_VALUE;
            continue;
         }
         
       
       }
       
       
       
      
     }
        
   //--- return value of prev_calculated for next call
      return(rates_total);
  }
//+------------------------------------------------------------------+
