package uI.infiniteIsland
;
   import com.maccherone.json.JSON;
   
    class II_ChampionsboardTopScore
   {
      
      public var name:String;
      
      public var score:Int = 0;
      
      public var skinId:Int = 0;
      
      var mWeaponsJson:Array<Dynamic>;
      
      public function new(param1:String, param2:Int, param3:Int, param4:String, param5:String, param6:String)
      {
         
         name = param1;
         score = param2;
         skinId = param3;
         mWeaponsJson = new Array<Dynamic>();
         if(param4 != null)
         {
            mWeaponsJson.push(com.maccherone.json.JSON.decode(param4));
         }
         else
         {
            mWeaponsJson.push(null);
         }
         if(param4 != null)
         {
            mWeaponsJson.push(com.maccherone.json.JSON.decode(param5));
         }
         else
         {
            mWeaponsJson.push(null);
         }
         if(param4 != null)
         {
            mWeaponsJson.push(com.maccherone.json.JSON.decode(param6));
         }
         else
         {
            mWeaponsJson.push(null);
         }
      }
      
      @:isVar public var weaponsJson(get,never):Array<Dynamic>;
public function  get_weaponsJson() : Array<Dynamic>
      {
         return mWeaponsJson;
      }
   }


