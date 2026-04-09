package com.junkbyte.console.core
;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.GraphGroup;
   import com.junkbyte.console.vos.GraphInterest;
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.utils.ByteArray;
   
    class Graphing extends ConsoleCore
   {
      
      var _groups:Array<ASAny>;
      
      var _map:ASObject;
      
      var _fpsGroup:GraphGroup;
      
      var _memGroup:GraphGroup;
      
      var _hadGraph:Bool = false;
      
      var _previousTime:Float = -1;
      
      public function new(param1:Console)
      {
         var m= param1;
         this._groups = [];
         this._map = {};
         super(m);
         remoter.registerCallback("fps",function(param1:ByteArray)
         {
            fpsMonitor = param1.readBoolean();
         });
         remoter.registerCallback("mem",function(param1:ByteArray)
         {
            memoryMonitor = param1.readBoolean();
         });
         remoter.registerCallback("removeGroup",function(param1:ByteArray)
         {
            removeGroup(param1.readUTF());
         });
         remoter.registerCallback("graph",this.handleRemoteGraph,true);
      }
      
      public function add(param1:String, param2:ASObject, param3:String, param4:Float = -1, param5:String = null, param6:Rectangle = null, param7:Bool = false) 
      {
         var group:GraphGroup;
         var interests:Array<ASAny>;
         var interest:GraphInterest;
         var v:Float;
         var newGroup= false;
         var i:GraphInterest = null;
         var n= param1;
         var obj:ASObject = param2;
         var prop= param3;
         var col= param4;
         var key= param5;
         var rect= param6;
         var inverse= param7;
         if(obj == null)
         {
            report("ERROR: Graph [" + n + "] received a null object to graph property [" + prop + "].",10);
            return;
         }
         group = ASCompat.dynamicAs(this._map[n], com.junkbyte.console.vos.GraphGroup);
         if(group == null)
         {
            newGroup = true;
            group = new GraphGroup(n);
         }
         interests = group.interests;
         if(Math.isNaN(col) || col < 0)
         {
            if(interests.length <= 5)
            {
               col = ASCompat.toNumber((config.style : ASAny)["priority" + (10 - interests.length * 2)]);
            }
            else
            {
               col = Math.random() * 16777215;
            }
         }
         if(key == null)
         {
            key = prop;
         }
         if (checkNullIteratee(interests)) for (_tmp_ in interests)
         {
            i  = ASCompat.dynamicAs(_tmp_, com.junkbyte.console.vos.GraphInterest);
            if(i.key == key)
            {
               report("Graph with key [" + key + "] already exists in [" + n + "]",10);
               return;
            }
         }
         if(rect != null)
         {
            group.rect = rect;
         }
         if(inverse)
         {
            group.inv = inverse;
         }
         interest = new GraphInterest(key,col);
         v = Math.NaN;
         try
         {
            v = interest.setObject(obj,prop);
         }
         catch(e:Dynamic)
         {
            report("Error with graph value for [" + key + "] in [" + n + "]. " + e,10);
            return;
         }
         if(Math.isNaN(v))
         {
            report("Graph value for key [" + key + "] in [" + n + "] is not a number (NaN).",10);
         }
         else
         {
            group.interests.push(interest);
            if(newGroup)
            {
               this._map[n] = group;
               this._groups.push(group);
            }
         }
      }
      
      public function fixRange(param1:String, param2:Float = null, param3:Float = null) 
{
         if (param2 == null) param2 = Math.NaN;
         if (param3 == null) param3 = Math.NaN;
         var _loc4_= ASCompat.dynamicAs(this._map[param1], com.junkbyte.console.vos.GraphGroup);
         if(_loc4_ == null)
         {
            return;
         }
         _loc4_.low = param2;
         _loc4_.hi = param3;
         _loc4_.fixed = !(Math.isNaN(param2) || Math.isNaN(param3));
      }
      
      public function remove(param1:String, param2:ASObject = null, param3:String = null) 
      {
         var _loc4_:Array<ASAny> = null;
         var _loc5_= 0;
         var _loc6_:GraphInterest = null;
         if(param2 == null && param3 == null)
         {
            this.removeGroup(param1);
         }
         else if(ASCompat.toBool(this._map[param1]))
         {
            _loc4_ = ASCompat.dynamicAs(this._map[param1].interests, Array);
            _loc5_ = _loc4_.length - 1;
            while(_loc5_ >= 0)
            {
               _loc6_ = ASCompat.dynamicAs(_loc4_[_loc5_], com.junkbyte.console.vos.GraphInterest);
               if((param2 == null || _loc6_.obj == param2) && (param3 == null || _loc6_.prop == param3))
               {
                  _loc4_.splice(_loc5_,(1 : UInt));
               }
               _loc5_--;
            }
            if(_loc4_.length == 0)
            {
               this.removeGroup(param1);
            }
         }
      }
      
      function removeGroup(param1:String) 
      {
         var _loc2_:ByteArray = null;
         var _loc3_:GraphGroup = null;
         var _loc4_= 0;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(param1);
            remoter.send("removeGroup",_loc2_);
         }
         else
         {
            _loc3_ = ASCompat.dynamicAs(this._map[param1], com.junkbyte.console.vos.GraphGroup);
            _loc4_ = this._groups.indexOf(_loc3_);
            if(_loc4_ >= 0)
            {
               this._groups.splice(_loc4_,(1 : UInt));
            }
            ASCompat.deleteProperty(this._map, param1);
         }
      }
      
            
      @:isVar public var fpsMonitor(get,set):Bool;
