
#property copyright "Copyright © 2017-2023, Ejtrader"
#property link "https://bitcoinnano.org"
#define VERSION "1.0"
#property version VERSION
#property description "Forex - Order Flow" + " - Power By Bitcoin Nano API"
#property icon "ejicon.ico"

#include <ejtrader/hash.mqh>
#include <ejtrader/json.mqh>
#include <ejtrader/PortMap.mqh>
#include <ejtrader/ChartSet.mqh>
#include <ejtrader/http.mqh>
#include <Zmq/Zmq.mqh>

#define MAX_ORDERS 1


#import "unlock.dll"
int DetachChart2(int a0, int a1);
#import

#import "wininet.dll"
int DeleteUrlCacheEntry(string fileName);
#import

#import "user32.dll"
int PostMessageA(int hWnd,int Msg,int wParam,int lParam);
int SetWindowLongA(int hWnd, int nIndex, int dwNewLong);
int GetWindowLongA(int hWnd, int nIndex);
int SetWindowPos(int hWnd, int hWndInsertAfter, int X, int Y, int cx, int cy, int uFlags);
int GetParent(int hWnd);
int GetTopWindow(int hWnd);
int GetWindow(int hWnd, int wCmd);
#import

int               intParent;
int               intChild;

#define GWL_STYLE         -16
#define WS_CAPTION        0x00C00000
#define WS_BORDER         0x00800000
#define WS_SIZEBOX        0x00040000
#define WS_DLGFRAME       0x00400000
#define SWP_NOSIZE        0x0001
#define SWP_NOMOVE        0x0002
#define SWP_NOZORDER      0x0004
#define SWP_NOACTIVATE    0x0010
#define SWP_FRAMECHANGED  0x0020
#define GW_CHILD          0x0005
#define GW_HWNDNEXT       0x0002
//--- to download the xml

#import "urlmon.dll"
int URLDownloadToFileW(int pCaller, string szURL, string szFileName, int dwReserved, int Callback);
#import




string xmlFileName = "EJTrader.ex4";
#define INAME ""

bool AllowUpdates = true; // Permitir atualizações
int UpdateHour = 24; // Atualize cada (em horas)
datetime xmlModifed;
int TimeOfDay;
datetime Midnight;
string sData;

string sic;

//-- Layout

enum layoutMaker
  {



   bookmicro, // Market Depth HD
   booksmall, // Market Depth FULLHD
   bookOnChart,// Market Depth CHART
   BookMap,   //  Xray Map



  };
input layoutMaker layout = bookmicro; // Layout
color bords;
input string SectionLogin = "==== Login API ===="; //===================================================
input static string genpub="6]&Tu69}*8wPDW&]dZ*@/NT<j):464xNauDn}&yM"; // Public Key
input static string gensec="iik8-mg<Q.tN47Va%ZX&e%0NB)O{V>+:NISEd!(/"; // secret Key

input string SectionAggression = "==== Aggression Config Market Depth On Chart ===="; //===================================================
input bool Futures=True; // futures
input int VolumeAggression=10; //  Chart Aggression Min Volume
input color VCAggressionB=DodgerBlue; // Buyer Aggression Color
input color VCAggressionS=clrRed; // Seller Aggression Color
input bool SoundIsEnabled = false; //Soud Alert
string Gs_1576 = "BNextBar_";
extern bool ShowNextCandleTime=True; //Show Next Candle Time
int NextCandleTimeTextColor=clrWhite; //Color Next Candle Time
input string Keyboard_Shortcuts = "==== Keyboard Shortcuts ===="; //===================================================
input string MouseCross="F"; //   Mouse Cross
input string AUTOSCROLL="G";//    Auto Scroll
input string ZoomIN="A";// Zoom In
input string ZoomOUT="S";// Zoom Out
input string PriceEtiquet="E"; // Price Tag
input string CreatTrendMark="Y"; //Create TrendMark
input string TrendLine="T"; //Create TrendLine
input string DeleteTrend="R"; //   Delete All Trend
input string DeleteAG="X";// Delete Aggression Chart
color ColorMedian;
string AG = "alert2.wav";
color FontColor = Gray;
color FontColorPlus = Lime;
color FontColorMinus = Red;
double MyPoint = 0.0;
string MySymbol = "";
color FontChanger;

bool resultt = false;
int Forex_Shift = 0;


//==== T&S Parameters ====
bool Show_TS = true; // Show Time and Sales Graph?

int MinVolume = 0;
bool MergeVolume = true; // Merge volume of same type&time&price
string Rows = "100";

color Title_Color = Gray;
color ASK_Color = Lime;
color BID_Color = Red;
color NA_Color = White;

color Time_NA_Color = White;
long LargeVolumeThreshold;
color LargeVolume_ASK_Color = DeepSkyBlue;
color LargeVolume_BID_Color = HotPink;
color LargeVolume_NA_Color = White;

color Background = Black;
color Border = Gray;


//==== DOM Parameters ====
int Width_In_Pixels;
bool Display_DOM = true; // Show Depth of Market?
bool Show_PRICE = true;
bool Show_VOLUME = true;
bool Use_Forex_Shift = true;
color PriceColor = LightGray;
color VolumeColor = LightGray;
color DOM_Buy_Color = DodgerBlue;
color DOM_Sell_Color = Red;
bool Show_Sum = true;
long Sum_DOM_Ask, Sum_DOM_Bid;
static long Delta_DOM_Bid, Delta_DOM_Ask;
double priceBid;
static double dBid_Price;
double bookLevel;
double ArBid;
string RiskReward = "";
//-----------------------------
int Ask_Bib_Diff;

int PriceXX = 150;
int PriceYY = 360;
int FontSize = 10;
string FontType = "Arial";

