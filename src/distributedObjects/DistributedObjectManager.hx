package distributedObjects
;
   import facade.DBFacade;
   import generatedCode.GeneratedDcSocket;
   
    class DistributedObjectManager
   {
      
      var mDBfacade:DBFacade;
      
      var mGeneratedDcSocket:GeneratedDcSocket;
      
      public var mMatchMaker:MatchMaker;
      
      public var mPresenceManager:PresenceManager;
      
      public function new(param1:DBFacade)
      {
         
         mDBfacade = param1;
      }
      
      public function Initialize(param1:String, param2:Int, param3:String, param4:String, param5:UInt, param6:UInt, param7:UInt) : Bool
      {
         if(mGeneratedDcSocket != null)
         {
            mGeneratedDcSocket.destroy();
         }
         mGeneratedDcSocket = null;
         mGeneratedDcSocket = new GeneratedDcSocket(mDBfacade,param1,param2,param3,param4,param5);
         mGeneratedDcSocket.pass2Init(param6,param7);
         return true;
      }
      
      public function destroy() 
      {
         if(mGeneratedDcSocket != null)
         {
            mGeneratedDcSocket.destroy();
         }
         mGeneratedDcSocket = null;
      }
      
      public function isAllOk() : Bool
      {
         var _loc1_= mGeneratedDcSocket != null && mGeneratedDcSocket.connected && mMatchMaker != null;
         trace("------------>isAllOk ",_loc1_);
         return _loc1_;
      }
      
      function SocketIsLeaving() 
      {
         if(mGeneratedDcSocket != null)
         {
            mGeneratedDcSocket.destroy();
         }
         mGeneratedDcSocket = null;
      }
      
      public function enterSocketErrorState(param1:UInt, param2:String = "") 
      {
         mDBfacade.mainStateMachine.enterSocketErrorState(param1,param2);
         mDBfacade.mDistributedObjectManager.SocketIsLeaving();
      }
   }


