package machines 
{
	import Box2D.Common.Math.b2Vec2;
	import flash.ui.Keyboard;
	import starling.events.KeyboardEvent;
	
	import core.Entity;
	
	import components.Machine;
	import components.Animation;
	import components.Physics;
	
	public class Girl extends MachineCode
	{
		private static const STANDING : Number = 0;
		private static const RUNNING  : Number = 1;
		private static const SLIDING  : Number = 2;
		private static const JUMPING  : Number = 3;
		private static const FALLING  : Number = 4;
		private static const GOT_HIT  : Number = 5;
		private static const SHOOTING : Number = 6;
		
		private static const LEFT  : Number = 0;
		private static const RIGHT : Number = 1;
		
		private var state : Number =  STANDING;
		private var direction : Number = RIGHT;
		
		public var jump_stamina : Number = 1;
		public var jump_down : Boolean = false;
		
		public function Girl(machine : Machine, entity : Entity) 
		{
			super( machine, entity );
		}
		
		override public function setup(): void {
		}
		
		override public function cleanup(): void {
		}
		
		private function stateToAnimName( state : Number ): String {
			switch( state ) {
				case STANDING : return 'stand';
				case RUNNING  : return 'run';
				case SLIDING  : return 'slide';
				case JUMPING  : return 'jump';
				case FALLING  : return 'fall';
				case GOT_HIT  : return 'got_hit';
				case SHOOTING : return 'shooting';
			}
			return "";
		}
		
		override public function update( dt : Number ):void {
			var animator : Animation = entity.$(Animation) as Animation;
			var physics : Physics = entity.$(Physics) as Physics;
			var curVelocity : b2Vec2;
			
			physics.body.SetSleepingAllowed(false);
			
			curVelocity = physics.body.GetLinearVelocity();
			if ( KeyboardControls.wasKeyJustPressed( Keyboard.SPACE ) || KeyboardControls.wasKeyJustPressed( Keyboard.UP )  ) {
				jump_down = true;
				jump_stamina = 1.0;
				animator.playOnce(stateToAnimName(JUMPING), direction == LEFT, 14 );
			}
			
			if ( jump_down ) {
				physics.body.SetLinearVelocity( new b2Vec2( curVelocity.x, -jump_stamina + curVelocity.y));
				jump_stamina *= 0.92;
				if ( jump_stamina < 0.6 ) {
					jump_down = false;
				}
			}
			
			if ( KeyboardControls.wasKeyJustReleased( Keyboard.SPACE ) || KeyboardControls.wasKeyJustReleased( Keyboard.UP ) ) {
				if( curVelocity.y < 0 )
					physics.body.SetLinearVelocity( new b2Vec2( curVelocity.x, curVelocity.y * 0.5));
				jump_down = false;
			}
			
			curVelocity = physics.body.GetLinearVelocity();
			var animating_other : Boolean = ((Math.abs(curVelocity.y) > 0.8) || jump_down) && !physics.sensorActive('ground');
			
			if ( KeyboardControls.isKeyDown( Keyboard.RIGHT ) ) {
				if( !animating_other )
					animator.play(stateToAnimName(RUNNING) , false, 14 );
				direction = RIGHT;
				curVelocity = physics.body.GetLinearVelocity();
				physics.body.SetLinearVelocity( new b2Vec2( 4.0, curVelocity.y));
			} else if ( KeyboardControls.isKeyDown( Keyboard.LEFT ) ) {
				if( !animating_other )
					animator.play(stateToAnimName(RUNNING), true, 14 );
				direction = LEFT;
				curVelocity = physics.body.GetLinearVelocity();
				physics.body.SetLinearVelocity( new b2Vec2( -4.0, curVelocity.y));
			} else {
				physics.body.SetLinearVelocity( new b2Vec2( curVelocity.x * 0.9, curVelocity.y));
				if( !animating_other )
					animator.play(stateToAnimName(STANDING), direction == LEFT, 14 );
			}
			
			if ( animating_other ) {
				if ( curVelocity.y > 0 ) {
					animator.play(stateToAnimName(FALLING), direction == LEFT, 14 );
				} else {
					animator.play(stateToAnimName(JUMPING), direction == LEFT, 14 );
				}
			}
		}
	}

}