string BookObjectLevel[15] =
  {
   "1","2","3","4","5","6","7","8","9","10","11","12","13","14","14"
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string SectionRiskManager = "==== Order Config ===="; //===================================================


input double StartLots = 0.01; // Manual Lots

//-- Risk Manager
input bool AutoRiskManger = false; // Auto Risk Management
input double Risk = 01; // Risk %
input bool AutoStop = false; // Auto SL &TP
input int TakeProfit = 100; // Take Profit
input int StopLoss = 30; // Stop Loss




input bool BreakevenEnable = false; // Auto Breakeven
input int Breakeven = 10; // Breakeven



int TralingStop = 45;

input double Percent = 50.0; // Partial Close %
input int Slippage = 3; // Slippage
input bool MaximumOrders = true; // 1 Openorder maximum

double SLL, TPP;
int Magic = 0;


string Puti = "", InpFileName = "", info[], pprefix = "EJ";
double tp = 0, sl = 0, tr = 0, br = 0, wlot = 0, glot = 0;
string Pprefix="AG";

string newSymbol;

bool upperCase = true;

bool lowerCase = true;
static double Datafeed;
string Gap;
int ArbPontos = 1; // Arbitrage pipettes
enum PortFeed
  {



   A = 10101, // FastFeed 1
   B = 40060, //  FastFeed 2
   C = 40050, //  FastFeed 3


  };
PortFeed Port = A; // FastFeed


template <typename T>
class PointerGuard
  {
public:
   T                 *p;
                     PointerGuard(T *raw = NULL): p(raw)
     {}~PointerGuard()
     {
      if(CheckPointer(p) != POINTER_INVALID)
         delete p;
     }
  };


int ActualWidth;

int X_coord = 50;
int Y_coord = 40;

static bool AlreadyInit = false;
static bool DeInit = false;
int Lines = 25;



Context context;
Socket socket(context, ZMQ_SUB);

PollItem pi[1];

JSONParser jsonParser;

string CurrentSymbol;
int CurrentDigits;

string ServerAddress = "";


datetime ExpirationDate = 0;
string UserName = "";
string ExpiDate = "";
static string ServerKey="JY%:%zEd6w]<6Z<%d]Ug&oy*-)XmAHJOFjfQUt8t";



int MILLISECOND_TIMER = 1;




// Modify below the color for your Bottom and top lines
color    Bottom_Line_Color = DodgerBlue;  // Color of bottom lines
color    Top_Line_Color    = Red;     // Color of Top lines

// Modify below the properties of the lines
int      Line_Width        = 1;           // From 1 (thin) to 5 (thick)
int      Line_length       = 4000;        // Length of segment line.
bool     Line_Ray          = false;       // If "true" all lines will be drawn as a "Ray" (Long Line). If false = as a segment.

// Modify below the properties of the text
bool     Insert_Text       = false;        // If true the level value will be displayed below or above the line. False = Not displayed
double   Dist_Text         = 4;           // Distance of text from line line (percent value of the window vertical high)
int      Font_Size         = 8;           // Font size of the text
color    Text_Color        = Brown;       // Color of the text displayed below or above the line
int      Length_Factor;
double   Text_Dist;
color    Line_ColorTrend;
double            ClickPrice;
double            MousePrice;
datetime          MouseDate;
int screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
int base_width = 144;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int scale_factor=(TerminalInfoInteger(TERMINAL_SCREEN_DPI) * 100) / 96;
//+------------------------------------------------------------------+
//| Receiver initialization                                          |
//+------------------------------------------------------------------+
int OnInit()
  {



   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
   intParent= GetParent(WindowHandle(Symbol(),Period()));
   intChild = GetWindow(intParent,0);

//Z85::generateKeyPair(genpub,gensec);
// Prepare our context and socket

   socket.setCurvePublicKey(genpub);
   socket.setCurveSecretKey(gensec);
   socket.setCurveServerKey(ServerKey);




  
   ColorChartss();
//--- Delete OBJECT
   int obj_total = ObjectsTotal();
   for(int i = 0; i < obj_total; i++)
      while((StringSubstr(ObjectName(i), 0, 2) == "EJ"))
        {
         ObjectDelete(ObjectName(i));
        }
//----------------------------------------------------------------------------------------------------------

for(int i = 0; i < obj_total; i++)
      while((StringSubstr(ObjectName(i), 0, 2) == "AG"))
        {
         ObjectDelete(ObjectName(i));
        }

   EventSetMillisecondTimer(MILLISECOND_TIMER); // Set Millisecond Timer to get client socket input
   double lots = MathMin(AccountBalance(), AccountFreeMargin()) *Risk / StopLoss / (MarketInfo(Symbol(), MODE_TICKVALUE));
   lots = lots / 100;
//-----------Symbol spread by broker digit

   MyPoint = Point;
   if(Digits == 3 || Digits == 5)
      MyPoint = Point * 10;

   MySymbol = Symbol();
   if(AutoRiskManger)
     {
      if(lots < MarketInfo(_Symbol, MODE_MINLOT))
         wlot = MarketInfo(_Symbol, MODE_MINLOT);
      else
         wlot = lots;

      if(lots > MarketInfo(_Symbol, MODE_MAXLOT))
         wlot = MarketInfo(_Symbol, MODE_MAXLOT);
      else
         wlot = lots;
      glot = wlot;
     }
   else
     {
      if(StartLots < MarketInfo(_Symbol, MODE_MINLOT))
         wlot = MarketInfo(_Symbol, MODE_MINLOT);
      else
         wlot = StartLots;

      if(lots > MarketInfo(_Symbol, MODE_MAXLOT))
         wlot = MarketInfo(_Symbol, MODE_MAXLOT);
      else
         wlot = StartLots;

      glot = wlot;
     }
   tp = NormalizeDouble(TakeProfit *_Point, _Digits);
   sl = NormalizeDouble(StopLoss *_Point, _Digits);
   tr = NormalizeDouble(TralingStop *_Point, _Digits);
   br = NormalizeDouble(Breakeven *_Point, _Digits);

   TimeOfDay = (int) TimeLocal() % 86400;
   Midnight = TimeLocal() - TimeOfDay;



//--- get last modification time

//--- check for updates
   if(AllowUpdates && !FileIsExist(xmlFileName))
     {
      xmlUpdate();
     }






//-- Initialize Colors
   if(ColorsCharts != COLOR_REDGREEN)
     {
      COLOR_DOWN = clrRed;
      COLOR_UP = DodgerBlue;
     }
   else
     {
      COLOR_DOWN = clrRed;
      COLOR_UP = Green;
     }


   if(layout==bookOnChart || layout==BookMap)
     {
      ColorChartss();
      if(StringSubstr(Symbol(), 0, 3) == "EUR")
         Width_In_Pixels = 125;
      else
         if(StringSubstr(Symbol(), 0, 6) == "UsaTec")
            Width_In_Pixels = 45;
         else
            if(StringSubstr(Symbol(), 0, 6) == "UsaInd")
               Width_In_Pixels = 55;
            else
               if(StringSubstr(Symbol(), 0, 6) == "Usa500")
                  Width_In_Pixels = 45;
               else
                  Width_In_Pixels = 35;
     }
   else
     {

      if(StringSubstr(Symbol(), 0, 3) == "EUR")
         Width_In_Pixels = 85;
      else
         if(StringSubstr(Symbol(), 0, 6) == "UsaTec")
            Width_In_Pixels = 45;
         else
            if(StringSubstr(Symbol(), 0, 6) == "UsaInd")
               Width_In_Pixels = 55;
            else
               if(StringSubstr(Symbol(), 0, 6) == "Usa500")
                  Width_In_Pixels = 45;
               else
                  Width_In_Pixels = 35;



      PriceScale();

     }

   sic = Symbol();

   if(Futures)
     {
      if(StringSubstr(Symbol(), 0, 3) == "EUR")
         sic = "FEUR";
         socket.unsubscribe("EUR");
      if(StringSubstr(Symbol(), 0, 3) == "AUD")
         sic = "FAUD";
         socket.unsubscribe("AUD");
      if(StringSubstr(Symbol(), 0, 3) == "GBP")
         sic = "FGBP";
         socket.unsubscribe("GBP");
      if(StringSubstr(Symbol(), 0, 3) == "NZD")
         sic = "FNZD";
         socket.unsubscribe("NZD");

     }
   else
     {

      if(StringSubstr(Symbol(), 0, 3) == "EUR")
         sic = "EUR";
         socket.unsubscribe("FEUR");
      if(StringSubstr(Symbol(), 0, 3) == "AUD")
         sic = "AUD";
         socket.unsubscribe("FAUD");
      if(StringSubstr(Symbol(), 0, 3) == "GBP")
         sic = "GBP";
         socket.unsubscribe("FGBP");
     }







   int port = AutoSelectPort(PortMaps, sic);
   ServerAddress = StringFormat("tcp://%s:%d", ServerIP, port);
   


  

   if(!socket.connect(ServerAddress))
     {
      int error = Zmq::errorNumber();
      // PrintFormat(">>> Error connecting to server %s[%d]: %s",ServerAddress,error,Zmq::errorMessage(error));
      return INIT_FAILED;
     }




//--- subscribe to server side symbol
   string subscribeSymbol = _Symbol;
   if(Instrument != "AUTO")
      subscribeSymbol = Instrument;
      
     

// PrintFormat(">>> Subscribe to symbol %s",subscribeSymbol);
   if(!socket.subscribe(sic))
     {
      int error = Zmq::errorNumber();
      // PrintFormat(">>> Error subscribing to %s[%d]: %s",subscribeSymbol,error,Zmq::errorMessage(error));
      return INIT_FAILED;
     }


   CurrentSymbol = _Symbol;
   CurrentDigits = (int) SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

//--- setup ZMQ poll structure
   socket.fillPollItem(pi[0], ZMQ_POLLIN);





//--- setup the graphics
   ActualWidth = Width_In_Pixels;
   if(Width_In_Pixels < 150)
     {
      ActualWidth = (45 * screen_dpi) / 96;
     }
   if(Width_In_Pixels > (200 * screen_dpi) / 96)
     {
      ActualWidth = (200 * screen_dpi) / 96;
     }
   DeInit = false;
   AlreadyInit = false;
//--- Delete OBJECT
   for(int i = 0; i < obj_total; i++)
      while((StringSubstr(ObjectName(i), 0, 2) == "EJ"))
        {
         ObjectDelete(ObjectName(i));
        }

//--- kick off the timer



   ButtonCreate(0, "UNDOCK", 0, (3   * screen_dpi) / 96, 0, (58 * screen_dpi) / 96, (20 * screen_dpi) / 96, 0,    "UNDOCK", FontType, (8 * screen_dpi) / 96, White, C'45,45,45', Black);
   ButtonCreate(0, "REMOVE", 0, (60  * screen_dpi) / 96, 0, (84 * screen_dpi) / 96, (20 * screen_dpi) / 96, 0,   "REMOVE", FontType, (8 * screen_dpi) / 96, White, C'45,45,45', Black);
   ButtonCreate(0, "RESTORE", 0, (138 * screen_dpi) / 96, 0, (64 * screen_dpi) / 96, (20 * screen_dpi) / 96, 0, "RESTORE", FontType,(8 * screen_dpi) / 96, White, C'45,45,45', Black);
   ButtonCreate(0, "SYMBOL", 0, (200 * screen_dpi) / 96, 0, (64 * screen_dpi) / 96, (20 * screen_dpi) / 96, 0,  "SYMBOL", FontType, (8 * screen_dpi) / 96, White,   C'45,45,45', Black);
   ButtonCreate(0, "ENDDATE", 0, (105 * screen_dpi) / 96, 0, (75 * screen_dpi) / 96, (20 * screen_dpi) / 96, 1, "                  " + ExpiDate, FontType, (9 * screen_dpi) / 96, White, COLOR_DOWN, Black);
   ButtonCreate(0, "VERSION", 0, (30  * screen_dpi) / 96, 0, (33 * screen_dpi) / 96, (20 * screen_dpi) / 96, 1, VERSION, FontType, (8 * screen_dpi) / 96, White, COLOR_DOWN, Black);




   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| On every tick we check the data received and trigger             |
//| corresponding events                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(layout==BookMap)
     {
      ChartSetInteger(0,CHART_SHOW_GRID,false); // Hide the Grid.
      ChartSetInteger(0,CHART_SCALEFIX,true); // Hide the Grid.
     }
   else
      if(layout==bookOnChart)
        {


         //-----------Candle NexT Start code----------------------
         if(ShowNextCandleTime)
           {
            int Li_0 =   60 *  Period() - (int)(TimeCurrent() - Time[0]);
            string text_4 = "                           < ";
            if(Li_0 < 0)
               text_4 = text_4 + "--:--:--";
            else
               text_4 = text_4 + TimeToStr(Li_0, TIME_SECONDS);
            string str_concat_12 = StringConcatenate("DrW_", pprefix+Gs_1576, "Text");
            string str_concat_20 = StringConcatenate("DrW_", pprefix+Gs_1576, "Bg");
            if(ObjectFind(str_concat_12) != 0)
               ObjectCreate(str_concat_12, OBJ_TEXT, 0, Time[0], Bid);
            ObjectMove(str_concat_12, 0, Time[0], Bid);
            ObjectSetText(str_concat_12, text_4,(10 * screen_dpi) / 96, "Verdana", NextCandleTimeTextColor);
           }

        }
      else
        {
         string profit = DoubleToStr(total_profit(), 2);
         ObjectCreate(pprefix + "Profit", OBJ_LABEL, 0, 0, 0);
         ObjectSet(pprefix + "Profit", OBJPROP_CORNER, 0);
         ObjectSet(pprefix + "Profit", OBJPROP_YDISTANCE, 50);
         ObjectSet(pprefix + "Profit", OBJPROP_XDISTANCE, 10);
         ObjectSetText(pprefix + "Profit", "    " + profit +" "+ AccountCurrency()+"    |    " + DoubleToStr(total_profit() / AccountBalance() * 100, 2) + "%", 9, FontType, ColorOnSign(StringToDouble(profit)));


         ObjectCreate(pprefix + "Profit2", OBJ_LABEL, 0, 0, 0);
         ObjectSet(pprefix + "Profit2", OBJPROP_CORNER, 0);
         ObjectSet(pprefix + "Profit2", OBJPROP_XDISTANCE, 5);
         ObjectSet(pprefix + "Profit2", OBJPROP_YDISTANCE, 50);
         ObjectSetText(pprefix + "Profit2", "P:", FontSize - 1, FontType, White);


         ObjectCreate(pprefix + "Risk/Reward Ratio", OBJ_LABEL, 0, 0, 0);
         ObjectSet(pprefix + "Risk/Reward Ratio", OBJPROP_CORNER, 0);
         ObjectSet(pprefix + "Risk/Reward Ratio", OBJPROP_XDISTANCE, 125);
         ObjectSet(pprefix + "Risk/Reward Ratio", OBJPROP_YDISTANCE, 25);
         ObjectSetText(pprefix + "Risk/Reward Ratio", "R/R:", FontSize - 1, FontType, White);
         ObjectCreate(pprefix + "Risk/Reward Ratio2", OBJ_LABEL, 0, 0, 0);
         ObjectSet(pprefix + "Risk/Reward Ratio2", OBJPROP_CORNER, 0);
         ObjectSet(pprefix + "Risk/Reward Ratio2", OBJPROP_XDISTANCE, 150);
         ObjectSet(pprefix + "Risk/Reward Ratio2", OBJPROP_YDISTANCE, 25);
         ObjectSetText(pprefix + "Risk/Reward Ratio2", "1/" + RiskReward, 9, FontType, ColorOnSign2(StringToDouble(RiskReward)));


         ObjectCreate(pprefix + "Gap1", OBJ_LABEL, 0, 0, 0);
         ObjectSet(pprefix + "Gap1", OBJPROP_CORNER, 0);
         ObjectSet(pprefix + "Gap1", OBJPROP_XDISTANCE, 195);
         ObjectSet(pprefix + "Gap1", OBJPROP_YDISTANCE, 25);
         ObjectSetText(pprefix + "Gap1", "G:", FontSize - 1, FontType, White);


         ObjectCreate(pprefix + "Gap", OBJ_LABEL, 0, 0, 0);
         ObjectSet(pprefix + "Gap", OBJPROP_CORNER, 0);
         ObjectSet(pprefix + "Gap", OBJPROP_XDISTANCE, 212);
         ObjectSet(pprefix + "Gap", OBJPROP_YDISTANCE, 25);
         ObjectSetText(pprefix + "Gap", "" + StringSubstr(Gap, 3, 7), 9, FontType, ColorOnSign(StringToDouble(Gap)));




         ObjectCreate(pprefix + "Gap11", OBJ_LABEL, 0, 0, 0);
         ObjectSet(pprefix + "Gap11", OBJPROP_CORNER, 0);
         ObjectSet(pprefix + "Gap11", OBJPROP_XDISTANCE, 280);
         ObjectSet(pprefix + "Gap11", OBJPROP_YDISTANCE, 25);
         ObjectSetText(pprefix + "Gap11", "P:", FontSize - 1, FontType, White);


         ObjectCreate(pprefix + "Gap111", OBJ_LABEL, 0, 0, 0);
         ObjectSet(pprefix + "Gap111", OBJPROP_CORNER, 0);
         ObjectSet(pprefix + "Gap111", OBJPROP_XDISTANCE, 300);
         ObjectSet(pprefix + "Gap111", OBJPROP_YDISTANCE, 25);
         ObjectSetText(pprefix + "Gap111", "" + DoubleToStr(Datafeed,Digits), 10, FontType, ColorOnSign(Datafeed));

        }




   if(BreakevenEnable >= true)
     {
      int typee;
      int ticket;
      int total = OrdersTotal();
      double openPrice, stopPrice;

      for(int i = total - 1; i >= 0; i--)
        {
         for(int j = i; j >= 0; j--)
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
              {


               ticket = OrderTicket();
               typee = OrderType();
               openPrice = OrderOpenPrice();
               stopPrice = OrderStopLoss();
               if(typee == OP_SELL && stopPrice > openPrice && Ask <= (openPrice -  Breakeven * Point) && OrderSymbol() == Symbol())
                  resultt = OrderModify(ticket, OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Red);
               else
                  if(typee == OP_BUY && stopPrice <openPrice && Bid>= (openPrice +   Breakeven * Point) && OrderSymbol() == Symbol())
                     resultt = OrderModify(ticket, OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Blue);
              }
        }
     }

   if(AutoStop >= true)
     {
      double SL, TP;
      int ii, Total;
      int Dig = (int) MarketInfo(Symbol(), MODE_DIGITS);
      Total = OrdersTotal();
      if(Total > 0)
        {
         for(ii = Total - 1; ii >= 0; ii--)
           {
            if(OrderSelect(ii, SELECT_BY_POS, MODE_TRADES) == true)
              {
               if(OrderSymbol() == Symbol() && OrderType() == OP_SELL && OrderStopLoss() == 0 && OrderTakeProfit() == 0)
                 {
                  if(StopLoss > 0)
                     SL = OrderOpenPrice() + StopLoss *Point;
                  else
                     SL = 0;
                  if(TakeProfit > 0)
                     TP = OrderOpenPrice() - TakeProfit *Point;
                  else
                     TP = 0;

                  resultt = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(SL, Dig), NormalizeDouble(TP, Dig), OrderExpiration(), CLR_NONE);
                 }
               if(OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderStopLoss() == 0 && OrderTakeProfit() == 0)
                 {
                  if(StopLoss > 0)
                     SL = OrderOpenPrice() - StopLoss *Point;
                  else
                     SL = 0;
                  if(TakeProfit > 0)
                     TP = OrderOpenPrice() + TakeProfit *Point;
                  else
                     TP = 0;

                  resultt = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(SL, Dig), NormalizeDouble(TP, Dig), OrderExpiration(), CLR_NONE);
                 }
              }
           }
        }
     } //------------Risk Management End Code-----------------------


   MqlTick Latest_Price; // Structure to get the latest prices
   SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure


   dBid_Price = Latest_Price.bid; // Current Bid price.

   ArBid = NormalizeDouble(dBid_Price, Digits);

   if(!AlreadyInit)
     {
      AlreadyInit = true;
      InitLines();
     }
   if(DeInit)
      return;

   int ret = Socket::poll(pi, 100);
   if(ret == -1)
     {
      Print(">>> Polling command input failed: ", Zmq::errorMessage(Zmq::errorNumber()));
      return;
     }

   if(pi[0].hasInput())
     {


      ZmqMsg symbol;
      ZmqMsg type;
      ZmqMsg content;

      socket.recv(symbol);
      socket.recv(type);


      string msgType = type.getData();

      if(msgType == sic)
        {
         //--- we may receive more than 1 ticks
         JSONObject *Bticks[];
         do
           {
            socket.recv(content);
            //--- we need to receive all ticks even if they are not used


            if(!Show_TS)
               continue;
            JSONValue *value = jsonParser.parse(content.getData());
            if(value == NULL)
              {
               PrintFormat(">>> Invalid TickEvent[%d]: %s", jsonParser.getErrorCode(), jsonParser.getErrorMessage());
               delete value;
               continue;
              }
            else
               if(!value.isObject())
                 {
                  Print(">>> Object is excepted for TickEvent");
                  delete value;
                  continue;
                 }
               else
                 {
                  int len = ArraySize(Bticks);
                  ArrayResize(Bticks, len + 1, 10);
                  Bticks[len] = dynamic_cast <JSONObject *>(value);
                 }
           }
         while(content.more());
         if(ArraySize(Bticks) > 0)
           {
            OnBidUpdate(Bticks);
            for(int i = 0; i < ArraySize(Bticks); i++)
              {
               delete Bticks[i];
              }
           }
        }

      if(msgType == "BOOK")
        {
         socket.recv(content);

         if(!Display_DOM)
            return;

         OnMarketBookUpdate(content.getData());


        }
      else
         if(msgType == "TICK")
           {
            //--- we may receive more than 1 ticks
            JSONObject *ticks[];
            do
              {
               socket.recv(content);
               //--- we need to receive all ticks even if they are not used


               if(!Show_TS)
                  continue;
               JSONValue *value = jsonParser.parse(content.getData());
               if(value == NULL)
                 {
                  PrintFormat(">>> Invalid TickEvent[%d]: %s", jsonParser.getErrorCode(), jsonParser.getErrorMessage());
                  delete value;
                  continue;
                 }
               else
                  if(!value.isObject())
                    {
                     Print(">>> Object is excepted for TickEvent");
                     delete value;
                     continue;
                    }
                  else
                    {
                     int len = ArraySize(ticks);
                     ArrayResize(ticks, len + 1, 10);
                     ticks[len] = dynamic_cast <JSONObject *>(value);
                    }
              }
            while(content.more());
            if(ArraySize(ticks) > 0)
              {
               OnTickUpdate(ticks);
               for(int i = 0; i < ArraySize(ticks); i++)
                 {
                  delete ticks[i];
                 }
              }
           }
         else
           {
            if(type.more())
              {
               do
                 {
                  socket.recv(content);


                 }
               while(content.more());
              }
            // PrintFormat(">>> Unknow event type %s occurred, ignored.",msgType);
           }
     }
  }
