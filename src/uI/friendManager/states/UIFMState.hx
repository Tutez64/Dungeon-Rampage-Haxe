package uI.friendManager.states
;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import town.TownStateMachine;
   import uI.friendManager.UIFriendManager;
   import flash.display.MovieClip;
   
    class UIFMState
   {
      
      var mDBFacade:DBFacade;
      
      var mUIFriendManager:UIFriendManager;
      
      var mTownStateMachine:TownStateMachine;
      
      public function new(param1:DBFacade, param2:UIFriendManager, param3:TownStateMachine)
      {
         
         mDBFacade = param1;
         mUIFriendManager = param2;
         mTownStateMachine = param3;
      }
      
      public function enter() 
      {
      }
      
      public function exit() 
      {
      }
      
      public function createButton(param1:String, param2:String, param3:Int, param4:Int, param5:ASFunction) : UIButton
      {
         var _loc7_= mTownStateMachine.getTownAsset(param1);
         var _loc8_= ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []) , MovieClip);
         var _loc6_= new UIButton(mDBFacade,_loc8_);
         _loc6_.releaseCallback = param5;
         _loc8_.x = param3;
         _loc8_.y = param4;
         _loc6_.root.scaleY = _loc6_.root.scaleX = 1.8;
         _loc6_.label.text = param2;
         mUIFriendManager.addToUI(_loc6_.root);
         return _loc6_;
      }
   }