public function  get_fpsMonitor() : Bool
      {
         if(remoter.remoting == Remoting.RECIEVER)
         {
            return console.panels.fpsMonitor;
         }
         return this._fpsGroup != null;
      }
function  set_fpsMonitor(param1:Bool) :Bool      {
         var _loc2_:ByteArray = null;
         var _loc3_= 0;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeBoolean(param1);
            remoter.send("fps",_loc2_);
         }
         else if(param1 != this.fpsMonitor)
         {
            if(param1)
            {
               this._fpsGroup = this.addSpecialGroup((GraphGroup.FPS : Int));
               this._fpsGroup.low = 0;
               this._fpsGroup.fixed = true;
               this._fpsGroup.averaging = (30 : UInt);
            }
            else
            {
               this._previousTime = -1;
               _loc3_ = this._groups.indexOf(this._fpsGroup);
               if(_loc3_ >= 0)
               {
                  this._groups.splice(_loc3_,(1 : UInt));
               }
               this._fpsGroup = null;
            }
            console.panels.mainPanel.updateMenu();
         }
return param1;
      }
      
            
      @:isVar public var memoryMonitor(get,set):Bool;
public function  get_memoryMonitor() : Bool
      {
         if(remoter.remoting == Remoting.RECIEVER)
         {
            return console.panels.memoryMonitor;
         }
         return this._memGroup != null;
      }
function  set_memoryMonitor(param1:Bool) :Bool      {
         var _loc2_:ByteArray = null;
         var _loc3_= 0;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeBoolean(param1);
            remoter.send("mem",_loc2_);
         }
         else if(param1 != this.memoryMonitor)
         {
            if(param1)
            {
               this._memGroup = this.addSpecialGroup((GraphGroup.MEM : Int));
               this._memGroup.freq = 20;
            }
            else
            {
               _loc3_ = this._groups.indexOf(this._memGroup);
               if(_loc3_ >= 0)
               {
                  this._groups.splice(_loc3_,(1 : UInt));
               }
               this._memGroup = null;
            }
            console.panels.mainPanel.updateMenu();
         }
