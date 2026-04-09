package town
;
   import facade.DBFacade;
   import facade.Locale;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
    class CreditsTownSubState extends TownSubState
   {
      
      static inline final SCROLL_SPEED= (250 : UInt);
      
      static inline final BITMAP_SCALE= (2 : UInt);
      
      static inline final BOTTOM_OF_THE_SCREEN_Y= (603 : UInt);
      
      static inline final KICKSTARTER_BACKER_HEADER_STRING= "Kickstarters Backers!";
      
      public static inline final NAME= "CreditsTownSubState";
      
      static final Headers:Vector<String> = Vector.ofArray(["Dungeon Rampage\'s Revivalist","Gamebreaking Studios","Original Developers","Special Thanks","Additional Thanks","Kickstarters Backers!"]);
      
      var mHeaderLines:Vector<Int> = new Vector();
      
      var mTween:TweenMax;
      
      var mFile:File;
      
      var mFileStream:FileStream;
      
      var mFileContents:String;
      
      var mHeaderFormat:TextFormat;
      
      var mDevFormat:TextFormat;
      
      var mBitMapData:BitmapData;
      
      var mBitMapMatrix:Matrix;
      
      var mBitMapCreator:Bitmap;
      
      var mCreditsBitMap:Bitmap;
      
      public function new(param1:DBFacade, param2:TownStateMachine)
      {
         super(param1,param2,"CreditsTownSubState");
      }
      
      override function setupState() 
      {
         super.setupState();
         mHeaderFormat = new TextFormat();
         mHeaderFormat.color = 16711680;
         mHeaderFormat.bold = true;
         mHeaderFormat.size = 40;
         mDevFormat = new TextFormat();
         mDevFormat.size = 20;
      }
      
      override public function enterState() 
      {
         super.enterState();
         mFile = File.applicationDirectory.resolvePath("Resources/credits.txt");
         mFileStream = new FileStream();
         mFileStream.open(mFile,flash.filesystem.FileMode.READ);
         mFileContents = mFileStream.readUTFBytes(mFileStream.bytesAvailable);
         mFileStream.close();
         mTownStateMachine.townHeader.showCloseButton(true);
         mTownStateMachine.townHeader.title = Locale.getString("CREDITS_HEADER");
         ASCompat.setProperty((mRootMovieClip : ASAny).label, "text", mFileContents);
         ASCompat.setProperty((mRootMovieClip : ASAny).label, "selectable", false);
         ASCompat.setProperty((mRootMovieClip : ASAny).label, "autoSize", "center");
         applyHeaderFormatting();
         mCreditsBitMap = textFieldToBitmap(ASCompat.dynamicAs((mRootMovieClip : ASAny).label, flash.text.TextField));
         mRootMovieClip.addChild(mCreditsBitMap);
         ASCompat.setProperty((mRootMovieClip : ASAny).label, "visible", false);
         mCreditsBitMap.y = 603 + 100;
         mCreditsBitMap.x = ASCompat.toNumberField((mRootMovieClip : ASAny).label, "x");
         mTween = TweenMax.to(mCreditsBitMap,250,{
            "y":603 - ASCompat.toNumberField((mRootMovieClip : ASAny).label, "height"),
            "ease":Linear
         });
         mRoot.addEventListener("mouseUp",resumeAutoScroll);
         mRoot.addEventListener("mouseWheel",onScrollWheel);
         mRoot.addEventListener("mouseDown",stopAutoScroll);
      }
      
      function textFieldToBitmap(param1:TextField) : Bitmap
      {
         mBitMapData = new BitmapData(Std.int(param1.width * 2),Std.int(param1.height * 2),true,(0 : UInt));
         mBitMapMatrix = new Matrix();
         mBitMapMatrix.scale(2,2);
         mBitMapData.draw(param1,mBitMapMatrix,null,null,null,true);
         mBitMapCreator = new Bitmap(mBitMapData,"auto",true);
         mBitMapCreator.scaleX = mBitMapCreator.scaleY = 1 / 2;
         return mBitMapCreator;
      }
      
      function applyHeaderFormatting() 
      {
         var _loc6_:String;
         var __ax4_iter_123:Vector<String>;
         var _loc5_= 0;
         var _loc3_:String = null;
         var _loc8_= 0;
         var _loc1_= 0;
         var _loc11_= 0;
         var _loc7_= 0;
         var _loc10_= 0;
         var _loc2_= 0;
         var _loc12_= 0;
         var _loc9_:Array<ASAny> = (cast mFileContents.split("\n"));
         var _loc4_= 0;
         _loc5_ = 0;
         while(_loc5_ < _loc9_.length)
         {
            _loc3_ = _loc9_[_loc5_];
            if(_loc3_.indexOf("Kickstarters Backers!") != -1)
            {
               _loc4_ = _loc5_;
            }
            __ax4_iter_123 = Headers;
            if (checkNullIteratee(__ax4_iter_123)) for (_tmp_ in __ax4_iter_123)
            {
               _loc6_ = _tmp_;
               if(_loc3_.indexOf(_loc6_) != -1)
               {
                  mHeaderLines.push(_loc5_);
               }
            }
            _loc5_++;
         }
         _loc8_ = 0;
         while(_loc8_ <= _loc4_)
         {
            _loc1_ = ASCompat.toInt((mRootMovieClip : ASAny).label.getLineOffset(_loc8_));
            _loc11_ = ASCompat.toInt((mRootMovieClip : ASAny).label.getLineLength(_loc8_));
            (mRootMovieClip : ASAny).label.setTextFormat(mDevFormat,_loc1_,_loc1_ + _loc11_);
            _loc8_++;
         }
         _loc7_ = 0;
         while(_loc7_ < mHeaderLines.length)
         {
            _loc10_ = mHeaderLines[_loc7_];
            _loc2_ = ASCompat.toInt((mRootMovieClip : ASAny).label.getLineOffset(_loc10_));
            _loc12_ = ASCompat.toInt((mRootMovieClip : ASAny).label.getLineLength(_loc10_));
            (mRootMovieClip : ASAny).label.setTextFormat(mHeaderFormat,_loc2_,_loc2_ + _loc12_);
            _loc7_++;
         }
      }
      
      function onScrollWheel(param1:MouseEvent) 
      {
         if(param1.delta > 0)
         {
            mTween.reverse();
         }
         else if(param1.delta < 0)
         {
            mTween.play();
         }
      }
      
      function resumeAutoScroll(param1:MouseEvent) 
      {
         mTween.resume();
      }
      
      function stopAutoScroll(param1:MouseEvent) 
      {
         mTween.pause();
      }
      
      override public function exitState() 
      {
         super.exitState();
         mRoot.removeEventListener("mouseDown",stopAutoScroll);
         mRoot.removeEventListener("mouseUp",resumeAutoScroll);
         mRoot.removeEventListener("mouseWheel",onScrollWheel);
         mBitMapData.dispose();
         mRootMovieClip.removeChild(mCreditsBitMap);
         mBitMapData = null;
         mBitMapMatrix = null;
         mBitMapCreator = null;
         mCreditsBitMap = null;
         mFile = null;
         mFileStream = null;
         mFileContents = null;
         if(mTween != null)
         {
            mTween.kill();
         }
      }
      
      override public function destroy() 
      {
         mHeaderLines = null;
         mHeaderFormat = null;
         mDevFormat = null;
         super.destroy();
      }
   }


