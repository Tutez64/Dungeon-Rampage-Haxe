package generatedCode
;
   import distributedObjects.PlayerGameObject;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class PlayerGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance__GeneratedCode_PlayerGameObjectNetworkComponent/*redefined private*/:PlayerGameObject;
      
      public static inline final FLID_screenName= (180 : UInt);
      
      public static inline final FLID_basicCurrency= (181 : UInt);
      
      public static inline final FLID_Chat= (182 : UInt);
      
      public static inline final FLID_ShowPlayerIsTyping= (183 : UInt);
      
      public static inline final FLID_requesthero= (184 : UInt);
      
      public static inline final FLID_requestentry= (185 : UInt);
      
      public static inline final FLID_requestpartymemberinvite= (186 : UInt);
      
      public static inline final FLID_requestexit= (187 : UInt);
      
      public function new(param1:PlayerGameObject, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance__GeneratedCode_PlayerGameObjectNetworkComponent = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : PlayerGameObjectNetworkComponent
      {
         var _loc5_= new PlayerGameObject(param2.facade,param3);
         var _loc4_= new PlayerGameObjectNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentPlayerGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 180)
         {
            case 0:
               recv_screenName(param1);
               
            case 2:
               recv_Chat(param1);
               
            case 3:
               recv_ShowPlayerIsTyping(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_screenName(param1);
         recvByIdLoop(param1);
      }
      
      override public function destroy() 
      {
         the_instance__GeneratedCode_PlayerGameObjectNetworkComponent.destroy();
      }
      
      public function recv_screenName(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance__GeneratedCode_PlayerGameObjectNetworkComponent.screenName = _loc2_;
      }
      
      public function recv_Chat(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance__GeneratedCode_PlayerGameObjectNetworkComponent.Chat(_loc2_);
      }
      
      public function recv_ShowPlayerIsTyping(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance__GeneratedCode_PlayerGameObjectNetworkComponent.ShowPlayerIsTyping(_loc2_);
      }
   }