//+------------------------------------------------------------------+
//| To ensure fast enough updates, we need to trigger OnTick when the|
//| timer fires                                                      |
//+------------------------------------------------------------------+
void OnTimer()
  {
   OnTick();
   ord_del_obj();
  }


//+------------------------------------------------------------------+
//| Disconnect server and remove all graphics                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   socket.disconnect(ServerAddress);
   
   EventKillTimer();
   DeInit = true;
   ColorChartss();
//--- Delete OBJECT
   int obj_total = ObjectsTotal();
   for(int i = 0; i < obj_total; i++)
      while((StringSubstr(ObjectName(i), 0, 2) == "EJ"))
        {
         ObjectDelete(ObjectName(i));
        }
//----------------------------------------------------------------------------------------------------------

   Comment("");
   return;
  }
//+------------------------------------------------------------------+
//| Handles market book update events                                |
//+------------------------------------------------------------------+
void OnMarketBookUpdate(string content)
  {
   JSONValue *value = jsonParser.parse(content);

   if(value == NULL)
     {
      PrintFormat(">>> Invalid MarketBookEvent[%d]: %s", jsonParser.getErrorCode(), jsonParser.getErrorMessage());
     }
   else
      if(!value.isArray())
        {
         Print(">>> Array is excepted for MarketBookEvent");
        }
      else
        {
         JSONArray *marketBookArray = dynamic_cast <JSONArray *>(value);

         int size = marketBookArray.size();
         if(size > 0)  // update DOM display
           {
            long maxVolume = 0;
            int buyStart = -1;
            MqlBookInfo infos[];
            ArrayResize(infos, 0, size);
            int s = 0;
            for(int i = 0; i < size; i++)
              {
               JSONObject *obj = marketBookArray.getObject(i);

               ArrayResize(infos, s + 1);
               infos[s].price = obj.getDouble("price");
               infos[s].volume = obj.getLong("volume");

               if(infos[s].volume > maxVolume)
                  maxVolume = infos[s].volume;

               double FeePrice= obj.getDouble("price");

               if(buyStart == -1 && StringFind(obj.getString("type"), "SELL") == -1)
                 {
                  buyStart = s;
                 }
               s++;
              }

            if(maxVolume == 0)
              {
               maxVolume = 1;
              }
            //DOM
            Sum_DOM_Ask = 0;
            Sum_DOM_Bid = 0;
            Delta_DOM_Ask = 0;
            Delta_DOM_Bid = 0;
            for(int i = 0; i < s; i++)
              {
               int n = 0;

               if(i < buyStart)
                  n = buyStart - i;
               else
                  n = -(i - buyStart + 1);
               int som= n * 5;
               double pricing = infos[i].price;
               double p = 0; //=infos[i].price;
               long vol;
               int width;


               static long lastVolume = 0;

                          {
                           Ask_Bib_Diff= 5;
                           /////////////////////Bid Side/////////////////////
                           priceBid = NormalizeDouble(dBid_Price, 4);
                           vol = infos[i].volume;
                           width = (int) MathRound(vol *ActualWidth / maxVolume);
                           if(i >= 0 && i <= 9)
                              Sum_DOM_Ask += vol;
                           else
                              Sum_DOM_Bid += vol;




                           if(i >= 0 && i <= 9)
                             {
                              int soma= n * Ask_Bib_Diff;
                              p = priceBid + soma *_Point;

                             }
                           else
                             {
                              int soma= n * -Ask_Bib_Diff;
                              p = priceBid - soma *_Point;

                             }

                          }


               if(vol > 0 && MathAbs(p - p) < 0.000001 && n == n)
                 {
                  lastVolume = vol;

                 }


               if(p > 0)

                 {

                  Create_DOM(n, DoubleToString(NormalizeDouble(p, CurrentDigits), CurrentDigits), IntegerToString(vol), width, s);
                 }
              }
           }
        }
   delete value;
  }

