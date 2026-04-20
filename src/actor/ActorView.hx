package actor
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.sound.SoundAsset;
   import brain.utils.ColorMatrix;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.PreRenderWorkComponent;
   import combat.weapon.WeaponView;
   import distributedObjects.HeroGameObject;
   import distributedObjects.NPCGameObject;
   import effects.EffectGameObject;
   import effects.EffectView;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import dr_floor.FloorView;
   import gameMasterDictionary.GMAttack;
   import generatedCode.CombatResult;
   import sound.DBSoundComponent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Vector3D;
   
    class ActorView extends FloorView
   {
      
      public static var BODY_Y_OFFSET:Float = -45;
      
      static var mMouseOverEffect:GlowFilter = new GlowFilter((16633879 : UInt),1,16,16,5);
      
      static var mMouseSelectedEffect:GlowFilter = new GlowFilter((16711680 : UInt),1,16,16,5);
      
      var mBody:Sprite;
      
      var mEffect:Sprite;
      
      var mParentActorObject:ActorGameObject;
      
      var mEventComponent:EventComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mSoundComponent:DBSoundComponent;
      
      var mVelocity:Vector3D;
      
      var mBodyAnimRenderer:ActorRenderer;
      
      var mAnimName:String = "idle";
      
      var mHeading:Float = 0;
      
      var mWantNametag:Bool = false;
      
      var mNametag:ActorNametag;
      
      var mCurrentWeaponView:WeaponView;
      
      var mCurrentWeaponAnimRenderer:ActorRenderer;
      
      var mBodyFilters:Array<ASAny>;
      
      var mDeathSoundEffect:SoundAsset;
      
      var mDeathSoundVolume:Float = Math.NaN;
      
      var specialVFXObject_Back:EffectGameObject;
      
      var specialVFXObject_Front:EffectGameObject;
      
      public function new(param1:DBFacade, param2:ActorGameObject)
      {
         super(param1,param2);
         mParentActorObject = param2;
         mBodyFilters = [];
         mVelocity = new Vector3D(0,0,0);
         mEventComponent = new EventComponent(mFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mFacade,"ActorView");
         mLogicalWorkComponent = new LogicalWorkComponent(mFacade,"ActorView");
         mSoundComponent = new DBSoundComponent(param1);
         mRoot.name = "ActorView.mRoot_" + param2.id;
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mBody = new Sprite();
         mBody.name = "ActorView.mBody";
         mRoot.addChild(mBody);
         mEffect = new Sprite();
         mEffect.name = "ActorView.mEffect";
         mRoot.addChild(mEffect);
      }
      
      function applyColor(param1:DisplayObject) 
      {
         var _loc3_= mParentActorObject.actorData.brightness;
         var _loc5_= mParentActorObject.actorData.hue;
         var _loc2_= mParentActorObject.actorData.saturation;
         var _loc4_= new ColorMatrix();
         if(_loc3_ != 0)
         {
            _loc4_.adjustBrightness(_loc3_);
         }
         if(_loc5_ != 0)
         {
            _loc4_.adjustHue(_loc5_);
         }
         if(_loc2_ != 0)
         {
            _loc4_.adjustSaturation(_loc2_);
         }
         param1.filters = cast([_loc4_.filter]);
      }
      
      @:isVar public var bodyAnimRenderer(get,never):ActorRenderer;
public function  get_bodyAnimRenderer() : ActorRenderer
      {
         return mBodyAnimRenderer;
      }
      
            
      @:isVar public var currentWeapon(get,set):WeaponView;
public function  get_currentWeapon() : WeaponView
      {
         return mCurrentWeaponView;
      }
function  set_currentWeapon(param1:WeaponView) :WeaponView      {
         if(mCurrentWeaponView == param1)
         {
            return param1;
         }
         mCurrentWeaponView = param1;
         if(mCurrentWeaponAnimRenderer != null)
         {
            mCurrentWeaponAnimRenderer.stop();
         }
         mCurrentWeaponAnimRenderer = mCurrentWeaponView.weaponRenderer;
         if(mCurrentWeaponAnimRenderer != null)
         {
            if(mCurrentWeaponAnimRenderer.hasAnim(mAnimName))
            {
               this.bodyAnimRenderer.forceFrame(0);
               mCurrentWeaponAnimRenderer.heading = this.heading;
               mCurrentWeaponAnimRenderer.play(mAnimName,this.bodyAnimRenderer.currentFrame,this.bodyAnimRenderer.loop);
               mBody.addChild(mCurrentWeaponAnimRenderer);
            }
            else
            {
               mCurrentWeaponAnimRenderer.stop();
            }
         }
return param1;
      }
      
      @:isVar public var nametag(get,never):ActorNametag;
public function  get_nametag() : ActorNametag
      {
         return mNametag;
      }
      
      public function disableMouse() 
      {
         mRoot.mouseChildren = false;
         mRoot.mouseEnabled = false;
      }
      
      public function enableMouse() 
      {
         mRoot.mouseChildren = true;
         mRoot.mouseEnabled = true;
      }
      
      public function actionsForDeadState() 
      {
         this.mouseOverUnhighlight();
         this.mouseSelectedUnhighlight();
         disableMouse();
         if(mDeathSoundEffect != null)
         {
            mSoundComponent.playSfxOneShot(mDeathSoundEffect,worldCenter,0,mDeathSoundVolume);
         }
         velocity = new Vector3D(0,0);
         hideSpecialEffect();
      }
      
      public function actionsForExitDeadState() 
      {
         enableMouse();
         showSpecialEffect();
      }
      
      function buildNametag() 
      {
         if(mWantNametag)
         {
            mNametag = new ActorNametag(mFacade,mAssetLoadingComponent,mLogicalWorkComponent,mParentActorObject.actorData.gMActor.NametagY);
            mNametag.cacheAsBitmap = true;
            mNametag.hpBar.scaleX = mParentActorObject.actorData.gMActor.HealthbarScale / root.scaleX;
            mNametag.hpBar.scaleY = mParentActorObject.actorData.gMActor.HealthbarScale / root.scaleY;
            mRoot.addChild(mNametag);
            mNametag.AFK = this.mParentActorObject.AFK;
            mNametag.screenName = this.mParentActorObject.screenName;
            mNametag.setHp(mParentActorObject.hitPoints,(Std.int(mParentActorObject.maxHitPoints) : UInt));
         }
      }
      
            
      @:isVar public var body(get,set):Sprite;
public function  get_body() : Sprite
      {
         return mBody;
      }
      
      public function buildBuff(param1:MovieClip, param2:String) 
      {
         if(param1 == null)
         {
            return;
         }
         if(mRoot.contains(param1))
         {
            Logger.warn("buff already is a child of mRoot");
            return;
         }
         if(param2 == "foreground")
         {
            mRoot.addChild(param1);
         }
         else
         {
            mRoot.addChildAt(param1,0);
         }
      }
      
      public function destroyBuff(param1:MovieClip) 
      {
         if(param1 == null)
         {
            return;
         }
         if(mRoot.contains(param1))
         {
            mRoot.removeChild(param1);
         }
      }
      
      override public function init() 
      {
         super.init();
         mBodyAnimRenderer = new ActorRenderer(mDBFacade,mParentActorObject,true);
         mBodyAnimRenderer.loadAssets();
         if(mParentActorObject.actorData.assetType == "SPRITE_SHEET")
         {
            mBody.scaleX = mBody.scaleY = mParentActorObject.actorData.scale3DModel;
         }
         mBody.addChild(mBodyAnimRenderer);
         applyColor(mBodyAnimRenderer);
         buildNametag();
         if(ASCompat.stringAsBool(mParentActorObject.actorData.deathSound))
         {
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mParentActorObject.actorData.deathSound,function(param1:SoundAsset)
            {
               mDeathSoundEffect = param1;
               mDeathSoundVolume = mParentActorObject.actorData.deathVolume;
            });
         }
         if(mParentActorObject.gmSkin != null && mParentActorObject.gmSkin.doesSpecialFXBackExist())
         {
            addSpecialBackEffect(mParentActorObject.gmSkin.specialFXSwfPath_Back,mParentActorObject.gmSkin.specialFXName_Back);
         }
         if(mParentActorObject.gmSkin != null && mParentActorObject.gmSkin.doesSpecialFXFrontExist())
         {
            addSpecialFrontEffect(mParentActorObject.gmSkin.specialFXSwfPath_Front,mParentActorObject.gmSkin.specialFXName_Front);
         }
      }
      
      public function addSpecialBackEffect(param1:String, param2:String) 
      {
         var swfPath= param1;
         var className= param2;
         specialVFXObject_Back = new EffectGameObject(mDBFacade,DBFacade.buildFullDownloadPath(swfPath),className,1);
         MemoryTracker.track(specialVFXObject_Back,"EffectGameObject \'" + swfPath + ":" + className + "\' - created in ActorView.addSpecialBackEffect()");
         root.addChildAt(specialVFXObject_Back.view.root,0);
         cast(specialVFXObject_Back.view, EffectView).play(true,function()
         {
         });
      }
      
      public function addSpecialFrontEffect(param1:String, param2:String) 
      {
         var swfPath= param1;
         var className= param2;
         specialVFXObject_Front = new EffectGameObject(mDBFacade,DBFacade.buildFullDownloadPath(swfPath),className,1);
         MemoryTracker.track(specialVFXObject_Front,"EffectGameObject \'" + swfPath + ":" + className + "\' - created in ActorView.addSpecialFrontEffect()");
         root.addChild(specialVFXObject_Front.view.root);
         cast(specialVFXObject_Front.view, EffectView).play(true,function()
         {
         });
      }
      
      public function showSpecialEffect() 
      {
         if(specialVFXObject_Back != null)
         {
            specialVFXObject_Back.view.root.visible = true;
         }
         if(specialVFXObject_Front != null)
         {
            specialVFXObject_Front.view.root.visible = true;
         }
      }
      
      public function hideSpecialEffect() 
      {
         if(specialVFXObject_Back != null)
         {
            specialVFXObject_Back.view.root.visible = false;
         }
         if(specialVFXObject_Front != null)
         {
            specialVFXObject_Front.view.root.visible = false;
         }
      }
      
      public function hasAnim(param1:String) : Bool
      {
         return this.bodyAnimRenderer.hasAnim(param1);
      }
      
      public function getAnimDurationInSeconds(param1:String) : Float
      {
         return this.bodyAnimRenderer.getAnimDurationInSeconds(param1);
      }
      
      public function playAnim(param1:String, param2:Int = 0, param3:Bool = false, param4:Bool = true, param5:Float = 1) : Bool
      {
         mAnimName = param1;
         if(this.bodyAnimRenderer != null)
         {
            this.bodyAnimRenderer.heading = this.heading;
            this.bodyAnimRenderer.play(param1,param2,param3,param4,param5);
         }
         if(mCurrentWeaponAnimRenderer != null)
         {
            if(mCurrentWeaponAnimRenderer.hasAnim(param1))
            {
               mCurrentWeaponAnimRenderer.heading = this.heading;
               mCurrentWeaponAnimRenderer.play(param1,param2,param3,param4,param5);
            }
            else
            {
               mCurrentWeaponAnimRenderer.stop();
            }
         }
         return true;
      }
      
      @:isVar public var currentAnim(get,never):String;
