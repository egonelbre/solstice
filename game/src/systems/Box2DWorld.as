package systems 
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Common.Math.b2Vec3;
	import Box2D.Dynamics.b2World;
	import components.Physics;
	import core.Clock;
	import core.System;
	import core.Systems;
	import utils.PhysicsContactListener;
	/**
	 * ...
	 * @author Egon Elbre
	 */
	public class Box2DWorld extends System
	{
		protected var _gravity: b2Vec2;
		public var world: b2World;
		public var editing : Boolean = false;
		
		[Serialize]
		public var gravity : Number = 9.8;
		
		public function Box2DWorld(sys: Systems) 
		{
			super(sys);
			_gravity = new b2Vec2(0, 9.8);
			world = new b2World(_gravity, true);
			world.SetContactListener( new PhysicsContactListener() );
		}
		
		override public function processOneGameTick( clock : Clock ): void {
			if ( editing )
				world.Step(0, 8, 3);
			else
				world.Step(Constants.TimeStep, 8, 3);
			for each (var pc:Physics in sys.em.$$( Physics )) {
				var pos:b2Vec2 = pc.getPosition();
				
				pc.owner.x = pos.x;
				pc.owner.y = pos.y;
				pc.owner.rotation = pc.getAngle();
			}
		}
	}
}