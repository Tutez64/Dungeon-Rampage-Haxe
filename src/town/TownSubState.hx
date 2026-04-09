package town
;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.stateMachine.State;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
    class TownSubState extends State
   {
      
      static var FRIEND_NAME_HIGHLIGHT_COLOR:UInt = (16764232 : UInt);
      
      var mTownStateMachine:TownStateMachine;
      
      var mRoot:Sprite = new Sprite();
      
      var mRootMovieClip:MovieClip;
      
      var mHomeButton:UIButton;
      
      var mDBFacade:DBFacade;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mTimeEnter:Float = Math.NaN;
      
      public function new(param1:DBFacade, param2:TownStateMachine, param3:String)
      {
         super(param3);
         mDBFacade = param1;
         mTownStateMachine = param2;
      }
      
      override public function destroy() 
      {
         if(mHomeButton != null)
         {
            mHomeButton.destroy();
         }
         mTownStateMachine = null;
         mDBFacade = null;
         super.destroy();
      }
      
      @:isVar public var rootMovieClip(never,set):MovieClip;
public function  set_rootMovieClip(param1:MovieClip) :MovieClip      {
         mRootMovieClip = param1;
         mRoot.addChild(mRootMovieClip);
         setupState();
return param1;
      }
      
      function setupState() 
      {
      }
      
      override public function enterState() 
      {
         super.enterState();
         mDBFacade.mouseCursorManager.disable = false;
         mDBFacade.mouseCursorManager.pushMouseCursor("auto");
         mTimeEnter = mDBFacade.gameClock.realTime;
         mDBFacade.metrics.log("AreaEnter",{"areaType":this.name});
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mSceneGraphComponent.addChild(mRoot,(50 : UInt));
         if(mTownStateMachine.leaderboard != null)
         {
            mTownStateMachine.leaderboard.hidePopup();
         }
      }
      
      override public function exitState() 
      {
         mDBFacade.mouseCursorManager.popMouseCursor();
         var _loc1_= (Std.int((mDBFacade.gameClock.realTime - mTimeEnter) / 1000) : UInt);
         mDBFacade.metrics.log("AreaExit",{
            "areaType":this.name,
            "timeSpentSeconds":_loc1_
         });
         mSceneGraphComponent.removeChild(mRoot);
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         super.exitState();
      }
   }


