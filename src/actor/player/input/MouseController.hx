package actor.player.input
;
   import actor.ActorGameObject;
   import actor.player.input.dBMouseEvents.MouseDownOnActorEvent;
   import actor.player.input.dBMouseEvents.MouseOutOnActorEvent;
   import actor.player.input.dBMouseEvents.MouseOverOnActorEvent;
   import actor.player.input.dBMouseEvents.MouseUpOnActorEvent;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import flash.events.MouseEvent;
   import flash.geom.Vector3D;
   
    class MouseController implements IMouseController
   {
      
      var mDBFacade:DBFacade;
      
      var mHeroGameObjectOwner:HeroGameObjectOwner;
      
      var mEventComponent:EventComponent;
      
      var mInputVelocity:Vector3D;
      
      var mInputHeading:Vector3D;
      
      var mMouseDownActorThisFrame:ActorGameObject;
      
      var mMouseUpActorThisFrame:ActorGameObject;
      
      var mMouseOverActorThisFrame:ActorGameObject;
      
      var mMouseOutActorThisFrame:ActorGameObject;
      
      var mMouseDownThisFrame:Bool = false;
      
      var mMouseUpThisFrame:Bool = false;
      
      var mMouseDownPosition:Vector3D;
      
      var mMouseUpPosition:Vector3D;
      
      var mRightMouseDown:Bool = false;
      
      var mMiddleMouseDown:Bool = false;
      
      var mDungeonBusterControlActivatedThisFrame:Bool = false;
      
      var mMouseDownActorPrevious:ActorGameObject;
      
      var mMouseUpActorPrevious:ActorGameObject;
      
      var mMouseOverActorPrevious:ActorGameObject;
      
      var mMouseOutActorPrevious:ActorGameObject;
      
      var mActorMousedOver:ActorGameObject;
      
      var mPotentialAttacksThisFrame:Array<ASAny>;
      
      var mCombatDisabled:Bool = false;
      
      public function new(param1:DBFacade, param2:HeroGameObjectOwner)
      {
         
         mDBFacade = param1;
         mHeroGameObjectOwner = param2;
         mEventComponent = new EventComponent(mDBFacade);
         mPotentialAttacksThisFrame = [];
         mInputVelocity = new Vector3D();
         mCombatDisabled = false;
      }
      
      function addListeners() 
      {
         mEventComponent.addListener("MouseDownOnActorEvent",handleMouseDownOnActor);
         mEventComponent.addListener("MouseUpOnActorEvent",handleMouseUpOnActor);
         mEventComponent.addListener("MouseOverOnActorEvent",handleMouseOverOnActor);
         mEventComponent.addListener("MouseOutOnActorEvent",handleMouseOutOnActor);
         mEventComponent.addListener("DungeonBusterControlActivatedEvent",handleDungeonBusterControlActivated);
         mDBFacade.stageRef.addEventListener("mouseDown",handleMouseDown);
         mDBFacade.stageRef.addEventListener("mouseUp",handleMouseUp);
         mDBFacade.stageRef.addEventListener("rightMouseDown",handleRightMouseDown);
         mDBFacade.stageRef.addEventListener("rightMouseUp",handleRightMouseUp);
         mDBFacade.stageRef.addEventListener("middleMouseDown",handleMiddleMouseDown);
         mDBFacade.stageRef.addEventListener("middleMouseUp",handleMiddleMouseUp);
      }
      
      function removeListeners() 
      {
         mEventComponent.removeAllListeners();
         mDBFacade.stageRef.removeEventListener("mouseDown",handleMouseDown);
         mDBFacade.stageRef.removeEventListener("mouseUp",handleMouseUp);
         mDBFacade.stageRef.removeEventListener("rightMouseDown",handleRightMouseDown);
         mDBFacade.stageRef.removeEventListener("rightMouseUp",handleRightMouseUp);
         mDBFacade.stageRef.removeEventListener("middleMouseDown",handleMiddleMouseDown);
         mDBFacade.stageRef.removeEventListener("middleMouseUp",handleMiddleMouseUp);
      }
      
      function handleMouseDownOnActor(param1:MouseDownOnActorEvent) 
      {
         mMouseDownActorThisFrame = param1.actor;
      }
      
      function handleMouseUpOnActor(param1:MouseUpOnActorEvent) 
      {
         mMouseUpActorThisFrame = param1.actor;
      }
      
      function handleMouseOverOnActor(param1:MouseOverOnActorEvent) 
      {
         mMouseOverActorThisFrame = param1.actor;
         mActorMousedOver = mMouseOverActorThisFrame;
         if(mMouseOverActorThisFrame.actorView != null && mActorMousedOver.team != mHeroGameObjectOwner.team)
         {
            mMouseOverActorThisFrame.actorView.mouseOverHighlight();
         }
      }
      
      function handleMouseOutOnActor(param1:MouseOutOnActorEvent) 
      {
         mMouseOutActorThisFrame = param1.actor;
         if(mMouseOutActorThisFrame.actorView != null && mMouseOutActorThisFrame.team != mHeroGameObjectOwner.team)
         {
            mMouseOutActorThisFrame.actorView.mouseOverUnhighlight();
         }
         if(mActorMousedOver == mMouseOutActorThisFrame)
         {
            mActorMousedOver = null;
         }
      }
      
      function handleDungeonBusterControlActivated(param1:DungeonBusterControlActivatedEvent) 
      {
         mDungeonBusterControlActivatedThisFrame = true;
      }
      
      function handleMouseUp(param1:MouseEvent) 
      {
         mMouseUpThisFrame = true;
         mMouseDownPosition = new Vector3D(param1.stageX,param1.stageY);
      }
      
      function handleMouseDown(param1:MouseEvent) 
      {
         mMouseDownThisFrame = true;
         mMouseDownPosition = new Vector3D(param1.stageX,param1.stageY);
      }
      
      function handleRightMouseDown(param1:MouseEvent) 
      {
         mRightMouseDown = true;
      }
      
      function handleRightMouseUp(param1:MouseEvent) 
      {
         mRightMouseDown = false;
      }
      
      function handleMiddleMouseDown(param1:MouseEvent) 
      {
         mMiddleMouseDown = true;
      }
      
      function handleMiddleMouseUp(param1:MouseEvent) 
      {
         mMiddleMouseDown = false;
      }
      
      @:isVar public var combatDisabled(never,set):Bool;
public function  set_combatDisabled(param1:Bool) :Bool      {
         return mCombatDisabled = param1;
      }
      
      public function perFrameUpCall() 
      {
         mPotentialAttacksThisFrame.resize(0);
         determineSelection();
         if(!mCombatDisabled)
         {
            determineAttacks();
         }
         determineMotion();
         flushMouseEventVars();
      }
      
      function determineMotion() 
      {
         Logger.error("determineMotion function is meant to be virtual and overriden by the subclasses.");
      }
      
      function determineAttacks() 
      {
         Logger.error("determineAttacks function is meant to be virtual and overriden by the subclasses.");
      }
      
      function determineSelection() 
      {
         Logger.error("determineSelection function is meant to be virtual and overriden by the subclasses.");
      }
      
      function flushMouseEventVars() 
      {
         mMouseDownActorPrevious = mMouseDownActorThisFrame;
         mMouseUpActorPrevious = mMouseUpActorThisFrame;
         mMouseOverActorPrevious = mMouseOverActorThisFrame;
         mMouseOutActorPrevious = mMouseOutActorThisFrame;
         mMouseUpActorThisFrame = null;
         mMouseDownActorThisFrame = null;
         mMouseOverActorThisFrame = null;
         mMouseOutActorThisFrame = null;
         mMouseUpThisFrame = false;
         mMouseDownThisFrame = false;
         mDungeonBusterControlActivatedThisFrame = false;
         mMouseUpPosition = new Vector3D();
         mMouseDownPosition = new Vector3D();
      }
      
      public function move(param1:String) : Bool
      {
         Logger.error("move function is meant to be virtual and overriden by the subclasses.");
         return false;
      }
      
      public function init() 
      {
         addListeners();
      }
      
      public function stop() 
      {
         removeListeners();
      }
      
      public function clearMovement() 
      {
         Logger.error("clearMovement is meant to be virtual and overriden by the subclasses.");
      }
      
      @:isVar public var potentialAttacksThisFrame(get,never):Array<ASAny>;
public function  get_potentialAttacksThisFrame() : Array<ASAny>
      {
         return mPotentialAttacksThisFrame;
      }
      
      @:isVar public var inputVelocity(get,never):Vector3D;
public function  get_inputVelocity() : Vector3D
      {
         return mInputVelocity;
      }
      
      @:isVar public var inputHeading(get,never):Vector3D;
public function  get_inputHeading() : Vector3D
      {
         return mInputHeading;
      }
      
      public function destroy() 
      {
         stop();
         mEventComponent.destroy();
         mEventComponent = null;
      }
   }


