package networkCode
;
    interface DcNetworkInterface
   {
      
      function recvById(param1:DcNetworkPacket, param2:UInt) : Void;
      
      function generate(param1:DcNetworkPacket) : Void;
      
      function destroy() : Void;
   }


