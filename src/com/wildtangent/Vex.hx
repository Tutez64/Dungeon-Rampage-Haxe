package com.wildtangent
;
    final class Vex extends Core
   {
      
      public function new()
      {
         super();
      }
      
      public function redemptionComplete(param1:ASObject) : Bool
      {
         return ASCompat.toBool(myVex.redemptionComplete(param1));
      }
      
      public function sendExistingParameters() 
      {
         if(_redeemCode != null)
         {
            ASCompat.setProperty(myVex, "redeemCode", _redeemCode);
         }
         if(_error != null)
         {
            ASCompat.setProperty(myVex, "error", _error);
         }
         if(_itemHandler != null)
         {
            ASCompat.setProperty(myVex, "itemHandler", _itemHandler);
         }
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
      
      @:isVar public var redeemCode(never,set):ASFunction;
public function  set_redeemCode(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "redeemCode", param1);
         }
         else
         {
            _redeemCode = param1;
         }
return param1;
      }
      
      @:isVar public var itemHandler(never,set):ASFunction;
public function  set_itemHandler(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "itemHandler", param1);
         }
         else
         {
            _itemHandler = param1;
         }
return param1;
      }
   }


