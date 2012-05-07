package systems 
{
	import Box2D.Common.Math.b2Vec2;
	
	import components.CameraTrack;
	import components.Layer;
	import components.Physics;
	
	import core.Clock;
	import core.SceneObject;
	import core.System;
	import core.Systems;
	
	import flash.ui.Keyboard;
	import starling.events.KeyboardEvent;

	public class Camera extends System
	{	
		public var manualCamera:Boolean = false;
		
		public function Camera( sys: Systems ) 
		{
			super(sys);
		}
		
		override public function processOneGameTick( clock : Clock ): void {
			var ca : Array = sys.em.$$( CameraTrack );
			var coords : b2Vec2 = calculateCamera(ca); 
			var speed : b2Vec2 = calculateSpeed(ca); 
			var newx : Number = -coords.x + Constants.CenterX - speed.x / 3;
			var newy : Number = -coords.y + Constants.CenterY - speed.y / 100;
			var smoothing : Number = 0.05;
			if (manualCamera) {
				if (KeyboardControls.isKeyDown( Keyboard.A )) {
					//sys.root.x = sys.root.x + 10;
					sys.root.x = sys.root.x + 500 * Constants.TimeStep;
				}
				if (KeyboardControls.isKeyDown( Keyboard.W )) {
					sys.root.y = sys.root.y + 500 * Constants.TimeStep;
				}
				if (KeyboardControls.isKeyDown( Keyboard.D )) {
					sys.root.x = sys.root.x - 500 * Constants.TimeStep;
				}
				if (KeyboardControls.isKeyDown( Keyboard.S )) {
					sys.root.y = sys.root.y - 500 * Constants.TimeStep;
				}
			}
			else {
				sys.root.x = sys.root.x * ( 1.0 - smoothing ) + newx * smoothing;
				sys.root.y = sys.root.y * ( 1.0 - smoothing ) + newy * smoothing;
				
				smoothing = 0.01;
				var speedl : Number = Math.min((Math.abs(speed.x) / 600), 1);
				var newscale : Number = 1.0 - Math.log( speedl + 1 ) / 4;
				var smoothscale : Number = sys.root.scaleX * ( 1.0 - smoothing ) + newscale * smoothing;
				sys.root.scaleX = smoothscale;
				sys.root.scaleY = smoothscale;
			}
			
			updateLayers();
		}
		
		private function updateLayers(): void {
			var ca : Array = sys.em.$$(Layer);
			for each( var lay : Layer in ca ) {
				if ( lay.fixed ) {
					lay.owner.x = -sys.root.x;
					lay.owner.y = -sys.root.y;
				} else if ( lay.z != 0 ) {
					lay.owner.x = sys.root.x * lay.z * 0.01;
					lay.owner.y = sys.root.y * lay.z * 0.01;
				}
			}
		}
		
		private function calculateCamera ( ca : Array ) : b2Vec2 {
			var x : int = 0;
			var y : int = 0;
			
			var counter : int = 0;
			for each ( var c : CameraTrack in ca ) {
				x += c.owner.x;
				y += c.owner.y;
				counter++;
			}
			
			if (counter > 0) {
				x /= counter;
				y /= counter;
			}
			
			return new b2Vec2(x, y);
		}
		
		private function calculateSpeed ( ca : Array ) : b2Vec2 {
			var x : int = 0;
			var y : int = 0;
			
			var counter : int = 0;
			for each ( var c : CameraTrack in ca ) {
				var p : Physics = c.owner.$(Physics) as Physics;
				if ( p == null ) continue;
				var vel : b2Vec2 = p.body.GetLinearVelocity();
				x += vel.x / Constants.SimulationScale;
				y += vel.y / Constants.SimulationScale;
				counter++;
			}
			
			if (counter > 0) {
				x /= counter;
				y /= counter;
			}
			
			return new b2Vec2(x, y);
		}
		
		public function moveCameraInEditor () :void{
			
		}
	}

}