public function  get_currentAnim() : String
      {
         return mAnimName;
      }
      
      public function setAnimAt(param1:String, param2:UInt) : Bool
      {
         this.bodyAnimRenderer.heading = this.heading;
         this.bodyAnimRenderer.setFrame(param1,(param2 : Int));
         if(mCurrentWeaponAnimRenderer != null)
         {
            if(mCurrentWeaponAnimRenderer.hasAnim(param1))
            {
               mCurrentWeaponAnimRenderer.heading = this.heading;
               mCurrentWeaponAnimRenderer.setFrame(param1,(param2 : Int));
            }
            else
            {
               mCurrentWeaponAnimRenderer.stop();
            }
         }
         return true;
      }
      
      public function stopAnim() 
      {
         this.bodyAnimRenderer.stop();
         if(mCurrentWeaponAnimRenderer != null)
         {
            mCurrentWeaponAnimRenderer.stop();
         }
      }
      
      public function setHp(param1:UInt, param2:UInt) 
      {
         if(mNametag != null)
         {
            mNametag.setHp(param1,param2);
         }
      }
      
      @:isVar public var screenName(never,set):String;
public function  set_screenName(param1:String) :String      {
         if(mNametag != null)
         {
            mNametag.screenName = param1;
         }
return param1;
      }
      
      public function setChat(param1:String) 
      {
         if(mNametag != null)
         {
            mNametag.setChat(param1);
         }
      }
      
            
      @:isVar public var velocity(get,set):Vector3D;
