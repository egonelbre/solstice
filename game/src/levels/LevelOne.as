package levels 
{
	import starling.events.Event;
	import starling.display.Image;
	import starling.text.TextField;
	import starling.display.Button;

	import core.*;
	import components.*;
	import machines.*;
	import systems.*;	
	
	public class LevelOne extends World
	{
		private var _scoreValue : Number = 0;
		private var _scoreElement : TextField;
		
		public function LevelOne() 
		{
			super();
		}
		
		override public function setupScene(e: Event): void
		{
			super.setupScene(e);
		}
		
		dynamic public function addElements(): void
		{
			_scoreElement = new TextField(150, 100, _scoreValue.toString() + '/25' );
			_scoreElement.fontSize = 40;
			_scoreElement.x = Constants.GameWidth - 180;
			_scoreElement.y = 20;
			_scoreElement.fontName = "Georgia";
			hud.addChild(_scoreElement);

			super.addElements();
		}
		
		private function updateScore(): void
		{
			var ca : Array = sys.em.$$(Collectable);
			for each (var c : Collectable in ca ) {
				var phys : Physics = c.owner.$(Physics) as Physics;
				if ( phys.sensorActive('acorn') ) {
					_scoreValue += 1;
					_scoreElement.text = _scoreValue.toString() + '/25';
					var en : Entity = c.owner;
					sys.em.removeEntity(en);
					en.parent.removeChild(c.owner, true);
				}
			}
		}
		
		override public function update(e: Event): void
		{
			super.update(e);
			updateScore();
		}		
	}
}
