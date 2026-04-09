package com.junkbyte.console.vos
;
   
    class WeakRef
   {
      
      var _val:ASAny;
      
      var _strong:Bool = false;
      
      public function new(param1:ASAny, param2:Bool = false)
      {
         
         this._strong = param2;
         this.reference = param1;
      }
      
            
      @:isVar public var reference(get,set):ASAny;
public function  get_reference() : ASAny
      {
         var _loc1_:ASAny = /*undefined*/null;
         if(this._strong)
         {
            return this._val;
         }
         var _loc2_= 0;
         var _loc3_:ASAny = this._val;
         if (checkNullIteratee(_loc3_)) for(_tmp_ in _loc3_.___keys())
         {
            _loc1_  = _tmp_;
            return _loc1_;
         }
         return null;
      }
function  set_reference(param1:ASAny) :ASAny      {
         if(this._strong)
         {
            this._val = param1;
         }
         else
         {
            this._val = new ASDictionary<ASAny,ASAny>(true);
            this._val[param1] = null;
         }
return param1;
      }
      
      @:isVar public var strong(get,never):Bool;
public function  get_strong() : Bool
      {
         return this._strong;
      }
   }


