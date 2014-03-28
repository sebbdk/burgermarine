package dk.sebb.tiled.mobs
{
	import dk.sebb.tiled.Level;
	import dk.sebb.tiled.layers.TMXObject;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	public class NPC extends Mob
	{
		public var object:TMXObject; 
		
		public var proximityPoly:Polygon;
		public var onEnterListener:InteractionListener;
		public var onLeaveListener:InteractionListener;
		public var collisionType:CbType = new CbType();
		
		public var playerInProximity:Boolean = false;
		
		public function NPC(object:TMXObject)
		{
			this.object = object;
			draw();
			
			body = new Body(BodyType.DYNAMIC, new Vec2(0, 0));
			body.type = BodyType.STATIC;
			body.allowRotation = false;
			body.cbTypes.add(collisionType);
			
			poly = new Polygon(Polygon.box(16, 16));
			body.shapes.add(poly);
			
			proximityPoly = new Polygon(Polygon.box(32, 32));
			proximityPoly.sensorEnabled = true;
			body.shapes.add(proximityPoly);
			
			onEnterListener = new InteractionListener(CbEvent.BEGIN, 
				InteractionType.SENSOR,
				collisionType,
				Player.collisionType,
				onPlayerEnter);
			
			Level.space.listeners.add(onEnterListener);
			
			onLeaveListener = new InteractionListener(CbEvent.END, 
				InteractionType.SENSOR,
				collisionType,
				Player.collisionType,
				onPlayerExit);
			
			Level.space.listeners.add(onLeaveListener);
		}
		
		private function onPlayerEnter(collision:InteractionCallback):void {
			trace("YOU ARE TOO CLOSE!!");
			if(object.onEnter) {
				Level.lua.doString(object.onEnter);
			}
			
			playerInProximity = true;
		}
		
		private function onPlayerExit(collision:InteractionCallback):void {
			trace("yes, get out of here you ruffian!");
			if(object.onExit) {
				Level.lua.doString(object.onExit);
			}
			
			playerInProximity = false;
		}
		
		public function draw():void {
			animator = new Humti();
			animator.scaleX = 2;
			animator.scaleY = 2;
			
			animator.x = (-animator.width/2);
			animator.y = (-animator.height) + 8;
			
			addChild(animator);
		}
		
		public override function update():void {
			super.update();
			
			if(parent) {
				for(var c:int = parent.numChildren-1; c >= 0; c--) {
					var child:DisplayObject = parent.getChildAt(c);
					if(child != this) {
						if(child.y > this.y && parent.getChildIndex(this) > c) {
							parent.swapChildren(this, child);
						}
						
						if(child.y < this.y && parent.getChildIndex(this) < c) {
							parent.swapChildren(this, child);
						}
						
					}
				}
			}
		}
	}
}