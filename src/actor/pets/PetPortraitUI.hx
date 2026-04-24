package actor.pets
;
   import account.ItemInfo;
   import brain.event.EventComponent;
   import brain.render.MovieClipRenderer;
   import brain.uI.UIObject;
   import brain.uI.UIProgressBar;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.NPCGameObject;
   import events.GameObjectEvent;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import flash.display.MovieClip;
   
    class PetPortraitUI extends UIObject
   {
      
      static inline final PET_PORTRAIT_ICON_SIZE= (80 : UInt);
      
      static inline final PET_NON_RESPAWNING_DEATH_FADE_OUT_TIME= (2 : UInt);
      
      static inline final PET_RESPAWNS_IN= "PET_RESPAWNS_IN";
      
      var mRespawnTask:Task;
      
      var mDBFacade:DBFacade;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mPetNPCGameObject:NPCGameObject;
      
      var mNoPetUI:UIObject;
      
      var mHpBar:UIProgressBar;
      
      var mCoolDownRenderer:MovieClipRenderer;
      
      var mCoolDownClipLength:Float = Math.NaN;
      
      var mIsDead:Bool = false;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:MovieClip, param4:NPCGameObject)
      {
         super(param1,param2,0,true);
         mDBFacade = param1;
         if(param3 != null)
         {
            mNoPetUI = new UIObject(mDBFacade,param3,0,true);
            if(mNoPetUI.tooltip != null)
            {
               ASCompat.setProperty((mNoPetUI.tooltip : ASAny).title_label, "text", Locale.getString("NO_PET_EQUIPPED_TOOLTIP_TITLE"));
               ASCompat.setProperty((mNoPetUI.tooltip : ASAny).description_label, "text", Locale.getString("NO_PET_EQUIPPED_TOOLTIP_DESCRIPTION"));
            }
         }
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"PetPortraitUI");
         mEventComponent = new EventComponent(mDBFacade);
         mPetNPCGameObject = param4;
         mRoot.visible = false;
         setupPetUI();
      }
      
      @:isVar public var petNPCGameObject(get,never):NPCGameObject;
public function  get_petNPCGameObject() : NPCGameObject
      {
         return mPetNPCGameObject;
      }
      
      function setupPetUI() 
      {
         mHpBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((root : ASAny).hp.hpBar, flash.display.MovieClip));
         ASCompat.setProperty((mRoot : ASAny).hp_death, "visible", false);
         if(mNoPetUI != null)
         {
            mNoPetUI.visible = false;
         }
         if(mPetNPCGameObject != null)
         {
            ASCompat.setProperty((mRoot : ASAny).tooltip.description_label, "text", GameMasterLocale.getGameMasterSubString("PET_DESCRIPTION",mPetNPCGameObject.gmNpc.Constant));
            ASCompat.setProperty((mRoot : ASAny).tooltip.title_label, "text", GameMasterLocale.getGameMasterSubString("PET_NAME",mPetNPCGameObject.gmNpc.Constant).toUpperCase());
            mEventComponent.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",mPetNPCGameObject.id),function(param1:events.HpEvent)
            {
               setHp(param1.hp,param1.maxHp);
            });
            setHp(mPetNPCGameObject.hitPoints,(Std.int(mPetNPCGameObject.maxHitPoints) : UInt));
            ItemInfo.loadItemIcon(mPetNPCGameObject.actorData.gMActor.IconSwfFilepath,mPetNPCGameObject.actorData.gMActor.IconName,ASCompat.dynamicAs((root : ASAny).graphic, flash.display.DisplayObjectContainer),mDBFacade,(80 : UInt),(68 : UInt));
            if(mNoPetUI != null)
            {
               mNoPetUI.visible = false;
            }
            mHpBar.visible = true;
            this.visible = true;
         }
         else
         {
            mHpBar.visible = false;
            if(mNoPetUI != null)
            {
               mNoPetUI.visible = true;
            }
            this.visible = false;
            this.hideTooltip();
         }
         mCoolDownRenderer = new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((root : ASAny).cooldown, flash.display.MovieClip));
         mCoolDownRenderer.clip.visible = false;
         mCoolDownClipLength = ASCompat.toNumber(ASCompat.toNumberField((root : ASAny).cooldown, "totalFrames") * brain.clock.GameClock.ANIMATION_FRAME_DURATION);
      }
      
      function setHp(param1:UInt, param2:UInt) 
      {
         mHpBar.value = param1 / param2;
      }
      
      public function petDeath() 
      {
         var _loc1_= Math.NaN;
         mIsDead = true;
         if(mPetNPCGameObject != null)
         {
            mEventComponent.removeListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",mPetNPCGameObject.id));
            _loc1_ = mPetNPCGameObject.gmNpc.RespawnT;
            if(_loc1_ > 0)
            {
               handleRespawningPetDeath(_loc1_);
            }
         }
         mPetNPCGameObject = null;
      }
      
      function handleRespawningPetDeath(param1:Float) 
      {
         var respawnTimer= param1;
         ItemInfo.loadItemIcon(mPetNPCGameObject.actorData.gMActor.IconSwfFilepath,mPetNPCGameObject.actorData.gMActor.IconName,ASCompat.dynamicAs((root : ASAny).graphic, flash.display.DisplayObjectContainer),mDBFacade,(80 : UInt),(68 : UInt));
         ASCompat.setProperty((mRoot : ASAny).hp_death, "visible", true);
         ASCompat.setProperty((root : ASAny).tooltip.title_label, "text", GameMasterLocale.getGameMasterSubString("PET_NAME",mPetNPCGameObject.gmNpc.Constant).toUpperCase());
         ASCompat.setProperty((root : ASAny).tooltip.description_label, "text", Locale.getString("PET_RESPAWNS_IN") + ": " + Std.string(respawnTimer));
         mCoolDownRenderer.playRate = mCoolDownClipLength / respawnTimer;
         mCoolDownRenderer.clip.visible = true;
         mCoolDownRenderer.play();
         if(mRespawnTask != null)
         {
            mRespawnTask.destroy();
         }
         mRespawnTask = mLogicalWorkComponent.doEverySeconds(1,function(param1:brain.clock.GameClock)
         {
            respawnTimer = respawnTimer - 1;
            ASCompat.setProperty((root : ASAny).tooltip.description_label, "text", Locale.getString("PET_RESPAWNS_IN") + Std.string(respawnTimer));
            if(respawnTimer == 0)
            {
               if(mRespawnTask != null)
               {
                  mRespawnTask.destroy();
               }
               mRespawnTask = null;
            }
         });
      }
      
      @:isVar public var npcId(get,never):Int;
public function  get_npcId() : Int
      {
         if(mPetNPCGameObject.gmNpc != null)
         {
            return (mPetNPCGameObject.id : Int);
         }
         return -1;
      }
      
      @:isVar public var isDead(get,never):Bool;
public function  get_isDead() : Bool
      {
         return mIsDead;
      }
      
      override public function destroy() 
      {
         mLogicalWorkComponent.destroy();
         mDBFacade = null;
         mPetNPCGameObject = null;
         if(mRespawnTask != null)
         {
            mRespawnTask.destroy();
         }
         mRespawnTask = null;
         if(mNoPetUI != null)
         {
            mNoPetUI.destroy();
         }
         mNoPetUI = null;
         if(mCoolDownRenderer != null)
         {
            mCoolDownRenderer.destroy();
         }
         mCoolDownRenderer = null;
         mHpBar = null;
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         super.destroy();
      }
   }


