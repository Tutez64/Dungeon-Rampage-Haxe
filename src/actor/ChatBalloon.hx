package actor
;
   import brain.assetRepository.SwfAsset;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
    class ChatBalloon extends Sprite
   {
      
      var mText:TextField;
      
      var mTypingClip:MovieClip;
      
      var mBubbleSmall:MovieClip;
      
      var mBubbleMedium:MovieClip;
      
      var mBubbleMediumScaledDown:MovieClip;
      
      var mBubbleLargeScaledDown:MovieClip;
      
      var mIsInitialized:Bool = false;
      
      public function new()
      {
         super();
      }
      
      public function initializeChatBalloon(param1:SwfAsset, param2:MovieClip = null) 
      {
         mTypingClip = param2;
         var _loc3_= param1.getClass("UI_speechbubble");
         mBubbleSmall = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
         _loc3_ = param1.getClass("UI_speechbubble_02");
         mBubbleMedium = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
         _loc3_ = param1.getClass("UI_speechbubble_03");
         mBubbleMediumScaledDown = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
         _loc3_ = param1.getClass("UI_speechbubble_04");
         mBubbleLargeScaledDown = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
         if(mTypingClip != null)
         {
            addChild(mTypingClip);
            hidePlayerTyping();
         }
         mIsInitialized = true;
      }
      
      public function showPlayerTyping() 
      {
         mTypingClip.visible = true;
      }
      
      public function hidePlayerTyping() 
      {
         mTypingClip.visible = false;
      }
      
      public function showBalloon() 
      {
         this.visible = true;
      }
      
      public function hideBalloon() 
      {
         this.visible = false;
      }
      
            
      @:isVar public var text(get,set):String;
public function  set_text(param1:String) :String      {
         var _loc2_:MovieClip = null;
         if(mIsInitialized)
         {
            if(mText != null)
            {
               mText.parent.parent.removeChild(mText.parent);
            }
            _loc2_ = mBubbleSmall;
            mText = ASCompat.dynamicAs((_loc2_ : ASAny).chatMessage, flash.text.TextField);
            mText.text = param1;
            if(mText.numLines > 3)
            {
               _loc2_ = mBubbleMedium;
            }
            mText = ASCompat.dynamicAs((_loc2_ : ASAny).chatMessage, flash.text.TextField);
            mText.text = param1;
            if(mText.numLines > 4)
            {
               _loc2_ = mBubbleMediumScaledDown;
            }
            mText = ASCompat.dynamicAs((_loc2_ : ASAny).chatMessage, flash.text.TextField);
            mText.text = param1;
            if(mText.numLines > 6)
            {
               _loc2_ = mBubbleLargeScaledDown;
            }
            mText = ASCompat.dynamicAs((_loc2_ : ASAny).chatMessage, flash.text.TextField);
            mText.text = param1;
            addChild(_loc2_);
            _loc2_.addChild(mText);
         }
return param1;
      }
function  get_text() : String
      {
         if(mText != null)
         {
            return mText.text;
         }
         return "";
      }
   }


