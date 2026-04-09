package brain.sound
;
   import brain.component.Component;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   
    class SoundComponent extends Component
   {
      
      var mSoundHandles:Set;
      
      public function new(param1:Facade)
      {
         super(param1);
         mSoundHandles = new Set();
      }
      
      public function playOneShot(param1:SoundAsset, param2:String, param3:Int = 0, param4:Float = 1, param5:Float = 0, param6:Float = 0) 
      {
         var _loc7_= new SoundHandle(mFacade.soundManager,mFacade,param1.sound,param2,null,false,param4,param5);
         MemoryTracker.track(_loc7_,"SoundHandle - one-shot, category: " + param2,"brain");
         _loc7_.play(param3,param6);
      }
      
      public function playManagedSound(param1:SoundAsset, param2:String, param3:Float = 1, param4:Float = 0) : SoundHandle
      {
         var soundAsset= param1;
         var category= param2;
         var volume= param3;
         var panning= param4;
         var soundHandle= new SoundHandle(mFacade.soundManager,mFacade,soundAsset.sound,category,function(param1:SoundHandle)
         {
            unregisterSoundHandle(param1);
         },true,volume,panning);
         MemoryTracker.track(soundHandle,"SoundHandle - managed, category: " + category,"brain");
         mSoundHandles.add(soundHandle);
         return soundHandle;
      }
      
      function unregisterSoundHandle(param1:SoundHandle) 
      {
         if(!mSoundHandles.has(param1))
         {
            Logger.warn("Trying to unregister soundHandle which does not exist in SoundComponent\'s set.");
            return;
         }
         mSoundHandles.remove(param1);
      }
      
      override public function destroy() 
      {
         var _loc1_:SoundHandle = null;
         var _loc2_= ASCompat.reinterpretAs(mSoundHandles.iterator() , ISetIterator);
         while(_loc2_.hasNext())
         {
            _loc1_ = ASCompat.dynamicAs(_loc2_.next(), brain.sound.SoundHandle);
            _loc1_.destroy();
         }
         mSoundHandles.clear();
         mSoundHandles = null;
      }
   }


