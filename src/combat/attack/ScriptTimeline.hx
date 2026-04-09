package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import generatedCode.CombatResult;
   import org.as3commons.collections.ArrayList;
   import org.as3commons.collections.LinkedList;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.ILinkedListIterator;
   import org.as3commons.collections.framework.IListIterator;
   import org.as3commons.collections.framework.IMapIterator;
   
    class ScriptTimeline
   {
      
      var mActorGameObject:ActorGameObject;
      
      var mTargetActor:ActorGameObject;
      
      var mActorView:ActorView;
      
      var mScriptJson:ASObject;
      
      var mDBFacade:DBFacade;
      
      var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      var mTimelineActions:Map;
      
      var mFinishedCallback:ASFunction;
      
      var mStopCallback:ASFunction;
      
      var mPlayHeadTime:Float = 0;
      
      var mLastExecutedFrame:Int = -1;
      
      var mFinishedFrame:Int = 0;
      
      var mLoop:Bool = false;
      
      var mHasGoto:Bool = false;
      
      var mAutoAim:Bool = false;
      
      var mIsPlaying:Bool = false;
      
      var mIsLooping:Bool = false;
      
      var mTotalFrames:UInt = 0;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mPlayTimelineTask:Task;
      
      var mCurrentAttackType:UInt = 0;
      
      var mCurrentGMAttack:GMAttack;
      
      var mCurrentCombatResult:CombatResult;
      
      var mCurrentAttacker:ActorGameObject;
      
      var mPlaySpeed:Float = 1;
      
      var mContinuousCollisions:ArrayList;
      
      var mRemovalContinuous:ArrayList;
      
      public var mManagedEffects:ArrayList;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:ASObject, param4:DBFacade, param5:DistributedDungeonFloor)
      {
         
         mDBFacade = param4;
         mDistributedDungeonFloor = param5;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mTimelineActions = new Map();
         mActorView = param2;
         mActorGameObject = param1;
         mScriptJson = param3;
         parseJson(mScriptJson);
         mContinuousCollisions = new ArrayList();
         mRemovalContinuous = new ArrayList();
         mManagedEffects = new ArrayList();
      }
      
            
      @:isVar public var playSpeed(get,set):Float;
public function  set_playSpeed(param1:Float) :Float      {
         return mPlaySpeed = param1;
      }
