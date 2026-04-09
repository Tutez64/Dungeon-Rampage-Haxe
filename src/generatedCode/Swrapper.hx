package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class Swrapper
   {
      
      public var fileName:String;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : Swrapper
      {
         var _loc2_= new Swrapper();
         _loc2_.fileName = param1.readUTF();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeUTF(fileName);
      }
   }


