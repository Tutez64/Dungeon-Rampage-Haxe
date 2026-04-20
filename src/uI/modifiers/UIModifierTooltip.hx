package uI.modifiers
;
   import brain.assetRepository.SwfAsset;
   import brain.sceneGraph.SceneGraphComponent;
   import facade.DBFacade;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
    class UIModifierTooltip extends MovieClip
   {
      
      public var mRoot:MovieClip;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:SwfAsset, param4:String, param5:String)
      {
         super();
         var _loc6_= param3.getClass("modifier_tooltip");
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []) , MovieClip);
         ASCompat.setProperty((mRoot : ASAny).title_label, "text", param4.toUpperCase());
         ASCompat.setProperty((mRoot : ASAny).title_description, "text", param5);
         mRoot.mouseChildren = false;
         mRoot.mouseEnabled = false;
         param2.addChild(mRoot);
         var _loc7_= param2.localToGlobal(new Point());
         mRoot.x = _loc7_.x;
         mRoot.y = _loc7_.y + 20;
         mSceneGraphComponent = new SceneGraphComponent(param1,"UIModifierTooltip");
         mSceneGraphComponent.addChild(mRoot,(107 : UInt));
      }
      
      public function show() 
      {
         mRoot.visible = true;
      }
      
      public function hide() 
      {
         mRoot.visible = false;
      }
      
      public function destroy() 
      {
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mRoot = null;
      }
   }


