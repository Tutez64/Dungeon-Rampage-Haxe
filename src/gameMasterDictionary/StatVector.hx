package gameMasterDictionary
;
   import brain.logger.Logger;
   import dBGlobals.DBGlobal;
   
    class StatVector
   {
      
      public static var slotCount:UInt = (15 : UInt);
      
      public var values:Vector<Float>;
      
      public function new()
      {
         
         values = new Vector<Float>((15 : UInt),true);
      }
      
      public static function clone(param1:StatVector) : StatVector
      {
         var _loc3_= 0;
         var _loc2_= new StatVector();
         _loc3_ = 0;
         while((_loc3_ : UInt) < slotCount)
         {
            _loc2_.values[_loc3_] = param1.values[_loc3_];
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
         return _loc2_;
      }
      
      public static function multiply(param1:StatVector, param2:StatVector) : StatVector
      {
         var _loc4_= 0;
         var _loc3_= StatVector.clone(param1);
         _loc4_ = 0;
         while((_loc4_ : UInt) < slotCount)
         {
            _loc3_.values[_loc4_] *= param2.values[_loc4_];
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         return _loc3_;
      }
      
      public static function multiplyScalar(param1:StatVector, param2:Float) : StatVector
      {
         var _loc4_= 0;
         var _loc3_= StatVector.clone(param1);
         _loc4_ = 0;
         while((_loc4_ : UInt) < slotCount)
         {
            _loc3_.values[_loc4_] *= param2;
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         return _loc3_;
      }
      
      public static function add(param1:StatVector, param2:StatVector) : StatVector
      {
         var _loc4_= 0;
         var _loc3_= StatVector.clone(param1);
         _loc4_ = 0;
         while((_loc4_ : UInt) < slotCount)
         {
            _loc3_.values[_loc4_] += param2.values[_loc4_];
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         return _loc3_;
      }
      
      public function setConstant(param1:Int) 
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while((_loc2_ : UInt) < slotCount)
         {
            values[_loc2_] = param1;
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      public function SetFromJSON(param1:ASObject, param2:String = "") 
      {
         var _loc3_= 0;
         _loc3_ = 0;
         while(_loc3_ < DBGlobal.StatNames.length)
         {
            if(param1[param2 + DBGlobal.StatNames[_loc3_]] == null)
            {
               Logger.error("StatVector Reading JSON Value " + param2 + DBGlobal.StatNames[_loc3_] + "Not Found Continuing ?");
            }
            values[_loc3_] = ASCompat.toNumber(param1[param2 + DBGlobal.StatNames[_loc3_]]);
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
      
      public function destroy() 
      {
         values = null;
      }
      
      @:isVar public var data(never,set):Vector<Float>;
public function  set_data(param1:Vector<Float>) :Vector<Float>      {
         return values = param1;
      }
      
      @:isVar public var maxHitPoints(get,never):Float;
public function  get_maxHitPoints() : Float
      {
         return values[0];
      }
      
      @:isVar public var maxManaPoints(get,never):Float;
public function  get_maxManaPoints() : Float
      {
         return values[1];
      }
      
      @:isVar public var movementSpeed(get,never):Float;
public function  get_movementSpeed() : Float
      {
         return values[13];
      }
      
      public function getSpeed(param1:String) : Float
      {
         if(param1 == "MELEE")
         {
            return values[8];
         }
         if(param1 == "SHOOT" || param1 == "SHOOTING")
         {
            return values[9];
         }
         if(param1 == "MAGIC")
         {
            return values[10];
         }
         return 1;
      }
      
      public function DebugPrint() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while((_loc1_ : UInt) < slotCount)
         {
            trace(DBGlobal.StatNames[_loc1_],this.values[_loc1_]);
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
   }


