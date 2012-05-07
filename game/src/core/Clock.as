package core 
{
	import flash.utils.getTimer;
	
	public class Clock 
	{
		protected var _running : Boolean = false;
		
		protected var _realTime : Number = 0;
		protected var _lastRealTime : Number = 0;
		
		protected var _systemTime : Number = 0;
		protected var _pauseTime : Number = 0;
		protected var _systemOffset : Number = 0;
		
		protected var _frameCount : Number = 0;
		protected var _frameStart : Number = 0;
		protected var _frameEnd : Number = 0;
		
		protected var _simTime : Number = 0;
		protected var _simOffset : Number = 0;
		
		protected var _getTimeF : Function = function() : Number {
			return getTimer() / 1000.0;
		};
		
		public function Clock( getTimeFunction : Function = null ) {
			if ( getTimeFunction != null )
				_getTimeF = getTimeFunction;
			_realTime = _getTimeF();
			_systemOffset = _realTime;
		}
		
		// accessors to properties
		public function get running() : Boolean { return _running };
		public function get system() : Number { Update(); return _systemTime; }
		public function get time(): Number { return _simTime; }
		public function get frame(): Number { return _frameCount; }
		public function get frameStart(): Number { return _frameStart; }
		public function get frameEnd(): Number { return _frameEnd; }
		
		public function Run(): void {
			if ( ! _running ) {
				Update();
				_simOffset += _systemTime - _pauseTime;
			}
			_running = true;
		}
		
		public function Stop(): void {
			if ( _running ) {
				Update();
				_pauseTime = _systemTime;
			}
			_running = false;
		}
		
		public function Update(): void {
			var elapsed: Number = 0;
			
			_lastRealTime = _realTime;
			_realTime = _getTimeF();
			
			elapsed = _realTime - _lastRealTime;
			_systemTime += elapsed;
		}
		
		public function BeginFrame(): void {
			_frameCount++;
			Update();
			if ( _running ) {
				_frameStart = _frameEnd;
				_frameEnd = _systemTime - _simOffset;
				_simTime  = _frameStart;
			}
		}
		
		public function AdvanceTo( newTime : Number ): void {
			if ( _running && ( newTime > _simTime ) )
				_simTime = newTime;
		}
		
		public function AdvanceToEnd(): void {
			if ( _running )
				_simTime = _frameEnd;
		}
		
	}

}