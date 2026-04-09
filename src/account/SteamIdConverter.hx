package account
;
   import brain.logger.Logger;
   
    class SteamIdConverter
   {
      
      static inline final STEAM_ID64_BASE_U1= "76561197960265728";
      
      public function new()
      {
         
      }
      
      public static function isValidSteamId(param1:String) : Bool
      {
         if(!ASCompat.stringAsBool(param1))
         {
            return false;
         }
         return isValidSteamID64(param1) || isValidSteamHex(param1);
      }
      
      public static function normalizeSteamIdToSteamID64(param1:String) : String
      {
         var _loc6_:String;
         var _loc2_:String = null;
         if(!ASCompat.stringAsBool(param1))
         {
            return "";
         }
         if(!isValidSteamId(param1))
         {
            return "";
         }
         if(isValidSteamID64(param1))
         {
            return param1;
         }
         try
         {
            _loc2_ = convertSteamHexToSteamID64(param1);
            if(!isValidSteamID64(_loc2_))
            {
               return "";
            }
            return _loc2_;
         }
         catch(e:Dynamic)
         {
            _loc6_ = "";
         }
         return _loc6_;
      }
      
      public static function convertSteamID64ToSteamHex(param1:String) : String
      {
         var _loc2_= convertSteamID64ToAccountId(param1);
         return convertUintToSteamHexFormat(_loc2_);
      }
      
      public static function convertSteamID64ToSteam3ID(param1:String) : String
      {
         var _loc2_= convertSteamID64ToAccountId(param1);
         return "[U:1:" + Std.string(_loc2_) + "]";
      }
      
      public static function convertSteamID64ToAccountId(param1:String) : UInt
      {
         var _loc6_:Int;
         var _loc2_:String = null;
         var _loc3_= 0;
         if(param1 == null || param1.length == 0 || !new compat.RegExp("^\\d+$").test(param1))
         {
            Logger.error("Invalid SteamID64 input (not a number string): " + param1);
            return (0 : UInt);
         }
         if(param1.length < "76561197960265728".length || param1.length == "76561197960265728".length && param1 < "76561197960265728")
         {
            Logger.error("Invalid or non-U:1 SteamID64 input for string subtraction: " + param1);
            return (0 : UInt);
         }
         try
         {
            _loc2_ = subtractDecimalStrings(param1,"76561197960265728");
            return (ASCompat.toInt(_loc2_) : UInt);
         }
         catch(e:Dynamic)
         {
            Logger.error("Error during string subtraction for SteamID64 " + param1 + ": " + Std.string(e.message));
            _loc6_ = 0;
         }
         return (_loc6_ : UInt);
      }
      
      public static function convertSteamHexToSteamID64(param1:String) : String
      {
         var _loc2_= convertSteamHexFormatToUint(param1);
         return convertAccountIdToSteamID64(_loc2_);
      }
      
      public static function convertAccountIdToSteamID64(param1:UInt) : String
      {
         return addDecimalStrings("76561197960265728",Std.string(param1));
      }
      
      static function isValidSteamID64(param1:String) : Bool
      {
         if(!ASCompat.stringAsBool(param1))
         {
            return false;
         }
         if(!new compat.RegExp("^\\d+$").test(param1))
         {
            return false;
         }
         if(param1.length < 2 || param1.substr(0,2) != "76")
         {
            return false;
         }
         return true;
      }
      
      static function isValidSteamHex(param1:String) : Bool
      {
         if(!ASCompat.stringAsBool(param1))
         {
            return false;
         }
         var _loc2_= new compat.RegExp("^[bcdfghjkmnpqrtvw]+$", "i");
         if(!_loc2_.test(param1))
         {
            return false;
         }
         if(param1.length < 1 || param1.length > 12)
         {
            return false;
         }
         return true;
      }
      
      public static function convertUintToSteamHexFormat(param1:UInt) : String
      {
         var _loc6_= 0;
         var _loc7_:String = null;
         var _loc5_:String = null;
         var _loc3_= ASCompat.toRadix(param1, (16 : UInt));
         var _loc2_:ASObject = {
            "0":"b",
            "1":"c",
            "2":"d",
            "3":"f",
            "4":"g",
            "5":"h",
            "6":"j",
            "7":"k",
            "8":"m",
            "9":"n",
            "a":"p",
            "b":"q",
            "c":"r",
            "d":"t",
            "e":"v",
            "f":"w"
         };
         var _loc4_= "";
         _loc3_ = _loc3_.toLowerCase();
         _loc6_ = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc7_ = _loc3_.charAt(_loc6_);
            _loc5_ = _loc2_[_loc7_];
            _loc4_ += _loc5_;
            _loc6_++;
         }
         return _loc4_;
      }
      
      public static function convertSteamHexFormatToUint(param1:String) : UInt
      {
         var _loc4_= 0;
         var _loc3_:String = null;
         var _loc6_:String = null;
         if(!ASCompat.stringAsBool(param1))
         {
            return (0 : UInt);
         }
         var _loc5_:ASObject = {
            "b":"0",
            "c":"1",
            "d":"2",
            "f":"3",
            "g":"4",
            "h":"5",
            "j":"6",
            "k":"7",
            "m":"8",
            "n":"9",
            "p":"a",
            "q":"b",
            "r":"c",
            "t":"d",
            "v":"e",
            "w":"f"
         };
         var _loc2_= "";
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = param1.charAt(_loc4_).toLowerCase();
            _loc6_ = _loc5_[_loc3_];
            if(_loc6_ == null)
            {
               Logger.error("Invalid Steam hex character encountered: " + _loc3_);
               return (0 : UInt);
            }
            _loc2_ += _loc6_;
            _loc4_++;
         }
         return (ASCompat.parseInt(_loc2_,16) : UInt);
      }
      
      public static function subtractDecimalStrings(param1:String, param2:String) : String
      {
         var _loc9_= 0;
         var _loc4_= 0;
         _loc9_ = 0;
         _loc4_ = 0;
         var _loc3_= "";
         var _loc5_= param1.length;
         var _loc6_= param2.length;
         var _loc10_= _loc5_ - _loc6_;
         var _loc8_= 0;
         _loc9_ = _loc6_ - 1;
         while(_loc9_ >= 0)
         {
            _loc4_ = Std.int(ASCompat.toNumber(param1.charAt(_loc9_ + _loc10_)) - ASCompat.toNumber(param2.charAt(_loc9_)) - _loc8_);
            if(_loc4_ < 0)
            {
               _loc4_ += 10;
               _loc8_ = 1;
            }
            else
            {
               _loc8_ = 0;
            }
            _loc3_ = Std.string(_loc4_) + _loc3_;
            _loc9_--;
         }
         _loc9_ = _loc5_ - _loc6_ - 1;
         while(_loc9_ >= 0)
         {
            if(param1.charAt(_loc9_) == "0" && _loc8_ > 0)
            {
               _loc3_ = "9" + _loc3_;
            }
            else
            {
               _loc4_ = Std.int(ASCompat.toNumber(param1.charAt(_loc9_)) - _loc8_);
               if(_loc9_ > 0 || _loc4_ > 0)
               {
                  _loc3_ = Std.string(_loc4_) + _loc3_;
               }
               _loc8_ = 0;
            }
            _loc9_--;
         }
         var _loc7_= 0;
         while(_loc7_ < _loc3_.length - 1 && _loc3_.charAt(_loc7_) == "0")
         {
            _loc7_++;
         }
         return _loc3_.substring(_loc7_);
      }
      
      public static function addDecimalStrings(param1:String, param2:String) : String
      {
         var _loc4_:String = null;
         var _loc8_= 0;
         var _loc7_= 0;
         var _loc9_= 0;
         var _loc10_= 0;
         var _loc11_= 0;
         if(param1.length < param2.length)
         {
            _loc4_ = param1;
            param1 = param2;
            param2 = _loc4_;
         }
         var _loc3_= "";
         var _loc5_= param1.length;
         var _loc6_= param2.length;
         var _loc12_= 0;
         _loc8_ = 0;
         while(_loc8_ < _loc5_)
         {
            _loc7_ = _loc8_ < _loc5_ ? ASCompat.parseInt(param1.charAt(_loc5_ - 1 - _loc8_)) : 0;
            _loc9_ = _loc8_ < _loc6_ ? ASCompat.parseInt(param2.charAt(_loc6_ - 1 - _loc8_)) : 0;
            _loc10_ = _loc7_ + _loc9_ + _loc12_;
            _loc12_ = Math.floor(_loc10_ / 10);
            _loc11_ = _loc10_ % 10;
            _loc3_ = Std.string(_loc11_) + _loc3_;
            _loc8_++;
         }
         if(_loc12_ > 0)
         {
            _loc3_ = Std.string(_loc12_) + _loc3_;
         }
         return _loc3_;
      }
   }


