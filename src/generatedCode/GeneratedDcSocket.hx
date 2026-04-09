package generatedCode
;
   import facade.DBFacade;
   import networkCode.DcNetworkPacket;
   import networkCode.DcSocket;
   import networkCode.DcSocketGenerate;
   
    class GeneratedDcSocket extends DcSocket implements DcSocketGenerate
   {
      
      public static inline final CLID_Trash= (0 : UInt);
      
      public static inline final CLID_DistributedDistrict= (19 : UInt);
      
      public static inline final CLID_ObjectServer= (23 : UInt);
      
      public static inline final CLID_StatAccumulator= (25 : UInt);
      
      public static inline final CLID_AreaManager= (26 : UInt);
      
      public static inline final CLID_DistributedNPCGameObject= (27 : UInt);
      
      public static inline final CLID_HeroGameObject= (28 : UInt);
      
      public static inline final CLID_PlayerGameObject= (29 : UInt);
      
      public static inline final CLID_PresenceManager= (30 : UInt);
      
      public static inline final CLID_DistributedDungeonFloor= (32 : UInt);
      
      public static inline final CLID_DistributedTownFloor= (33 : UInt);
      
      public static inline final CLID_DistributedDungionArea= (36 : UInt);
      
      public static inline final CLID_DistributedDungeonSummary= (38 : UInt);
      
      public static inline final CLID_DistributedTownArea= (39 : UInt);
      
      public static inline final CLID_DistributedDooberGameObject= (40 : UInt);
      
      public static inline final CLID_DistributedBuffGameObject= (41 : UInt);
      
      public static inline final CLID_MatchMaker= (42 : UInt);
      
      public static inline final DcHash= (1346577049 : UInt);
      
      public function new(param1:DBFacade, param2:String, param3:Int, param4:String, param5:String, param6:UInt)
      {
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override public function getDcHash() : UInt
      {
         return (1346577049 : UInt);
      }
      
      public function ObjectFactoryOwner(param1:UInt, param2:UInt, param3:DcNetworkPacket) 
      {
         switch(param1 - 28)
         {
            case 0:
               Doid_NetInterfaces[Std.string(param2)] = HeroGameObjectOwnerNetworkComponent.ownerFactory(param3,this,param2);
               
            case 1:
               Doid_NetInterfaces[Std.string(param2)] = PlayerGameObjectOwnerNetworkComponent.ownerFactory(param3,this,param2);
               
            default:
               trace("Received generate for object of unknown Class ID " + param1);
         }
      }
      
      public function ObjectFactoryVisible(param1:UInt, param2:UInt, param3:DcNetworkPacket) 
      {
         switch(param1 - 27)
         {
            case 0:
               Doid_NetInterfaces[Std.string(param2)] = DistributedNPCGameObjectNetworkComponent.netFactory(param3,this,param2);
               
            case 1:
               Doid_NetInterfaces[Std.string(param2)] = HeroGameObjectNetworkComponent.netFactory(param3,this,param2);
               
            case 2:
               Doid_NetInterfaces[Std.string(param2)] = PlayerGameObjectNetworkComponent.netFactory(param3,this,param2);
               
            case 3:
               Doid_NetInterfaces[Std.string(param2)] = PresenceManagerNetworkComponent.netFactory(param3,this,param2);
               
            case 5:
               Doid_NetInterfaces[Std.string(param2)] = DistributedDungeonFloorNetworkComponent.netFactory(param3,this,param2);
               
            case 6:
               Doid_NetInterfaces[Std.string(param2)] = DistributedTownFloorNetworkComponent.netFactory(param3,this,param2);
               
            case 9:
               Doid_NetInterfaces[Std.string(param2)] = DistributedDungionAreaNetworkComponent.netFactory(param3,this,param2);
               
            case 11:
               Doid_NetInterfaces[Std.string(param2)] = DistributedDungeonSummaryNetworkComponent.netFactory(param3,this,param2);
               
            case 12:
               Doid_NetInterfaces[Std.string(param2)] = DistributedTownAreaNetworkComponent.netFactory(param3,this,param2);
               
            case 13:
               Doid_NetInterfaces[Std.string(param2)] = DistributedDooberGameObjectNetworkComponent.netFactory(param3,this,param2);
               
            case 14:
               Doid_NetInterfaces[Std.string(param2)] = DistributedBuffGameObjectNetworkComponent.netFactory(param3,this,param2);
               
            case 15:
               Doid_NetInterfaces[Std.string(param2)] = MatchMakerNetworkComponent.netFactory(param3,this,param2);
               
            default:
               trace("Received generate for object of unknown Class ID " + param1);
         }
      }
   }


