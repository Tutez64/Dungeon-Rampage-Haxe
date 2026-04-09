package uI.inventory
;
   import facade.DBFacade;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UITapHoldTooltip extends MovieClip
   {
      
      var mDBFacade:DBFacade;
      
      var mRoot:MovieClip;
      
      var mTitle:TextField;
      
      var mDescription:TextField;
      
      public function new(param1:DBFacade, param2:Dynamic)
      {
         super();
         mDBFacade = param1;
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(param2, []), flash.display.MovieClip);
         this.addChild(mRoot);
         mTitle = ASCompat.dynamicAs((mRoot : ASAny).title_label, flash.text.TextField);
         mDescription = ASCompat.dynamicAs((mRoot : ASAny).charge_description_label, flash.text.TextField);
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      public function setValues(param1:String, param2:String) 
      {
         mTitle.text = param1.toUpperCase();
         mDescription.text = param2;
      }
   }