return param1;
      }
      
      function addSpecialGroup(param1:Int) : GraphGroup
      {
         var _loc2_= new GraphGroup("special");
         _loc2_.type = (param1 : UInt);
         this._groups.push(_loc2_);
         var _loc3_= new GraphInterest("special");
         if((param1 : UInt) == GraphGroup.FPS)
         {
            _loc3_.col = 16724787;
         }
         else
         {
            _loc3_.col = 5267711;
         }
         _loc2_.interests.push(_loc3_);
         return _loc2_;
      }
      
      public function update(param1:Float = 0) : Array<ASAny>
      {
         var _loc2_:GraphInterest = null;
         var _loc3_= Math.NaN;
         var _loc4_:GraphGroup = null;
         var _loc5_= false;
         var _loc6_= (0 : UInt);
         var _loc7_= (0 : UInt);
         var _loc8_:Array<ASAny> = null;
         var _loc9_= 0;
         var _loc10_= Math.NaN;
         var _loc11_= (0 : UInt);
         var _loc12_:ByteArray = null;
         var _loc13_= (0 : UInt);
         final __ax4_iter_90 = this._groups;
         if (checkNullIteratee(__ax4_iter_90)) for (_tmp_ in __ax4_iter_90)
         {
            _loc4_  = ASCompat.dynamicAs(_tmp_, com.junkbyte.console.vos.GraphGroup);
            _loc5_ = true;
            if(_loc4_.freq > 1)
            {
               ++_loc4_.idle;
               if(_loc4_.idle < _loc4_.freq)
               {
                  _loc5_ = false;
               }
               else
               {
                  _loc4_.idle = 0;
               }
            }
            if(_loc5_)
            {
               _loc6_ = _loc4_.type;
               _loc7_ = _loc4_.averaging;
               _loc8_ = _loc4_.interests;
               if(_loc6_ == GraphGroup.FPS)
               {
                  _loc4_.hi = param1;
                  _loc2_ = ASCompat.dynamicAs(_loc8_[0], com.junkbyte.console.vos.GraphInterest);
                  _loc9_ = flash.Lib.getTimer();
                  if(this._previousTime >= 0)
                  {
                     _loc10_ = _loc9_ - this._previousTime;
                     _loc3_ = 1000 / _loc10_;
                     _loc2_.setValue(_loc3_,_loc7_);
                  }
                  this._previousTime = _loc9_;
               }
               else if(_loc6_ == GraphGroup.MEM)
               {
                  _loc2_ = ASCompat.dynamicAs(_loc8_[0], com.junkbyte.console.vos.GraphInterest);
                  _loc3_ = Math.fround(System.totalMemory / 10485.76) / 100;
                  _loc4_.updateMinMax(_loc3_);
                  _loc2_.setValue(_loc3_,_loc7_);
               }
               else
               {
                  this.updateExternalGraphGroup(_loc4_);
               }
            }
         }
         if(remoter.canSend && (this._hadGraph || this._groups.length != 0))
         {
            _loc11_ = (this._groups.length : UInt);
            _loc12_ = new ByteArray();
            _loc13_ = (0 : UInt);
            while(_loc13_ < _loc11_)
            {
               cast(this._groups[(_loc13_ : Int)], GraphGroup).toBytes(_loc12_);
               _loc13_++;
            }
            remoter.send("graph",_loc12_);
            this._hadGraph = this._groups.length > 0;
         }
         return this._groups;
      }
      
      function updateExternalGraphGroup(param1:GraphGroup) 
      {
         var i:GraphInterest = null;
         var v= Math.NaN;
         var group= param1;
         final __ax4_iter_91 = group.interests;
         if (checkNullIteratee(__ax4_iter_91)) for (_tmp_ in __ax4_iter_91)
         {
            i  = ASCompat.dynamicAs(_tmp_, com.junkbyte.console.vos.GraphInterest);
            try
            {
               v = i.getCurrentValue();
               i.setValue(v,group.averaging);
            }
            catch(e:Dynamic)
            {
               report("Error with graph value for key [" + i.key + "] in [" + group.name + "]. " + e,10);
               remove(group.name,i.obj,i.prop);
            }
            group.updateMinMax(v);
         }
      }
      
      function handleRemoteGraph(param1:ByteArray = null) 
      {
         var _loc2_:Array<ASAny> = null;
         if(ASCompat.toBool(param1) && ASCompat.toBool(param1.length))
         {
            param1.position = (0 : UInt);
            _loc2_ = new Array<ASAny>();
            while(param1.bytesAvailable != 0)
            {
               _loc2_.push(GraphGroup.FromBytes(param1));
            }
            console.panels.updateGraphs(_loc2_);
         }
         else
         {
            console.panels.updateGraphs(new Array<ASAny>());
         }
      }
   }


