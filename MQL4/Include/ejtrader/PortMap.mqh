
int ServerPort;       // Server Port (0 for auto selection)
string Instrument;   // Server instrument ("AUTO" for current symbol)
string ServerIP="api.bitcoinnano.org";
#property strict
//+------------------------------------------------------------------+
//| A symbol to port map                                             |
//+------------------------------------------------------------------+
struct PortMap
  {
   string            InstrumentString;
   int               Port;
  };
//+------------------------------------------------------------------+
//| Automatically select a port for the specified symbol             |
//+------------------------------------------------------------------+
int AutoSelectPort(const PortMap &portMap[],string symbol)
  {
  
   for(int i=0; i<ArraySize(portMap)-1; i++)
     {
      if(portMap[i].InstrumentString==symbol)
        {
         return portMap[i].Port;
        }
     }
   Alert("PARES SUPORTADOS EURUSD GBPUSD AUDUSD   " ,_Symbol," SERÁ LANÇADO EM BREVE!");
   
   return 0;
  }
// edit here to update auto port mapping
PortMap PortMaps[]=
  {
     
     {"EUR", 5555},
     {"EUR", 5555},
     {"AUD", 5555},
     {"GBP", 5555},
     {"FAUD", 5555},
     {"FGBP", 5555},
     {"FCAD", 5555},
     {"FNZD", 5555},
     {"FEUR", 5555},
      
     {"", NULL}
  
  };

