package dk.sebb.tiled.mobs
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;

	public class TileMob extends Mob
	{
		public var size:int;
		public var color:uint;
		
		public function TileMob(type:BodyType, size:int = 32, color:uint = 0x0000FF)
		{
			super(type);
			this.size = size;
			this.color = color;
			body = new Body(type || BodyType.DYNAMIC, new Vec2(0, 0));
			poly = new Polygon(Polygon.box(size,size));
			body.shapes.add(poly);
			
			draw();
		}
		
		public function draw():void {
			/*var rectangle:Shape = new Shape();
			rectangle.graphics.beginFill(color, 1);
			rectangle.graphics.drawRect(-size/2, -size/2, size, size );
			rectangle.graphics.endFill();
			addChild(rectangle);
			*/
		}
	}
}