function  get_playSpeed() : Float
      {
         return mPlaySpeed;
      }
      
      public function getPercentageOfTimelinePlayed() : Float
      {
         return mLastExecutedFrame / mTotalFrames;
      }
      
      public function getTimeRemaining() : Float
      {
         var _loc1_:Float = mTotalFrames - mLastExecutedFrame;
         return _loc1_ * mDBFacade.gameClock.tickLength / playSpeed;
      }
      
      function parseJson(param1:ASObject) 
      {
         var _loc6_:AttackTimelineAction = null;
         var _loc11_:LinkedList = null;
         var _loc7_= 0;
         var _loc5_:ASObject = null;
         var _loc3_= 0;
         var _loc10_:Array<ASAny> = null;
         var _loc8_= 0;
         var _loc9_= 0;
         var _loc2_:ASObject = null;
         var _loc12_:Array<ASAny> = ASCompat.dynamicAs(param1.frames, Array);
         mTotalFrames = (ASCompat.toInt(param1.totalFrames) : UInt);
         var _loc4_= (_loc12_.length : UInt);
         _loc7_ = 0;
         while((_loc7_ : UInt) < _loc4_)
         {
            _loc5_ = _loc12_[_loc7_];
            _loc3_ = ASCompat.toInt(_loc5_.frame);
            _loc10_ = ASCompat.dynamicAs(_loc5_.actions, Array);
            _loc8_ = _loc10_.length;
            _loc11_ = new LinkedList();
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc2_ = (_loc10_[_loc9_] : ASObject) ;
               _loc6_ = parseAction(_loc2_);
               if(_loc6_ != null)
               {
                  if(_loc3_ >= ASCompat.toNumberField(param1, "totalFrames"))
                  {
                     Logger.error("ScriptTimeline.as " + Std.string(param1.attackName) + " action:" + _loc6_ + " at frame:" + _loc3_ + " after last frame:" + Std.string((ASCompat.toNumberField(param1, "totalFrames") - 1)));
                  }
                  _loc11_.add(_loc6_);
               }
               _loc9_++;
            }
            mTimelineActions.add(_loc3_,_loc11_);
            _loc7_++;
         }
         mFinishedFrame = ASCompat.toInt(param1.totalFrames);
      }
      
      function parseAction(param1:ASObject) : AttackTimelineAction
      {
         mHasGoto = false;
         var _loc3_= ASCompat.asString(param1.type );
         var _loc2_:AttackTimelineAction = null;
         switch(_loc3_)
         {
            case "attackSound":
               _loc2_ = SoundAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "sound":
               _loc2_ = SoundTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "animFrame":
               _loc2_ = AnimationFrameAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "playAnim":
               _loc2_ = PlayAnimationAttackTimelineAction.buildFromJson(this,mActorGameObject,mActorView,mDBFacade,param1);
               
            case "move":
               _loc2_ = MovementAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "runIdleMonitor":
               _loc2_ = RunIdleMonitorTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "goto":
               mHasGoto = true;
               _loc2_ = GotoTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1,gotoFrame);
               
            case "knockback":
               _loc2_ = KnockBackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade);
               
            case "shake":
               _loc2_ = CameraShakeTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "effect":
               _loc2_ = PlayEffectTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "color":
               _loc2_ = ColorShiftTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "glow":
               _loc2_ = GlowTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "fadebackground":
               _loc2_ = FadeBackgroundTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "visible":
               _loc2_ = HideTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "hideSpecialEffect":
               _loc2_ = HideSpecialEffectTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "scale":
               _loc2_ = ScaleAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "zoom"
               | "timeScale"
               | "circleCollider"
               | "rectangleCollider"
               | "inputType"
               | "sufferImmunity":
               _loc2_ = SufferImmunityTimeLineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "knockbackImmunity":
               _loc2_ = KnockbackImmunityTimeLineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            case "attemptRevive"
               | "proposeRevive"
               | "spawndoober"
               | "spawnnpc"
               | "invulnerable":
               
            case "teleport":
               _loc2_ = TeleportTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            default:
               if(_loc3_.charAt(0) != "#")
               {
                  Logger.debug("No handle for attack timeline action type: " + _loc3_);
               }
         }
         return _loc2_;
      }
      
      @:isVar public var currentAttackType(never,set):UInt;
public function  set_currentAttackType(param1:UInt) :UInt      {
         mCurrentAttackType = param1;
         mCurrentGMAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(param1), gameMasterDictionary.GMAttack);
         if(mCurrentGMAttack == null)
         {
            Logger.error("Could not find GMAttack for id: " + param1);
         }
return param1;
      }
      
      @:isVar public var currentGMAttack(get,never):GMAttack;
public function  get_currentGMAttack() : GMAttack
      {
         return mCurrentGMAttack;
      }
      
      @:isVar public var currentCombatResult(never,set):CombatResult;
public function  set_currentCombatResult(param1:CombatResult) :CombatResult      {
         mCurrentCombatResult = param1;
         currentAttackType = param1.attack.attackType;
return param1;
      }
      
      @:isVar public var currentAttacker(never,set):ActorGameObject;
public function  set_currentAttacker(param1:ActorGameObject) :ActorGameObject      {
         return mCurrentAttacker = param1;
      }
      
      @:isVar public var isPlaying(get,never):Bool;
public function  get_isPlaying() : Bool
      {
         return mIsPlaying;
      }
      
      @:isVar public var loop(get,never):Bool;
public function  get_loop() : Bool
      {
         return mLoop || mHasGoto;
      }
      
            
      @:isVar public var autoAim(get,set):Bool;
public function  get_autoAim() : Bool
      {
         return mAutoAim;
      }
