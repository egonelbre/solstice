package core 
{
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.display.Button;
	
	public class Scene extends Sprite
	{
		public static const CLOSING : String = "closing";
		private var mBackButton : Button;
		
		public function Scene() 
		{
			addEventListener( Event.ADDED_TO_STAGE, onSetupScene );
		}
		
		public function onSetupScene(e :Event): void
		{
			setupScene( e );
		}
		
		public function setupScene(e: Event): void
		{
			mBackButton = new Button( ResourceManager.getTexture( "textures/ui/buttons/back.png" ));
			//mBackButton.x = Constants.GameWidth - mBackButton.width - 5;
			mBackButton.x = 5;
			mBackButton.y = Constants.GameHeight - mBackButton.height + 1;
			mBackButton.addEventListener( Event.TRIGGERED, onBackButtonTriggered );
			addChild( mBackButton );
			
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		public function onEnterFrame(e: Event): void
		{
			update(e);
		}
		
		public function update(e: Event): void
		{
			
		}
		
		private function onBackButtonTriggered( event: starling.events.Event ): void
		{
			mBackButton.removeEventListener( Event.TRIGGERED, onBackButtonTriggered );
			dispatchEvent( new Event( CLOSING, true ) );
		}
		
		override public function dispose(): void {
			removeEventListener( EnterFrameEvent.ENTER_FRAME, onEnterFrame );
			super.dispose();
		}
	}

}