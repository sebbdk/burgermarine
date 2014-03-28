package dk.sebb.tiled.mobs
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	public class Mob extends MovieClip
	{
		public var body:Body;
		public var poly:Polygon;
		public var animator:MovieClip;

		public function Mob(type:BodyType = null)
		{
			super();
			body = new Body(type || BodyType.DYNAMIC, new Vec2(50, 50));
		}
		
		public function update():void {
			x = body.position.x;
			y = body.position.y;
			rotation = body.rotation;
		} 
	}
}