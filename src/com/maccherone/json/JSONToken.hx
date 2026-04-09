package com.maccherone.json
;
    class JSONToken
   {
      
      var _value:ASObject;
      
      var _type:Int = 0;
      
      public function new(param1:Int = -1, param2:ASObject = null)
      {
         
         _type = param1;
         _value = param2;
      }
      
            
      @:isVar public var value(get,set):ASObject;
public function  get_value() : ASObject
      {
         return _value;
      }
      
            
      @:isVar public var type(get,set):Int;
public function  get_type() : Int
      {
         return _type;
      }
function  set_type(param1:Int) :Int      {
         return _type = param1;
      }
function  set_value(param1:ASObject) :ASObject      {
         return _value = param1;
      }
   }


