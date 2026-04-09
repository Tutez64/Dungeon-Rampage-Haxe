package brain.render
;
   import brain.utils.MemoryTracker;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import org.as3commons.collections.utils.ArrayUtils;

import org.as3commons.collections.framework.IComparator;
   
    class Layer extends Sprite
   {
      
      var mComparator:ChildComparator;
      
      var mSortIndex:Int = 0;
      
      public function new(param1:Int = 0)
      {
         super();
         mComparator = new ChildComparator();
         this.mouseEnabled = false;
         mSortIndex = param1;
         MemoryTracker.track(this,"Layer sortIndex=" + param1 + " - created in Layer()","brain");
      }
      
      @:isVar public var sortIndex(get,never):Int;
public function  get_sortIndex() : Int
      {
         return mSortIndex;
      }
      
      function fixChildIndex(param1:DisplayObject, param2:Int, param3:Array<ASAny>) 
      {
         if(this.getChildAt(param2) != param1)
         {
            this.setChildIndex(param1,param2);
         }
      }
      
      public function sortLayer() 
      {
         var _loc2_= 0;
         if(this.numChildren == 0)
         {
            return;
         }
         var _loc1_= ASCompat.allocArray(this.numChildren);
         _loc2_ = 0;
         while(_loc2_ < this.numChildren)
         {
            _loc1_[_loc2_] = getChildAt(_loc2_);
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
         ArrayUtils.insertionSort(_loc1_,mComparator);
         ASCompat.ASArray.forEach(_loc1_, fixChildIndex,this);
      }
      
      public function render() 
      {
      }
      
      public function destroy() 
      {
         mComparator = null;
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }
   }


private class ChildComparator implements IComparator
{
   
   public function new()
   {
      
   }
   
   public function compare(param1:ASAny, param2:ASAny) : Int
   {
      if(param1.y == param2.y)
      {
         if(param1.x == param2.x)
         {
            if(param1.height == param2.height)
            {
               return 0;
            }
            return param1.height > param2.height ? -1 : 1;
         }
         return param2.x < param1.x ? -1 : 1;
      }
      return param1.y < param2.y ? -1 : 1;
   }
}
