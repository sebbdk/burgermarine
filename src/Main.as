package
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import dk.sebb.tiled.Level;
	import dk.sebb.util.Key;
	
	[SWF(backgroundColor="#999999", frameRate="60", height="600", width="800", quality="HIGH")]
	public class Main extends Sprite
	{
		public var levelindex:int = -1;
		public var level:Level;
		public var levels:Array = [
			'../levels/demo_001_basic/',
			'../levels/demo_002_basic/'
		];
		
		public function Main()
		{			
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Key.init(stage);
			level = new Level();
			addChild(level);
			
			loadNextLevel();
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		} 
		
		public function loadNextLevel():void {
			if(levels[levelindex+1]) {
				levelindex++;
				level.unload();
				level.load(levels[levelindex]);
			}
		}
		
		public function loadPrevLevel():void {
			if(levels[levelindex-1]) {
				levelindex--;
				level.unload();
				level.load(levels[levelindex]);
			}
		}
		
		public function onKeyUp(evt:KeyboardEvent):void {
			if(evt.keyCode === Keyboard.RIGHT && evt.shiftKey) {
				loadNextLevel();
			}
			
			if(evt.keyCode === Keyboard.LEFT && evt.shiftKey) {
				loadPrevLevel();
			}		
		}
	}
}