public function  get_velocity() : Vector3D
      {
         return mVelocity;
      }
function  set_velocity(param1:Vector3D) :Vector3D      {
         return mVelocity = param1;
      }
      
            
      @:isVar public var heading(get,set):Float;
public function  set_heading(param1:Float) :Float      {
         mHeading = param1;
         if(this.bodyAnimRenderer != null)
         {
            this.bodyAnimRenderer.heading = param1;
         }
         if(mCurrentWeaponAnimRenderer != null)
         {
            mCurrentWeaponAnimRenderer.heading = param1;
         }
return param1;
      }
function  get_heading() : Float
      {
         return mHeading;
      }
      
      override public function destroy() 
      {
         if(mNametag != null)
         {
            mNametag.destroy();
            mNametag = null;
         }
         if(mDeathSoundEffect != null)
         {
            mDeathSoundEffect = null;
         }
         mEventComponent.destroy();
         mEventComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mPreRenderWorkComponent.destroy();
         mPreRenderWorkComponent = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         if(mBodyAnimRenderer != null)
         {
            mBodyAnimRenderer.destroy();
            mBodyAnimRenderer = null;
         }
         mCurrentWeaponView = null;
         mCurrentWeaponAnimRenderer = null;
         mBodyFilters = null;
         mBody = null;
         mEffect = null;
         mParentActorObject = null;
         super.destroy();
      }
