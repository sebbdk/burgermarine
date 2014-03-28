package dk.sebb.tiled
{
	import avmplus.getQualifiedClassName;
	
	import dk.sebb.tiled.layers.ImageLayer;
	import dk.sebb.tiled.layers.Layer;
	import dk.sebb.tiled.layers.ObjectLayer;
	import dk.sebb.tiled.layers.TMXObject;
	import dk.sebb.tiled.mobs.Mob;
	import dk.sebb.tiled.mobs.NPC;
	import dk.sebb.tiled.mobs.ObjMob;
	import dk.sebb.tiled.mobs.Player;
	import dk.sebb.tiled.mobs.TileMob;
	import dk.sebb.util.ShakeEffect;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import luaAlchemy.LuaAlchemy;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.space.Space;
	import nape.util.ShapeDebug;
	
	import net.hires.debug.Stats;
	
	public class Level extends MovieClip
	{
		public var debug:ShapeDebug;
		public var lastFrameTime:Number = 0;
		
		public static var data:LevelData;
		public static var space:Space = new Space(new Vec2(0, 0));
		public static var lua:LuaInterface = new LuaInterface();
		public static var infoBox:InfoBox = new InfoBox();
		public static var player:Player;

		public var screenShake:ShakeEffect;
		
		public static var instance:Level;
		
		public static var settings:Object = {
			debug:true,
			pause:false
		};
		
		public function Level() {			
			screenShake = new ShakeEffect();
			
			scaleX = 2;
			scaleY = 2;
			
			instance = this;
		}
		
		public function load(levelpath:String):void {
			unload();

			space.clear();
			data = new LevelData(levelpath);
			data.addEventListener(Event.COMPLETE, onLevelLoaded);
			data.load();
		}
		
		public function onLevelLoaded(evt:Event):void {
			//add layers!
			for each(var layer:Layer in data.tmxLoader.layers) {
				addChild(layer.displayObject);
			}
			
			//setup player
			player = player ? player:new Player();
			player.body.position = data.spawns[0];
			data.addMob(player);
			
			//setup mobs
			for each(var mob:Mob in data.mobs) {
				addChild(mob);
			}
			
			//setup info box
			parent.addChild(infoBox);
			
			//debug?
			if(settings.debug) {
				debug = new ShapeDebug(512, 512); //width/height not really important
				addChild(debug.display);
			}
			
			//debug
			if(settings.debug) {
				parent.addChild(new Stats());
			}
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			//start the game!
			addEventListener(Event.ENTER_FRAME, run);
			settings.pause = false;
		}
		
		public function unload():void {
			settings.pause = true;
			if(stage) {
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}

			removeEventListener(Event.ENTER_FRAME, run);
			removeChildren();
			
			if(data) {
				data.unload();
				data = null;
			}
		}
		
		public function onKeyUp(evt:KeyboardEvent):void {
			if(evt.keyCode === Keyboard.SPACE) {
				if(infoBox.hasConvo) {//the info box takes over input when active
					infoBox.convoNext();
				} else {//else just check mobs
					for each(var mob:Mob in data.mobs) {
						if(mob is NPC && NPC(mob).playerInProximity && NPC(mob).object.onActivate) {
							Level.lua.doString(NPC(mob).object.onActivate);
							return;
						}
					}
				}
			}		
		}
		
		public static function pause():void {
			settings.pause = true;
			
			for each(var mob:Mob in data.mobs) {
				mob.stop();
				if(mob.animator) {
					mob.animator.stop();
				}
			}
		}
		
		public static function unPause():void {
			settings.pause = false;
		}
		
		public function run(evt:Event = null):void {
			var deltaTime:Number = (getTimer() - lastFrameTime) / (1000/30);
			if(!settings.pause && deltaTime > 1) {
				//FIXX ME!
				space.step((1/30) * deltaTime, 10, 10);
				
				for each(var mob:Mob in data.mobs) {
					mob.update();
				}
				
				if(debug) {
					debug.clear();
					debug.draw(space);
				}
				
				//move "camera" onto player
				x = (-(player.body.position.x * scaleX) + stage.stageWidth/2) + screenShake.offSetX;
				y = (-(player.body.position.y * scaleY) + stage.stageHeight/2) + screenShake.offSetY;
					
				//update parallax
				for each(var layer:Layer in data.parallaxLayers) {
					var playerRatioX:Number = (player.body.position.x * scaleX) / (layer.displayObject.width * scaleX);
					layer.displayObject.x = ((this.width/2) * playerRatioX) * layer.offsetX;
					
					var playerRatioY:Number = (player.body.position.y * scaleY) / (layer.displayObject.height * scaleY);
					layer.displayObject.y = ((this.height/2) * playerRatioY) * layer.offsetY;
				}
			}
			if(deltaTime > 1) {
				lastFrameTime = getTimer();
			}
		}

	}
}