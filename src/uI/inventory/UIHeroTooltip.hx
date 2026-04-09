package uI.inventory
;
   import account.AvatarInfo;
   import facade.DBFacade;
   import gameMasterDictionary.GMHero;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UIHeroTooltip extends MovieClip
   {
      
      var mDBFacade:DBFacade;
      
      var mRoot:MovieClip;
      
      var mLabel:TextField;
      
      var mLevelLabel:TextField;
      
      var mDescriptionLabel:TextField;
      
      var mStar:MovieClip;
      
      public function new(param1:DBFacade, param2:Dynamic)
      {
         super();
         mDBFacade = param1;
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(param2, []), flash.display.MovieClip);
         this.addChild(mRoot);
         mLabel = ASCompat.dynamicAs((mRoot : ASAny).title_label, flash.text.TextField);
         mLevelLabel = ASCompat.dynamicAs((mRoot : ASAny).level_star_label, flash.text.TextField);
         mDescriptionLabel = ASCompat.dynamicAs((mRoot : ASAny).description_label, flash.text.TextField);
         mStar = ASCompat.dynamicAs((mRoot : ASAny).star, flash.display.MovieClip);
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      @:isVar public var ownedHero(never,set):AvatarInfo;
public function  set_ownedHero(param1:AvatarInfo) :AvatarInfo      {
         mLabel.text = param1.gmHero.Name.toUpperCase();
         mLevelLabel.text = Std.string(param1.level);
         mLevelLabel.visible = true;
         mStar.visible = true;
         mDescriptionLabel.visible = false;
return param1;
      }
      
      @:isVar public var unownedHero(never,set):GMHero;
public function  set_unownedHero(param1:GMHero) :GMHero      {
         mLabel.text = param1.Name.toUpperCase();
         mLevelLabel.visible = false;
         mStar.visible = false;
         mDescriptionLabel.text = "Not Unlocked";
         mDescriptionLabel.visible = true;
return param1;
      }
   }