function  set_body(param1:Sprite) :Sprite      {
         if(mBody != null && mBody.parent != null)
         {
            mBody.parent.removeChild(mBody);
         }
         mBody = param1;
         mRoot.addChild(mBody);
return param1;
      }
      
      public function mouseOverHighlight() 
      {
         addEffect(mMouseOverEffect);
      }
      
      public function mouseOverUnhighlight() 
      {
         removeEffect(mMouseOverEffect);
      }
      
      public function mouseSelectedHighlight() 
      {
         addEffect(mMouseSelectedEffect);
      }
      
      public function mouseSelectedUnhighlight() 
      {
         removeEffect(mMouseSelectedEffect);
      }
      
      public function reviveHighlight() 
      {
         var _loc1_= new ColorTransform();
         _loc1_.color = (16777215 : UInt);
         mBody.transform.colorTransform = _loc1_;
      }
      
      public function reviveUnhighlight() 
      {
         mBody.transform.colorTransform = new ColorTransform();
      }
      
      function addEffect(param1:GlowFilter) 
      {
         if(mBodyFilters.indexOf(param1) < 0)
         {
            mBodyFilters.push(param1);
            mBody.filters = cast(mBodyFilters);
         }
      }
      
      function removeEffect(param1:GlowFilter) 
      {
         var _loc2_= mBodyFilters.indexOf(param1);
         if(_loc2_ >= 0)
         {
            mBodyFilters.splice(_loc2_,(1 : UInt));
            mBody.filters = cast(mBodyFilters);
         }
      }
      
      function playHitEffect(param1:GMAttack, param2:Bool) 
      {
         var _loc5_= DBFacade.buildFullDownloadPath(param1.HitEffectFilepath);
         var _loc3_= Std.isOfType(mParentActorObject , HeroGameObject) ? "db_fx_hitRed" : param1.HitEffect;
         if(param2)
         {
            _loc3_ = param1.HitEffect;
         }
         var _loc4_= new Vector3D(0,mParentActorObject.actorData.gMActor.ProjEmitOffset);
         var _loc6_= 1 / mRoot.scaleX;
         var _loc7_= param1.HitEffectStopRotation ? 0 : Math.random() * 360;
         if(ASCompat.stringAsBool(_loc3_))
         {
            mParentActorObject.distributedDungeonFloor.effectManager.playEffect(_loc5_,_loc3_,_loc4_,mParentActorObject,param1.HitEffectBehindAvatar,_loc6_,_loc7_);
         }
      }
      
      function playHitEffectToLerpToAttacker(param1:GMAttack, param2:ActorGameObject) 
      {
         var swfPath:String;
         var hitEffectName:String;
         var lerpedFunc:ASFunction;
         var i:Int;
         var gmAttack= param1;
         var lerpActor= param2;
         if(ASCompat.stringAsBool(gmAttack.HitEffectToLerpToAttacker))
         {
            swfPath = DBFacade.buildFullDownloadPath(gmAttack.HitEffectLerpFilepath);
            hitEffectName = gmAttack.HitEffectToLerpToAttacker;
            if(ASCompat.stringAsBool(hitEffectName))
            {
               lerpedFunc = function()
               {
                  playLerpedEffect(swfPath,hitEffectName,mParentActorObject,lerpActor,gmAttack.HitEffectToLerpSpeed,gmAttack.HitEffectToLerpGlowColor);
               };
               i = 0;
               while(i < 5)
               {
                  mLogicalWorkComponent.doLater(Math.random() / 100 * i,lerpedFunc);
                  i = i + 1;
               }
            }
         }
      }
      
      function playHitEffectToLerpFromAttacker(param1:GMAttack, param2:ActorGameObject) 
      {
         var swfPath:String;
         var hitEffectName:String;
         var lerpedFunc:ASFunction;
         var i:Int;
         var gmAttack= param1;
         var lerpActor= param2;
         if(ASCompat.stringAsBool(gmAttack.HitEffectToLerpFromAttacker))
         {
            swfPath = DBFacade.buildFullDownloadPath(gmAttack.HitEffectLerpFilepath);
            hitEffectName = gmAttack.HitEffectToLerpFromAttacker;
            if(ASCompat.stringAsBool(hitEffectName))
            {
               lerpedFunc = function()
               {
                  playLerpedEffect(swfPath,hitEffectName,lerpActor,mParentActorObject,gmAttack.HitEffectToLerpSpeed,gmAttack.HitEffectToLerpGlowColor);
               };
               i = 0;
               while(i < 5)
               {
                  mLogicalWorkComponent.doLater(Math.random() / 100 * i,lerpedFunc);
                  i = i + 1;
               }
            }
         }
      }
      
      function playLerpedEffect(param1:String, param2:String, param3:FloorObject = null, param4:ActorGameObject = null, param5:Float = 1, param6:UInt = (13369344 : UInt)) 
      {
         var _loc7_= new Vector3D(0,0);
         var _loc8_= 0.5 + Math.random();
         mParentActorObject.distributedDungeonFloor.effectManager.playLerpedEffect(param1,param2,_loc7_,param3,param4,param5,param6,false,_loc8_);
      }
      
      function playHealEffect() 
      {
         var _loc2_= DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf");
         var _loc5_= "db_fx_heal";
         var _loc1_= mParentActorObject.projectileLaunchOffset;
         var _loc3_= 1 / mRoot.scaleX;
         var _loc4_:Float = 0;
         mParentActorObject.distributedDungeonFloor.effectManager.playEffect(_loc2_,_loc5_,_loc1_,mParentActorObject,false,_loc3_,_loc4_);
      }
      
      function isThisIdTheOwner(param1:UInt) : Bool
      {
         var _loc2_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1) , ActorGameObject);
         return _loc2_.isOwner;
      }
      
      function isThisIdAnOwnersPet(param1:UInt) : Bool
      {
         var _loc3_:NPCGameObject = null;
         var _loc2_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1) , ActorGameObject);
         if(_loc2_ != null)
         {
            _loc3_ = ASCompat.reinterpretAs(_loc2_ , NPCGameObject);
            if(_loc3_ == null)
            {
               return false;
            }
            if(_loc3_.masterIsUser())
            {
               return true;
            }
         }
         return false;
      }
      
      function isThisAProp(param1:UInt) : Bool
      {
         var _loc2_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1) , ActorGameObject);
         if(_loc2_ != null && _loc2_.actorData.gMActor.CharType == "PROP")
         {
            return true;
         }
         return false;
      }
      
      function doesCombatResultInvolveUserOrPetOfUser(param1:CombatResult) : Bool
      {
         if(isThisIdUserOrPetOfUser(param1.attacker) || isThisIdUserOrPetOfUser(param1.attackee))
         {
            return true;
         }
         return false;
      }
      
      function doesCombatResultHaveShowHealFlag(param1:CombatResult) : Bool
      {
         var _loc2_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1.attackee) , ActorGameObject);
         if(_loc2_.hasShowHealNumbers)
         {
            return true;
         }
         return false;
      }
      
      function isThisIdUserOrPetOfUser(param1:UInt) : Bool
      {
         if(isThisIdTheOwner(param1))
         {
            return true;
         }
         return isThisIdAnOwnersPet(param1);
      }
      
      public function localCombatHit(param1:CombatResult) 
      {
         var _loc2_:GMAttack = null;
         var _loc3_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1.attacker) , ActorGameObject);
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_.isOwner)
         {
            _loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(param1.attack.attackType), gameMasterDictionary.GMAttack);
            playHitEffect(_loc2_,_loc3_.isHeroType);
            playHitEffectToLerpToAttacker(_loc2_,_loc3_);
            playHitEffectToLerpFromAttacker(_loc2_,_loc3_);
         }
      }
      
      public function receiveDamage(param1:CombatResult, param2:GMAttack) 
      {
         var impactSound:String;
         var combatResult= param1;
         var gmAttack= param2;
         var attackerGameObject= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(combatResult.attacker) , ActorGameObject);
         if(attackerGameObject != null)
         {
            if(!attackerGameObject.isOwner)
            {
               playHitEffect(gmAttack,attackerGameObject.isHeroType);
            }
            if(combatResult.damage != 0)
            {
               if(doesCombatResultInvolveUserOrPetOfUser(combatResult) && !isThisAProp(combatResult.attackee))
               {
                  spawnDamageFloater(ASCompat.toBool(combatResult.criticalHit),combatResult.damage,isThisIdTheOwner(combatResult.attacker),isThisIdTheOwner(combatResult.attackee),combatResult.effectiveness);
               }
            }
            if(ASCompat.stringAsBool(mParentActorObject.actorData.hitSound))
            {
               this.mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mParentActorObject.actorData.hitSound,function(param1:SoundAsset)
               {
                  mSoundComponent.playSfxOneShot(param1,worldCenter,0,mParentActorObject.actorData.hitVolume);
               });
            }
         }
         if(gmAttack != null && ASCompat.stringAsBool(gmAttack.ImpactSound))
         {
            impactSound = gmAttack.ImpactSound;
            if(combatResult.effectiveness < 0)
            {
               impactSound = "WeakAttack";
            }
            else if(combatResult.effectiveness > 0)
            {
               impactSound = "StrongHit";
            }
            this.mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),impactSound,function(param1:SoundAsset)
            {
               mSoundComponent.playSfxOneShot(param1,worldCenter,0,gmAttack.ImpactVolume);
            });
         }
      }
      
      public function receiveHeal(param1:CombatResult, param2:GMAttack) 
      {
         var _loc3_= false;
         if(param1.damage != 0)
         {
            if(doesCombatResultInvolveUserOrPetOfUser(param1) || doesCombatResultHaveShowHealFlag(param1))
            {
               _loc3_ = isThisIdTheOwner(param1.attacker) || isThisIdTheOwner(param1.attackee);
               spawnHealFloater(param1.damage,isThisIdTheOwner(param1.attacker),isThisIdTheOwner(param1.attackee),param1.effectiveness);
            }
         }
      }
      
      public function spawnDamageFloater(param1:Bool, param2:Int, param3:Bool, param4:Bool, param5:Int, param6:UInt = (0 : UInt), param7:String = "DAMAGE_MOVEMENT_TYPE") 
      {
         var _loc8_:DamageFloater = null;
         if(mDBFacade.featureFlags.getFlagValue("want-damage-floaters"))
         {
            _loc8_ = new DamageFloater(mDBFacade,param2,mParentActorObject,(0 : UInt),(24 : UInt),0.9,90,null,param3,param4,true,param1,param5,param6,param7);
         }
      }
      
      public function spawnHealFloater(param1:Int, param2:Bool, param3:Bool, param4:Int, param5:UInt = (0 : UInt), param6:String = "DAMAGE_MOVEMENT_TYPE") 
      {
         var _loc7_:DamageFloater = null;
         if(mDBFacade.featureFlags.getFlagValue("want-damage-floaters"))
         {
            _loc7_ = new DamageFloater(mDBFacade,param1,mParentActorObject,(4 : UInt),(24 : UInt),0.9,90,null,param2,param3,true,false,param4,param5,param6);
         }
      }
      
      public function hasAnimationRenderer() : Bool
      {
         if(bodyAnimRenderer != null)
         {
            return true;
         }
         return false;
      }
      
      @:isVar public var AFK(never,set):Bool;
public function  set_AFK(param1:Bool) :Bool      {
         if(mNametag != null)
         {
            mNametag.AFK = param1;
         }
return param1;
      }
   }


