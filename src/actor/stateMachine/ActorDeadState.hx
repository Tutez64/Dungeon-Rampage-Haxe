package actor.stateMachine
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.NPCGameObject;
   import facade.DBFacade;
   import com.greensock.TweenMax;
   
    class ActorDeadState extends ActorState
   {
      
      static inline final ROT_ON_FLOOR_TIME:Float = 8;
      
      static inline final ROT_ON_FLOOR_ALPHA:Float = 0.7;
      
      public static inline final NAME= "ActorDeadState";
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mFinishedDeathCallback:Task;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:ActorView)
      {
         super(param1,param2,param3,"ActorDeadState");
         mWorkComponent = new LogicalWorkComponent(mDBFacade);
      }
      
      override public function destroy() 
      {
         TweenMax.killTweensOf(mActorGameObject.view);
         TweenMax.killTweensOf(mActorGameObject.view.root);
         if(mFinishedDeathCallback != null)
         {
            mFinishedDeathCallback.destroy();
            mFinishedDeathCallback = null;
         }
         mWorkComponent.destroy();
         mWorkComponent = null;
         super.destroy();
      }
      
      override public function enterState() 
      {
         super.enterState();
         if(this.mActorGameObject.actorData.gMActor.CharType == "PROP")
         {
            propDeath();
         }
         else
         {
            enemyDeath();
         }
      }
      
      function enemyDeath() 
      {
         var deathAnimDuration:Float;
         var angle:Float;
         var actorView= ASCompat.reinterpretAs(mActorGameObject.view , ActorView);
         if(actorView.hasAnim("death"))
         {
            deathAnimDuration = actorView.getAnimDurationInSeconds("death") + 8;
            mFinishedDeathCallback = mWorkComponent.doLater(deathAnimDuration,mFinishedCallback);
            actorView.playAnim("death",0,false,false);
         }
         else
         {
            switch(mActorGameObject.actorData.gMActor.DefaultDestruct)
            {
               case "TIPOVER":
                  angle = Math.random() < 0.5 ? -90 : 90;
                  TweenMax.to(actorView,0.3,{"rotation":angle});
                  
               default:
                  actorView.root.visible = false;
            }
            mFinishedDeathCallback = mWorkComponent.doLater(8,mFinishedCallback);
         }
         mActorView.actionsForDeadState();
         if(actorView.currentWeapon != null && actorView.currentWeapon.weaponRenderer != null)
         {
            actorView.currentWeapon.weaponRenderer.stop();
         }
         actorView.removeFromStage();
         actorView.layer = 10;
         actorView.root.alpha = 0.7;
         actorView.addToStage();
         mWorkComponent.doLater(8 * 0.8,function(param1:brain.clock.GameClock)
         {
            TweenMax.to(actorView.root,8 * 0.2,{"alpha":0});
         });
         mActorGameObject.removeNavColliders();
         if(mActorGameObject.isPet && mActorGameObject.usePetUI)
         {
            mDBFacade.hud.unregisterPet(ASCompat.reinterpretAs(mActorGameObject , NPCGameObject));
         }
      }
      
      function propDeath() 
      {
         var _loc2_= Math.NaN;
         var _loc3_= Math.NaN;
         var _loc1_= ASCompat.reinterpretAs(mActorGameObject.view , ActorView);
         _loc1_.removeFromStage();
         _loc1_.layer = 10;
         _loc1_.root.alpha = 0.7;
         _loc1_.addToStage();
         if(_loc1_.hasAnim("death"))
         {
            _loc2_ = Math.random() < 0.5 ? -20 : 20;
            _loc2_ *= Math.random();
            TweenMax.to(_loc1_,0.3,{"rotation":_loc2_});
            _loc1_.playAnim("death",0,false,false);
         }
         else
         {
            switch(mActorGameObject.actorData.gMActor.DefaultDestruct)
            {
               case "TIPOVER":
                  _loc3_ = Math.random() < 0.5 ? -90 : 90;
                  TweenMax.to(_loc1_,0.3,{"rotation":_loc3_});
                  
               default:
                  _loc1_.root.visible = false;
            }
            mFinishedDeathCallback = mWorkComponent.doLater(8,mFinishedCallback);
         }
         mActorView.actionsForDeadState();
         if(_loc1_.currentWeapon != null && _loc1_.currentWeapon.weaponRenderer != null)
         {
            _loc1_.currentWeapon.weaponRenderer.stop();
         }
         mActorGameObject.removeNavColliders();
         if(mActorGameObject.isPet && mActorGameObject.usePetUI)
         {
            mDBFacade.hud.unregisterPet(ASCompat.reinterpretAs(mActorGameObject , NPCGameObject));
         }
      }
      
      override public function exitState() 
      {
         super.exitState();
         if(mFinishedDeathCallback != null)
         {
            mFinishedDeathCallback.destroy();
            mFinishedDeathCallback = null;
         }
      }
   }


