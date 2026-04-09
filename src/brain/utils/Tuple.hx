package brain.utils
;
    class Tuple
   {
      
      var mFirst:ASAny;
      
      var mSecond:ASAny;
      
      public function new(param1:ASAny, param2:ASAny)
      {
         
         mFirst = param1;
         mSecond = param2;
      }
      
      @:isVar public var first(get,never):ASAny;
public function  get_first() : ASAny
      {
         return mFirst;
      }
      
      @:isVar public var second(get,never):ASAny;
public function  get_second() : ASAny
      {
         return mSecond;
      }
   }


