package sound
;
   import brain.logger.Logger;
   import brain.sound.SoundHandle;
   import brain.sound.SoundManager;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import org.as3commons.collections.Set;
   
    class DBSoundManager extends SoundManager
   {
      
      public static inline final MUSIC_MIXER_CATEGORY= "music";
      
      public static inline final SFX_MIXER_CATEGORY= "sfx";
      
      var mCurrentMusic:SoundHandle;
      
      public function new(param1:DBFacade)
      {
         super(param1);
         setVolumeScaleForCategory("music",DBGlobal.MUSIC_VOLUME);
         setVolumeScaleForCategory("sfx",DBGlobal.SFX_VOLUME);
      }
      
            
      @:isVar public var musicVolumeScale(get,set):Float;
public function  set_musicVolumeScale(param1:Float) :Float      {
         this.setVolumeScaleForCategory("music",param1);
return param1;
      }
function  get_musicVolumeScale() : Float
      {
         return getVolumeScaleForCategory("music");
      }
      
            
      @:isVar public var sfxVolumeScale(get,set):Float;
public function  set_sfxVolumeScale(param1:Float) :Float      {
         this.setVolumeScaleForCategory("sfx",param1);
return param1;
      }
function  get_sfxVolumeScale() : Float
      {
         return getVolumeScaleForCategory("sfx");
      }
      
      override public function registerSoundPlaying(param1:SoundHandle) 
      {
         if(param1.category == "music")
         {
            registerMusicPlaying(param1);
         }
         else
         {
            super.registerSoundPlaying(param1);
         }
      }
      
      function registerMusicPlaying(param1:SoundHandle) 
      {
         if(mCurrentMusic == null)
         {
            mCurrentMusic = param1;
            super.registerSoundPlaying(param1);
            return;
         }
         var _loc2_= ASCompat.dynamicAs(mSoundsDictionary.itemFor("music") , Set);
         if(!_loc2_.has(mCurrentMusic))
         {
            Logger.error("CurrentMusicHandle in DBSoundManager is not registered.");
            return;
         }
         mCurrentMusic.stop();
         mCurrentMusic = null;
         mCurrentMusic = param1;
         super.registerSoundPlaying(mCurrentMusic);
      }
      
      override public function unregisterSoundPlaying(param1:SoundHandle) 
      {
         if(param1.category == "music")
         {
            unregisterMusicPlaying(param1);
         }
         else
         {
            super.unregisterSoundPlaying(param1);
         }
      }
      
      function unregisterMusicPlaying(param1:SoundHandle) 
      {
         if(mCurrentMusic == null)
         {
            Logger.error("Trying to unregister music playing but mCurrentMusic is null");
            return;
         }
         mCurrentMusic = null;
         super.unregisterSoundPlaying(param1);
      }
   }


