package brain.render
;
   import brain.clock.GameClock;
   import brain.utils.MemoryTracker;
   import flash.display.Sprite;
   import org.as3commons.collections.SortedMap;
   import org.as3commons.collections.framework.core.SortedMapIterator;

import org.as3commons.collections.framework.IComparator;
   
    class LayerGroup extends Sprite
   {
      
      var mTransformNode:Sprite;
      
      var mLayers:SortedMap = new SortedMap(new LayerComparator());
      
      var mNeedsSort:Bool = false;
      
      public function new()
      {
         super();
         mTransformNode = new Sprite();
         mTransformNode.name = "LayerGroup.transformNode";
         this.addChild(mTransformNode);
         MemoryTracker.track(this,"LayerGroup - created in LayerGroup()","brain");
      }
      
      @:isVar public var transformNode(get,never):Sprite;
public function  get_transformNode() : Sprite
      {
         return mTransformNode;
      }
      
      function markDirty() 
      {
         mNeedsSort = true;
      }
      
      public function getLayer(param1:Int) : Layer
      {
         return ASCompat.dynamicAs(mLayers.itemFor(param1), brain.render.Layer);
      }
      
      public function addLayer(param1:Layer) 
      {
         if(mLayers.has(param1))
         {
            throw new Error("Layer already in LayerGroup");
         }
         mLayers.add(param1.sortIndex,param1);
         mTransformNode.addChild(param1);
         this.markDirty();
      }
      
      public function removeLayer(param1:Layer) : Bool
      {
         var _loc2_= mLayers.remove(param1);
         mTransformNode.removeChild(param1);
         this.markDirty();
         return _loc2_;
      }
      
      function sortLayers() 
      {
         var _loc3_:Layer = null;
         var _loc1_= ASCompat.reinterpretAs(mLayers.iterator() , SortedMapIterator);
         var _loc2_= 0;
         while(_loc1_.hasNext())
         {
            _loc3_ = ASCompat.dynamicAs(_loc1_.next(), brain.render.Layer);
            if(mTransformNode.getChildAt(_loc2_) != _loc3_)
            {
               mTransformNode.setChildIndex(_loc3_,_loc2_);
            }
            _loc2_++;
         }
         mNeedsSort = false;
      }
      
      public function onFrame(param1:GameClock) 
      {
         var _loc3_:Layer = null;
         if(this.stage == null)
         {
            return;
         }
         if(mNeedsSort)
         {
            sortLayers();
         }
         var _loc2_= ASCompat.reinterpretAs(mLayers.iterator() , SortedMapIterator);
         while(_loc2_.hasNext())
         {
            _loc3_ = ASCompat.dynamicAs(_loc2_.next(), brain.render.Layer);
            _loc3_.render();
         }
      }
      
      public function destroy() 
      {
         var _loc2_:Layer = null;
         var _loc1_= ASCompat.reinterpretAs(mLayers.iterator() , SortedMapIterator);
         while(_loc1_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc1_.next(), brain.render.Layer);
            _loc2_.destroy();
         }
         mLayers.clear();
         mLayers = null;
         if(mTransformNode.parent != null)
         {
            mTransformNode.parent.removeChild(mTransformNode);
         }
      }
   }


private class LayerComparator implements IComparator
{
   
   public function new()
   {
      
   }
   
   public function compare(param1:ASAny, param2:ASAny) : Int
   {
      if(param1.sortIndex < param2.sortIndex)
      {
         return -1;
      }
      if(param1.sortIndex > param2.sortIndex)
      {
         return 1;
      }
      return 0;
   }
}
