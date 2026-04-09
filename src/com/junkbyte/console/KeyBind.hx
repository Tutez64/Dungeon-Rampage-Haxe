package com.junkbyte.console
;
    class KeyBind
   {
      
      var _code:Bool = false;
      
      var _key:String;
      
      public function new(param1:ASAny, param2:Bool = false, param3:Bool = false, param4:Bool = false, param5:Bool = false)
      {
         
         this._key = ASCompat.toString(param1).toUpperCase();
         if(Std.isOfType(param1 , Int))
         {
            this._code = true;
         }
         else if(!ASCompat.toBool(param1) || this._key.length != 1)
         {
            throw new Error("KeyBind: character (first char) must be a single character. You gave [" + Std.string(param1) + "]");
         }
         if(this._code)
         {
            this._key = "keycode:" + this._key;
         }
         if(param2)
         {
            this._key += "+shift";
         }
         if(param3)
         {
            this._key += "+ctrl";
         }
         if(param4)
         {
            this._key += "+alt";
         }
         if(param5)
         {
            this._key += "+up";
         }
      }
      
      @:isVar public var useKeyCode(get,never):Bool;
public function  get_useKeyCode() : Bool
      {
         return this._code;
      }
      
      @:isVar public var key(get,never):String;
public function  get_key() : String
      {
         return this._key;
      }
   }


