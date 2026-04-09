package generatedCode
;
   import distributedObjects.PlayerGameObjectOwner;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class PlayerGameObjectOwnerNetworkComponent extends PlayerGameObjectNetworkComponent implements DcNetworkInterface
   {
      
      var the_instance:IPlayerGameObjectOwner;
      
      public function new(param1:PlayerGameObjectOwner, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function ownerFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : PlayerGameObjectOwnerNetworkComponent
      {
         var _loc5_= new PlayerGameObjectOwner(param2.facade,param3);
         var _loc4_= new PlayerGameObjectOwnerNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentPlayerGameObject(_loc4_);
         _loc5_.setOwnerNetworkComponentPlayerGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 181)
         {
            case 0:
               recv_basicCurrency(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_screenName(param1);
         recv_basicCurrency(param1);
         recvByIdLoop(param1);
      }
      
      public function recv_basicCurrency(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.basicCurrency = _loc2_;
      }
      
      public function send_Chat(param1:String) 
      {
         var _loc2_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,(182 : UInt));
         _loc2_.writeUTF(param1);
         Send_packet(_loc2_);
      }
      
      public function send_ShowPlayerIsTyping(param1:UInt) 
      {
         var _loc2_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,(183 : UInt));
         _loc2_.writeByte((param1 : Int));
         Send_packet(_loc2_);
      }
      
      public function send_requesthero() 
      {
         var _loc1_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc1_,(184 : UInt));
         Send_packet(_loc1_);
      }
      
      public function send_requestentry() 
      {
         var _loc1_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc1_,(185 : UInt));
         Send_packet(_loc1_);
      }
      
      public function send_requestpartymemberinvite() 
      {
         var _loc1_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc1_,(186 : UInt));
         Send_packet(_loc1_);
      }
   }


