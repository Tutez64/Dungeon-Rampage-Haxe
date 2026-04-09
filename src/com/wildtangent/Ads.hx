package com.wildtangent
;
    final class Ads extends Core
   {
      
      public function new()
      {
         super();
      }
      
      public function show(param1:ASObject = null) : Bool
      {
         if(vexFailed)
         {
            if(_adComplete != null)
            {
               _adComplete(param1);
            }
            return false;
         }
         if(vexReady)
         {
            return ASCompat.toBool(myVex.showAd(param1));
         }
         storeMethod(show,param1);
         return true;
      }
      
      public function sendExistingParameters() 
      {
         if(_adComplete != null)
         {
            ASCompat.setProperty(myVex, "adComplete", _adComplete);
         }
         if(_error != null)
         {
            ASCompat.setProperty(myVex, "error", _error);
         }
      }
      
      @:isVar public var complete(never,set):ASFunction;
public function  set_complete(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "adComplete", param1);
         }
         else
         {
            _adComplete = param1;
         }
return param1;
      }
      
      @:isVar public var error(never,set):ASFunction;
public function  set_error(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "error", param1);
         }
         else
         {
            _error = param1;
         }
return param1;
      }
   }


