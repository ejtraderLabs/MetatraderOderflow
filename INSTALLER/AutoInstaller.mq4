#property copyright                 "Copyright © 2017-2023, EJTRADER Power by Bitcoin Nano"
#property link                      "https://bitcoinnano.org"
#property description "EJtrader Installer" + " - Power By Bitcoin Nano API"
#define    INAME     "EJTRADER"

#import "wininet.dll"
int DeleteUrlCacheEntry(string fileName);
int DeleteUrlCacheEntryA(string fileName);
int DeleteUrlCacheEntryW(string fileName);
#import

#import "urlmon.dll"
int URLDownloadToFileW(int pCaller,string szURL,string szFileName,int dwReserved,int Callback);
#import

#import "user32.dll"
int PostMessageA(int hWnd, int msg, int wparam, int lparam);
int GetParent(int hWnd);
#import

#import "shell32.dll"
int ShellExecuteW(int hwnd,string lpOperation,string lpFile,string lpParameters,
                  string lpDirectory,int nShowCmd);
#import
#define WM_CLOSE 16




string url = "https://raw.githubusercontent.com/ejtraderLabs/MetatraderOderflow/main/INSTALLER/";



string TPDEFAULT="default.tpl";
string EXPERTCONFIG="experts.ini";


bool       AllowUpdates      = true;                 // Permitir atualizações
datetime   xmlModifed;



string Experties[3] =
  {
   "Renko.ex4","EJTrader.ex4","AutoInstaller.ex4"
  };


// string Indicators[6] =
//   {
//    "Calendar.ex4","MTFLines.ex4","ZoneSR.ex4","VProfile.ex4","CandleHiLo.ex4","FiboRetracement.ex4"
//   };

string Libraries[3] =
  {
   "libzmq.dll","unlock.dll","libsodium.dll"
  };


string Library = "";
string IndiCators = "";
string Experts = "";

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!IsDllsAllowed())
     {
      Alert("Error: Dll calls must be allowed!");
     }
//--- check for updates
   if(AllowUpdates)
     {
      EJUpdate();
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Exp()
  {
//---
   ResetLastError();
   string sUrl= url+Experts+".txt";;
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\Experts\\",Experts);
   int delResult = DeleteUrlCacheEntry(FilePath);
   int delResult1 = DeleteUrlCacheEntryA(FilePath);
   int delResult2 = DeleteUrlCacheEntryW(FilePath);
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);
   if(FileGet==0)
      PrintFormat(INAME+": %s file downloaded successfully!",Experts);
//--- check for errors
   else
      PrintFormat(INAME+": failed to download %s file, Error code = %d",Experts,GetLastError());
//---
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Ind()
  {
//---
   ResetLastError();
   string sUrl= url+IndiCators+".txt";
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\Indicators\\",IndiCators);
   int delResult = DeleteUrlCacheEntry(FilePath);
   int delResult1 = DeleteUrlCacheEntryA(FilePath);
   int delResult2 = DeleteUrlCacheEntryW(FilePath);
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);
   if(FileGet==0)
      PrintFormat(INAME+": %s file downloaded successfully!",IndiCators);
//--- check for errors
   else
      PrintFormat(INAME+": failed to download %s file, Error code = %d",IndiCators,GetLastError());
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Lib()
  {
//---
   ResetLastError();
   string sUrl=url+Library+".txt";
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\Libraries\\",Library);
   int delResult = DeleteUrlCacheEntry(FilePath);
   int delResult1 = DeleteUrlCacheEntryA(FilePath);
   int delResult2 = DeleteUrlCacheEntryW(FilePath);
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);
   if(FileGet==0)
      PrintFormat(INAME+": %s file downloaded successfully!",Library);
//--- check for errors
   else
      PrintFormat(INAME+": failed to download %s file, Error code = %d",Library,GetLastError());
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TEMPLATEDF()
  {
//---
   ResetLastError();
   string sUrl=url+"default.tpl.txt";
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\templates\\",TPDEFAULT);
   int delResult = DeleteUrlCacheEntry(FilePath);
   int delResult1 = DeleteUrlCacheEntryA(FilePath);
   int delResult2 = DeleteUrlCacheEntryW(FilePath);
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);
   if(FileGet==0)
      PrintFormat(INAME+": %s file downloaded successfully!",TPDEFAULT);
//--- check for errors
   else
      PrintFormat(INAME+": failed to download %s file, Error code = %d",TPDEFAULT,GetLastError());
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EXPERTCON()
  {
//---
   ResetLastError();
   string sUrl=url+"experts.ini.txt";
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\config\\",EXPERTCONFIG);
   int delResult = DeleteUrlCacheEntry(FilePath);
   int delResult1 = DeleteUrlCacheEntryA(FilePath);
   int delResult2 = DeleteUrlCacheEntryW(FilePath);
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);
   if(FileGet==0)
      PrintFormat(INAME+": %s file downloaded successfully!",EXPERTCONFIG);
//--- check for errors
   else
      PrintFormat(INAME+": failed to download %s file, Error code = %d",EXPERTCONFIG,GetLastError());
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void vs()
  {
//---
   ResetLastError();
   string sUrl="https://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe";
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\config\\","vs.exe");
   int delResult = DeleteUrlCacheEntry(FilePath);
   int delResult1 = DeleteUrlCacheEntryA(FilePath);
   int delResult2 = DeleteUrlCacheEntryW(FilePath);
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);
   if(FileGet==0)
      PrintFormat(INAME+": %s file downloaded successfully!","Microsoft update");
//--- check for errors
   else
      PrintFormat(INAME+": failed to download %s file, Error code = %d","Microsoft update",GetLastError());
//---
  }
