package networkCode
;
   import flash.utils.ByteArray;
   
    class DcNetworkBuffer extends ASByteArrayBase
   {
      
      public function new()
      {
         super();
         endian = "littleEndian";
      }
      
      public function do_slide() 
      {
         var _loc1_= new DcNetworkPacket();
         readBytes(_loc1_);
         length = (0 : UInt);
         position = (0 : UInt);
         writeBytes(_loc1_);
         position = (0 : UInt);
      }
      
      public function eof() : Bool
      {
         return position == length;
      }
   }


