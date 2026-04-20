package stateMachine.mainStateMachine
;
   import brain.stateMachine.State;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import facade.Locale;
   import uI.popup.DBUIOneButtonPopup;
   import flash.desktop.NativeApplication;
   
    class SocketErrorState extends State
   {
      
      public static inline final NAME= "SocketErrorState";
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade, param2:ASFunction = null)
      {
         mDBFacade = param1;
         super("SocketErrorState",param2);
      }
      
      override public function enterState() 
      {
         super.enterState();
      }
      
      override public function exitState() 
      {
         super.exitState();
      }
      
      override public function destroy() 
      {
         super.destroy();
      }
      
      function errorDialogResponce() 
      {
         NativeApplication.nativeApplication.exit();
      }
      
      public function enterReason(param1:UInt, param2:String = "") : DBUIOneButtonPopup
      {
         var _loc3_:DBUIOneButtonPopup = null;
         if(param1 == 60)
         {
            _loc3_ = new DBUIOneButtonPopup(mDBFacade,Locale.getString("SOCKET_CLOSE_60_HEADER"),Locale.getString("SOCKET_CLOSE_60_TEXT"),Locale.getString("EXIT"),errorDialogResponce,false);
         }
         else if(param1 == 61)
         {
            _loc3_ = new DBUIOneButtonPopup(mDBFacade,Locale.getString("SOCKET_CLOSE_61_HEADER"),Locale.getString("SOCKET_CLOSE_61_TEXT"),Locale.getString("EXIT"),errorDialogResponce,false);
         }
         else
         {
            _loc3_ = new DBUIOneButtonPopup(mDBFacade,Locale.getString("SOCKET_UNEXPECT_CLOSE"),Locale.getError((param1 : Int)) + "\n" + param2,Locale.getString("CENTER_BUTTON_POPUP_RELOAD_TEXT"),errorDialogResponce,false);
         }
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in SocketErrorState.enterReason()");
         mDBFacade.enteringSocketError();
         return _loc3_;
      }
   }