//+------------------------------------------------------------------+
//| Handles tick update events                                       |
//+------------------------------------------------------------------+
void OnTickUpdate(JSONObject *&ticks[])
  {
   static string lastType = "";
   static datetime lastTime = 0;
   static double lastPrice = -1;
   static long lastVolume = 0;
   long vol = 0;
   long volMedian = 0;
   color AskBidColor;

   int Custom_Timeframe = 0;



   for(int i = 0; i < ArraySize(ticks); i++)
     {
      JSONObject *tick = ticks[i];

      string type = tick.getString("type");
      datetime time = (datetime) tick.getLong("time");
      datetime ttime = TimeLocal();
      long volume = tick.getLong("volume");
      double price = tick.getDouble("price");


      if(type == "B")
        {
         AskBidColor =VCAggressionB ;



        }
      else
         if(type == "S")
           {
            AskBidColor = VCAggressionS ;

           }
         else //--- has to be "N" for N/A
           {
            AskBidColor = White;

           }

      if(type == "N")  //--- has to be "N" for N/A
        {
         price = tick.getDouble("ask") - tick.getDouble("bid");
        }

      if(MergeVolume && type != "N" && type == lastType && time == lastTime && MathAbs(price - lastPrice) < 0.000001)
        {

         volume += lastVolume;

        }
      else
        {
         ShiftLines(1);

        }

      if(MinVolume <= 0 || volume >= MinVolume)


         if(layout==bookOnChart || layout==BookMap)

           {

           
               vol = volume;
           



            if(vol>=VolumeAggression)
              {
               Custom_Timeframe = OBJ_ALL_PERIODS;
               EllipseCreate(0,Pprefix+TimeToString(TimeCurrent())+(string)volume+(string)ttime+(string)price,0,TimeCurrent(),NormalizeDouble(dBid_Price,5),TimeCurrent(),NormalizeDouble(dBid_Price,5),0.2,AskBidColor,STYLE_SOLID,(int)vol-(int)vol+((int)volMedian * screen_dpi) / 96,true,false,false,false,0);
               ObjectSetString(0, Pprefix+TimeToString(TimeCurrent())+(string)volume+(string)ttime+(string)price, OBJPROP_TOOLTIP,"Vol : "+(string)vol+" Price : "+DoubleToString(dBid_Price,_Digits));
               ObjectSet(pprefix+TimeToString(TimeCurrent())+(string)volume+(string)ttime+(string)price,OBJPROP_TIMEFRAMES,Custom_Timeframe);
              }


           }
         else
           {

            if(StringSubstr(Symbol(), 0, 3) == "Ger")
               DrawTSLine(type, ttime, volume, price, 1);
            else
               if(StringSubstr(Symbol(), 0, 6) == "Usa500" && StringSubstr(Symbol(), 0, 6) == "UsaTec" && StringSubstr(Symbol(), 0, 6) == "UsaInd")
                  DrawTSLine(type, ttime, volume, price, 1);

               else
                  DrawTSLine(type, ttime, volume, price, 1);

           }

      if(MergeVolume)
        {
         lastType = type;
         lastTime = time;
         lastVolume = volume;
         lastPrice = price;
        }

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnBidUpdate(JSONObject *&Bticks[])
  {
   for(int i = 0; i < ArraySize(Bticks); i++)
     {
      JSONObject *tick = Bticks[i];

      Datafeed = tick.getDouble("bid");

      if(Datafeed - ArBid >= ArbPontos *Point())
        {
         double Cal = Datafeed - ArBid;
         string PPrice = DoubleToString(Cal);
         Gap = StringSubstr(PPrice, 0, 7);

        }

      if(Datafeed - ArBid <= -ArbPontos *Point())
        {
         double Cal = Datafeed - ArBid;
         string PPrice = DoubleToString(Cal);
         Gap = StringSubstr(PPrice, 0, 8);
        }


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _PlaySound(const string FileName)
  {
   if(SoundIsEnabled)
      PlaySound(FileName);
  }
//+------------------------------------------------------------------+
//| draw line n of the time &sales log                              |
//+------------------------------------------------------------------+
void DrawTSLine(string type, datetime time, long volume, double price, int n)
  {
   color TimeColor = Title_Color, AskBidColor = Title_Color;
   color bidColor = BID_Color;
   color askColor = ASK_Color;
   color naColor = NA_Color;
   color timeBidColor = BID_Color;
   color timeAskColor = ASK_Color;
   color timeNaColor = NA_Color;

   if(StringSubstr(Symbol(), 0, 3) == "EUR")
      LargeVolumeThreshold = 17;
   if(StringSubstr(Symbol(), 0, 6) == "UsaTec")
      LargeVolumeThreshold = 15;
   if(StringSubstr(Symbol(), 0, 6) == "UsaInd")
      LargeVolumeThreshold = 15;
   if(StringSubstr(Symbol(), 0, 6) == "Usa500")
      LargeVolumeThreshold = 100;
   if(StringSubstr(Symbol(), 0, 3) == "AUD")
      LargeVolumeThreshold = 10;
   if(StringSubstr(Symbol(), 0, 3) == "GBP")
      LargeVolumeThreshold = 10;
   if(StringSubstr(Symbol(), 0, 3) == "Ger")
      LargeVolumeThreshold = 37;
   if(volume > LargeVolumeThreshold)
     {
      _PlaySound(AG);

      bidColor = LargeVolume_BID_Color;
      askColor = LargeVolume_ASK_Color;
      naColor = LargeVolume_NA_Color;
      timeBidColor = LargeVolume_BID_Color;
      timeAskColor = LargeVolume_ASK_Color;
      timeNaColor = LargeVolume_NA_Color;
     }

   if(type == "B")
     {
      AskBidColor = askColor;
      TimeColor = timeAskColor;
      price = priceBid + Ask_Bib_Diff * _Point;

     }
   else
      if(type == "S")
        {
         AskBidColor = bidColor;
         TimeColor = timeBidColor;
         price = priceBid - Ask_Bib_Diff * _Point;
        }
      else //--- has to be "N" for N/A
        {
         AskBidColor = naColor;
         TimeColor = timeNaColor;
         price = dBid_Price;
        }
   SetLineN_Text(n, TimeToString(time, TIME_SECONDS), DoubleToString(price, CurrentDigits), IntegerToString(volume), AskBidColor, TimeColor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShiftLines(int NumberOfLines)
  {

   if(NumberOfLines >= Lines)
      return;

   int s, n;
   string VolumeGetName, VolumeSetName, VolumePriceGetName, VolumePriceSetName, VolumeTimeGetName, VolumeTimeSetName;
   string VolumeValue, VolumePriceValue, VolumeTimeValue;
   color oldTextColor, oldTimeColor;
//Comment(Lines-NumberOfLines);
   n = Lines;
   s = Lines - NumberOfLines;

   while(s >= 1)
     {
      string ss = IntegerToString(s);
      string nn = IntegerToString(n);

      VolumeGetName = pprefix + "TS_Line_Volume_" + ss;
      VolumeSetName = pprefix + "TS_Line_Volume_" + nn;

      VolumePriceGetName = pprefix + "TS_Line_Price_" + ss;
      VolumePriceSetName = pprefix + "TS_Line_Price_" + nn;

      VolumeTimeGetName = pprefix + "TS_Line_Time_" + ss;
      VolumeTimeSetName = pprefix + "TS_Line_Time_" + nn;

      VolumeTimeValue = ObjectGetString(0, VolumeTimeGetName, OBJPROP_TEXT);
      VolumePriceValue = ObjectGetString(0, VolumePriceGetName, OBJPROP_TEXT);
      VolumeValue = ObjectGetString(0, VolumeGetName, OBJPROP_TEXT);
      oldTextColor = (color) ObjectGetInteger(0, VolumeGetName, OBJPROP_COLOR);
      oldTimeColor = (color) ObjectGetInteger(0, VolumeTimeGetName, OBJPROP_COLOR);

      ObjectSetText(VolumeSetName, VolumeValue, FontSize, FontType, oldTextColor);
      ObjectSetText(VolumePriceSetName, VolumePriceValue, FontSize, FontType, oldTextColor);
      ObjectSetText(VolumeTimeSetName, VolumeTimeValue, FontSize, FontType, oldTimeColor);
      n--;
      s--;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitLines()
  {
   if(!Show_TS)
      return;
   int j;

   string Time_Text = "";
   string Price_Text = "";
   string Volume_Text = "";

   color Line_Color = ASK_Color;
   color Time_Color = ASK_Color;

   string TS_Name = pprefix + "TimeAndSales_Title";
   string TS_Text = "";

   string TS_SiteName = pprefix + "TimeAndSales_Site";
   string TS_SiteText = "";


//--- 疣珈屦?铌磬 沭圄桕?
   long x_distance;
   long y_distance;
//--- 铒疱溴腓?疣珈屦?铌磬
   if(!ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0, x_distance))
     {
      DeInit = true;
      return;
     }
   if(!ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0, y_distance))
     {
      DeInit = true;
      return;
     }
   if(!(StringToInteger(Rows) > 0))
     {
      Lines = (int) MathRound((y_distance - 102) / 13);
     }
   else
     {
      Lines = (int) StringToInteger(Rows);
     }
   if(Lines > 100)
      Lines = 100;
   if(Lines <= 0)
      Lines = 25;

   int x;
   int y;
   int width;
   int height;

   x = X_coord + 65;
   y = Y_coord + 56;
   width = 200;
   height = 40 + Lines * 12;


   X_coord = PriceXX + 43;
   Y_coord = PriceYY - 310;


   if(layout==bookOnChart|| layout==BookMap)
     {
     }
   else
     {

      RectLabelCreate(0, "HIDE", 0, PriceXX + 130, PriceYY - 295, 590, 1900, Black, BORDER_FLAT, 0, Red, STYLE_SOLID, 0, false, false, false, 0);

      RectLabelCreate(0, "BOX", 0, PriceXX + 25, PriceYY - 295, 190, 1900, Black, BORDER_FLAT, 0, Border, STYLE_SOLID, 2, false, false, false, 0);

     }

   ObjectCreate(TS_Name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(TS_Name, OBJPROP_CORNER, 0);
   ObjectSet(TS_Name, OBJPROP_XDISTANCE, X_coord + 20);
   ObjectSet(TS_Name, OBJPROP_YDISTANCE, Y_coord - 2);
   ObjectSetText(TS_Name, TS_Text, FontSize, FontType, Title_Color);

   ObjectCreate(TS_SiteName, OBJ_LABEL, 0, 0, 0);
   ObjectSet(TS_SiteName, OBJPROP_CORNER, 0);
   ObjectSet(TS_SiteName, OBJPROP_XDISTANCE, X_coord + 10);
   ObjectSet(TS_SiteName, OBJPROP_YDISTANCE, Y_coord + 14);
   ObjectSetText(TS_SiteName, TS_SiteText, FontSize, FontType, Title_Color);

   for(j = 1; j <= Lines; j++)
     {
      Time_Text = "";
      Price_Text = "";
      Volume_Text = "";
      Line_Color = ASK_Color;
      Time_Color = ASK_Color;

      CreateLine(j);
      SetLineN_Coords(j, X_coord, Y_coord + 16);
      SetLineN_Text(j, Time_Text, Price_Text, Volume_Text, Line_Color, Time_Color);
     }

  }
//+------------------------------------------------------------------+
void CreateLine(int n)
//+------------------------------------------------------------------+
  {
   CreateLine_Type(n, "Time");
   CreateLine_Type(n, "Price");
   CreateLine_Type(n, "Volume");
  }
//+------------------------------------------------------------------+
void CreateLine_Type(int n, string LineType)
//+------------------------------------------------------------------+
  {
   string Line_Name = pprefix + "TS_Line_" + LineType + "_" + IntegerToString(n);
   ObjectGet(Line_Name, OBJPROP_COLOR);
   int Error = GetLastError();
   if(Error == 4202)
     {
      ObjectCreate(Line_Name, OBJ_LABEL, 0, 0, 0);

     }
  }
//+------------------------------------------------------------------+
void SetLineN_Coords(int n, int x, int y)
//+------------------------------------------------------------------+
  {
   SetLineN_Coords_Type(n, x, y + 1, "Time");
   SetLineN_Coords_Type(n, x + 70, y + 1, "Price");
   SetLineN_Coords_Type(n, x + 135, y + 1, "Volume");
  }
//+------------------------------------------------------------------+
void SetLineN_Coords_Type(int n, int x, int y, string LineType)
//+------------------------------------------------------------------+
  {
   string Line_Name = pprefix + "TS_Line_" + LineType + "_" + IntegerToString(n);
   ObjectSet(Line_Name, OBJPROP_CORNER, 0);
   ObjectSet(Line_Name, OBJPROP_XDISTANCE, x - 10);
   ObjectSet(Line_Name, OBJPROP_YDISTANCE, y + n * 16);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLineN_Text(int n, string Time_Text, string Price_Text, string Volume_Text, color Line_Color, color Time_Color)
  {
   SetLineN_Text_Type(n, Time_Text, Time_Color, "Time");
   SetLineN_Text_Type(n, Price_Text, Line_Color, "Price");
   SetLineN_Text_Type(n, Volume_Text, Line_Color, "Volume");

  }

//+------------------------------------------------------------------+
void SetLineN_Text_Type(int n, string Text, color LineColor, string LineType)
//+------------------------------------------------------------------+
  {
   string Line_Name = pprefix + "TS_Line_" + LineType + "_" + IntegerToString(n);
   if(LineType == "Volume")
     {
      Text = StringFormat("%4s", Text);
     }
   if(LineType == "Price" && StrToDouble(Text) > 0)
     {
      Text = DoubleToString(NormalizeDouble(StrToDouble(Text) + Forex_Shift *_Point, _Digits), _Digits);


     }
   ObjectSetText(Line_Name, Text, FontSize, FontType, LineColor);
  }
//+------------------------------------------------------------------+
bool ButtonCreate(const long chart_ID = 0,
                  string name = "Button", const int sub_window = 0, const int xx = 0, const int yy = 0, const int width = 50, const int height = 18, const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, const string text = "Button", const string font = "Arial", const int font_size = 10, const color clr = clrBlack, const color back_clr = C'236,233,216', const color border_clr = clrNONE, const bool state = false, const bool back = false, const bool selection = false, const bool hidden = true, const long z_order = 0, const string toltip = "")
  {
//+------------------------------------------------------------------+
   ResetLastError();
   name = StringConcatenate(pprefix, name);
   if(ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0))
     {
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);

      ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
     }
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, xx);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, yy);
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
   ObjectSetString(chart_ID, name, OBJPROP_TOOLTIP, toltip);
   return (true);
  }
//+------------------------------------------------------------------+
bool RectLabelCreate(const long chart_ID = 0,
                     string name = "RectLabel", const int sub_window = 0, const int x = 0, const int y = 0, const int width = 50, const int height = 18, const color back_clr = C'81,81,81', const ENUM_BORDER_TYPE border = BORDER_SUNKEN, const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, const color clr = clrRed, const ENUM_LINE_STYLE style = STYLE_SOLID, const int line_width = 1, const bool back = false, const bool selection = false, const bool hidden = true, const long z_order = 0)
  {
//+------------------------------------------------------------------+
   ResetLastError();
   name = StringConcatenate(pprefix, name);

   if(!ObjectCreate(chart_ID, name, OBJ_RECTANGLE_LABEL, sub_window, 0, 0))
     {

     }

   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_TYPE, border);
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, line_width);
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);

   return (true);
  }
//+------------------------------------------------------------------+
void LabelCreate(const int xcoord, const int ycoord, string TS_Name, string TS_Text, color titleColor)
//+------------------------------------------------------------------+
  {
   ObjectCreate(TS_Name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(TS_Name, OBJPROP_CORNER, 0);
   ObjectSet(TS_Name, OBJPROP_BACK, false);
   ObjectSet(TS_Name, OBJPROP_XDISTANCE, xcoord);
   ObjectSet(TS_Name, OBJPROP_YDISTANCE, ycoord);
   ObjectSetText(TS_Name, TS_Text, FontSize, FontType, titleColor);


  }

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
//+------------------------------------------------------------------+
  {

   datetime dt    =0;
   double   price =0;
   int      window=0;
   ResetLastError();

   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(ObjectType(sparam) == OBJ_BUTTON)
        {
         ButtonPressed(0, sparam);
        }
     }

//+------------------------------------------------------------------+
//| CHARTEVENT_MOUSE_MOVE                                            |
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
      MousePrice=NormalizeDouble(price,Digits);
      MouseDate=dt;
      // ObjectSetString(0,prefix+"_L2C2",OBJPROP_TEXT,"Mouse : "+DoubleToStr(MousePrice,Digits)+" / "+TimeToStr(MouseDate,TIME_DATE|TIME_SECONDS));
      //M1 button
     }

   if(id==CHARTEVENT_KEYDOWN)
     {
      if(lparam==(StringGetChar(CreatTrendMark,0)))
        {


         double      Price_on_Drop = NormalizeDouble(MousePrice,Digits);
         datetime    time = MouseDate;
         datetime         TimeNow;
         int         timeframe = Period();

         int         shift=iBarShift(NULL,timeframe,time);
         double      Max_at_time = High[shift];
         double      Min_at_time = Low[shift];
         double      Dist_to_Max = MathAbs(Price_on_Drop - Max_at_time)*10000;
         double      Dist_to_Min = MathAbs(Price_on_Drop - Min_at_time)*10000;
         double      Window_Max = WindowPriceMax();
         double      Window_Min = WindowPriceMin();
         double      Window_Dist = Window_Max - Window_Min;

         string      Level_Value = DoubleToStr(Price_on_Drop,(int)MarketInfo(Symbol(),MODE_DIGITS));

         if(IsConnected())
           {
            TimeNow = TimeCurrent();
           }
         else
           {
            TimeNow = time;
           }

         if(Dist_to_Max < Dist_to_Min)
           {
            Text_Dist = Window_Dist * (Dist_Text/100);
            Line_ColorTrend = Top_Line_Color;
           }
         if(Dist_to_Max > Dist_to_Min)
           {
            Text_Dist = Window_Dist * (-Dist_Text/100) + (0.03 * Window_Dist);
            Line_ColorTrend = Bottom_Line_Color;
           }


         switch(timeframe)
           {
            case 1      :
               Length_Factor = 1;
               break;
            case 5      :
               Length_Factor = 2;
               break;
            case 10     :
               Length_Factor = 1;
               break;
            case 15     :
               Length_Factor = 3;
               break;
            case 30     :
               Length_Factor = 6;
               break;
            case 20     :
               Length_Factor = 6;
               break;
            case 31     :
               Length_Factor = 6;
               break;
            case 40     :
               Length_Factor = 6;
               break;
            case 50     :
               Length_Factor = 6;
               break;
            case 60     :
               Length_Factor = 12;
               break;
            case 240    :
               Length_Factor = 48;
               break;
            case 1440   :
               Length_Factor = 288;
               break;
            case 10080  :
               Length_Factor = 2016;
               break;
            case 43200  :
               Length_Factor = 8640;
               break;
           }



         int length = Length_Factor * Line_length;

         if(Line_Ray == false)
            ObjectCreate("Tr" + (string)TimeNow + (string)Price_on_Drop,OBJ_TREND,0,time+length,Price_on_Drop,time-length,Price_on_Drop);
         else
            ObjectCreate("Tr" + (string)TimeNow +(string) Price_on_Drop,OBJ_HLINE,0,0,Price_on_Drop);
         ObjectSet("Tr" + (string)TimeNow +(string) Price_on_Drop,OBJPROP_COLOR,Line_ColorTrend);
         ObjectSet("Tr" +(string) TimeNow + (string)Price_on_Drop,OBJPROP_WIDTH,Line_Width);
         ObjectSet("Tr" + (string)TimeNow + (string)Price_on_Drop,OBJPROP_RAY,Line_Ray);

         if(Insert_Text == true)
           {
            ObjectCreate("Text" + (string)TimeNow + (string)Price_on_Drop,OBJ_TEXT,0,time,Price_on_Drop + Text_Dist,(int)Price_on_Drop);
            ObjectSetText("Text" + (string)TimeNow + (string)Price_on_Drop,"" + Level_Value,Font_Size,"Arial",Text_Color);
           }
        }

      if(lparam==(StringGetChar(ZoomIN,0)))
        {
         PostMessageA(intParent,0x0111,33025,0);
        }
      if(lparam==(StringGetChar(ZoomOUT,0)))
        {
         PostMessageA(intParent,0x0111,33026,0);
        }
      if(lparam==(StringGetChar(MouseCross,0)))
        {
         PostMessageA(intParent,0x0111,33233,0);
        }
      if(lparam==(StringGetChar(TrendLine,0)))
        {
         PostMessageA(intParent,0x0111,33257,0);
        }
      if(lparam==(StringGetChar(PriceEtiquet,0)))
        {
         PostMessageA(intParent,0x0111,35464,0);
        }
      if(lparam==(StringGetChar(AUTOSCROLL,0)))
        {
         PostMessageA(intParent,0x0111,33017,0);
        }

      if(lparam==(StringGetChar(DeleteTrend,0)))
        {

         int obj_total = ObjectsTotal();
         for(int i = 0; i < obj_total; i++)
            while((StringSubstr(ObjectName(i), 0, 2) == "Tr"))
              {
               ObjectDelete(ObjectName(i));

              }
        }
      if(lparam==(StringGetChar(DeleteAG,0)))
        {

         int obj_total = ObjectsTotal();
         for(int i = 0; i < obj_total; i++)
            while((StringSubstr(ObjectName(i), 0, 2) == "AG"))
              {
               ObjectDelete(ObjectName(i));

              }
        }
     }
  }