function  set_autoAim(param1:Bool) :Bool      {
         return mAutoAim = param1;
      }
      
      public function play(param1:Float, param2:ActorGameObject, param3:ASFunction = null, param4:ASFunction = null, param5:Bool = false) 
      {
         mPlayHeadTime = 0;
         mTargetActor = param2;
         mIsPlaying = true;
         mLoop = param5;
         mPlaySpeed = param1;
         if(mPlayTimelineTask != null)
         {
            mPlayTimelineTask.destroy();
            mPlayTimelineTask == null;
         }
         mFinishedCallback = param3;
         mStopCallback = param4;
         mLastExecutedFrame = -1;
         applyCurrentTimelineValues();
         mPlayTimelineTask = mLogicalWorkComponent.doEveryFrame(update);
         update(mLogicalWorkComponent.gameClock);
      }
      
      function applyCurrentTimelineValues() 
      {
         extractActionToUpdateCurrentValues(mTimelineActions);
      }
      
      function extractActionToUpdateCurrentValues(param1:Map) 
      {
         var _loc4_:LinkedList = null;
         var _loc5_:ILinkedListIterator = null;
         var _loc3_:AttackTimelineAction = null;
         var _loc2_= ASCompat.reinterpretAs(param1.iterator() , IMapIterator);
         while(_loc2_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc2_.next() , LinkedList);
            _loc5_ = ASCompat.reinterpretAs(_loc4_.iterator() , ILinkedListIterator);
            while(_loc5_.hasNext())
            {
               _loc3_ = ASCompat.dynamicAs(_loc5_.next() , AttackTimelineAction);
               updateAction(_loc3_);
            }
         }
      }
      
      function updateAction(param1:AttackTimelineAction) 
      {
         param1.combatResult = mCurrentCombatResult;
         param1.attacker = mCurrentAttacker;
         param1.attackType = mCurrentAttackType;
      }
      
      public function stop() 
      {
         var _loc1_= 0;
         mIsPlaying = false;
         stopAllActions();
         if(mStopCallback != null)
         {
            mStopCallback();
            mStopCallback = null;
         }
         if(mPlayTimelineTask != null)
         {
            mPlayTimelineTask.destroy();
            mPlayTimelineTask = null;
         }
         var _loc2_= ASCompat.reinterpretAs(mManagedEffects.iterator() , IListIterator);
         while(_loc2_.hasNext())
         {
            _loc1_ = (ASCompat.asUint(_loc2_.next() ) : Int);
            mActorGameObject.distributedDungeonFloor.effectManager.endManagedEffect((_loc1_ : UInt));
         }
         mManagedEffects.clear();
      }
      
      public function stopAndFinish() 
      {
         if(!mIsPlaying)
         {
            return;
         }
         stop();
         if(mFinishedCallback != null)
         {
            mFinishedCallback();
         }
         else
         {
            Logger.warn("the finished callback on the AttackTimeline was null during a non-loop attack.");
         }
      }
      
      function stopAllActions() 
      {
         var _loc4_:LinkedList = null;
         var _loc5_:ILinkedListIterator = null;
         var _loc3_:AttackTimelineAction = null;
         var _loc6_:AttackTimelineAction = null;
         var _loc2_:Array<ASAny> = [];
         var _loc1_= ASCompat.reinterpretAs(mTimelineActions.iterator() , IMapIterator);
         while(_loc1_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc1_.next() , LinkedList);
            _loc5_ = ASCompat.reinterpretAs(_loc4_.iterator() , ILinkedListIterator);
            while(_loc5_.hasNext())
            {
               _loc3_ = ASCompat.dynamicAs(_loc5_.next() , AttackTimelineAction);
               _loc2_.push(_loc3_);
            }
         }
         while(_loc2_.length > 0)
         {
            _loc6_ = ASCompat.dynamicAs(_loc2_.pop(), combat.attack.AttackTimelineAction);
            _loc6_.stop();
         }
      }
      
      function gotoFrame(param1:Int) 
      {
         mPlayHeadTime = param1;
         mIsLooping = true;
      }
      
      function processTimelineFrame(param1:Map, param2:Int, param3:GameClock) 
      {
         var _loc5_:LinkedList = null;
         var _loc6_:ILinkedListIterator = null;
         var _loc4_:AttackTimelineAction = null;
         if(param2 == mLastExecutedFrame && !mIsLooping)
         {
            return;
         }
         if(param1.hasKey(param2))
         {
            _loc5_ = ASCompat.dynamicAs(param1.itemFor(param2), org.as3commons.collections.LinkedList);
            _loc6_ = ASCompat.reinterpretAs(_loc5_.iterator() , ILinkedListIterator);
            while(_loc6_.hasNext())
            {
               _loc4_ = ASCompat.dynamicAs(_loc6_.next() , AttackTimelineAction);
               _loc4_.execute(this);
            }
         }
      }
      
      function update(param1:GameClock) 
      {
         var _loc3_= 0;
         if(mFinishedFrame <= mLastExecutedFrame && mFinishedFrame <= mPlayHeadTime)
         {
            timelineActionsFinished();
            return;
         }
         var _loc2_= (mLastExecutedFrame + 1 : UInt);
         if(mPlayHeadTime < mLastExecutedFrame)
         {
            _loc2_ = (Std.int(mPlayHeadTime - 1) : UInt);
         }
         _loc3_ = (_loc2_ : Int);
         while(_loc3_ <= mPlayHeadTime)
         {
            processTimelineActions(_loc3_,param1);
            mLastExecutedFrame = _loc3_;
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
         updatePlayHead(param1);
      }
      
      function updatePlayHead(param1:GameClock) 
      {
         mPlayHeadTime += mPlaySpeed * param1.timeScale;
      }
      
      function processTimelineActions(param1:Int, param2:GameClock) 
      {
         processTimelineFrame(mTimelineActions,param1,param2);
         processContinuousCollision();
      }
      
      function timelineActionsFinished() 
      {
         if(mLoop)
         {
            mPlayHeadTime = 0;
            return;
         }
         stopAndFinish();
      }
      
      public function destroy() 
      {
         var _loc1_:ILinkedListIterator = null;
         var _loc4_:LinkedList = null;
         var _loc2_:AttackTimelineAction = null;
         mActorGameObject = null;
         mActorView = null;
         mDBFacade = null;
         mDistributedDungeonFloor = null;
         var _loc3_= ASCompat.reinterpretAs(mTimelineActions.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc3_.next(), org.as3commons.collections.LinkedList);
            _loc1_ = ASCompat.reinterpretAs(_loc4_.iterator() , ILinkedListIterator);
            while(_loc1_.hasNext())
            {
               _loc2_ = ASCompat.dynamicAs(_loc1_.next(), combat.attack.AttackTimelineAction);
               _loc2_.destroy();
            }
            _loc4_.clear();
         }
         mTimelineActions.clear();
         mTimelineActions = null;
         mFinishedCallback = null;
         mStopCallback = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         if(mPlayTimelineTask != null)
         {
            mPlayTimelineTask.destroy();
            mPlayTimelineTask = null;
         }
         mCurrentGMAttack = null;
         mCurrentCombatResult = null;
         mCurrentAttacker = null;
         mContinuousCollisions.clear();
         mContinuousCollisions = null;
         mManagedEffects.clear();
         mManagedEffects = null;
      }
      
      @:isVar public var attackName(get,never):String;
