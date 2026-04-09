package com.adobe.serialization.json
;
    class JSONParseError extends Error
   {
      
      var _location:Int = 0;
      
      var _text:String;
      
      public function new(param1:String = "", param2:Int = 0, param3:String = "")
      {
         super(param1);
         name = "JSONParseError";
         this._location = param2;
         this._text = param3;
      }
      
      @:isVar public var location(get,never):Int;
public function  get_location() : Int
      {
         return this._location;
      }
      
      @:isVar public var text(get,never):String;
public function  get_text() : String
      {
         return this._text;
      }
   }


