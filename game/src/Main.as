package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import starling.core.Starling;
	
	[SWF(width = "1024", height = "768", frameRate = "60", backgroundColor = "#6B839D")]
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{
		private var mStarling : Starling;

		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			mStarling = new Starling(Game, stage);
			mStarling.antiAliasing = 1;
			
			mStarling.start();
		}		
	}
}