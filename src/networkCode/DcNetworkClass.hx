package networkCode
;
    class DcNetworkClass
   {
      
      static var CREATION_ORDER_SEED:UInt = (0 : UInt);
      
      var the_gamesocket:DcSocket;
      
      public var do_id:UInt = 0;
      
      var mCreationOrder:UInt = 0;
      
      public function new(param1:ASAny, param2:DcSocket, param3:UInt)
      {
         
         do_id = param3;
         the_gamesocket = param2;
         mCreationOrder = ++CREATION_ORDER_SEED;
      }
      
      @:isVar public var creationOrder(get,never):UInt;
public function  get_creationOrder() : UInt
      {
         return mCreationOrder;
      }
      
      public function recvByIdLoop(param1:DcNetworkPacket) 
      {
         var _loc4_= 0;
         var _loc2_= 0;
         var _loc3_= ASCompat.reinterpretAs(this , DcNetworkInterface);
         if(!param1.eof())
         {
            _loc4_ = (param1.readUnsignedShort() : Int);
            while(!param1.eof())
            {
               _loc2_ = (param1.readUnsignedShort() : Int);
               _loc3_.recvById(param1,(_loc2_ : UInt));
            }
         }
      }
      
      public function Process_SetFieldValue(param1:DcNetworkPacket) 
      {
         var _loc3_= ASCompat.reinterpretAs(this , DcNetworkInterface);
         var _loc2_= param1.readUnsignedShort();
         _loc3_.recvById(param1,_loc2_);
      }
      
      public function Send_packet(param1:DcNetworkPacket) 
      {
         the_gamesocket.sendpacket(param1);
      }
      
      public function Prepare_FieldUpdate(param1:DcNetworkPacket, param2:UInt) 
      {
         param1.writeShort(124);
         param1.writeUnsignedInt(do_id);
         param1.writeShort((param2 : Int));
      }
      
      public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
      }
      
      public function generate(param1:DcNetworkPacket) 
      {
      }
      
      public function destroy() 
      {
      }
   }


