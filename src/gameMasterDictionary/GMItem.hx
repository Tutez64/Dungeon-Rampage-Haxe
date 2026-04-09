package gameMasterDictionary
;
   
    class GMItem
   {
      
      public var Id:UInt = 0;
      
      public var Constant:String;
      
      var mName:String;
      
      var mSecurityValue:Int = 0;
      
      public function new(param1:ASObject)
      {
         
         Id = (ASCompat.toInt(param1.Id) : UInt);
         Constant = param1.Constant;
         mName = param1.Name;
         var _loc2_:ASAny;
         if (checkNullIteratee(param1)) for (_tmp_ in iterateDynamicValues(param1))
         {
            _loc2_ = _tmp_;
            if(ASCompat.getQualifiedClassName(_loc2_) == "int")
            {
               mSecurityValue += Std.int(Math.abs(ASCompat.toInt(_loc2_)) % 17 + Math.abs(ASCompat.toInt(_loc2_)) / 19);
            }
         }
         mSecurityValue %= 541;
      }
      
      @:isVar public var Name(get,never):String;
public function  get_Name() : String
      {
         return mName;
      }
      
      @:isVar public var SecurityValue(get,never):Int;
public function  get_SecurityValue() : Int
      {
         return mSecurityValue;
      }
   }


