package brain.render
;
   import brain.utils.MemoryTracker;
   import flash.display.DisplayObject;
   
    class SortOnAddLayer extends Layer
   {
      
      var mNeedsSort:Bool = false;
      
      public function new(param1:Int = 0)
      {
         super(param1);
         MemoryTracker.track(this,"SortOnAddLayer sortIndex=" + param1 + " - created in SortOnAddLayer()","brain");
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         super.addChild(param1);
         mNeedsSort = true;
         return param1;
      }
      
      override public function addChildAt(param1:DisplayObject, param2:Int) : DisplayObject
      {
         super.addChildAt(param1,param2);
         mNeedsSort = true;
         return param1;
      }
      
      override public function render() 
      {
         if(mNeedsSort)
         {
            this.sortLayer();
            mNeedsSort = false;
         }
      }
   }


