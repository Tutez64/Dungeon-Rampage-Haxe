package distributedObjects
;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import events.ChatEvent;
   import events.GameObjectEvent;
   import facade.DBFacade;
   import generatedCode.IPlayerGameObjectOwner;
   import generatedCode.PlayerGameObjectOwnerNetworkComponent;
   import flash.events.Event;
   
    class PlayerGameObjectOwner extends PlayerGameObject implements IPlayerGameObjectOwner
   {
      
      public static inline final REQUEST_ENTRY_PLAYER_FLOOR= "REQUEST_ENTRY_PLAYER_FLOOR";
      
      public static inline final REQUEST_ENTRY_PLAYER_HERO= "REQUEST_ENTRY_PLAYER_HERO";
      
      var mEventComponent:EventComponent;
      
      var mBasicCurrency:UInt = 0;
      
      var mPlayerGameObjectOwnerNetworkComponent:PlayerGameObjectOwnerNetworkComponent;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         Logger.debug("New  PlayerGameObjectOwner******************************");
         super(param1,param2);
         mBasicCurrency = (0 : UInt);
         mEventComponent = new EventComponent(param1);
         mEventComponent.addListener("REQUEST_ENTRY_PLAYER_FLOOR",event_request_entry);
         mEventComponent.addListener("REQUEST_ENTRY_PLAYER_HERO",event_request_entry_hero);
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_OUTGOING_CHAT_UPDATE",(0 : UInt)),this.handleOutgoingChat);
      }
      
      function event_request_entry_hero(param1:Event) 
      {
         Logger.debug(" Sending Request Hero");
         mPlayerGameObjectOwnerNetworkComponent.send_requesthero();
      }
      
      function event_request_entry(param1:Event) 
      {
         Logger.debug(" Sending Request Entry Floor");
         mPlayerGameObjectOwnerNetworkComponent.send_requestentry();
      }
      
      public function setOwnerNetworkComponentPlayerGameObject(param1:PlayerGameObjectOwnerNetworkComponent) 
      {
         mPlayerGameObjectOwnerNetworkComponent = param1;
      }
      
      function handleOutgoingChat(param1:ChatEvent) 
      {
         var _loc2_= this.screenName + ": " + param1.message;
         this.sendChat(_loc2_);
      }
      
      public function sendChat(param1:String) 
      {
         this.Chat(param1);
         mPlayerGameObjectOwnerNetworkComponent.send_Chat(param1);
      }
      
      public function sendPlayerIsTyping(param1:Bool) 
      {
         if(param1)
         {
            this.ShowPlayerIsTyping((1 : UInt));
            mPlayerGameObjectOwnerNetworkComponent.send_ShowPlayerIsTyping((1 : UInt));
         }
         else
         {
            this.ShowPlayerIsTyping((0 : UInt));
            mPlayerGameObjectOwnerNetworkComponent.send_ShowPlayerIsTyping((0 : UInt));
         }
      }
      
      override public function  get_basicCurrency() : UInt
      {
         return mBasicCurrency;
      }
      
      public override function  set_basicCurrency(param1:UInt) :UInt      {
         mBasicCurrency = param1;
         if(mDBFacade.hud != null)
         {
            mDBFacade.hud.setBasicCurrency((mBasicCurrency : Int));
         }
return param1;
      }
      
      override public function destroy() 
      {
         super.destroy();
         mEventComponent.destroy();
         mEventComponent = null;
      }
   }


