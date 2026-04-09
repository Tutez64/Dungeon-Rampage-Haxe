package com.wildtangent
;
    final class BrandBoost extends Core
   {
      
      public function new()
      {
         super();
      }
      
      public function launch(param1:ASObject) 
      {
         if(vexReady)
         {
            if(param1.promoName == null)
            {
               throw new Error("Please provide a valid promoName when calling BrandBoost.launch");
            }
            myVex.launchBrandBoost(param1);
         }
         else
         {
            storeMethod(launch,param1);
         }
      }
      
      public function getPromo(param1:ASObject) : Bool
      {
         var _loc2_= false;
         if(vexFailed)
         {
            if(_handlePromo != null)
            {
               _handlePromo({"available":false});
            }
            return false;
         }
         if(vexReady)
         {
            _loc2_ = ASCompat.toBool(myVex.addPromo(param1));
            if(_loc2_)
            {
               myVex.initialize();
            }
            return _loc2_;
         }
         storeMethod(getPromo,param1);
         return true;
      }
      
      public function resumeAfterLogin(param1:ASObject) 
      {
         ASCompat.setProperty(myVex, "userId", param1.userId);
      }
      
      public function sendExistingParameters() 
      {
         if(_closed != null)
         {
            ASCompat.setProperty(myVex, "closed", _closed);
         }
         if(_error != null)
         {
            ASCompat.setProperty(myVex, "error", _error);
         }
         if(_handlePromo != null)
         {
            ASCompat.setProperty(myVex, "handlePromo", _handlePromo);
         }
         if(_requireLogin != null)
         {
            ASCompat.setProperty(myVex, "requireLogin", _requireLogin);
         }
      }
      
      @:isVar public var closed(never,set):ASFunction;
public function  set_closed(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "closed", param1);
         }
         else
         {
            _closed = param1;
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
      
      @:isVar public var handlePromo(never,set):ASFunction;
public function  set_handlePromo(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "handlePromo", param1);
         }
         else
         {
            _handlePromo = param1;
         }
return param1;
      }
      
      @:isVar public var requireLogin(never,set):ASFunction;
public function  set_requireLogin(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "requireLogin", param1);
         }
         else
         {
            _requireLogin = param1;
         }
return param1;
      }
   }


