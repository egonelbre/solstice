package 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Egon Elbre
	 */
	public class Preloader extends MovieClip 
	{
		[Embed(source = "../data/textures/ui/loading.png")]
		public static const LoadingImage : Class;
		
		public var loadProgress : TextField;
		
		public function Preloader() 
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			var loadingScreen: DisplayObject = new LoadingImage();
			addChild(loadingScreen);
			
			loadProgress = new TextField();
			loadProgress.x = 556;
			loadProgress.y = 519;
			loadProgress.textColor = 0x614236;
			addChild(loadProgress);
		}
		
		private function ioError(e:IOErrorEvent):void 
		{
			trace(e.text);
		}
		
		private function progress(e:ProgressEvent):void 
		{
			var percent_loaded : Number = e.bytesLoaded * 100.0 / (17.0*1024.0*1024.0);
			loadProgress.text = percent_loaded.toFixed(0) + '%';
		}
		
		private function checkFrame(e:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
		}
		
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			startup();
			visible = false;
		}
		
		private function startup():void 
		{
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}