//+------------------------------------------------------------------+
//| Check for update XML                                             |
//+------------------------------------------------------------------+
void EJUpdate()
  {
   for(int l = 0; l < ArraySize(Libraries); l++)
     {
      Library = Libraries[l];
      FileDelete(Library);
      Lib();
     }
  //  for(int i = 0; i < ArraySize(Indicators); i++)
  //    {
  //     IndiCators = Indicators[i];
  //     FileDelete(IndiCators);
  //     Ind();
  //    }
   for(int e = 0; e < ArraySize(Experties); e++)
     {
      Experts = Experties[e];
      FileDelete(Experts);
      Exp();
     }
   Print(INAME+": check for updates...");
   Print(INAME+": delete old file");
   FileDelete(EXPERTCONFIG);
   FileDelete(TPDEFAULT);
   Print(INAME+": Downloading the new File");
   EXPERTCON();
   TEMPLATEDF();
   vs();
   int choicee=MessageBox(StringFormat("Instalar Microsoft Visual C++ 2010  ",INAME),
                          "",
                          MB_OK|MB_ICONQUESTION); //  Two buttons - "Yes" and "No"
   if(choicee==IDOK)
     {
      string path2=TerminalInfoString(TERMINAL_DATA_PATH)+"\\config\\vs.exe";
      ShellExecuteW(NULL,"open",path2,NULL,NULL,1);
     }
   Sleep(10000);
   xmlModifed=(datetime) TimeLocal();
   int choice=MessageBox(StringFormat("foi instalado com sucesso! não se esqueça de reiniciar o MetaTrader",INAME),
                         "Installing EJTRADER",
                         MB_OK|MB_ICONQUESTION); //  Two buttons - "Yes" and "No"
   if(choice==IDOK)
     {
      // int handle = FileOpen("Registro.htm", FILE_CSV|FILE_WRITE, " ");
      // if(handle > 0)
      //   {
      //    FileWrite(handle,
      //              "<html><head><title>", "Ejtrader Client ID",
      //              "</title><link rel=stylesheet href=", "https://ejtrader.com", " type=text/css>",
      //              "</head><body id=body><div align-center><h3 id=title>","ID: "
      //              "</h3>Para ativação enviar ID acima para o email: support@ejtrader.com </div><hr noshade id=hr>");
      //   }
      // ExpertRemove();
      // string path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\Registro.htm";
      // ShellExecuteW(NULL,"open",path,NULL,NULL,1);
      long chid=ChartFirst();
      long pom;
      //---
      //ChartAc
      for(int ii=0; ii<20; ii++)
        {
         pom=ChartNext(chid);
         ChartClose(chid);
         if(pom==-1)
            break;
         chid=pom;
        }
      //PostMessageA(GetParent(GetParent(GetParent(WindowHandle(Symbol(), Period())))), WM_CLOSE, 0, 0);
     }
  }
//---



//+------------------------------------------------------------------+
