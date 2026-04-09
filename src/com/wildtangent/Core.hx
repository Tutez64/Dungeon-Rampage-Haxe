package com.wildtangent
;
   import flash.display.Sprite;
   
    class Core extends Sprite
   {
      
      public var vexReady:Bool = false;
      
      public var vexFailed:Bool = false;
      
      public var myVex:ASAny = null;
      
      var callbacks:ASObject;
      
      var _dpName:String;
      
      var _gameName:String;
      
      var _partnerName:String;
      
      var _siteName:String;
      
      var _userId:String;
      
      var _cipherKey:String;
      
      var _vexUrl:String = "http://vex.wildtangent.com";
      
      var _sandbox:Bool = false;
      
      var _javascriptReady:Bool = false;
      
      public var _adComplete:ASFunction;
      
      public var _closed:ASFunction;
      
      public var _error:ASFunction;
      
      public var _handlePromo:ASFunction;
      
      public var _redeemCode:ASFunction;
      
      public var _requireLogin:ASFunction;
      
      var _itemHandler:ASFunction;
      
      public var methodStorage:Array<ASAny> = [];
      
      public function new()
      {
         super();
      }
      
      public function storeMethod(param1:ASFunction, param2:ASObject) 
      {
         methodStorage.push({
            "tempMethod":param1,
            "obj":param2
         });
      }
      
      public function launchMethods() 
      {
         var _loc1_:String = null;
         final __ax4_iter_77 = methodStorage;
         if (checkNullIteratee(__ax4_iter_77)) for(_tmp_ in 0...__ax4_iter_77.length)
         {
            _loc1_  = Std.string(_tmp_);
            if((methodStorage : ASAny)[ASCompat.toInt(_loc1_)].obj != null)
            {
               (methodStorage : ASAny)[ASCompat.toInt(_loc1_)].tempMethod((methodStorage : ASAny)[ASCompat.toInt(_loc1_)].obj);
            }
            else
            {
               (methodStorage : ASAny)[ASCompat.toInt(_loc1_)].tempMethod();
            }
         }
         methodStorage = [];
      }
      
      public function checkTop() 
      {
         var _loc1_= root;
         var _loc2_= parent;
         cast(_loc1_, flash.display.DisplayObjectContainer).setChildIndex(cast(_loc1_, flash.display.DisplayObjectContainer).getChildByName(_loc2_.name),ASCompat.toInt(ASCompat.toNumberField(_loc1_, "numChildren") - 1));
      }
   }