public function  get_attackName() : String
      {
         return mScriptJson.attackName;
      }
      
      @:isVar public var currentFrame(get,never):UInt;
public function  get_currentFrame() : UInt
      {
         return (mLastExecutedFrame : UInt);
      }
      
      @:isVar public var targetActor(get,never):ActorGameObject;
public function  get_targetActor() : ActorGameObject
      {
         return mTargetActor;
      }
      
      public function addContinuousCollision(param1:ColliderTimelineAction) 
      {
         mContinuousCollisions.add(param1);
      }
      
      public function processContinuousCollision() 
      {
         var _loc1_:IListIterator = null;
         var _loc2_:ColliderTimelineAction = null;
         if(mContinuousCollisions.size > 0)
         {
            _loc1_ = ASCompat.reinterpretAs(mContinuousCollisions.iterator() , IListIterator);
            while(_loc1_.hasNext())
            {
               _loc2_ = ASCompat.dynamicAs(_loc1_.next() , ColliderTimelineAction);
               if(!_loc2_.perFrameUpCall(this))
               {
                  mRemovalContinuous.add(_loc2_);
               }
            }
            _loc1_ = ASCompat.reinterpretAs(mRemovalContinuous.iterator() , IListIterator);
            while(_loc1_.hasNext())
            {
               _loc2_ = ASCompat.dynamicAs(_loc1_.next() , ColliderTimelineAction);
               mContinuousCollisions.remove(_loc2_);
            }
            mRemovalContinuous.clear();
         }
      }
   }


