package dk.sebb.tiled.mobs
{
	import flash.display.DisplayObject;
	import flash.ui.Keyboard;
	
	import Anime.charAnimation;
	
	import dk.sebb.util.Key;
	
	import nape.callbacks.CbType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	public class Player extends TileMob
	{
		public var vaultForce:Vec2 = Vec2.get();
		public static var collisionType:CbType = new CbType();
		
		public var currentAnimation:String = "run_down";
		
		public function Player()
		{
			super(null, 32, 0x00DD00);
			
			body = new Body(BodyType.DYNAMIC, new Vec2(0, 0));
			poly = new Polygon(Polygon.box(10,18));
			body.shapes.add(poly);
			body.allowRotation = false;
			body.cbTypes.add(collisionType);
		}
		
		public override function draw():void {
			animator = new charAnimation();
			animator.x = -10;
			animator.y = -25;
			animator.scaleX = 2;
			animator.scaleY = 2;
			addChild(animator);
		}
		
		public override function update():void {
			super.update();
			updateKinematics();
			
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
		
		private function updateKinematics():void {
			var kx:int = 0;
			var ky:int = 0;
			
			var vel:int = 80;
			
			if(Key.isDown(Keyboard.D)) {
				kx += vel;
			}
			
			if(Key.isDown(Keyboard.A)) {
				kx += -vel;
			}
			
			if(Key.isDown(Keyboard.W)) {
				ky += -vel;
			}
			
			if(Key.isDown(Keyboard.S)) {
				ky += vel;
			}
			
			var vec:Vec2 = body.localVectorToWorld(new Vec2(kx, ky));
			body.force = vec;
			//if(kx == 0 && ky == 0) {
				//vec.setxy(kx * 0.9, ky * 0.9)
				//body.velocity = vec;
			//}
			//body.applyImpulse(vec);
			
			body.velocity = vec;
			body.kinematicVel= new Vec2(-kx*3, -ky*3);
			//trace(body.kinematicVel);
			//body.kinematicVel.x -= vaultForce.x * 2;
			//body.kinematicVel.y -= vaultForce.y * 2;
			
			var isMoving:Boolean = (ky !== 0 || kx !== 0);

			if(!isMoving && currentAnimation != "") {
				animator.gotoAndStop(currentAnimation);
				currentAnimation = "";
			}
			


			if(isMoving && kx < 0) {
				this.scaleX = 1;
			} else if(isMoving) {
				this.scaleX = -1;
			}
			
			if(isMoving){
				if(vec.x != 0 && currentAnimation != 'run_horizontal') {
					animator.gotoAndPlay('run_horizontal');
					currentAnimation = 'run_horizontal';
				} else if(vec.x === 0 && vec.y > 0 && currentAnimation != 'run_down'){
					animator.gotoAndPlay('run_down');
					currentAnimation = 'run_down';
				} else if(vec.x === 0 && vec.y < 0 && currentAnimation != 'run_up') {
					animator.gotoAndPlay('run_up');
					currentAnimation = 'run_up';
				}
				
				
				//animator.gotoAndPlay('run_horizontal');
				//currentAnimation
			}
		}
	}
}