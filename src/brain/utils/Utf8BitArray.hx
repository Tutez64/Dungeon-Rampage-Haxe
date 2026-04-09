package brain.utils
;
   import flash.utils.ByteArray;
   
    class Utf8BitArray
   {
      
      public var decodedByteArray:ByteArray;
      
      public function new()
      {
         
         decodedByteArray = new ByteArray();
      }
      
      public function init(param1:String) 
      {
         var _loc2_= 0;
         var _loc3_= Math.NaN;
         if(param1 == null)
         {
            decodedByteArray = new ByteArray();
         }
         else
         {
            decodedByteArray = new ByteArray();
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               _loc3_ = param1.charCodeAt(_loc2_);
               decodedByteArray.writeByte(Std.int(_loc3_));
               if(Std.int(_loc3_) >> 8 != 0)
               {
                  decodedByteArray.writeByte(Std.int(_loc3_) >> 8);
               }
               _loc2_++;
            }
         }
      }
      
      public function destroy() 
      {
         decodedByteArray = null;
      }
      
      public function setBit(param1:UInt) 
      {
      }
      
      public function getBit(param1:UInt) : Bool
      {
         var _loc2_= (Std.int(param1 / 8) : UInt);
         var _loc3_= 7 - param1 % 8;
         if(_loc2_ < decodedByteArray.length)
         {
            return ((decodedByteArray[_loc2_] : Int) & 1 << (_loc3_ : Int)) != 0;
         }
         return false;
      }
      
      public function getLength() : UInt
      {
         return decodedByteArray.length * 8;
      }
   }


