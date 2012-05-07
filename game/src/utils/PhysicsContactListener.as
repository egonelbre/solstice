package utils 
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import components.Physics;
	
	public class PhysicsContactListener extends b2ContactListener 
	{
		
		override public function BeginContact(contact:b2Contact):void 
		{
			super.BeginContact(contact);
			var fixA : b2Fixture = contact.GetFixtureA();
			var fixB : b2Fixture = contact.GetFixtureB();
			if( fixA.IsSensor() ){
				var physA : Physics = fixA.GetUserData()[0];
				var idA : String = fixA.GetUserData()[1];
				physA.sensors[ idA ] += 1;
				//trace( 'SENSOR+: ', idA, physA.sensors[ idA ] );
			}
			if( fixB.IsSensor() ){
				var physB : Physics = fixB.GetUserData()[0];
				var idB : String = fixB.GetUserData()[1];
				physB.sensors[ idB ] += 1;
				//trace( 'SENSOR+: ', idB, physB.sensors[ idB ] );
			}
		}
		
		override public function EndContact(contact:b2Contact):void 
		{
			var fixA : b2Fixture = contact.GetFixtureA();
			var fixB : b2Fixture = contact.GetFixtureB();
			if( fixA.IsSensor() ){
				var physA : Physics = fixA.GetUserData()[0];
				var idA : String = fixA.GetUserData()[1];
				physA.sensors[ idA ] -= 1;
				//trace( 'SENSOR-: ', idA, physA.sensors[ idA ] );
			}
			if( fixB.IsSensor() ){
				var physB : Physics = fixB.GetUserData()[0];
				var idB : String = fixB.GetUserData()[1];
				physB.sensors[ idB ] -= 1;
				//trace( 'SENSOR-: ', idB, physB.sensors[ idB ] );
			}
			super.EndContact(contact);
		}
		
		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void 
		{
			super.PreSolve(contact, oldManifold);
		}
		
		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void 
		{
			super.PostSolve(contact, impulse);
		}
	}

}