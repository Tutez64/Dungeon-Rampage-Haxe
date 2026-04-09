package com.wildtangent
;
    final class Store extends Core
   {
      
      var _windowClose:ASFunction = null;
      
      var _windowOpen:ASFunction = null;
      
      public function new()
      {
         super();
      }
      
      public function sendExistingParameters() 
      {
         if(_closed != null)
         {
            ASCompat.setProperty(myVex, "itemStoreClosed", _closed);
         }
         if(_windowClose != null)
         {
            ASCompat.setProperty(myVex, "itemStoreWindowClose", _windowClose);
         }
         if(_windowOpen != null)
         {
            ASCompat.setProperty(myVex, "itemStoreWindowOpen", _windowOpen);
         }
      }
      
      public function showItem(param1:ASObject) 
      {
         if(vexReady)
         {
            myVex.showItem(param1);
         }
         else
         {
            storeMethod(showItem,param1);
         }
      }
      
      @:isVar public var closed(never,set):ASFunction;
public function  set_closed(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "itemStoreClosed", param1);
         }
         else
         {
            _closed = param1;
         }
return param1;
      }
      
      @:isVar public var windowClose(never,set):ASFunction;
public function  set_windowClose(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "itemStoreWindowClose", param1);
         }
         else
         {
            _windowClose = param1;
         }
return param1;
      }
      
      @:isVar public var windowOpen(never,set):ASFunction;
public function  set_windowOpen(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "itemStoreWindowOpen", param1);
         }
         else
         {
            _windowOpen = param1;
         }
return param1;
      }
   }


