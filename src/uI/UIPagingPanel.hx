package uI
;
   import brain.uI.UIButton;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import flash.display.MovieClip;
   
    class UIPagingPanel
   {
      
      var mDBFacade:DBFacade;
      
      var mRoot:MovieClip;
      
      var mCallback:ASFunction;
      
      var mNumPages:UInt = 0;
      
      var mCurrentPage:UInt = 0;
      
      var mPageLeftButton:UIButton;
      
      var mPageRightButton:UIButton;
      
      var mPageButtonClass:Dynamic;
      
      var mPageButtons:Vector<UIButton>;
      
      public function new(param1:DBFacade, param2:UInt, param3:MovieClip, param4:Dynamic, param5:ASFunction)
      {
         
         mDBFacade = param1;
         mNumPages = param2;
         mRoot = param3;
         mPageButtonClass = param4;
         mPageButtons = new Vector<UIButton>();
         mCurrentPage = (0 : UInt);
         mCallback = param5;
         this.setupUI(param3);
         updatePageArrows();
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         mCallback = null;
         mPageLeftButton.destroy();
         mPageRightButton.destroy();
      }
      
      @:isVar public var root(get,never):MovieClip;
public function  get_root() : MovieClip
      {
         return mRoot;
      }
      
            
      @:isVar public var visible(get,set):Bool;
public function  set_visible(param1:Bool) :Bool      {
         return mRoot.visible = param1;
      }
function  get_visible() : Bool
      {
         return mRoot.visible;
      }
      
            
      @:isVar public var numPages(get,set):UInt;
public function  set_numPages(param1:UInt) :UInt      {
         mNumPages = param1;
         this.updatePageArrows();
return param1;
      }
function  get_numPages() : UInt
      {
         return mNumPages;
      }
      
            
      @:isVar public var currentPage(get,set):UInt;
public function  set_currentPage(param1:UInt) :UInt      {
         if(param1 == mCurrentPage)
         {
            return param1;
         }
         mCurrentPage = param1;
         this.updatePageArrows();
return param1;
      }
function  get_currentPage() : UInt
      {
         return mCurrentPage;
      }
      
      public function dontKillUI() 
      {
         mPageLeftButton.dontKillMyChildren = true;
         mPageRightButton.dontKillMyChildren = true;
      }
      
      function setupUI(param1:MovieClip) 
      {
         mRoot = param1;
         mPageLeftButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).page_left, flash.display.MovieClip));
         mPageRightButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).page_right, flash.display.MovieClip));
         mPageLeftButton.releaseCallback = pageLeft;
         mPageRightButton.releaseCallback = pageRight;
         mPageLeftButton.enabled = false;
         mPageRightButton.enabled = false;
      }
      
      function pageLeft() 
      {
         this.currentPage = (Std.int(Math.max(0,mCurrentPage - 1)) : UInt);
         if(mCallback != null)
         {
            mCallback(mCurrentPage);
         }
      }
      
      function pageRight() 
      {
         this.currentPage = (Std.int(Math.min(mNumPages,mCurrentPage + 1)) : UInt);
         if(mCallback != null)
         {
            mCallback(mCurrentPage);
         }
      }
      
      function updatePageArrows() 
      {
         var pageButton:UIButton;
         var pageButtonMC:MovieClip;
         var PAD:UInt;
         var MAX_BUTTONS:UInt;
         var startPage:UInt;
         var endPage:UInt;
         var numPagesShowing:UInt;
         var even:Bool;
         var i:UInt;
         var buttonWidth:Float;
         var leftEdge:Float;
         var offset:Float;
         mPageLeftButton.enabled = mCurrentPage != 0;
         mPageRightButton.enabled = mCurrentPage < mNumPages - 1;
         final __ax4_iter_121 = mPageButtons;
         if (checkNullIteratee(__ax4_iter_121)) for (_tmp_ in __ax4_iter_121)
         {
            pageButton  = _tmp_;
            pageButton.detach();
            pageButton.destroy();
         }
         mPageButtons.length = 0;
         PAD = (8 : UInt);
         MAX_BUTTONS = (9 : UInt);
         startPage = (Std.int(Math.max(0,Math.min(mNumPages - MAX_BUTTONS,mCurrentPage - MAX_BUTTONS / 2 + 1))) : UInt);
         endPage = (Std.int(Math.min(startPage + MAX_BUTTONS,mNumPages)) : UInt);
         numPagesShowing = (endPage - startPage : UInt);
         even = numPagesShowing % 2 == 0;
         i = startPage;
         while(i < endPage)
         {
            pageButtonMC = ASCompat.dynamicAs(ASCompat.createInstance(mPageButtonClass, []), flash.display.MovieClip);
            mRoot.addChild(pageButtonMC);
            pageButton = new UIButton(mDBFacade,pageButtonMC);
            pageButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            pageButton.label.text = Std.string((i + 1));
            buttonWidth = pageButton.root.width + PAD;
            leftEdge = numPagesShowing * buttonWidth * -0.5;
            offset = even ? buttonWidth * 0.5 : 0;
            pageButton.root.x = leftEdge + offset + (i - startPage) * buttonWidth;
            ASCompat.setProperty(pageButton.root, "pageIndex", i);
            pageButton.releaseCallbackThis = function(param1:UIButton)
            {
               param1.bringToFront();
               currentPage = (ASCompat.toInt((param1.root : ASAny).pageIndex) : UInt);
               if(mCallback != null)
               {
                  mCallback(mCurrentPage);
               }
            };
            mPageButtons.push(pageButton);
            if(i == mCurrentPage)
            {
               pageButton.enabled = false;
               pageButton.root.scaleX = pageButton.root.scaleY = 1.2;
               pageButton.root.filters = cast([DBGlobal.UI_SELECTED_FILTER]);
            }
            else
            {
               pageButton.enabled = true;
               pageButton.root.scaleX = pageButton.root.scaleY = 1;
               pageButton.root.filters = cast([]);
            }
            i = i + 1;
         }
         if((mPageButtons.length : UInt) > mCurrentPage - startPage)
         {
            mPageButtons[(mCurrentPage - startPage : Int)].bringToFront();
         }
      }
   }