//+------------------------------------------------------------------+
color ColorOnSign(double value)
  {
//+------------------------------------------------------------------+
   color lcColor = FontColor;

   if(value > 0)
      lcColor = FontColorPlus;
   if(value < 0)
      lcColor = FontColorMinus;

   return (lcColor);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color ColorOnSign2(double value)
  {
//+------------------------------------------------------------------+
   color lcColor = FontColor;


   if(value > 1.0)
      lcColor = FontColorPlus;
   if(value < 1.0 && value > 0.1)
      lcColor = FontColorMinus;

   return (lcColor);
  }
//+------------------------------------------------------------------+
bool ButtonPressed(const long ChartID, const string sparam)
//+------------------------------------------------------------------+
  {
//-- BUY SELL CLOSE PARTIAL BUTTONS
   if(sparam == pprefix + "LINEBUY")
      Buy_Button(sparam);
   if(sparam == pprefix + "LINESELL")
      Sell_Button(sparam);
   if(sparam == pprefix + "LINECLOSE")
      Close_Button(sparam);
   if(sparam == pprefix + "LINEPARTIAL")
      Partial_Button(sparam);

//-- LIMIT BUY &SELL BUTTONS
   if(StringSubstr(sparam, 0, 7) == "EJORDER")
      Order_Button(sparam);


//-- TP SL
   if(StringSubstr(sparam, 0, 6) == "EJSTOP")
      SL_Button(sparam);
//-- BORDER WORKES
   if(sparam == pprefix + "REMOVE")
      Remove_Button(sparam);
   if(sparam == pprefix + "RESTORE")
      Restore_Button(sparam);
   if(sparam == pprefix + "UNDOCK")
      Undock_Button(sparam);
   if(sparam == pprefix + "SYMBOL")
      ChartSymb_Button(sparam);


   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChartSymb_Button(const string sparam) //-- Change Symbol
  {
   long id = ChartNext(0);
   while(id >= 0)
     {
      int period = ChartPeriod(id);
      if(!ChartSetSymbolPeriod(id, _Symbol, period))


         ChartRedraw(id);
      id = ChartNext(id);

     }
   return (0);
  }

//+------------------------------------------------------------------+
int Remove_Button(const string sparam) //-- SL Blue
//+------------------------------------------------------------------+
  {
   int hChartParent = GetParent((int) ChartGetInteger(ChartID(), CHART_WINDOW_HANDLE));
   int hMDIClient = GetParent(hChartParent);
   int hChildWindow = GetTopWindow(hMDIClient);
   while(hChildWindow > 0)
     {

      RemoveBorderByWindowHandle(hChildWindow);
      hChildWindow = GetWindow(hChildWindow, GW_HWNDNEXT);
     }


   return (0);
  }


//+------------------------------------------------------------------+
int Restore_Button(const string sparam) //-- SL Blue
//+------------------------------------------------------------------+
  {
   int hChartParent = GetParent((int) ChartGetInteger(ChartID(), CHART_WINDOW_HANDLE));
   int hMDIClient = GetParent(hChartParent);
   int hChildWindow = GetTopWindow(hMDIClient);
   while(hChildWindow > 0)
     {

      RestoreBorderByWindowHandle(hChildWindow);
      hChildWindow = GetWindow(hChildWindow, GW_HWNDNEXT);
     }


   return (0);
  }


//+------------------------------------------------------------------+
int Undock_Button(const string sparam) //-- SL Blue
//+------------------------------------------------------------------+
  {




   DetachChart2(WindowHandle(Symbol(), Period()), 3);




   return (0);
  }




//+------------------------------------------------------------------+
int SL_Button(const string sparam) //-- SL Blue
//+------------------------------------------------------------------+
  {





   resultt = OrderModify(OrderTicket(), OrderOpenPrice(), StringToDouble(ObjectDescription(sparam)), OrderTakeProfit(), OrderExpiration(), CLR_NONE);

   resultt = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), StringToDouble(ObjectDescription(sparam)), OrderExpiration(), CLR_NONE);




   return (0);
  }



//+------------------------------------------------------------------+
int Close_Button(const string sparam) //-- CLOSE ORDENS FUNTION
//+------------------------------------------------------------------+
  {
   _PlaySound("tick.wav");

   int ticket;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber() == Magic || Magic == -1)
            if(OrderSymbol() == _Symbol)

              {
               if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                 {
                  if(OrderType() == 0 && OrderSymbol() == Symbol())
                    {
                     ticket = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, CLR_NONE);
                     if(ticket == -1)
                        Print("Error: ", GetLastError());
                     if(ticket > 0)
                        Print("Position ", OrderTicket(), " closed");
                    }
                  if(OrderType() == 1 && OrderSymbol() == Symbol())
                    {
                     ticket = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, CLR_NONE);

                     if(ticket == -1)
                        Print("Error: ", GetLastError());
                     if(ticket > 0)
                        Print("Position ", OrderTicket(), " closed");
                    }
                  else
                     if(OrderType() == OP_BUYLIMIT || OP_SELLLIMIT || OrderSymbol() == Symbol())
                       {
                        ticket = OrderDelete(OrderTicket());
                       }
                 }
              }
   return (0);
  }


//+------------------------------------------------------------------+
int Order_Button(const string sparam) //-- BUY LIMIT FUCTION
//+------------------------------------------------------------------+
  {

   _PlaySound("ok.wav");


   if(OrderSymbol() == Symbol() && OrdersTotal() >= MAX_ORDERS && MaximumOrders == true)
     {
      if(StringToDouble(ObjectDescription(sparam)) < Bid)
         resultt = OrderModify(OrderTicket(), StringToDouble(ObjectDescription(sparam)), OrderStopLoss(), OrderTakeProfit(), 0, CLR_NONE);

      else
         resultt = OrderModify(OrderTicket(), StringToDouble(ObjectDescription(sparam)), OrderStopLoss(), OrderTakeProfit(), 0, CLR_NONE);
     }
   else
     {
      if(StringToDouble(ObjectDescription(sparam)) < Bid)
         resultt = OrderSend(Symbol(), OP_BUYLIMIT, glot, StringToDouble(ObjectDescription(sparam)), Slippage, 0, 0, "EJTRADER BUY LIMIT", Magic, 0, CLR_NONE);
      else
         resultt = OrderSend(Symbol(), OP_SELLLIMIT, glot, StringToDouble(ObjectDescription(sparam)), Slippage, 0, 0, "EJTRADER SELL LIMIT", Magic, 0, CLR_NONE);
     }

   return (0);
  }





//+------------------------------------------------------------------+
int Buy_Button(const string sparam) // -- BULL BUTTON FUNTION
//+------------------------------------------------------------------+
  {
   _PlaySound("ok.wav");
   if(OrderSymbol() == Symbol() && OrdersTotal() >= MAX_ORDERS && MaximumOrders == true)
     {
      // Don't add new orders
     }
   else
     {
      resultt = OrderSend(Symbol(), OP_BUY, glot, Ask, Slippage, 0, 0, "EJTRADER BUY MARKET", Magic, 0, CLR_NONE);
      // You can add new orders
     }

   return (0);
  }

//+------------------------------------------------------------------+
int Sell_Button(const string sparam) //-- SELL BUTTON FUNTION
//+------------------------------------------------------------------+
  {
   _PlaySound("ok.wav");
   if(OrderSymbol() == Symbol() && OrdersTotal() >= MAX_ORDERS && MaximumOrders == true)
     {
      // Don't add new orders
     }
   else
     {
      resultt = OrderSend(Symbol(), OP_SELL, glot, Bid, Slippage, 0, 0, "EJTRADER SELL MARKET", Magic, 0, CLR_NONE);
     }

   return (0);
  }
