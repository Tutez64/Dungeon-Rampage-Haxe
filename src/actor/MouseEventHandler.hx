package actor
;
   import actor.player.HeroOwnerView;
   import actor.player.input.dBMouseEvents.MouseDownOnActorEvent;
   import actor.player.input.dBMouseEvents.MouseOutOnActorEvent;
   import actor.player.input.dBMouseEvents.MouseOverOnActorEvent;
   import actor.player.input.dBMouseEvents.MouseUpOnActorEvent;
   import brain.event.EventComponent;
   import facade.DBFacade;
   import dr_floor.FloorView;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
    class MouseEventHandler
   {
      
      var mDBFacade:DBFacade;
      
      var mActorGameObject:ActorGameObject;
      
      var mEventComponent:EventComponent;
      
      public function new(param1:ActorGameObject, param2:DBFacade)
      {
         
         mDBFacade = param2;
         mActorGameObject = param1;
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      public function destroy() 
      {
         removeListeners();
         mEventComponent.destroy();
         mEventComponent = null;
         mDBFacade = null;
         mActorGameObject = null;
      }
      
      public function Init() 
      {
         addListeners();
      }
      
      @:isVar public var actorView(get,never):ActorView;
public function  get_actorView() : ActorView
      {
         return mActorGameObject.actorView;
      }
      
      @:isVar public var floorView(get,never):FloorView;
public function  get_floorView() : FloorView
      {
         return mActorGameObject.view;
      }
      
      @:isVar public var heroOwnerView(get,never):HeroOwnerView;
public function  get_heroOwnerView() : HeroOwnerView
      {
         return ASCompat.reinterpretAs(mActorGameObject.actorView , HeroOwnerView);
      }
      
      function addListeners() 
      {
         mEventComponent.removeAllListeners();
         mActorGameObject.view.root.mouseEnabled = false;
         if(!mActorGameObject.isAttackable || mActorGameObject.isPet)
         {
            return;
         }
         if(mActorGameObject.navCollisions.length == 0)
         {
            return;
         }
         if(mActorGameObject.isHeroType && !mActorGameObject.isOwner)
         {
            return;
         }
         if(heroOwnerView != null && !heroOwnerView.wantMouseEnabled)
         {
            return;
         }
         mActorGameObject.view.root.mouseEnabled = true;
         actorView.root.addEventListener("rollOver",onMouseOver);
         actorView.root.addEventListener("rollOut",onMouseOut);
         if(!mActorGameObject.isHeroType)
         {
            actorView.root.addEventListener("mouseDown",onMouseDown);
            actorView.root.addEventListener("mouseUp",onMouseUp);
         }
      }
      
      function removeListeners() 
      {
         mEventComponent.removeAllListeners();
         actorView.root.removeEventListener("rollOver",onMouseOver);
         actorView.root.removeEventListener("rollOut",onMouseOut);
         actorView.root.removeEventListener("mouseDown",onMouseDown);
         actorView.root.removeEventListener("mouseUp",onMouseUp);
      }
      
      public function onMouseOver(param1:MouseEvent) 
      {
         mEventComponent.dispatchEvent(new MouseOverOnActorEvent(mActorGameObject));
      }
      
      public function onMouseOut(param1:MouseEvent) 
      {
         mEventComponent.dispatchEvent(new MouseOutOnActorEvent(mActorGameObject));
      }
      
      public function onMouseDown(param1:MouseEvent) 
      {
         mEventComponent.dispatchEvent(new MouseDownOnActorEvent(mActorGameObject));
      }
      
      public function onMouseUp(param1:MouseEvent) 
      {
         mEventComponent.dispatchEvent(new MouseUpOnActorEvent(mActorGameObject));
      }
      
      public function sendGotHitEvent() 
      {
         mEventComponent.dispatchEvent(new Event("GotHit_" + mActorGameObject.id));
      }
   }


