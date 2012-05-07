package  
{
	import flash.ui.Keyboard;
	
	import starling.display.Stage;
	import starling.events.KeyboardEvent;
	
	public class KeyboardControls 
	{
		protected static var _keyState:Array = new Array();     // The most recent information on key states
        protected static var _keyStateOld:Array = new Array();  // The state of the keys on the previous tick
        protected static var _justPressed:Array = new Array();  // An array of keys that were just pressed within the last tick.
        protected static var _justReleased:Array = new Array(); // An array of keys that were just released within the last tick.
		
		public static var stage : Stage = null;
		
		public static function initialize( stage: Stage ): void
		{
			cleanup();
			stage = stage;
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
		}
		
		public static function cleanup(): void
		{
			if (stage == null) return;
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			stage.removeEventListener( KeyboardEvent.KEY_UP, onKeyUp );
		}
		
		public static function onKeyDown( e: KeyboardEvent ): void
		{
			_keyState[e.keyCode] = true;
		}
		
		public static function onKeyUp( e: KeyboardEvent ): void
		{
			_keyState[e.keyCode] = false;
		}
		
		public static function update(): void {
			for (var cnt:int = 0; cnt < _keyState.length; cnt++)
            {
                if (_keyState[cnt] && !_keyStateOld[cnt])
                    _justPressed[cnt] = true;
                else
                    _justPressed[cnt] = false;
                
                if (!_keyState[cnt] && _keyStateOld[cnt])
                    _justReleased[cnt] = true;
                else
                    _justReleased[cnt] = false;
                
                _keyStateOld[cnt] = _keyState[cnt];
            }
		}
		
		public static function wasKeyJustPressed(keyCode:int):Boolean
        {
            return _justPressed[keyCode];
        }
        
        public static function wasKeyJustReleased(keyCode:int):Boolean
        {
            return _justReleased[keyCode];
        }
        
        public static function isKeyDown(keyCode:int):Boolean
        {
            return _keyState[keyCode];
        }
	}

}