//+------------------------------------------------------------------+
int Partial_Button(const string sparam) //-- PARTIAL BUTTON FUNTION
//+------------------------------------------------------------------+
  {
   int result;
   _PlaySound("ok.wav");
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() == Symbol() && (OrderType() < 2))
        {
         while(IsTradeContextBusy())
            Sleep(1);
         RefreshRates();

         double lot = OrderLots() *Percent / 100.0;
         lot = MathMax(lot, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
         lot = MathMin(lot, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
         double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
         int digits = (int) MathCeil(MathLog10(1 / volumeStep));
         lot = NormalizeDouble(lot, digits);

         if(OrderType() == OP_BUY)
           {
            result = OrderClose(OrderTicket(), lot, Bid, Slippage, CLR_NONE);
           }
         else
            if(OrderType() == OP_SELL)
              {
               result = OrderClose(OrderTicket(), lot, Ask, Slippage, CLR_NONE);
              }
        }
     }
   return (0);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RestoreBorderByWindowHandle(int hWindow)
  {
   int iNewStyle = GetWindowLongA(hWindow, GWL_STYLE) | ((WS_BORDER | WS_DLGFRAME | WS_SIZEBOX));
   if(hWindow > 0 && iNewStyle > 0)
     {
      SetWindowLongA(hWindow, GWL_STYLE, iNewStyle);
      SetWindowPos(hWindow, 0, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_FRAMECHANGED);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveBorderByWindowHandle(int hWindow)
  {
   long iNewStyle = GetWindowLongA(hWindow, GWL_STYLE) &(~(WS_BORDER | WS_DLGFRAME | WS_SIZEBOX));
   if(hWindow > 0 && iNewStyle > 0)
     {
      SetWindowLongA(hWindow, GWL_STYLE, (int) iNewStyle);
      SetWindowPos(hWindow, 0, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_FRAMECHANGED);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetChartLimits(int &iLeft, int &iRight, double &top, double &bot, int iW = 0)
  {
   top = WindowPriceMax(iW);
   iLeft = WindowFirstVisibleBar();
   bot = WindowPriceMin(iW);
   iRight = iLeft - WindowBarsPerChart();

   if(iRight < 0)
      iRight = 0; // Chart is shifted.
  } // GetChartL
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool Create_DOM(int n,string Price,string Vol,int mywidth, int max_n)
//+------------------------------------------------------------------+
  {


   if(StringToInteger(Vol)<=9)
      ColorMedian= C'37,44,48';
   if(StringToInteger(Vol)>=10  && StringToInteger(Vol)<=20)
      ColorMedian= C'47,56,62';
   if(StringToInteger(Vol)>=21  && StringToInteger(Vol)<=30)
      ColorMedian= C'52,63,69';
   if(StringToInteger(Vol)>=31  && StringToInteger(Vol)<=40)
      ColorMedian= C'61,73,80';
   if(StringToInteger(Vol)>=41  && StringToInteger(Vol)<=50)
      ColorMedian= C'61,73,80';
   if(StringToInteger(Vol)>=51  && StringToInteger(Vol)<=60)
      ColorMedian= C'61,73,80';
   if(StringToInteger(Vol)>=61  && StringToInteger(Vol)<=70)
      ColorMedian= C'61,73,80';
   if(StringToInteger(Vol)>=71  && StringToInteger(Vol)<=80)
      ColorMedian= C'149,164,176';
   if(StringToInteger(Vol)>=81  && StringToInteger(Vol)<=90)
      ColorMedian= C'149,164,176';
   if(StringToInteger(Vol)>=91  && StringToInteger(Vol)<=100)
      ColorMedian= C'149,164,176';
   if(StringToInteger(Vol)>=101 && StringToInteger(Vol)<=150)
      ColorMedian= C'170,182,191';
   if(StringToInteger(Vol)>=151 && StringToInteger(Vol)<=200)
      ColorMedian= C'192,201,207';
   if(StringToInteger(Vol)>=201 && StringToInteger(Vol)<=250)
      ColorMedian= C'214,220,224';
   if(StringToInteger(Vol)>=251 && StringToInteger(Vol)<=300)
      ColorMedian= C'232,236,238';
   if(StringToInteger(Vol)>=301 && StringToInteger(Vol)<=600)
      ColorMedian=C'251,251,251';
   if(StringToInteger(Vol)>=600)
      ColorMedian=C'255,43,43';
   if(layout==BookMap)
     {




      long x_distance;
      ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance);
      int x,y,PriceX,PriceY;

      ChartTimePriceToXY(0,0,Time[0],NormalizeDouble(StringToDouble(Price),_Digits),x,y);

      PriceX = (int)x_distance - ActualWidth - 1;
      PriceY = y;



      int height=(15 * screen_dpi) / 96;
      int x_shift=(1 * screen_dpi) / 96;
      string Text="";

      string PriceName=IntegerToString(n);
      string RectName=pprefix+"DOM"+IntegerToString(n);

      string LabelVName=RectName;
      color Bg=n>0 ? DOM_Sell_Color: DOM_Buy_Color;


      RectLabelCreate(0,RectName,0,PriceX+x_shift+ActualWidth-mywidth,PriceY-10,(mywidth * screen_dpi) / 96,height,Bg,BORDER_FLAT,0,Black,STYLE_SOLID,1,true,false,false,0);
      LabelCreate(PriceX-x_shift+ActualWidth-mywidth-7*StringLen(Vol),PriceY-10,LabelVName,Vol,VolumeColor);



      int Custom_Timeframe = 0;
      Custom_Timeframe = OBJ_ALL_PERIODS;

      RectangleCreate(0,Pprefix+PriceName+TimeToString(TimeCurrent())+(string)Vol+(string)n+(string)Price,0,TimeCurrent(),NormalizeDouble(StringToDouble(Price),5),TimeCurrent()+10,NormalizeDouble(StringToDouble(Price),5),ColorMedian,STYLE_SOLID,5,false,false,false,false,0);
      ObjectSetString(0, Pprefix+PriceName+TimeToString(TimeCurrent())+(string)Vol+(string)n+(string)Price, OBJPROP_TOOLTIP, "Price: "+Price+"  Volume: "+Vol);
      ObjectSet(Pprefix+PriceName+TimeToString(TimeCurrent())+(string)Vol+(string)n+(string)Price,OBJPROP_TIMEFRAMES,Custom_Timeframe);


     }


   else
      if(layout==bookOnChart)
        {










         long x_distance;
         ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance);
         int x,y,PriceX,PriceY;

         ChartTimePriceToXY(0,0,Time[0],NormalizeDouble(StringToDouble(Price),_Digits),x,y);

         PriceX = (int)x_distance - ActualWidth - 1;
         PriceY = y;



         int height=(15 * screen_dpi) / 96;
         int x_shift=(1 * screen_dpi) / 96;
         string Text="";

         string PriceName=IntegerToString(n);
         string RectName=pprefix+"DOM"+IntegerToString(n);

         string LabelVName=RectName;
         color Bg=n>0 ? DOM_Sell_Color: DOM_Buy_Color;


         RectLabelCreate(0,RectName,0,PriceX+x_shift+ActualWidth-mywidth,PriceY-10,(mywidth * screen_dpi) / 96,height,Bg,BORDER_FLAT,0,Black,STYLE_SOLID,1,true,false,false,0);
         LabelCreate(PriceX-x_shift+ActualWidth-mywidth-7*StringLen(Vol),PriceY-10,LabelVName,Vol,VolumeColor);








        }
      else
        {

         long x_distance;
         ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance);
         int PriceX,PriceY;
         color Bg=n>0 ? COLOR_DOWN: COLOR_UP;






         int x_shift=0;
         string Text="";

         string PriceName=IntegerToString(n);
         string RectName=pprefix+"DOM"+IntegerToString(n);
         string LineName1="Rect";




         string LineNameBuy="LINEBUY";
         string LineNameSell="LINESELL";
         string LineNamePartial="LINEPARTIAL";
         string LineNameClose="LINECLOSE";


         //-- Volume
         string LabelVName=RectName;


         string LabelSName="LABELBUY";
         string LabelBName="LABELSELL";

         ord_del_obj();


         PriceX = -62;
         PriceY = 390;

         //+------------------------------------------------------------------+
         if(layout == booksmall)
            //+------------------------------------------------------------------+
           {

            if(sic=="DOWN")
              {
               //-- 10 Nivel Book
               RectLabelCreate(0,LineName1,0,PriceX+62,PriceY-344,365,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,1,true,false,true,0);

               RectLabelCreate(0,LineName1+"BOX",0,PriceX+62,PriceY+330,358,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,1,true,false,true,0);

               //-- Buttons BUY SELL PARTIAL
               ButtonCreate(0,"LOTS",0,PriceX + 63,PriceY+332,FontSize+42,16,0,DoubleToStr(glot,2),FontType,9,Black,White,Black);
               ButtonCreate(0,LineNameBuy,0,PriceX + 114,PriceY+332,FontSize+28,16,0,"Buy",FontType,9,White,COLOR_UP,Black);
               ButtonCreate(0,LineNameSell,0,PriceX + 152,PriceY+332,FontSize+32,16,0,"Sell",FontType,9,White,COLOR_DOWN,Black);
               ButtonCreate(0,LineNamePartial,0,PriceX + 194,PriceY+332,FontSize+32,16,0,IntegerToString((int) Percent)+"%",FontType,9,Black,Yellow,Black);


               int height=22+FontSize;
               PriceX = -65;
               PriceY = 392;


               x_shift=7*StringLen(Price)+3;

               ButtonCreate(0,"ORDER"+PriceName,0,PriceX+160-7*StringLen(Price),PriceY-15-height*n+n,FontSize+53,height,0,Price,FontType,FontSize,White,clrNONE,C'40,40,40');
               //---Price Bid Etiquet
               ButtonCreate(0,LineNameClose,0,PriceX+149-14*StringLen(Price),PriceY-14,FontSize+153,height-3,0,DoubleToString(priceBid,Digits),FontType,FontSize,White,Black,Border);

               if(n<=0)
                 {


                  //--- Volume Bar
                  RectLabelCreate(0,RectName,0,PriceX-x_shift + 159-mywidth+3,PriceY-15-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                  //---- Volume Lable
                  LabelCreate(PriceX-x_shift+160-FontSize*StringLen(Vol), PriceY+5-FontSize-height*n+n, LabelVName, Vol, VolumeColor);

                  //-- SL Button
                  ButtonCreate(0,"STOP"+PriceName,0,PriceX+172+2*StringLen(Price),PriceY-15-height*n+n,FontSize+32,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');

                 }
               else
                 {
                  //--- Volume Bar
                  RectLabelCreate(0,RectName,0,PriceX-x_shift + 160+66,PriceY-15-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                  //---- Volume Lable
                  LabelCreate(PriceX+x_shift+155, PriceY+5-FontSize-height*n+n, LabelVName, Vol, VolumeColor);

                  //-- SL Button
                  ButtonCreate(0,"STOP"+PriceName,0,PriceX+152-13*StringLen(Price)-4,PriceY-15-height*n+n,FontSize+32,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');

                 }
               long maxVolume=Sum_DOM_Ask+Sum_DOM_Bid;
               //long maxVolumeB=0;

               if(maxVolume==0)
                 {
                  maxVolume=1;
                 }
               int widthA=(int)MathRound(Sum_DOM_Ask*150/maxVolume*4);
               if(widthA==0)
                 {
                  widthA=1;
                 }
               int widthB=(int)MathRound(Sum_DOM_Bid*150/maxVolume*4);
               if(widthB==0)
                 {
                  widthB=1;
                 }

               int PriceYYY =337;
               int PriceXXX =400;
               RectLabelCreate(0,LabelBName,0,PriceXXX -400,PriceYYY -267,15,widthA+25,COLOR_DOWN,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);
               RectLabelCreate(0,LabelSName,0,PriceXXX -400,PriceYYY+353 - widthB,15,widthB+25,COLOR_UP,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);




               //---- Volumes Count
               LabelCreate(PriceX+150-11*StringLen(Price), PriceY-FontSize-320-height*(-max_n/2)+4,pprefix+"DOM_SUM_ASK",IntegerToString(Sum_DOM_Bid), COLOR_UP);
               LabelCreate(PriceX+173+3*StringLen(Price), PriceY-FontSize+328-height*(max_n/2)-4,pprefix+"DOM_SUM_BID", IntegerToString(Sum_DOM_Ask), COLOR_DOWN);
              }


            else
               if(sic=="DAX")
                 {
                  RectLabelCreate(0,LineName1,0,PriceX+62,PriceY-344,365,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,1,true,false,true,0);
                  RectLabelCreate(0,LineName1+"BOX",0,PriceX+62,PriceY+486,358,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,2,true,false,true,0);
                  //+------------------------------------------------------------------+
                  //-- Buttons BUY SELL PARTIAL
                  ButtonCreate(0,"LOTS",0,PriceX + 63,PriceY+487,FontSize+42,16,0,DoubleToStr(glot,2),FontType,9,Black,White,Black);
                  ButtonCreate(0,LineNameBuy,0,PriceX + 114,PriceY+487,FontSize+28,16,0,"Buy",FontType,9,White,COLOR_UP,Black);
                  ButtonCreate(0,LineNameSell,0,PriceX + 152,PriceY+487,FontSize+32,16,0,"Sell",FontType,9,White,COLOR_DOWN,Black);
                  ButtonCreate(0,LineNamePartial,0,PriceX + 194,PriceY+487,FontSize+32,16,0,IntegerToString((int) Percent)+"%",FontType,9,Black,Yellow,Black);


                  //+------------------------------------------------------------------+
                  int height=17+FontSize;
                  PriceX = -38;
                  PriceY = 472;
                  FontSize=10;
                  FontType="Arial";
                  x_shift=7*StringLen(Price)+3;


                  //+------------------------------------------------------------------+
                  ButtonCreate(0,"ORDER"+PriceName,0,PriceX+150-7*StringLen(Price),PriceY-13-height*n+n,FontSize+53,height,0,Price,FontType,FontSize,White,clrNONE,Black);
                  //---Price Bid Etiquet
                  ButtonCreate(0,LineNameClose,0,PriceX+150-14*StringLen(Price),PriceY-12,FontSize+153,height-3,0,DoubleToString(priceBid,Digits),FontType,FontSize,White,Black,Border);



                  if(n<=0)
                    {

                     //-- SL Button
                     ButtonCreate(0,"STOP"+PriceName,0,PriceX+150+2*StringLen(Price),PriceY-13-height*n+n,FontSize+32,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');
                     //+------------------------------------------------------------------+

                     //--- Volume Bar
                     RectLabelCreate(0,RectName,0,PriceX-x_shift + 150-mywidth+3,PriceY-13-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                     //---- Volume Lable
                     LabelCreate(PriceX-x_shift+150-FontSize*StringLen(Vol), PriceY+2-FontSize-height*n+n, LabelVName, Vol, VolumeColor);
                     //+------------------------------------------------------------------+
                    }
                  else
                    {

                     //-- SL Button
                     ButtonCreate(0,"STOP"+PriceName,0,PriceX+150-13*StringLen(Price)-4,PriceY-13-height*n+n,FontSize+33,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');

                     //--- Volume Bar
                     RectLabelCreate(0,RectName,0,PriceX-x_shift + 150+66,PriceY-13-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                     //---- Volume Lable
                     LabelCreate(PriceX+x_shift+118, PriceY+1-FontSize-height*n+n, LabelVName, Vol, VolumeColor);
                     //+------------------------------------------------------------------+

                    }
                  long maxVolume=Sum_DOM_Ask+Sum_DOM_Bid;
                  //long maxVolumeB=0;

                  if(maxVolume==0)
                    {
                     maxVolume=1;
                    }
                  int widthA=(int)MathRound(Sum_DOM_Ask*150/maxVolume*4);
                  if(widthA==0)
                    {
                     widthA=1;
                    }
                  int widthB=(int)MathRound(Sum_DOM_Bid*150/maxVolume*4);
                  if(widthB==0)
                    {
                     widthB=1;
                    }

                  int PriceYYY =337;
                  int PriceXXX =400;
                  RectLabelCreate(0,LabelBName,0,PriceXXX -400,PriceYYY -268,15,widthA+105,COLOR_DOWN,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);
                  RectLabelCreate(0,LabelSName,0,PriceXXX -400,PriceYYY+434 - widthB,15,widthB+105,COLOR_UP,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);




                  //---- Volumes Count
                  LabelCreate(PriceX+150-13*StringLen(Price), PriceY-FontSize-406-height*(-max_n/2)+4,pprefix+"DOM_SUM_ASK",IntegerToString(Sum_DOM_Bid), COLOR_UP);
                  LabelCreate(PriceX+150+3*StringLen(Price), PriceY-FontSize+411-height*(max_n/2)-4, pprefix+"DOM_SUM_BID", IntegerToString(Sum_DOM_Ask), COLOR_DOWN);
                 }
               else
                 {
                  //-- 10 Nivel Book
                  RectLabelCreate(0,LineName1,0,PriceX+62,PriceY-344,365,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,1,true,false,true,0);

                  RectLabelCreate(0,LineName1+"BOX",0,PriceX+62,PriceY+330,358,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,1,true,false,true,0);

                  //-- Buttons BUY SELL PARTIAL
                  ButtonCreate(0,"LOTS",0,PriceX + 63,PriceY+332,FontSize+42,16,0,DoubleToStr(glot,2),FontType,9,Black,White,Black);
                  ButtonCreate(0,LineNameBuy,0,PriceX + 114,PriceY+332,FontSize+28,16,0,"Buy",FontType,9,White,COLOR_UP,Black);
                  ButtonCreate(0,LineNameSell,0,PriceX + 152,PriceY+332,FontSize+32,16,0,"Sell",FontType,9,White,COLOR_DOWN,Black);
                  ButtonCreate(0,LineNamePartial,0,PriceX + 194,PriceY+332,FontSize+32,16,0,IntegerToString((int) Percent)+"%",FontType,9,Black,Yellow,Black);


                  int height=22+FontSize;
                  PriceX = -38;
                  PriceY = 392;


                  x_shift=7*StringLen(Price)+3;

                  ButtonCreate(0,"ORDER"+PriceName,0,PriceX+150-7*StringLen(Price),PriceY-15-height*n+n,FontSize+53,height,0,Price,FontType,FontSize,White,clrNONE,C'40,40,40');



                  //---Price Bid Etiquet
                  ButtonCreate(0,LineNameClose,0,PriceX+150-14*StringLen(Price),PriceY-14,FontSize+153,height-3,0,DoubleToString(priceBid,Digits),FontType,FontSize,White,Black,Border);

                  if(n<=0)
                    {


                     //--- Volume Bar
                     RectLabelCreate(0,RectName,0,PriceX-x_shift + 150-mywidth+3,PriceY-15-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                     //---- Volume Lable
                     LabelCreate(PriceX-x_shift+150-FontSize*StringLen(Vol), PriceY+5-FontSize-height*n+n, LabelVName, Vol, VolumeColor);

                     //-- SL Button
                     ButtonCreate(0,"STOP"+PriceName,0,PriceX+152+2*StringLen(Price),PriceY-15-height*n+n,FontSize+32,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');

                    }
                  else
                    {
                     //--- Volume Bar
                     RectLabelCreate(0,RectName,0,PriceX-x_shift + 150+66,PriceY-15-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                     //---- Volume Lable
                     LabelCreate(PriceX+x_shift+118, PriceY+5-FontSize-height*n+n, LabelVName, Vol, VolumeColor);

                     //-- SL Button
                     ButtonCreate(0,"STOP"+PriceName,0,PriceX+152-13*StringLen(Price)-4,PriceY-15-height*n+n,FontSize+32,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');

                    }
                  long maxVolume=Sum_DOM_Ask+Sum_DOM_Bid;
                  //long maxVolumeB=0;

                  if(maxVolume==0)
                    {
                     maxVolume=1;
                    }
                  int widthA=(int)MathRound(Sum_DOM_Ask*150/maxVolume*4);
                  if(widthA==0)
                    {
                     widthA=1;
                    }
                  int widthB=(int)MathRound(Sum_DOM_Bid*150/maxVolume*4);
                  if(widthB==0)
                    {
                     widthB=1;
                    }

                  int PriceYYY =337;
                  int PriceXXX =400;
                  RectLabelCreate(0,LabelBName,0,PriceXXX -400,PriceYYY -267,15,widthA+25,COLOR_DOWN,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);
                  RectLabelCreate(0,LabelSName,0,PriceXXX -400,PriceYYY+353 - widthB,15,widthB+25,COLOR_UP,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);




                  //---- Volumes Count
                  LabelCreate(PriceX+150-11*StringLen(Price), PriceY-FontSize-320-height*(-max_n/2)+4,pprefix+"DOM_SUM_ASK",IntegerToString(Sum_DOM_Bid), COLOR_UP);
                  LabelCreate(PriceX+150+3*StringLen(Price), PriceY-FontSize+328-height*(max_n/2)-4,pprefix+"DOM_SUM_BID", IntegerToString(Sum_DOM_Ask), COLOR_DOWN);
                 }
           }
         //+------------------------------------------------------------------+
         if(layout == bookmicro)
            //+---{---------------------------------------------------------------+
           {
            if(sic=="DOWN")
              {
               //-- 10 Nivel Book
               RectLabelCreate(0,LineName1,0,PriceX+62,PriceY-344,365,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,1,true,false,true,0);

               RectLabelCreate(0,LineName1+"BOX",0,PriceX+62,PriceY+330,358,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,1,true,false,true,0);

               //-- Buttons BUY SELL PARTIAL
               ButtonCreate(0,"LOTS",0,PriceX + 63,PriceY+332,FontSize+42,16,0,DoubleToStr(glot,2),FontType,9,Black,White,Black);
               ButtonCreate(0,LineNameBuy,0,PriceX + 114,PriceY+332,FontSize+28,16,0,"Buy",FontType,9,White,COLOR_UP,Black);
               ButtonCreate(0,LineNameSell,0,PriceX + 152,PriceY+332,FontSize+32,16,0,"Sell",FontType,9,White,COLOR_DOWN,Black);
               ButtonCreate(0,LineNamePartial,0,PriceX + 194,PriceY+332,FontSize+32,16,0,IntegerToString((int) Percent)+"%",FontType,9,Black,Yellow,Black);


               int height=22+FontSize;
               PriceX = -65;
               PriceY = 392;


               x_shift=7*StringLen(Price)+3;

               ButtonCreate(0,"ORDER"+PriceName,0,PriceX+160-7*StringLen(Price),PriceY-15-height*n+n,FontSize+53,height,0,Price,FontType,FontSize,White,clrNONE,C'40,40,40');



               //---Price Bid Etiquet
               ButtonCreate(0,LineNameClose,0,PriceX+149-14*StringLen(Price),PriceY-14,FontSize+153,height-3,0,DoubleToString(priceBid,Digits),FontType,FontSize,White,Black,Border);

               if(n<=0)
                 {


                  //--- Volume Bar
                  RectLabelCreate(0,RectName,0,PriceX-x_shift + 159-mywidth+3,PriceY-15-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                  //---- Volume Lable
                  LabelCreate(PriceX-x_shift+160-FontSize*StringLen(Vol), PriceY+5-FontSize-height*n+n, LabelVName, Vol, VolumeColor);

                  //-- SL Button
                  ButtonCreate(0,"STOP"+PriceName,0,PriceX+172+2*StringLen(Price),PriceY-15-height*n+n,FontSize+32,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');

                 }
               else
                 {
                  //--- Volume Bar
                  RectLabelCreate(0,RectName,0,PriceX-x_shift + 160+66,PriceY-15-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                  //---- Volume Lable
                  LabelCreate(PriceX+x_shift+155, PriceY+5-FontSize-height*n+n, LabelVName, Vol, VolumeColor);

                  //-- SL Button
                  ButtonCreate(0,"STOP"+PriceName,0,PriceX+152-13*StringLen(Price)-4,PriceY-15-height*n+n,FontSize+32,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');

                 }
               long maxVolume=Sum_DOM_Ask+Sum_DOM_Bid;
               //long maxVolumeB=0;

               if(maxVolume==0)
                 {
                  maxVolume=1;
                 }
               int widthA=(int)MathRound(Sum_DOM_Ask*150/maxVolume*4);
               if(widthA==0)
                 {
                  widthA=1;
                 }
               int widthB=(int)MathRound(Sum_DOM_Bid*150/maxVolume*4);
               if(widthB==0)
                 {
                  widthB=1;
                 }

               int PriceYYY =337;
               int PriceXXX =400;
               RectLabelCreate(0,LabelBName,0,PriceXXX -400,PriceYYY -267,15,widthA+25,COLOR_DOWN,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);
               RectLabelCreate(0,LabelSName,0,PriceXXX -400,PriceYYY+353 - widthB,15,widthB+25,COLOR_UP,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);




               //---- Volumes Count
               LabelCreate(PriceX+150-11*StringLen(Price), PriceY-FontSize-320-height*(-max_n/2)+4,pprefix+"DOM_SUM_ASK",IntegerToString(Sum_DOM_Bid), COLOR_UP);
               LabelCreate(PriceX+173+3*StringLen(Price), PriceY-FontSize+328-height*(max_n/2)-4,pprefix+"DOM_SUM_BID", IntegerToString(Sum_DOM_Ask), COLOR_DOWN);
              }



            else
               if(sic=="DAX")
                 {
                  RectLabelCreate(0,LineName1,0,PriceX+62,PriceY-344,365,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,1,true,false,true,0);
                  RectLabelCreate(0,LineName1+"BOX",0,PriceX+62,PriceY+486,358,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,2,true,false,true,0);
                  //+------------------------------------------------------------------+
                  //-- Buttons BUY SELL PARTIAL
                  ButtonCreate(0,"LOTS",0,PriceX + 63,PriceY+487,FontSize+42,16,0,DoubleToStr(glot,2),FontType,9,Black,White,Black);
                  ButtonCreate(0,LineNameBuy,0,PriceX + 114,PriceY+487,FontSize+28,16,0,"Buy",FontType,9,White,COLOR_UP,Black);
                  ButtonCreate(0,LineNameSell,0,PriceX + 152,PriceY+487,FontSize+32,16,0,"Sell",FontType,9,White,COLOR_DOWN,Black);
                  ButtonCreate(0,LineNamePartial,0,PriceX + 194,PriceY+487,FontSize+32,16,0,IntegerToString((int) Percent)+"%",FontType,9,Black,Yellow,Black);


                  //+------------------------------------------------------------------+
                  int height=17+FontSize;
                  PriceX = -38;
                  PriceY = 472;
                  FontSize=10;
                  FontType="Arial";
                  x_shift=7*StringLen(Price)+3;


                  //+------------------------------------------------------------------+
                  ButtonCreate(0,"ORDER"+PriceName,0,PriceX+150-7*StringLen(Price),PriceY-13-height*n+n,FontSize+53,height,0,Price,FontType,FontSize,White,clrNONE,Black);
                  //---Price Bid Etiquet
                  ButtonCreate(0,LineNameClose,0,PriceX+150-14*StringLen(Price),PriceY-12,FontSize+153,height-3,0,DoubleToString(priceBid,Digits),FontType,FontSize,White,Black,Border);



                  if(n<=0)
                    {

                     //-- SL Button
                     ButtonCreate(0,"STOP"+PriceName,0,PriceX+150+2*StringLen(Price),PriceY-13-height*n+n,FontSize+32,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');
                     //+------------------------------------------------------------------+

                     //--- Volume Bar
                     RectLabelCreate(0,RectName,0,PriceX-x_shift + 150-mywidth+3,PriceY-13-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                     //---- Volume Lable
                     LabelCreate(PriceX-x_shift+150-FontSize*StringLen(Vol), PriceY+2-FontSize-height*n+n, LabelVName, Vol, VolumeColor);
                     //+------------------------------------------------------------------+
                    }
                  else
                    {

                     //-- SL Button
                     ButtonCreate(0,"STOP"+PriceName,0,PriceX+150-13*StringLen(Price)-4,PriceY-13-height*n+n,FontSize+33,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');

                     //--- Volume Bar
                     RectLabelCreate(0,RectName,0,PriceX-x_shift + 150+66,PriceY-13-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,true,false,false,0);
                     //---- Volume Lable
                     LabelCreate(PriceX+x_shift+118, PriceY+1-FontSize-height*n+n, LabelVName, Vol, VolumeColor);
                     //+------------------------------------------------------------------+

                    }
                  long maxVolume=Sum_DOM_Ask+Sum_DOM_Bid;
                  //long maxVolumeB=0;

                  if(maxVolume==0)
                    {
                     maxVolume=1;
                    }
                  int widthA=(int)MathRound(Sum_DOM_Ask*150/maxVolume*4);
                  if(widthA==0)
                    {
                     widthA=1;
                    }
                  int widthB=(int)MathRound(Sum_DOM_Bid*150/maxVolume*4);
                  if(widthB==0)
                    {
                     widthB=1;
                    }

                  int PriceYYY =337;
                  int PriceXXX =400;
                  RectLabelCreate(0,LabelBName,0,PriceXXX -400,PriceYYY -268,15,widthA+105,COLOR_DOWN,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);
                  RectLabelCreate(0,LabelSName,0,PriceXXX -400,PriceYYY+434 - widthB,15,widthB+105,COLOR_UP,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);




                  //---- Volumes Count
                  LabelCreate(PriceX+150-13*StringLen(Price), PriceY-FontSize-406-height*(-max_n/2)+4,pprefix+"DOM_SUM_ASK",IntegerToString(Delta_DOM_Ask), COLOR_UP);
                  LabelCreate(PriceX+150+3*StringLen(Price), PriceY-FontSize+411-height*(max_n/2)-4, pprefix+"DOM_SUM_BID", IntegerToString(Delta_DOM_Bid), COLOR_DOWN);
                 }
               else
                 {
                  //-- 10 Nivel Book
                  RectLabelCreate(0,LineName1,0,PriceX+62,PriceY-344,365,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,1,true,false,true,0);
                  RectLabelCreate(0,LineName1+"BOX",0,PriceX+62,PriceY+226,358,20,Black,BORDER_FLAT,0,Border,STYLE_SOLID,2,true,false,true,0);
                  //+------------------------------------------------------------------+
                  //-- Buttons BUY SELL PARTIAL
                  ButtonCreate(0,"LOTS",0,PriceX + 63,PriceY+228,FontSize+42,16,0,DoubleToStr(glot,2),FontType,9,Black,White,Black);
                  ButtonCreate(0,LineNameBuy,0,PriceX + 114,PriceY+228,FontSize+28,16,0,"Buy",FontType,9,White,COLOR_UP,Black);
                  ButtonCreate(0,LineNameSell,0,PriceX + 152,PriceY+228,FontSize+32,16,0,"Sell",FontType,9,White,COLOR_DOWN,Black);
                  ButtonCreate(0,LineNamePartial,0,PriceX + 194,PriceY+228,FontSize+32,16,0,IntegerToString((int) Percent)+"%",FontType,9,Black,Yellow,Black);


                  //+------------------------------------------------------------------+
                  int height=17+FontSize;
                  PriceX = -38;
                  PriceY = 342;
                  FontSize=10;
                  FontType="Arial";
                  x_shift=7*StringLen(Price)+3;


                  //+------------------------------------------------------------------+
                  ButtonCreate(0,"ORDER"+PriceName,0,PriceX+150-7*StringLen(Price),PriceY-13-height*n+n,FontSize+53,height,0,Price,FontType,FontSize,White,clrNONE,Black);
                  //---Price Bid Etiquet
                  ButtonCreate(0,LineNameClose,0,PriceX+150-14*StringLen(Price),PriceY-12,FontSize+153,height-3,0,DoubleToString(priceBid,Digits),FontType,FontSize,White,Black,Border);



                  if(n<=0)
                    {

                     //-- SL Button
                     ButtonCreate(0,"STOP"+PriceName,0,PriceX+150+2*StringLen(Price),PriceY-13-height*n+n,FontSize+32,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');
                     //+------------------------------------------------------------------+

                     //--- Volume Bar
                     RectLabelCreate(0,RectName,0,PriceX-x_shift + 150-mywidth+3,PriceY-13-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,bords,STYLE_SOLID,1,true,false,false,0);
                     //---- Volume Lable
                     LabelCreate(PriceX-x_shift+150-FontSize*StringLen(Vol), PriceY+2-FontSize-height*n+n, LabelVName, Vol, VolumeColor);
                     //+------------------------------------------------------------------+
                    }
                  else
                    {

                     //-- SL Button
                     ButtonCreate(0,"STOP"+PriceName,0,PriceX+150-13*StringLen(Price)-4,PriceY-13-height*n+n,FontSize+33,height,0,Price,FontType,FontSize-2,clrNONE,clrNONE,C'40,40,40');

                     //--- Volume Bar
                     RectLabelCreate(0,RectName,0,PriceX-x_shift + 150+66,PriceY-13-height*n+n,mywidth,height,Bg,BORDER_FLAT,0,bords,STYLE_SOLID,1,true,false,false,0);
                     //---- Volume Lable
                     LabelCreate(PriceX+x_shift+118, PriceY+1-FontSize-height*n+n, LabelVName, Vol, VolumeColor);
                     //+------------------------------------------------------------------+

                    }
                  long maxVolume=Sum_DOM_Ask+Sum_DOM_Bid;
                  //long maxVolumeB=0;

                  if(maxVolume==0)
                    {
                     maxVolume=1;
                    }
                  int widthA=(int)MathRound(Sum_DOM_Ask*150/maxVolume*4);
                  if(widthA==0)
                    {
                     widthA=1;
                    }
                  int widthB=(int)MathRound(Sum_DOM_Bid*150/maxVolume*4);
                  if(widthB==0)
                    {
                     widthB=1;
                    }

                  int PriceYYY =337;
                  int PriceXXX =400;
                  RectLabelCreate(0,LabelBName,0,PriceXXX -400,PriceYYY -267,15,widthA-26,COLOR_DOWN,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);
                  RectLabelCreate(0,LabelSName,0,PriceXXX -400,PriceYYY+303 - widthB,15,widthB-26,COLOR_UP,BORDER_FLAT,0,clrBlack,STYLE_SOLID,1,false,false,false,0);




                  //---- Volumes Count
                  LabelCreate(PriceX+160-13*StringLen(Price), PriceY-FontSize-323-height*(-max_n/2)+4,pprefix+"DOM_SUM_ASK",IntegerToString(Delta_DOM_Ask), COLOR_UP);
                  LabelCreate(PriceX+150+3*StringLen(Price), PriceY-FontSize+329-height*(max_n/2)-4, pprefix+"DOM_SUM_BID", IntegerToString(Delta_DOM_Bid), COLOR_DOWN);
                 }
           }

         ButtonCreate(0,"Line20",0, 175,48,64,16,0,"TIME",FontType,7,White,Black,C'40,40,40');
         ButtonCreate(0,"LINE21",0, 242,48,60,16,0,"PRICE",FontType,7,White,Black,C'40,40,40');
         ButtonCreate(0,"LINE22",0, 305,48,58,16,0,"VOLUME",FontType,7,White,Black,C'40,40,40');
        }
   return true;
  }
//+------------------------------------------------------------------+
//| Total profit                                                     |
//+------------------------------------------------------------------+
double total_profit()
  {

   double tt_profit = 0.0;

   for(int x = 0; x < OrdersTotal(); x++)
     {

      if(OrderSelect(x, SELECT_BY_POS, MODE_TRADES))
        {

         if(OrderSymbol() == MySymbol)
           {

            tt_profit += OrderProfit() + OrderSwap() + OrderCommission();

           }

        }

     }

   return (tt_profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double current_spread()
  {

   double spread;

   if(Digits == 3 || Digits == 5)
     {

      spread = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD) / 10, 1);

     }
   else
     {

      spread = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), 0);

     }

   return (spread);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void xmlDownload()
  {
//---
   ResetLastError();
   string sUrl = "https://s3.amazonaws.com/ejtrader/MQL4/Experts/EJTRADER.txt";
   string FilePath = StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH), "\\MQL4\\Experts\\", xmlFileName);
   int delResult = DeleteUrlCacheEntry(FilePath);
   int FileGet = URLDownloadToFileW(NULL, sUrl, FilePath, 0, NULL);
   if(FileGet == 0)
      PrintFormat(INAME + ": %s file downloaded successfully!", xmlFileName);
//--- check for errors
   else
      PrintFormat(INAME + ": failed to download %s file, Error code = %d", xmlFileName, GetLastError());
//---
  }



//+------------------------------------------------------------------+
//| Check for update XML                                             |
//+------------------------------------------------------------------+
void xmlUpdate()
  {
//--- do not download on saturday
   if(TimeDayOfWeek(Midnight) == 6)
      return;
   else
     {
      Print(INAME + ": check for updates...");
      Print(INAME + ": delete old file");
      FileDelete(xmlFileName);
      xmlDownload();
      xmlModifed = (datetime) TimeLocal();
      PrintFormat(INAME + ": updated successfully! last modified: %s", (string) xmlModifed);
     }
//---
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ord_del_obj()
  {
   int Total;
   int obj_total = ObjectsTotal();
   Total = OrdersTotal();
   double op = 0;
   double opsl = 0;
   double optp = 0;


   opsl = OrderStopLoss();
   optp = OrderTakeProfit();
   op = OrderOpenPrice();


   if(MathAbs(op - Bid) < 0.000054 && OrderSymbol() == Symbol())
     {
      ObjectSetInteger(0, "EJLINECLOSE", OBJPROP_STATE, true);
      ObjectSetInteger(0, "EJLINECLOSE", OBJPROP_BGCOLOR, C'91,91,91');
     }
   else
      if(MathAbs(Bid - op) < 0.000054)
        {
         ObjectSetInteger(0, "EJLINECLOSE", OBJPROP_STATE, true);
         ObjectSetInteger(0, "EJLINECLOSE", OBJPROP_BGCOLOR, C'91,91,91');
        }
      else
        {
         ObjectSetInteger(0, "EJLINECLOSE", OBJPROP_STATE, false);
         ObjectSetInteger(0, "EJLINECLOSE", OBJPROP_BGCOLOR, clrNONE);
        }



   double RiskReward_ratio = 0;

   if((op - opsl) != 0)
      RiskReward_ratio = (optp - op) / (op - opsl);


   if(opsl && optp)
      RiskReward = DoubleToStr(RiskReward_ratio, 2) + "\n";
   else
      RiskReward = "0:0";


   for(int s = 0; s < ArraySize(BookObjectLevel); s++)
     {
      string Nubook =  BookObjectLevel[s] ;



      if(OrderSymbol() == Symbol() && ObjectDescription("EJORDER"+Nubook) == DoubleToStr(op, Digits))
        {
         ObjectSetInteger(0, "EJORDER"+Nubook, OBJPROP_STATE, true);
         ObjectSetInteger(0, "EJORDER"+Nubook, OBJPROP_BGCOLOR, COLOR_DOWN);
        }
      else
        {
         ObjectSetInteger(0, "EJORDER"+Nubook, OBJPROP_STATE, false);
         ObjectSetInteger(0, "EJORDER"+Nubook, OBJPROP_BGCOLOR, clrNONE);
        }



      if(OrderSymbol() == Symbol() && ObjectDescription("EJORDER-"+Nubook) == DoubleToStr(op, Digits))
        {
         ObjectSetInteger(0, "EJORDER-"+Nubook, OBJPROP_STATE, true);
         ObjectSetInteger(0, "EJORDER-"+Nubook, OBJPROP_BGCOLOR, COLOR_UP);
        }
      else
        {
         ObjectSetInteger(0, "EJORDER-"+Nubook, OBJPROP_STATE, false);
         ObjectSetInteger(0, "EJORDER-"+Nubook, OBJPROP_BGCOLOR, clrNONE);
        }



      // Button Stop and Take profit
      if(OrderSymbol() == Symbol() && ObjectDescription("EJSTOP"+Nubook) == DoubleToStr(opsl, Digits))
        {
         ObjectSetInteger(0, "EJSTOP"+Nubook, OBJPROP_STATE, true);
         ObjectSetInteger(0, "EJSTOP"+Nubook, OBJPROP_BGCOLOR, Red);
        }
      else
         if(OrderSymbol() == Symbol() && ObjectDescription("EJSTOP"+Nubook) == DoubleToStr(optp, Digits))
           {
            ObjectSetInteger(0, "EJSTOP"+Nubook, OBJPROP_STATE, true);
            ObjectSetInteger(0, "EJSTOP"+Nubook, OBJPROP_BGCOLOR, Lime);
           }
         else
           {
            ObjectSetInteger(0, "EJSTOP"+Nubook, OBJPROP_STATE, false);
            ObjectSetInteger(0, "EJSTOP"+Nubook, OBJPROP_BGCOLOR, Black);
           }


      if(OrderSymbol() == Symbol() && ObjectDescription("EJSTOP-"+Nubook) == DoubleToStr(opsl, Digits))
        {
         ObjectSetInteger(0, "EJSTOP-"+Nubook, OBJPROP_STATE, true);
         ObjectSetInteger(0, "EJSTOP-"+Nubook, OBJPROP_BGCOLOR, Red);
        }
      else
         if(OrderSymbol() == Symbol() && ObjectDescription("EJSTOP-"+Nubook) == DoubleToStr(optp, Digits))
           {
            ObjectSetInteger(0, "EJSTOP-"+Nubook, OBJPROP_STATE, true);
            ObjectSetInteger(0, "EJSTOP-"+Nubook, OBJPROP_BGCOLOR, Lime);
           }
         else
           {
            ObjectSetInteger(0, "EJSTOP-"+Nubook, OBJPROP_STATE, false);
            ObjectSetInteger(0, "EJSTOP-"+Nubook, OBJPROP_BGCOLOR, Black);
           }


     }


   if(Total < 1 && OrderSymbol() == Symbol())
      for(int i = 0; i < obj_total; i++)
        {

         if(StringSubstr(ObjectName(i), 0, 11) == "EJLINECLOSE")
           {
            ObjectSetInteger(0, ObjectName(i), OBJPROP_STATE, false);
            ObjectSetInteger(0, ObjectName(i), OBJPROP_BGCOLOR, clrNONE);
           }

        }
   if(Total < 1 && OrderSymbol() == Symbol())
      for(int i = 0; i < obj_total; i++)
        {

         if(StringSubstr(ObjectName(i), 0, 7) == "EJORDER")
           {
            ObjectSetInteger(0, ObjectName(i), OBJPROP_STATE, false);
            ObjectSetInteger(0, ObjectName(i), OBJPROP_BGCOLOR, clrNONE);
           }

        }
   if(Total < 1 && OrderSymbol() == Symbol())
      for(int i = 0; i < obj_total; i++)
        {

         if(StringSubstr(ObjectName(i), 0, 6) == "EJSTOP")
           {
            ObjectSetInteger(0, ObjectName(i), OBJPROP_STATE, false);
            ObjectSetInteger(0, ObjectName(i), OBJPROP_BGCOLOR, Black);
           }
        }



  }
//+------------------------------------------------------------------+
//| Cоздает эллипс по заданным координатам                           |
//+------------------------------------------------------------------+
bool EllipseCreate(const long            chart_ID=0,        // ID графика
                   const string          name="Ellipse",    // имя эллипса
                   const int             sub_window=0,      // номер подокна
                   datetime              time1=0,           // время первой точки
                   double                price1=0,          // цена первой точки
                   datetime              time2=0,           // время второй точки
                   double                price2=0,          // цена второй точки
                   double                ellipse_scale=0.2,   // соотношение между временной и ценовой шкалами
                   const color           clr=clrRed,        // цвет эллипса
                   const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линий эллипса
                   const int             width=1,           // толщина линий эллипса
                   const bool            fill=false,        // заливка эллипса цветом
                   const bool            back=false,        // на заднем плане
                   const bool            selection=true,    // выделить для перемещений
                   const bool            hidden=true,       // скрыт в списке объектов
                   const long            z_order=0)         // приоритет на нажатие мышью
  {
//--- установим координаты точек привязки, если они не заданы
//ChangeEllipseEmptyPoints(time1,price1,time2,price2);
   ObjectDelete(name);
//--- сбросим значение ошибки
   ResetLastError();
//--- создадим эллипс по заданным координатам
   ObjectCreate(chart_ID,name,OBJ_ELLIPSE,sub_window,time1,price1,time2,price2);
//--- установим соотношение между временной и ценовой шкалами
   ObjectSetDouble(chart_ID,name,OBJPROP_SCALE,ellipse_scale);
//--- установим цвет эллипса
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим стиль линий эллипса
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- установим толщину линий эллипса
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим выделения эллипса для перемещений
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // ID графика
                     const string          name="Rectangle",  // имя прямоугольника
                     const int             sub_window=0,      // номер подокна
                     datetime              time1=0,           // время первой точки
                     double                price1=0,          // цена первой точки
                     datetime              time2=0,           // время второй точки
                     double                price2=0,          // цена второй точки
                     const color           clr=clrRed,        // цвет прямоугольника
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линий прямоугольника
                     const int             width=1,           // толщина линий прямоугольника
                     const bool            fill=false,        // заливка прямоугольника цветом
                     const bool            back=false,        // на заднем плане
                     const bool            selection=true,    // выделить для перемещений
                     const bool            hidden=true,       // скрыт в списке объектов
                     const long            z_order=0)         // приоритет на нажатие мышью
  {
   ObjectDelete(name);
   ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2);
   ResetLastError();
//--- установим цвет прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим стиль линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- установим толщину линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим выделения прямоугольника для перемещений
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);

//--- успешное выполнение
   return(true);
  }

//+------------------------------------------------------------------+
bool RectLabelCreatePrice(const long chart_ID = 0,
                          string name = "RectLabel", const int sub_window = 0, const int x = 0, const int  y = 0, const int width = 50, const int height = 18, const color back_clr = C'81,81,81', const ENUM_BORDER_TYPE border = BORDER_SUNKEN, const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, const color clr = clrRed, const ENUM_LINE_STYLE style = STYLE_SOLID, const int line_width = 1, const bool back = false, const bool selection = false, const bool hidden = true, const long z_order = 0)
  {
//+------------------------------------------------------------------+
   ResetLastError();
   name = StringConcatenate(pprefix, name);

   if(!ObjectCreate(chart_ID, name, OBJ_RECTANGLE_LABEL, sub_window, 0, 0))
     {

     }

   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_TYPE, border);
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, line_width);
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);

   return (true);
  }
//+------------------------------------------------------------------+
