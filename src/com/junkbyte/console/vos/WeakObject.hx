package com.junkbyte.console.vos
;
   
   /*use*/ /*namespace*/ /*flash_proxy*/
   
    /*dynamic*/ class WeakObject extends ASProxyBase
   {
      
      var _item:Array<ASAny>;
      
      var _dir:ASObject;
      
      public function new()
      {
         super();
         this._dir = new ASObject();
      }
      
      public function set(param1:String, param2:ASObject, param3:Bool = false) 
      {
         if(param2 == null)
         {
            ASCompat.deleteProperty(this._dir, param1);
         }
         else
         {
            this._dir[param1] = new WeakRef(param2,param3);
         }
      }
      
      public function get(param1:String) : ASAny
      {
         var _loc2_= this.getWeakRef(param1);
         return _loc2_ != null ? _loc2_.reference : /*undefined*/null;
      }
      
      public function getWeakRef(param1:String) : WeakRef
      {
         return ASCompat.dynamicAs(this._dir[param1] , WeakRef);
      }
      
      @:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function getProperty(param1:Dynamic) : Dynamic
      {
         return this.get(param1);
      }
      
      @:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function callProperty(param1:Dynamic, ..._rest: Dynamic) : Dynamic
      {
         var rest = ASCompat.restToArray(_rest);
         var _loc3_:ASObject = this.get(param1);
         return Reflect.callMethod(this,_loc3_, rest);
      }
      
      @:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function setProperty(param1:Dynamic, param2:Dynamic) 
      {
         this.set(param1,param2);
      }
      
      @:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function nextName(param1:Int) : String
      {
         return this._item[param1 - 1];
      }
      
      @:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function nextValue(param1:Int) : Dynamic
      {
         return (this : ASAny)[this/*flash_proxy::*/.nextName(param1)];
      }
      
      @:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function nextNameIndex(param1:Int) : Int
      {
         var __ax4_iter_45:ASObject;
         var _loc2_:String = /*undefined*/null;
         if(param1 == 0)
         {
            this._item = new Array<ASAny>();
            __ax4_iter_45 = this._dir;
            if (checkNullIteratee(__ax4_iter_45)) for(_tmp_ in __ax4_iter_45.___keys())
            {
               _loc2_  = _tmp_;
               this._item.push(_loc2_);
            }
         }
         if(param1 < this._item.length)
         {
            return param1 + 1;
         }
         return 0;
      }
      
      @:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function deleteProperty(param1:Dynamic) : Bool
      {
         return ASCompat.deleteProperty(this._dir, param1);
      }
      
      public function toString() : String
      {
         return "[WeakObject]";
      }
   }


